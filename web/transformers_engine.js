// web/transformers_engine.js

(function () {
    let transformers = null;
    let pipeline = null;
    let currentModel = null;
    let env = null;
    let requestedSource = 'huggingface';

    window.transformersEngine = {
        async initialize() {
            if (!transformers) {
                console.log("[JS] Transformers Engine v1.12 Initializing...");
                const module = await import('https://cdn.jsdelivr.net/npm/@xenova/transformers@2.17.2');
                transformers = module;
                env = module.env;

                // Configure environment
                env.allowLocalModels = false;
                env.useBrowserCache = true;

                this.setSource(requestedSource);
                console.log("[JS] Environment initialized. remoteHost:", env.remoteHost);
            }
        },

        setSource(source) {
            requestedSource = source;
            if (!env) return;
            console.log(`[JS] Applying download source: ${source}`);
            if (source === 'hf-mirror') {
                env.remoteHost = 'https://hf-mirror.com';
            } else {
                env.remoteHost = 'https://huggingface.co';
            }
        },

        async loadModel(modelName, taskType, onProgress) {
            console.log(`[JS] loadModel: ${modelName}, task: ${taskType}`);
            await this.initialize();

            try {
                if (currentModel !== modelName || !pipeline) {
                    const progressCallback = (typeof onProgress === 'function') ? onProgress : null;

                    const options = {
                        progress_callback: (p) => {
                            if (progressCallback) {
                                if (p.status === 'progress') {
                                    // p.progress is 0-100 from Transformers.js
                                    // BLoC expects 0-1 range for progress indicator.
                                    let val = p.progress;
                                    if (typeof val !== 'number' || isNaN(val)) {
                                        val = 0;
                                    }
                                    progressCallback(val / 100);
                                } else if (p.status === 'done') {
                                    // Ensure it reaches 100% (1.0) for each file
                                    progressCallback(1.0);
                                }
                            }
                        },
                        // Transformers.js 默认搜索顺序:
                        // 1. 根目录 model_quantized.onnx
                        // 2. onnx/model_quantized.onnx
                        // 3. 根目录 model.onnx
                        // 4. onnx/model.onnx (这是我们当前的目标位置)
                        quantized: false
                    };

                    // For punctuation models (token-classification), we must disable aggregation
                    // to get the label for every single character.
                    if (taskType === 'token-classification') {
                        options.aggregation_strategy = 'none';
                    }

                    console.log("[JS] Creating pipeline with standard structure...");
                    // 不再手动传 subfolder，让 Transformers.js 按默认约定在 onnx/ 下找模型
                    pipeline = await transformers.pipeline(taskType, modelName, options);
                    currentModel = modelName;
                    console.log("[JS] Model loaded successfully!");
                }
            } catch (e) {
                console.error("[JS] Load model failed:", e);
                throw e;
            }
        },

        async runInference(text, modelName, taskType, onProgress) {
            await this.loadModel(modelName, taskType, onProgress);

            try {
                const output = await pipeline(text);
                console.log("[JS] Inference output received (length):", output.length);

                // Return raw output structure as JSON string
                // Dart side will handle parsing and reconstruction
                return JSON.stringify(output);
            } catch (e) {
                console.error("[JS] Inference failed:", e);
                throw e;
            }
        },

        async checkCache(modelName) {
            if (!window.caches) return false;
            try {
                const cacheName = 'transformers-cache';
                const cache = await caches.open(cacheName);
                const keys = await cache.keys();
                const cachedFiles = keys.map(request => request.url);

                // 检查是否包含核心文件 (此时可能在根目录也可能在 onnx 目录，取决于缓存时的行为)
                const hasWeights = cachedFiles.some(url => url.includes(modelName) && url.includes('model.onnx'));
                const hasConfig = cachedFiles.some(url => url.includes(modelName) && url.includes('config.json'));

                return hasWeights && hasConfig;
            } catch (e) {
                return false;
            }
        },

        async exportModel(modelName) {
            const files = [
                'config.json',
                'tokenizer.json',
                'tokenizer_config.json',
                'special_tokens_map.json',
                'vocab.txt',
                'onnx/model.onnx' // 导出时使用新结构路径
            ];

            await this.initialize();
            const zip = new JSZip();
            const modelFolder = zip.folder(modelName.split('/').pop());

            let baseUrl = env.remoteHost + '/' + modelName + '/resolve/main/';

            console.log(`[JS] Exporting from: ${baseUrl}`);

            for (const file of files) {
                try {
                    const response = await fetch(baseUrl + file);
                    if (response.ok) {
                        const blob = await response.blob();
                        const fileName = file.includes('/') ? file.split('/').pop() : file;
                        modelFolder.file(fileName, blob);
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
