import io
from typing import Tuple

import torch
import torch.nn as nn
import torch.nn.functional as F
from torchvision import models, transforms
from PIL import Image

from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

# ---------------------------------------------------
# 1. CONFIG
# ---------------------------------------------------

MODEL_PATH = "best_nail_classifier_model.pth"

# Your 5 trained classes
class_names = [
    "Acral Lentiginous Melanoma",
    "Clubbing",
    "Healthy Nail",
    "Onychogryphosis",
    "Pitting",
]

num_classes = len(class_names)

# 🔧 Unknown-detection tuning (RELAXED so Healthy doesn't become Unknown)
THRESHOLD = 0.30     # minimum confidence to accept a class (was 0.80)
MARGIN = 0.12        # top1 - top2 must be at least this (was 0.15)
TEMPERATURE = 1.0    # 1.0 = no extra smoothing (was 2.0)

# same transform as training / testing
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])

# ---------------------------------------------------
# 2. MODEL LOADING
# ---------------------------------------------------

def load_model() -> nn.Module:
    """
    Build EfficientNet-B3 with the correct classifier head
    and load trained weights.
    """
    model = models.efficientnet_b3(weights=None)
    in_features = model.classifier[1].in_features
    model.classifier[1] = nn.Linear(in_features, num_classes)

    state_dict = torch.load(MODEL_PATH, map_location="cpu")
    model.load_state_dict(state_dict)
    model.eval()
    return model


model = load_model()

# ---------------------------------------------------
# 3. FASTAPI APP + CORS
# ---------------------------------------------------

app = FastAPI(title="Nail Disease Classifier API")

# Allow emulator / frontend to call this
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # you can restrict later
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------
# 4. PREDICTION LOGIC WITH UNKNOWN HANDLING
# ---------------------------------------------------

def predict_image(pil_img: Image.Image) -> Tuple[str, float]:
    """
    Returns (label, confidence) where label can be one of the 5 classes
    or 'Unknown / Not in trained classes'.

    Uses:
      - optional temperature scaling
      - confidence threshold
      - top1 vs top2 margin
    """
    img_t = transform(pil_img).unsqueeze(0)  # shape: [1, 3, 224, 224]

    with torch.no_grad():
        outputs = model(img_t)

        # Temperature scaling (here TEMPERATURE = 1.0 → no effect)
        scaled_logits = outputs / TEMPERATURE
        probs = F.softmax(scaled_logits, dim=1)

        # get top-2 classes
        top2_conf, top2_idx = torch.topk(probs, 2, dim=1)
        conf1 = float(top2_conf[0, 0].item())
        conf2 = float(top2_conf[0, 1].item())
        idx1 = int(top2_idx[0, 0].item())

    # ---------- UNKNOWN DECISION ----------
    # Unknown if:
    # 1) overall confidence very low, OR
    # 2) top1 and top2 are too close → ambiguous
    is_low_conf = conf1 < THRESHOLD
    is_ambiguous = (conf1 - conf2) < MARGIN

    if is_low_conf or is_ambiguous:
        return "Unknown / Not in trained classes", conf1

    # otherwise, accept the best class
    return class_names[idx1], conf1


# ---------------------------------------------------
# 5. API ENDPOINT
# ---------------------------------------------------

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Expects a multipart/form-data upload with field name 'file'.
    Returns JSON: { "label": <str>, "confidence": <float> }
    """
    try:
        contents = await file.read()
        img = Image.open(io.BytesIO(contents)).convert("RGB")
    except Exception:
        return JSONResponse(
            status_code=400,
            content={"error": "Could not read image file."},
        )

    label, confidence = predict_image(img)

    return JSONResponse(
        content={
            "label": label,
            "confidence": confidence,
        }
    )
