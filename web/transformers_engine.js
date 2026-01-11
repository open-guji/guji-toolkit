// web/transformers_engine.js

(function () {
    let transformers = null;
    let pipeline = null;
    let currentModel = null;
    let env = null;
    let requestedSource = 'hf-mirror';

    window.transformersEngine = {
        async initialize() {
            console.log("[JS] initialize() entry. transformers ready?", !!transformers);
            if (!transformers) {
                console.log("[JS] Transformers Engine v1.4 Initializing...");
                const module = await import('https://cdn.jsdelivr.net/npm/@xenova/transformers@2.17.2');
                transformers = module;
                env = module.env;

                // Configure environment based on user's best practices
                env.allowLocalModels = false; // Only remote/cache
                env.useBrowserCache = true;   // Enable browser caching

                // Set custom cache location if needed, but default is fine
                // env.cacheDir = 'transformers-cache'; 

                // Apply the requested source during initialization
                console.log("[JS] Applying initial source inside initialize():", requestedSource);
                this.setSource(requestedSource);
                console.log("[JS] Environment initialized. remoteHost is now:", env.remoteHost);
            }
        },

        setSource(source) {
            console.log(`[JS] setSource called with: ${source}`);
            requestedSource = source;
            if (!env) {
                console.log(`[JS] env not ready. Source [${source}] queued.`);
                return;
            }

            console.log(`[JS] Applying remoteHost for source: ${source}`);
            if (source === 'hf-mirror') {
                env.remoteHost = 'https://hf-mirror.com';
            } else {
                env.remoteHost = 'https://huggingface.co';
            }
            console.log("[JS] Current env.remoteHost:", env.remoteHost);
        },

        async loadModel(modelName, taskType, subfolder, onProgress) {
            console.log(`[JS] loadModel entry: ${modelName}, task: ${taskType}, subfolder: ${subfolder}`);
            await this.initialize();
            try {
                if (currentModel !== modelName || !pipeline) {
                    const options = {
                        progress_callback: (p) => {
                            if (p.status === 'progress' && onProgress) {
                                onProgress(p.progress);
                            }
                        }
                    };
                    if (subfolder) options.subfolder = subfolder;

                    console.log("[JS] Creating pipeline with options:", JSON.stringify(options));
                    console.log("[JS] Using remoteHost:", env.remoteHost);

                    pipeline = await transformers.pipeline(taskType, modelName, options);
                    currentModel = modelName;
                    console.log("[JS] Model loaded and cached successfully!");
                }
            } catch (e) {
                console.error("[JS] Load model failed:", e);
                throw e;
            }
        },

        async runInference(text, modelName, taskType, subfolder, onProgress) {
            console.log(`[JS] runInference entry: ${modelName}, task: ${taskType}`);
            await this.loadModel(modelName, taskType, subfolder, onProgress);

            try {
                const output = await pipeline(text);
                console.log("[JS] Inference output received:", output);

                if (taskType === 'token-classification') {
                    // Reconstruct from labels for punctuation
                    if (output.length > 0 && output[0].entity) {
                        return this._reconstructFromLabels(text, output);
                    }
                    return output.map(x => x.word).join('') || text;
                } else if (taskType === 'fill-mask') {
                    // For Fill-Mask, return the top result or pretty string
                    if (Array.isArray(output) && output.length > 0) {
                        return output[0].sequence || JSON.stringify(output[0]);
                    }
                    return JSON.stringify(output);
                }

                return typeof output === 'string' ? output : JSON.stringify(output);
            } catch (e) {
                console.error("[JS] Inference failed:", e);
                throw e;
            }
        },

        _reconstructFromLabels(text, output) {
            // Simplified reconstruction: join the words from tokens
            return output.map(x => x.word).join('');
        },

        async checkCache(modelName, subfolder) {
            if (!window.caches) return false;
            try {
                const cacheName = 'transformers-cache';
                const cache = await caches.open(cacheName);
                const keys = await cache.keys();

                const cachedFiles = keys.map(request => request.url);
                const searchString = subfolder ? `${modelName}/${subfolder}` : modelName;

                const hasWeights = cachedFiles.some(url => url.includes(searchString) && (url.includes('.onnx') || url.includes('.safetensors') || url.includes('.bin')));
                const hasConfig = cachedFiles.some(url => url.includes(searchString) && url.includes('config.json'));

                return hasWeights && hasConfig;
            } catch (e) {
                return false;
            }
        },

        async exportModel(modelName, subfolder) {
            const files = [
                'config.json',
                'tokenizer.json',
                'tokenizer_config.json',
                'special_tokens_map.json',
                'vocab.txt',
                'model.onnx'
            ];

            await this.initialize();
            const zip = new JSZip();
            const modelFolder = zip.folder(modelName.split('/').pop());

            let baseUrl = env.remoteHost + '/' + modelName + '/resolve/main/';
            if (subfolder) baseUrl += subfolder + '/';

            console.log(`[JS] Exporting from: ${baseUrl}`);

            for (const file of files) {
                try {
                    const response = await fetch(baseUrl + file);
                    if (response.ok) {
                        const blob = await response.blob();
                        modelFolder.file(file, blob);
                    }
                } catch (e) {
                    console.warn(`[JS] Failed to fetch ${file} for export:`, e);
                }
            }

            const content = await zip.generateAsync({ type: "blob" });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(content);
            link.download = `${modelName.split('/').pop()}.zip`;
            link.click();
        }
    };
})();
