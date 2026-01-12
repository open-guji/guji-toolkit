from huggingface_hub import HfApi, CommitOperationCopy, CommitOperationDelete
import os

api = HfApi()
# 指定需要处理的仓库
repo_ids = ["sheldonlidev/guwen-punc", "sheldonlidev/sikuBERT", "sheldonlidev/classical-chinese-punctuation-guwen-biaodian"]

for repo_id in repo_ids:
    print(f"Processing repository: {repo_id}")
    try:
        # 获取当前所有文件列表
        files = api.list_repo_files(repo_id=repo_id)
        
        operations = []
        
        # 将 model.onnx 从根目录移动到 onnx/ 子文件夹
        if "model.onnx" in files:
            operations.append(CommitOperationCopy(src_path_in_repo="model.onnx", path_in_repo="onnx/model.onnx"))
            operations.append(CommitOperationDelete(path_in_repo="model.onnx"))
            print("  Queued move: model.onnx -> onnx/model.onnx")
        
        # 确保其他配置文件在根目录（如果它们不小心跑到了 onnx/ 里，就移出来）
        config_files = ["config.json", "tokenizer_config.json", "tokenizer.json", "special_tokens_map.json", "vocab.txt"]
        for f in files:
            if f.startswith("onnx/") and os.path.basename(f) in config_files:
                dest = os.path.basename(f)
                operations.append(CommitOperationCopy(src_path_in_repo=f, path_in_repo=dest))
                operations.append(CommitOperationDelete(path_in_repo=f))
                print(f"  Queued move: {f} -> {dest}")

        if not operations:
            print(f"  No changes needed for {repo_id}")
            continue
            
        # 提交变更
        api.create_commit(
            repo_id=repo_id,
            operations=operations,
            commit_message="Move model.onnx to onnx/ folder for Transformers.js compatibility"
        )
        print(f"  Successfully updated {repo_id}")
    except Exception as e:
        print(f"  Error processing {repo_id}: {e}")