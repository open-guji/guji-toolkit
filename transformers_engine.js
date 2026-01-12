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
            if (source === 'modelscope' || source === 'hf-mirror') {
                // We use modelscope now as it is more stable than hf-mirror
                env.remoteHost = 'https://modelscope.cn/api/v1/models/';
                env.remoteFilenamePattern = '{model}/repo/resolve/master/{file}';
            } else {
                env.remoteHost = 'https://huggingface.co';
                env.remoteFilenamePattern = '{model}/resolve/{revision}/{file}';
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
                console.log("[JS] Inference output received:", output);

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

        async deleteCache(modelName) {
            console.log(`[JS] deleteCache called for: ${modelName}`);
            if (!window.caches) return;
            try {
                const cacheName = 'transformers-cache';
                const cache = await caches.open(cacheName);
                const keys = await cache.keys();

                // 删除所有包含 modelName 的请求
                for (const request of keys) {
                    if (request.url.includes(modelName)) {
                        console.log(`[JS] Deleting from cache: ${request.url}`);
                        await cache.delete(request);
                    }
                }
                console.log(`[JS] Cache cleared for model: ${modelName}`);
            } catch (e) {
                console.error("[JS] Delete cache failed:", e);
                throw e;
            }
        }
    };
})();
