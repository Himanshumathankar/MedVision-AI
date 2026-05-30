# RunPod Training Guide

This guide shows how to run training on RunPod GPU and bring artifacts back.

## Recommended GPU
- Best value: RTX 3090/4090 (24 GB) or A10 24 GB.
- Fastest: A100 40/80 GB.

This workload uses VGG19 + DenseNet121 for feature extraction (GPU helps) and SVM training (CPU-heavy but fast once features are computed).

## 1) Prepare the repo
- Make sure dataset and artifacts are not in Git (see .gitignore).
- Keep your Firebase service account JSON out of Git.

## 2) Upload code to RunPod
Option A (git):
- Push your repo to GitHub.
- On RunPod, `git clone` your repo.

Option B (rsync from local):
```
rsync -av --exclude-from=.gitignore /path/to/MedVision-AI/ user@runpod:/workspace/MedVision-AI/
```

## 3) Upload datasets
You have two dataset roots:
- `dataset/Original Dataset`
- `dataset/Augmented Dataset`

Upload both to the RunPod instance, e.g.:
```
rsync -av "C:\\Users\\himan\\Desktop\\New folder\\MedVision-AI\\dataset\\Original Dataset" user@runpod:/workspace/datasets/original
rsync -av "C:\\Users\\himan\\Desktop\\New folder\\MedVision-AI\\dataset\\Augmented Dataset" user@runpod:/workspace/datasets/augmented
```

## 4) Install dependencies
On RunPod (inside repo):
```
cd /workspace/MedVision-AI/backend
python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## 5) Run training on both datasets
Use a short Python command to pass multiple dataset roots:
```
cd /workspace/MedVision-AI/backend
source .venv/bin/activate
python - <<'PY'
from services.training import Trainer
trainer = Trainer()
trainer.train([
    "/workspace/datasets/original",
    "/workspace/datasets/augmented",
])
print("Training complete")
PY
```

Artifacts are saved to:
```
/backend/artifacts/scaler.npy
/backend/artifacts/pca.npy
/backend/artifacts/svm.npy
```

## 6) Download artifacts back to your PC
From your PC:
```
rsync -av user@runpod:/workspace/MedVision-AI/backend/artifacts/ "C:\\Users\\himan\\Desktop\\New folder\\MedVision-AI\\backend\\artifacts\\"
```

## 7) Run backend locally
```
cd backend
.venv\Scripts\activate
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## Notes
- If you use a custom RunPod image, make sure CUDA drivers match your TF version.
- If training runs out of memory, lower dataset size or run only one dataset at a time.
