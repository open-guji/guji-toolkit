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

        async loadModel(modelName, onProgress) {
            await this.initialize();
            try {
                if (currentModel !== modelName || !punctuationPipeline) {
                    punctuationPipeline = await transformers.pipeline('token-classification', modelName, {
                        progress_callback: (p) => {
                            if (p.status === 'progress' && onProgress) {
                                onProgress(p.progress);
                            }
                        }
                    });
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

                // TODO: 实现更精准的标点还原逻辑
                return text;
            } catch (e) {
                console.error("Punctuation failed:", e);
                throw e;
            }
        },

        async checkCache(modelName) {
            if (!window.caches) return false;
            try {
                const cache = await caches.open('transformers-cache');
                const keys = await cache.keys();
                // 只要缓存中存在该模型的任何条目即认为已缓存
                return keys.some(request => request.url.includes(modelName));
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

