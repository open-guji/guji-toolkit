// web/transformers_engine.js

(function () {
    let transformers = null;
    let punctuationPipeline = null;
    let currentModel = null;
    let env = null;

    window.transformersEngine = {
        async initialize() {
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

                // TODO: 实现精准还原逻辑
                // 这里暂时简单返回 text 以跑通流程
                return text;
            } catch (e) {
                console.error("Punctuation failed:", e);
                throw e;
            }
        }
    };
})();
