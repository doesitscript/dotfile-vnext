#!/usr/bin/env python3
"""Download HuggingFace model weights using the Python API."""
import sys
from pathlib import Path
from huggingface_hub import hf_hub_download

def main():
    if len(sys.argv) < 4:
        print("Usage: download_hf_model.py <repo_id> <pattern> <local_dir>", file=sys.stderr)
        sys.exit(1)
    
    repo_id = sys.argv[1]
    pattern = sys.argv[2]
    local_dir = Path(sys.argv[3])
    
    print(f"Downloading {repo_id} (pattern: {pattern}) to {local_dir}")
    
    try:
        from huggingface_hub import snapshot_download
        snapshot_download(
            repo_id=repo_id,
            allow_patterns=pattern,
            local_dir=str(local_dir),
            local_dir_use_symlinks=False,
            resume_download=True
        )
        print(f"Download complete: {repo_id}")
    except Exception as e:
        print(f"Download failed: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
