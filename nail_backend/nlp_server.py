# nlp_server.py
# FastAPI backend for KuBot NLP intent classification
# Uses the SAME preprocessing and TF-IDF setup as your Colab training.

import re
from typing import Any, Optional, Dict

import joblib
from fastapi import FastAPI
from pydantic import BaseModel

# ============================================================
# 1. PREPROCESS (MUST MATCH YOUR TRAINING EXACTLY)
# ============================================================

def preprocess(text: str) -> str:
    """
    EXACT preprocessing used during training:

    text = str(text)
    text = text.lower()
    text = re.sub(r"\\s+", " ", text).strip()
    """
    text = str(text)
    text = text.lower()
    text = re.sub(r"\s+", " ", text).strip()
    return text


# ============================================================
# 2. LOAD TF-IDF & SVM MODEL
# ============================================================

VECTORIZER_PATH = "intent_tfidf_vectorizer.joblib"
MODEL_PATH = "intent_model_linear_svc.joblib"

vectorizer = joblib.load(VECTORIZER_PATH)
intent_model = joblib.load(MODEL_PATH)

print("✅ Intent model (LinearSVC) + TF-IDF vectorizer loaded.")


# ============================================================
# 3. FASTAPI APP + REQUEST/RESPONSE SCHEMAS
# ============================================================

app = FastAPI(title="KuCognition KuBot NLP API")

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    intent: str
    reply: str


# ============================================================
# 4. BASIC SYMPTOM / LABEL → CONDITION MAPPING (not diagnosis)
# ============================================================

def match_condition_by_keywords(message: str) -> Optional[str]:
    """
    Simple pattern-matching helper.
    Matches BOTH:
      • symptom-style descriptions
      • direct label names like "clubbing", "pitting", etc.
    Does NOT diagnose — only suggests which condition info to show.
    """
    text = message.lower()

    patterns = {
        "Acral Lentiginous Melanoma": [
            # label forms
            "acral lentiginous melanoma",
            "alm melanoma",
            "alm",
            # symptom forms
            "dark line", "dark streak", "black line", "brown line",
            "vertical line", "vertical band", "dark band",
            "streak under my nail", "black streak", "brown streak",
        ],
        "Clubbing": [
            # label forms
            "clubbing",
            "clubbed nail",
            "clubbed nails",
            "clubbed fingers",
            # symptom forms
            "bulbous fingertip", "rounded fingertips", "curved nails",
            "swollen fingertips", "drumstick fingers",
        ],
        "Onychogryphosis": [
            # label forms
            "onychogryphosis",
            "onycho gryphosis",
            # symptom forms
            "ram horn nail", "ramshorn", "very thick nail",
            "claw like nail", "curved thick nail", "overgrown nail",
        ],
        "Pitting": [
            # label forms
            "pitting",
            "pitted nail",
            "pitted nails",
            # symptom forms
            "tiny dents", "small pits", "pinpoint holes",
            "dot like holes", "rough nail surface",
        ],
        "Healthy Nail": [
            # label forms
            "healthy nail",
            "normal nail",
            "normal nails",
            # symptom forms
            "looks normal", "looks healthy", "smooth nail",
            "no discoloration", "even color", "no lines", "no ridges",
        ],
    }

    for condition, keywords in patterns.items():
        for kw in keywords:
            if kw in text:
                return condition

    return None


def explain_condition(condition: str) -> str:
    """
    Central place for final text shown when a condition label is recognised.
    Used by BOTH:
      • nail_condition_info
      • scan_result_explanation
    """
    if condition == "Acral Lentiginous Melanoma":
        return (
            "The changes you're describing match features sometimes seen in **acral "
            "lentiginous melanoma**, such as dark streaks under the nail. Other benign "
            "causes exist, but melanoma is serious.\n\n"
            "Medical guidelines recommend that any new or changing dark streak be evaluated "
            "by a dermatologist."
        )
    elif condition == "Clubbing":
        return (
            "Clubbing causes rounded, bulbous fingertips and curved nails. It is sometimes "
            "associated with heart or lung conditions.\n\n"
            "If you're noticing this on your nails, it’s a good idea to mention it during "
            "a check-up."
        )
    elif condition == "Onychogryphosis":
        return (
            "Onychogryphosis often appears as a thick, curved, ram’s-horn-like nail. It can "
            "result from long-term pressure or underlying nail growth issues.\n\n"
            "A podiatrist or dermatologist can help manage this safely."
        )
    elif condition == "Pitting":
        return (
            "Pitting looks like many small dents in the nail surface. It is commonly associated "
            "with psoriasis or autoimmune skin conditions.\n\n"
            "If persistent, it’s worth showing to a professional."
        )
    elif condition == "Healthy Nail":
        return (
            "Your description suggests your nail may look normal — smooth surface, even color, "
            "and no unusual marks.\n\n"
            "Healthy nails are a good sign, but regular health monitoring is still important."
        )

    # Fallback if mapping fails
    return (
        "You’re asking about nail features. You can describe what you see — dark streaks, "
        "thickening, dents, color changes — and I’ll explain which conditions these are "
        "**commonly associated** with. This is not a diagnosis."
    )


# ============================================================
# 5. INTENT → REPLY ENGINE (KuBot’s personality)
# ============================================================

def build_reply(user_message: str, intent: str) -> str:
    msg = user_message.strip()

    if intent == "greeting_smalltalk":
        return (
            "Hi! I’m KuBot, your nail-health assistant inside KuCognition.\n\n"
            "You can ask me about nail conditions, what your scan result means, "
            "the app’s accuracy, or how to use different parts of KuCognition."
        )

    if intent == "app_navigation":
        m = msg.lower()

        if "history" in m or "past" in m or "previous" in m:
            return (
                "You can view your previous scans in the **History** tab. "
                "From the dashboard, scroll down to Recent Scans or tap the History icon."
            )
        if "profile" in m or "account" in m:
            return (
                "You can open your **Profile** from the bottom navigation bar. "
                "There you’ll see your name, email, total scans, and most common result."
            )
        if "scan" in m or "camera" in m or "start" in m:
            return (
                "To start a new scan, go to the **Dashboard** and tap the center Scan button. "
                "Follow the on-screen guide to capture a clear image of your nail."
            )

        return (
            "To navigate KuCognition:\n"
            "• Use **Dashboard** to start scans.\n"
            "• Use **History** to view past results.\n"
            "• Use **Profile** to see your info and scan statistics."
        )

    if intent == "faq_capabilities":
        return (
            "Here’s what KuCognition and KuBot can do:\n\n"
            "• Analyze nail images using a deep-learning model.\n"
            "• Detect patterns like acral lentiginous melanoma, clubbing, "
            "onychogryphosis, pitting, and healthy nail.\n"
            "• Explain what these conditions generally mean.\n"
            "• Answer questions about accuracy, app navigation, and health awareness.\n\n"
            "All information is for awareness only — not a medical diagnosis."
        )

    if intent == "faq_accuracy":
        return (
            "The KuCognition nail classifier achieves around **95–96% accuracy** on its test set, "
            "and the KuBot intent classifier achieves around **90–92%**.\n\n"
            "These tools are meant for **health awareness**, not medical diagnosis."
        )

    if intent == "emotion_support":
        return (
            "I understand that you may be feeling worried, confused, or stressed about your nails "
            "or your recent scan result.\n\n"
            "KuCognition can help you learn about possible nail patterns, but it cannot confirm or "
            "rule out any medical condition. If something seems new, changing, or painful, it’s best "
            "to get checked by a professional.\n\n"
            "If you want, you can describe what you’re seeing and I’ll try to explain what types of "
            "conditions are **commonly associated** with those features (without diagnosing)."
        )

    if intent == "nail_condition_info":
        # User is asking about symptoms / features in general
        condition = match_condition_by_keywords(msg)
        if condition:
            return explain_condition(condition)

        return (
            "You’re asking about nail symptoms. You can describe what you see — dark streaks, "
            "thickening, dents, color changes — and I’ll explain which conditions these are "
            "**commonly associated** with. This is not a diagnosis."
        )

    if intent == "scan_result_explanation":
        # User is asking specifically about their scan LABEL, e.g.
        # “What is clubbing”, “Explain my result: Pitting”
        condition = match_condition_by_keywords(msg)
        if condition:
            return explain_condition(condition)

        return (
            "If you give me a scan label such as **Healthy Nail, Pitting, Clubbing, "
            "Onychogryphosis, or Acral Lentiginous Melanoma**, I can explain what that label "
            "generally means.\n\n"
            "Example: “Explain my result: Pitting.”"
        )

    # Fallback
    return (
        "I'm not entirely sure what you mean, but I can help with:\n"
        "• Nail symptoms and what they may indicate\n"
        "• Explaining scan result labels\n"
        "• App navigation and features\n"
        "• Accuracy and limitations of KuCognition\n"
        "• Emotional reassurance if you're feeling worried"
    )


# ============================================================
# 6. ENDPOINTS
# ============================================================

@app.post("/predict_intent", response_model=ChatResponse)
def predict_intent(req: ChatRequest) -> ChatResponse:
    user_text = req.message
    cleaned = preprocess(user_text)
    vec = vectorizer.transform([cleaned])
    pred_intent = intent_model.predict(vec)[0]

    reply = build_reply(user_text, pred_intent)

    return ChatResponse(intent=pred_intent, reply=reply)


@app.get("/health")
def health_check() -> Dict[str, Any]:
    return {"status": "ok", "service": "kubot_nlp"}
