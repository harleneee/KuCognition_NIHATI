# nlp_server.py
# FastAPI backend for KuBot NLP: intent + nail symptom classification

import re
from typing import Any, Optional, Dict

import joblib
from fastapi import FastAPI
from pydantic import BaseModel


# ============================================================
# 1. PREPROCESS (MUST MATCH TRAINING)
# ============================================================

def preprocess(text: str) -> str:
    text = str(text)
    text = text.lower()
    text = re.sub(r"\s+", " ", text).strip()
    return text


# ============================================================
# 2. LOAD MODELS
# ============================================================

# ----- Intent classifier -----
VECTORIZER_PATH = "intent_tfidf_vectorizer.joblib"
MODEL_PATH = "intent_model_svc.joblib"

vectorizer = joblib.load(VECTORIZER_PATH)
intent_model = joblib.load(MODEL_PATH)
print("✅ Intent classifier loaded.")

# ----- Symptom classifier -----
SYMPTOM_VECTORIZER_PATH = "nail_symptom_tfidf_vectorizer.joblib"
SYMPTOM_MODEL_PATH = "nail_symptom_model_svc.joblib"

symptom_vectorizer = joblib.load(SYMPTOM_VECTORIZER_PATH)
symptom_model = joblib.load(SYMPTOM_MODEL_PATH)
print("✅ Symptom classifier loaded.")


# ============================================================
# 3. FASTAPI SCHEMA
# ============================================================

app = FastAPI(title="KuCognition KuBot NLP API")

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    intent: str
    reply: str
    condition: Optional[str] = None


# ============================================================
# 4. SYMPTOM CLASSIFICATION
# ============================================================

def classify_symptom(msg: str) -> Optional[str]:
    clean = preprocess(msg)
    vec = symptom_vectorizer.transform([clean])
    return symptom_model.predict(vec)[0]


# ============================================================
# 5. EXPLANATION ENGINE
# (condensed for brevity — same content you provided)
# ============================================================

def explain_condition(condition: str) -> str:
    if condition == "acral_lentiginous_melanoma":
        return (
            "The changes you're describing match features sometimes seen in **acral "
            "lentiginous melanoma**, such as dark streaks under the nail. Other benign "
            "causes exist, but melanoma is serious.\n\n"
            "Medical guidelines recommend that any new or changing dark streak be evaluated "
            "by a dermatologist."
        )
    if condition == "onychomycosis":
        return (
            "**Onychomycosis** (nail fungus) causes thick, yellow/brown, crumbly nails. "
            "Treatable with antifungal medication."
        )
    if condition == "pitting":
        return (
            "Pitting looks like many small dents in the nail surface. It is commonly associated "
            "with psoriasis or autoimmune skin conditions.\n\n"
            "If persistent, it’s worth showing to a professional."
        )
    if condition == "koilonychia":
        return (
            "**Koilonychia** (spoon nails) curve inward and may indicate iron deficiency anemia."
        )
    if condition == "beau_s_line":
        return (
            "**Beau’s lines** are horizontal grooves caused by stress, severe illness, or shock to nail growth."
        )
    if condition == "bluish_nail":
        return (
            "**Bluish nails** (known as cyanosis) indicate a lack of oxygen in the blood, "
            "which may be caused by cold exposure or serious circulation/lung issues. "
            "This color change is most visible in the nail bed because the blood underneath "
            "is low in oxygen and appears bluish-purple. If the blueness is new and persists "
            "after warming your hands, it signals a potentially serious systemic issue. "
            "\n\n**If this blueness is new or accompanied by breathing difficulties, seek medical attention immediately.**"
        )
    if condition == "yellow_nail":
        return (
            "The **Yellow Nail** condition (sometimes referred to as Syndrome) causes all nails to become "
            "thick, uniformly yellow, and grow very slowly. It is often associated with "
            "underlying respiratory or lymphatic issues.\n\n"
            "This warrants a conversation with your physician to check for systemic causes."
        )
    if condition == "white_nail":
        return (
            "A white appearance to the nail is called **Leukonychia** and can be total (entire nail) "
            "or partial (spots or lines). The pattern known as **Terry's nails** specifically "
            "describes a nail that is mostly white with only a narrow band of pink/brown at the tip."

        )
    if condition == "clubbing_nail":
        return (
            "Clubbing causes rounded, bulbous fingertips and curved nails. It is sometimes "
            "associated with heart or lung conditions.\n\n"
            "If you're noticing this on your nails, it’s a good idea to mention it during "
            "a check-up."
        )
    if condition == "onychogryphosis":
        return (
            "Onychogryphosis often appears as a thick, curved, ram’s-horn-like nail. It can "
            "result from long-term pressure or underlying nail growth issues.\n\n"
            "A podiatrist or dermatologist can help manage this safely."
        )
    if condition == "psoriasis":
        return (
            "Nail changes from **Psoriasis** are highly varied and can affect the nail plate (causing "
            "small pinprick dents or **pitting**) or the nail bed (causing the **oil drop** sign and "
            "separation).\n\n"
            "The severity of nail psoriasis often does not correlate with the severity of skin psoriasis,"
            "but it requires specific, long-term management to prevent permanent nail damage.\n\n"
            "If you have a history of psoriasis, these changes are likely related. Treatment "
            "is usually managed by a dermatologist."
        )
    if condition == "healthy_nail":
        return (
            "Your description suggests your nail may look normal — smooth surface, even color, "
            "and no unusual marks.\n\n"
            "Healthy nails are a good sign, but regular health monitoring is still important."
        )
    
    
    return "I recognize the pattern, but do not have a description for this label."


# ============================================================
# 6. INTENT → REPLY (KUBOT PERSONALITY)
# ============================================================

def build_reply(msg: str, intent: str) -> str:

    # --- greeting ---
    if intent == "greeting_smalltalk":
        return (
            "Hi! I’m KuBot, your nail-health assistant inside KuCognition.\n\n"
            "You can ask me about nail conditions, what your scan result means, "
            "the app’s accuracy, or how to use different parts of KuCognition."
        )

    # --- navigation ---
    if intent == "app_navigation":
        m = msg.lower()

        # 1. Specific Keyword Matching
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
        if "scan" in m or "camera" in m or "start" in m or "capture" in m or "analyze" in m:
            return (
                "To start a new scan, go to the **Dashboard** and tap the center Scan button. "
                "Follow the on-screen guide to capture a clear image of your nail."
            )
        # 2. Default Navigation Menu (Covers general queries like "how do I use the app?")
        return (
            "KuBot is happy to help with navigation. Here are the main areas of the app:\n\n"
            "1. **Scan (Dashboard):** To analyze a new nail image.\n"
            "2. **History:** To review all your past scan results and track changes.\n"
            "3. **Profile:** To manage your account and application settings."
        )

    # --- faq capabilities ---
    if intent == "faq_capabilities":
        return (
            "Here’s what KuCognition and KuBot can do:\n\n"
            "• Analyze nail images using a deep-learning model.\n"
            "• Detect patterns like acral lentiginous melanoma, clubbing, "
            "  onychogryphosis, pitting, beau's lines, bluish nail, koilonychia and healthy nail.\n"
            "• Explain what these conditions generally mean.\n"
            "• Answer questions about accuracy, app navigation, and health awareness.\n\n"
            "All information is for awareness only — not a medical diagnosis."
        )

    # --- faq accuracy ---
    if intent == "faq_accuracy":
        return (
            "Classifier accuracy: ~95% for nail images, ~90% for text.\n"
            "Awareness only — not medical diagnosis."
        )
    
    # --- faq treatment (SMARTEST ANSWER) ---
    if intent == "faq_treatment":
        return (
            "KuBot cannot recommend specific treatments, medications, home remedies, or cures. "
            "Treatment for any nail condition—whether it's an infection, an inflammatory disease "
            "like psoriasis, or a systemic issue like anemia—requires a comprehensive, in-person "
            "diagnosis from a qualified professional.\n\n"
            "**Your Next Steps:**\n"
            "1. **Consult a Specialist:** Please schedule an appointment with a **Dermatologist** "
            "(for skin/nail diseases) or a **Podiatrist** (for foot/toenail issues).\n"
            "2. **Use Your Results:** Share your KuBot scan results and confidence score with your doctor. "
            "This information can help guide their examination and diagnostic process."
        )
    
    # --- emotion support ---
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
    # --- farewell ---
    if intent == "farewell":
        return (
            "Thank you for using KuBot. Remember, your healthcare provider "
            "is the best resource for serious or persistent nail concerns. "
            "Have a great day!"
        )

    return (
        "I can help with:\n"
        "• Nail symptoms\n"
        "• Scan result explanations\n"
        "• App navigation\n"
        "• Accuracy questions"
    )


# ============================================================
# 7. MAIN ENDPOINT
# ============================================================

@app.post("/predict_intent", response_model=ChatResponse)
def predict_intent(req: ChatRequest) -> ChatResponse:
    user_text = req.message
    cleaned = preprocess(user_text)

    # 1) predict chat intent
    vec = vectorizer.transform([cleaned])
    pred_intent = intent_model.predict(vec)[0]

    # 2) classify nail symptom if needed
    if pred_intent in ["nail_condition_info", "scan_result_explanation"]:
        condition = classify_symptom(user_text)
        reply = explain_condition(condition)
        return ChatResponse(intent=pred_intent, condition=condition, reply=reply)

    # 3) otherwise standard bot reply
    reply = build_reply(user_text, pred_intent)
    return ChatResponse(intent=pred_intent, condition=None, reply=reply)


# ============================================================
# 8. HEALTH CHECK
# ============================================================

@app.get("/health")
def health():
    return {"status": "ok", "service": "kubot_nlp"}
