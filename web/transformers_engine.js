// web/transformers_engine.js

(function () {
    let transformers = null;
    let punctuationPipeline = null;
    let currentModel = null;
    let env = null;

    window.transformersEngine = {
        async initialize() {
            console.log("Transformers Engine v1.2 Initializing (with loadModel & Export)...");
            if (!transformers) {

                const module = await import('https://cdn.jsdelivr.net/npm/@xenova/transformers@2.17.2');
                transformers = module;
                env = module.env;
                env.allowLocalModels = true;
                env.remoteHost = 'https://hf-mirror.com'; // 默认镜像
            }
        },

        setSource(source) {
            if (!env) return;
            if (source === 'hf-mirror') {
                env.remoteHost = 'https://hf-mirror.com';
            } else {
                env.remoteHost = 'https://huggingface.co';
            }
        },

        async loadModel(modelName, subfolder, onProgress) {
            await this.initialize();
            try {
                if (currentModel !== modelName || !punctuationPipeline) {
                    const options = {
                        progress_callback: (p) => {
                            if (p.status === 'progress' && onProgress) {
                                onProgress(p.progress);
                            }
                        }
                    };
                    if (subfolder) options.subfolder = subfolder;

                    punctuationPipeline = await transformers.pipeline('token-classification', modelName, options);
                    currentModel = modelName;
                }
            } catch (e) {
                console.error("Load model failed:", e);
                throw e;
            }
        },


        async runPunctuation(text, modelName, onProgress) {
            await this.initialize();

            try {
                if (currentModel !== modelName || !punctuationPipeline) {
                    console.log(`Loading model: ${modelName}`);
                    punctuationPipeline = await transformers.pipeline('token-classification', modelName, {
                        progress_callback: (p) => {
                            if (p.status === 'progress' && onProgress) {
                                onProgress(p.progress);
                            }
                        }
                    });
                    currentModel = modelName;
                }

                const output = await punctuationPipeline(text);

                // Transformers.js for token-classification returns an array of tokens with their labels
                // We need to reconstruct the text with punctuation
                let punctuatedText = '';
                let lastIndex = 0;

                // Simple reconstruction: tokens usually map back to the original text
                // For Classical Chinese, tokens are often single characters
                for (let i = 0; i < output.length; i++) {
                    const item = output[i];
                    punctuatedText += item.word;

                    // Add punctuation based on label (e.g., 'LABEL_1' might be CC, 'LABEL_2' might be PU)
                    // The specific mapping depends on the model.
                    // For now, we return the raw output if it's already punctuated or handle it simply.
                    // Note: many classical Chinese punctuation models actually replace/insert marks.
                }

                // Temporary: if output is just classification, we need a better restorer.
                // But many models like raynardj's return the simplified result or we need to join them.
                if (output.length > 0 && output[0].entity) {
                    // If it's NER style, we need to join tokens and labels
                    return this._reconstructFromLabels(text, output);
                }

                return output.map(x => x.word).join('') || text;
            } catch (e) {
                console.error("Punctuation failed:", e);
                throw e;
            }
        },

        _reconstructFromLabels(text, output) {
            // Placeholder for a more complex reconstruction logic
            // In many cases, the output already contains the punctuated version in 'word'
            // or we need to map labels to characters like ， 。 etc.
            return output.map(x => x.word).join('');
        },

        async checkCache(modelName) {
            if (!window.caches) return false;
            try {
                const cacheName = 'transformers-cache';
                const cache = await caches.open(cacheName);
                const keys = await cache.keys();

                // A model is considered cached if we have the weight file and config
                const cachedFiles = keys.map(request => request.url);
                const hasWeights = cachedFiles.some(url => url.includes(modelName) && (url.includes('.onnx') || url.includes('.safetensors') || url.includes('.bin')));
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
                'model.safetensors'
            ];

            // 确保环境已初始化以获取 remoteHost
            await this.initialize();
            const baseUrl = env.remoteHost + '/' + modelName + '/resolve/main/';

            for (const file of files) {
                const url = baseUrl + file;
                const link = document.createElement('a');
                link.href = url;
                link.download = file;
                link.target = '_blank';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                await new Promise(r => setTimeout(r, 500));
            }
        }
    };
})();

