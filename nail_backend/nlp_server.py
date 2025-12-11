# nlp_server.py
# FastAPI backend for KuBot NLP: intent + nail symptom classification

import re
from typing import Optional

import joblib
from fastapi import FastAPI
from pydantic import BaseModel


# ============================================================
# 0. SIMPLE "MEMORY" OF LAST CONDITION
# ============================================================

LAST_CONDITION: Optional[str] = None  # remembers last condition explained briefly


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
    # Present ONLY when coming from Learn More / DiseaseDetailsPage
    condition: Optional[str] = None


class ChatResponse(BaseModel):
    intent: str
    reply: str
    condition: Optional[str] = None


# ============================================================
# 4. RULE-BASED CONDITION MATCHING (all 12 classes)
# ============================================================

KNOWN_CONDITIONS = {
    # Acral Lentiginous Melanoma
    "acral lentiginous melanoma": "acral_lentiginous_melanoma",
    "lentiginous melanoma": "acral_lentiginous_melanoma",
    "melanoma": "acral_lentiginous_melanoma",

    # Onychomycosis
    "onychomycosis": "onychomycosis",
    "nail fungus": "onychomycosis",
    "fungal nail": "onychomycosis",

    # Pitting
    "nail pitting": "pitting",
    "pitting": "pitting",

    # Koilonychia
    "koilonychia": "koilonychia",
    "spoon nail": "koilonychia",
    "spoon nails": "koilonychia",

    # Beau's line
    "beau's line": "beau_s_line",
    "beau's lines": "beau_s_line",
    "beaus line": "beau_s_line",
    "beaus lines": "beau_s_line",
    "beau line": "beau_s_line",
    "beau lines": "beau_s_line",
    "beau": "beau_s_line",

    # Bluish nail / cyanosis
    "bluish nail": "bluish_nail",
    "blue nail": "bluish_nail",
    "blue finger": "bluish_nail",
    "cyanosis": "bluish_nail",

    # Yellow nail
    "yellow nail": "yellow_nail",
    "yellow nails": "yellow_nail",

    # White nail
    "white nail": "white_nail",
    "white nails": "white_nail",

    # Clubbing
    "nail clubbing": "clubbing_nail",
    "clubbing nail": "clubbing_nail",
    "clubbing": "clubbing_nail",

    # Onychogryphosis
    "onychogryphosis": "onychogryphosis",
    "ram's horn": "onychogryphosis",
    "rams horn": "onychogryphosis",

    # Psoriasis
    "nail psoriasis": "psoriasis",
    "psoriasis": "psoriasis",

    # Healthy nail
    "healthy nail": "healthy_nail",
    "healthy nails": "healthy_nail",
    "normal nail": "healthy_nail",
}


def match_known_condition(text: str) -> Optional[str]:
    """Return a condition label if the text clearly names one of the 12 classes."""
    t = text.lower()
    for phrase, label in KNOWN_CONDITIONS.items():
        if phrase in t:
            return label
    return None


# ============================================================
# 4B. SIMPLE EMOTION / SENTIMENT RULES
# ============================================================

EMOTION_WORDS = [
    "scared", "afraid", "worried", "worry", "anxious", "anxiety",
    "nervous", "terrified", "frightened", "panic", "panicking",
    "concerned", "stressed", "stress", "fear", "fearful"
]


def has_strong_emotion(text: str) -> bool:
    """Detect if the user text clearly expresses fear/worry."""
    t = text.lower()
    return any(word in t for word in EMOTION_WORDS)


# ============================================================
# 4C. FOLLOW-UP QUESTION DETECTION
# ============================================================

FOLLOWUP_PATTERNS = [
    "tell me more",
    "explain this more",
    "explain more",
    "can you explain more",
    "more details",
    "details please",
    "what does this mean",
    "what does that mean",
    "elaborate this",
    "elaborate more",
    "explain it more",
    "i want to know more",
]


def is_followup_question(text: str) -> bool:
    """
    Very simple rule-based detector: checks if the user is asking
    for more explanation about something that was just mentioned.
    """
    t = text.lower()
    return any(pat in t for pat in FOLLOWUP_PATTERNS)


# ============================================================
# 5. SYMPTOM CLASSIFICATION (ML model)
# ============================================================

def classify_symptom(msg: str) -> Optional[str]:
    clean = preprocess(msg)
    vec = symptom_vectorizer.transform([clean])
    return symptom_model.predict(vec)[0]


# ============================================================
# 6A. BRIEF EXPLANATIONS (for free-text questions)
# ============================================================

def explain_condition_brief(condition: str) -> str:
    if condition == "acral_lentiginous_melanoma":
        return (
            "The changes you described can match **acral lentiginous melanoma**, a serious form "
            "of skin cancer that may appear as a dark streak under the nail. Other benign causes "
            "exist, but melanoma is important to rule out. Any new or changing dark streak should "
            "be checked by a dermatologist."
        )
    if condition == "onychomycosis":
        return (
            "**Onychomycosis** is a fungal nail infection. It often causes yellow or brown "
            "discoloration, thickening, and crumbling at the edges. It’s common on toenails and "
            "typically needs antifungal treatment if persistent."
        )
    if condition == "pitting":
        return (
            "**Nail pitting** looks like many tiny dents on the nail surface. It is most commonly "
            "seen in psoriasis or other autoimmune skin conditions and may signal inflammation."
        )
    if condition == "koilonychia":
        return (
            "**Koilonychia** (spoon nails) means the nails are thin and curve inward like a spoon. "
            "It is often linked with iron deficiency anemia and may improve after iron levels are corrected."
        )
    if condition == "beau_s_line":
        return (
            "**Beau’s lines** are horizontal grooves across the nail that appear when nail growth "
            "temporarily stops, for example after severe illness, high fever, or major stress."
        )
    if condition == "bluish_nail":
        return (
            "**Bluish nails** (cyanosis) indicate low oxygen levels in the blood or poor circulation. "
            "They can appear after cold exposure but may also reflect heart or lung problems. "
            "Persistent bluish color should be evaluated promptly."
        )
    if condition == "yellow_nail":
        return (
            "**Yellow nails** may result from fungal infection, smoking, chronic respiratory issues, "
            "or certain medications. Persistent uniform yellowing deserves medical review."
        )
    if condition == "white_nail":
        return (
            "**White nails** (leukonychia) can show as spots, bands, or almost complete whiteness. "
            "They may follow trauma but can also be associated with systemic conditions such as liver "
            "or kidney disease, depending on the pattern."
        )
    if condition == "clubbing_nail":
        return (
            "**Clubbing** means the fingertips look rounded and bulbous and the nails curve downward. "
            "It is sometimes linked to heart or lung diseases and should be mentioned to a clinician."
        )
    if condition == "onychogryphosis":
        return (
            "**Onychogryphosis** is a severe thickening and curving of the nail, often called "
            "'ram’s-horn nail'. It may be related to chronic pressure, trauma, or circulation issues "
            "and usually needs podiatric or dermatologic care."
        )
    if condition == "psoriasis":
        return (
            "**Nail psoriasis** can cause pitting, yellow-brown discoloration, thickening, and "
            "separation of the nail. It often occurs with skin psoriasis and needs long-term management."
        )
    if condition == "healthy_nail":
        return (
            "A **healthy nail** usually has a smooth surface, an even light-pink color, "
            "and is firmly attached to the nail bed with no unusual spots, streaks, or thickening.\n\n"
            "Changes in color, shape, or thickness over time can still signal health issues, "
            "so it’s important to notice new or persistent changes and discuss them with a professional."
        )

    return "I recognize the pattern, but do not have a brief description for this label."


# ============================================================
# 6A.1 EMOTION-AWARE BRIEF EXPLANATIONS
# ============================================================

PRETTY_NAMES = {
    "acral_lentiginous_melanoma": "acral lentiginous melanoma",
    "onychomycosis": "onychomycosis (fungal nail infection)",
    "pitting": "nail pitting",
    "koilonychia": "koilonychia (spoon nails)",
    "beau_s_line": "Beau’s lines",
    "bluish_nail": "bluish nail / cyanosis",
    "yellow_nail": "yellow nail",
    "white_nail": "white nail",
    "clubbing_nail": "nail clubbing",
    "onychogryphosis": "onychogryphosis",
    "psoriasis": "nail psoriasis",
    "healthy_nail": "healthy nail",
}


def explain_condition_with_emotion(condition: str) -> str:
    """
    Wrap the brief explanation with empathetic language when the user is
    clearly scared or worried about a specific condition.
    """
    base = explain_condition_brief(condition)
    pretty = PRETTY_NAMES.get(condition, condition.replace("_", " "))
    return (
        f"It’s completely understandable to feel worried or scared when you read about **{pretty}** "
        "or notice changes in your nails.\n\n"
        + base
        + "\n\nKuCognition can highlight patterns for **health awareness only** and cannot diagnose you. "
          "If these changes are new, painful, spreading, or causing you anxiety, please talk to a "
          "healthcare professional who can examine you in person."
    )


# ============================================================
# 6B. DETAILED EXPLANATIONS (for Ask KuBot About This)
# ============================================================

def explain_condition_detailed(condition: str) -> str:
    if condition == "acral_lentiginous_melanoma":
        return (
            "You’re asking about **Acral Lentiginous Melanoma (ALM)**, a rare but serious form of "
            "skin cancer that can appear under the nail.\n\n"
            "**How it looks:**\n"
            "• Usually a dark brown or black streak or band under the nail\n"
            "• Borders can be irregular and the color may spread to the cuticle or surrounding skin\n"
            "• It tends to affect a single nail rather than many nails at once\n\n"
            "**Why it matters:**\n"
            "ALM can be aggressive if not caught early. Some benign nail streaks exist, but new, "
            "widening, or changing dark streaks must be taken seriously.\n\n"
            "**What you can do:**\n"
            "• Arrange an appointment with a **dermatologist** (skin specialist)\n"
            "• Mention when the streak first appeared and whether it has changed in size or color\n"
            "• The doctor may perform a dermoscopic exam and, if needed, a biopsy of the nail unit\n\n"
            "KuCognition can only raise awareness; it cannot diagnose melanoma. Any suspicious "
            "streak under the nail deserves an in-person medical evaluation."
        )

    if condition == "onychomycosis":
        return (
            "Let’s look more closely at **Onychomycosis**, a fungal infection of the nail.\n\n"
            "**Typical features:**\n"
            "• Yellow, white, or brown discoloration\n"
            "• Thickened nail that may become brittle or crumbly\n"
            "• Rough or distorted nail shape, sometimes with foul odor\n"
            "• The nail may lift from the nail bed in more advanced cases\n\n"
            "**How it develops:**\n"
            "Fungi thrive in warm, moist environments—like sweaty socks, closed shoes, and public showers. "
            "Small cracks in the nail or skin let the organisms enter and slowly invade the nail plate.\n\n"
            "**Who is more at risk:**\n"
            "• People who frequently wear tight, non-breathable shoes\n"
            "• Those with diabetes, poor circulation, or weakened immunity\n"
            "• Older adults, because nails grow slower and are more easily damaged\n\n"
            "**What you can do (non-diagnostic guidance):**\n"
            "• See a doctor or dermatologist for confirmation—sometimes a nail clipping is sent to the lab\n"
            "• If infection is confirmed, they may prescribe **topical** or **oral antifungal medication**\n"
            "• Keep feet clean and dry, change socks regularly, and avoid sharing nail clippers or shoes\n\n"
            "Improvement can take months because nails grow slowly, so any treatment plan needs patience "
            "and follow-up with a professional."
        )

    if condition == "pitting":
        return (
            "You’re asking about **nail pitting**—tiny pin-prick depressions on the nail surface.\n\n"
            "**What it usually indicates:**\n"
            "• Most commonly linked to **psoriasis** of the nails\n"
            "• Can also appear with other autoimmune conditions such as alopecia areata or reactive arthritis\n\n"
            "**Why it happens:**\n"
            "The nail plate forms from a structure called the **nail matrix**. Inflammation there, as seen "
            "in psoriasis, disrupts the normal keratin formation and leaves small pits as the nail grows out.\n\n"
            "**Associated signs to watch for:**\n"
            "• Red, scaly skin plaques on elbows, knees, scalp or trunk\n"
            "• Joint pain or stiffness (possible psoriatic arthritis)\n"
            "• Nail discoloration or separation from the nail bed\n\n"
            "**What you can do:**\n"
            "• Arrange a consultation with a **dermatologist** if pitting is persistent or widespread\n"
            "• Mention any skin rashes or joint symptoms you have\n"
            "• Treatment might include topical therapies, injections into the nail matrix, or systemic "
            "psoriasis medications—chosen by the specialist\n\n"
            "Pitting itself is not dangerous, but it can be a visible clue to an underlying inflammatory disease "
            "that benefits from long-term management."
        )

    if condition == "koilonychia":
        return (
            "Let’s explore **Koilonychia**, commonly called **spoon nails**.\n\n"
            "**How it appears:**\n"
            "• Nails are thin and soft\n"
            "• The center of the nail dips while the outer edges lift, giving a spoon-like shape\n"
            "• It can affect one nail or several\n\n"
            "**Common associations:**\n"
            "• **Iron deficiency anemia** is the classic cause\n"
            "• Can also be seen in chronic blood loss, malnutrition, or certain systemic diseases\n\n"
            "**Why this matters:**\n"
            "Spoon nails are not just a cosmetic issue—they may be an external clue that your body’s iron "
            "stores are low or that another systemic condition is present.\n\n"
            "**What you can do:**\n"
            "• Ask a healthcare provider about getting a **blood test** for anemia (hemoglobin, ferritin)\n"
            "• Discuss your diet, menstrual history, and any chronic bleeding or digestive symptoms\n"
            "• If iron deficiency is confirmed, your provider may recommend iron supplements and investigation of the cause\n\n"
            "Nail shape may gradually improve once the underlying condition is addressed, but this can take several months "
            "because nails grow slowly."
        )

    if condition == "beau_s_line":
        return (
            "You’re asking about **Beau’s lines**, horizontal grooves that run across the nail plate.\n\n"
            "**What they represent:**\n"
            "Beau’s lines form when nail growth **temporarily stops or slows**. As the nail resumes growing, "
            "the pause shows up as a visible ridge.\n\n"
            "**Typical triggers include:**\n"
            "• High fever or serious infection\n"
            "• Major surgery or physical trauma\n"
            "• Severe emotional stress or crash dieting\n"
            "• Certain systemic illnesses or chemotherapy\n\n"
            "**How to interpret them:**\n"
            "Because nails grow at a roughly steady rate, the distance of the line from the cuticle can give a rough idea "
            "of when the health event occurred.\n\n"
            "**What you can do:**\n"
            "• Think back to serious illnesses or stresses in the past few months; they may line up with the grooves\n"
            "• If multiple nails show deep or repeated lines and you don’t recall a clear trigger, discuss this with a clinician\n\n"
            "The lines themselves usually grow out over time; the key is understanding and managing whatever interrupted nail growth."
        )

    if condition == "bluish_nail":
        return (
            "Let’s look more deeply at **bluish nails**, also called **cyanosis of the nail bed**.\n\n"
            "**What’s happening physiologically:**\n"
            "The pink color of normal nails comes from oxygen-rich blood in the tiny vessels underneath. "
            "When the blood has **less oxygen**, it appears darker and gives the nails a bluish or purplish tone.\n\n"
            "**Possible causes range from mild to serious:**\n"
            "• Temporary narrowing of blood vessels from cold exposure\n"
            "• Chronic lung diseases (e.g., COPD, severe asthma)\n"
            "• Heart conditions that impair oxygen delivery\n"
            "• Circulatory problems, blood clots, or certain congenital heart defects\n\n"
            "**Warning signs that need urgent attention:**\n"
            "• Bluish color that **does not resolve** after warming your hands\n"
            "• Associated shortness of breath, chest pain, dizziness, or confusion\n\n"
            "**What you can do:**\n"
            "• If the color change is new and persistent, seek prompt medical evaluation\n"
            "• A clinician may check oxygen levels, perform chest imaging, and evaluate heart and lung function\n\n"
            "KuCognition can highlight cyanosis as a potential sign, but only an in-person assessment can determine "
            "the exact cause and whether emergency care is needed."
        )

    if condition == "yellow_nail":
        return (
            "You’re asking about **Yellow Nails**, which can have several different causes.\n\n"
            "**How they typically look:**\n"
            "• Nails are uniformly yellow or yellow-green\n"
            "• They may be thickened, curved, and grow slowly\n"
            "• Cuticles may be reduced or absent\n\n"
            "**Common explanations include:**\n"
            "• **Fungal nail infection** (especially if only a few nails are involved)\n"
            "• **Yellow Nail Syndrome**, which can be associated with chronic lung disease or lymphatic problems\n"
            "• Staining from smoking or frequent nail polish use\n\n"
            "**When to be more concerned:**\n"
            "If yellow nails occur together with chronic cough, shortness of breath, or leg swelling, "
            "doctors may consider underlying respiratory or lymphatic disorders.\n\n"
            "**What you can do:**\n"
            "• Have a clinician examine the nails; they may take nail scrapings to check for fungus\n"
            "• Discuss any breathing problems, sinus issues, or swelling in your limbs\n"
            "• Follow medical advice on antifungal therapy or further tests if a systemic cause is suspected\n\n"
            "Addressing the underlying issue often improves nail appearance, but noticeable change may take several months."
        )

    if condition == "white_nail":
        return (
            "Let’s talk about **white nails**, medically known as **leukonychia**.\n\n"
            "**Forms it can take:**\n"
            "• Small white spots or streaks after minor trauma (very common and usually harmless)\n"
            "• Partial whitening in bands\n"
            "• Nearly completely white nails with only a narrow darker band at the tip (called **Terry’s nails**)\n\n"
            "**Potential associations:**\n"
            "• Repeated micro-injury from manicures or nail biting\n"
            "• Low albumin or chronic liver disease (especially with Terry’s nails)\n"
            "• Kidney disease or certain infections\n\n"
            "**What you can do:**\n"
            "• If you only see a few small spots after trauma, they typically grow out on their own\n"
            "• If most of the nail looks white, or you have other symptoms like fatigue, swelling, or jaundice, "
            "it’s important to talk to a healthcare provider\n"
            "• They may order blood tests to evaluate liver, kidney and nutritional status\n\n"
            "The nail appearance alone cannot diagnose these conditions, but it can be an early visual clue that further evaluation is needed."
        )

    if condition == "clubbing_nail":
        return (
            "You’re exploring **nail clubbing**, where fingertips enlarge and nails curve around them.\n\n"
            "**Key visual clues:**\n"
            "• Bulbous, rounded fingertips\n"
            "• Nails that slope and curve more than usual\n"
            "• Loss of the normal angle between nail plate and surrounding skin\n\n"
            "**Why clinicians pay attention to clubbing:**\n"
            "It can be associated with chronic **low blood oxygen** or long-standing inflammation, for example:\n"
            "• Chronic lung diseases (COPD, cystic fibrosis, interstitial lung disease)\n"
            "• Certain heart defects or heart failure\n"
            "• Some gastrointestinal or liver diseases\n\n"
            "**What you can do:**\n"
            "• Mention clubbing to a healthcare provider, especially if you also have cough, breathlessness, or chest discomfort\n"
            "• They may evaluate your lungs and heart with imaging and blood tests\n\n"
            "Clubbing itself does not cause pain, but it can be an outward sign of deeper conditions that benefit from early diagnosis."
        )

    if condition == "onychogryphosis":
        return (
            "Let’s look in more depth at **Onychogryphosis**, sometimes called **ram’s-horn nail**.\n\n"
            "**What it looks like:**\n"
            "• Very thick, hard nail plate\n"
            "• Marked curvature or twisting, often in one direction\n"
            "• Most commonly affects toenails, especially the big toe\n\n"
            "**Common contributing factors:**\n"
            "• Long-term pressure from tight shoes\n"
            "• Repeated trauma (for example, in certain sports)\n"
            "• Poor circulation, advanced age, or underlying nail disorders\n"
            "• Sometimes co-exists with fungal infection\n\n"
            "**Why it’s important to address:**\n"
            "The nail can become painful, difficult to trim, and prone to secondary infection or skin breakdown.\n\n"
            "**What you can do:**\n"
            "• See a **podiatrist** or dermatologist for proper trimming and evaluation\n"
            "• They may thin the nail, treat any fungal infection, and advise on footwear and foot care\n"
            "• Do not attempt aggressive self-trimming at home, as this can cause injury\n\n"
            "Professional care focuses on comfort, preventing complications, and managing any underlying causes."
        )

    if condition == "psoriasis":
        return (
            "You’re asking about **nail psoriasis**, which is a manifestation of the autoimmune disease psoriasis.\n\n"
            "**Typical nail changes include:**\n"
            "• Small pits or dents on the surface\n"
            "• Yellow-brown “oil drop” discoloration under the nail\n"
            "• Thickening, crumbling, or separation of the nail from the nail bed\n\n"
            "**How it fits into overall psoriasis:**\n"
            "Not everyone with skin psoriasis has nail changes, but when present, they may correlate with a higher "
            "risk of **psoriatic arthritis** (joint involvement).\n\n"
            "**What you can do:**\n"
            "• Consult a **dermatologist**—describe both nail and any skin or joint symptoms\n"
            "• Treatments may include topical medications, injections near the nail matrix, or systemic therapies "
            "for moderate-to-severe psoriasis\n"
            "• Protect nails from trauma, keep them short, and avoid harsh chemicals to reduce worsening\n\n"
            "Nail psoriasis is chronic but manageable; coordinated care can greatly improve comfort and appearance "
            "over time."
        )

    if condition == "healthy_nail":
        return (
            "Your result lines up with a **healthy-appearing nail**.\n\n"
            "**Healthy nail features typically include:**\n"
            "• Smooth surface without pits or grooves\n"
            "• Light pink color with a clear, even tone\n"
            "• Firm attachment to the nail bed with no lifting\n"
            "• No thickening, crumbling, or unusual streaks\n\n"
            "**How to keep nails healthy:**\n"
            "• Protect them from repeated trauma and harsh chemicals\n"
            "• Keep them clean, dry, and neatly trimmed\n"
            "• Moisturize the surrounding skin to prevent cracking\n"
            "• Maintain a balanced diet with adequate protein, iron and vitamins\n\n"
            "Even with healthy nails, any **sudden change** in color, shape, or thickness should be discussed with a "
            "healthcare provider, because nails can sometimes give early clues about general health."
        )

    return "I recognize the pattern, but do not have a detailed description for this label."


# ============================================================
# 7. INTENT → REPLY (KUBOT PERSONALITY)
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
            "  onychogryphosis, pitting, Beau’s lines, bluish nail, koilonychia and healthy nail.\n"
            "• Explain what these conditions generally mean.\n"
            "• Answer questions about accuracy, app navigation, and health awareness.\n\n"
            "All information is for awareness only — not a medical diagnosis."
        )

    # --- faq accuracy ---
    if intent == "faq_accuracy":
        return (
            "The nail-image classifier performs well on the evaluation dataset used in this thesis, "
            "but real-world images can be more variable. KuCognition is designed for **health awareness only** "
            "and cannot replace a professional diagnosis."
        )

    # --- faq treatment ---
    if intent == "faq_treatment":
        return (
            "KuBot cannot recommend specific treatments, medications, home remedies, or cures. "
            "Treatment for any nail condition—whether it's an infection, an inflammatory disease "
            "like psoriasis, or a systemic issue like anemia—requires a comprehensive, in-person "
            "diagnosis from a qualified professional.\n\n"
            "**Your next steps could include:**\n"
            "1. Scheduling a visit with a **dermatologist** (for skin and nail disease) "
            "or **podiatrist** (for foot/toenail issues).\n"
            "2. Bringing photos or your KuCognition scan results to that appointment as a starting point for discussion."
        )

    # --- emotion support ---
    if intent == "emotion_support":
        return (
            "It’s understandable to feel worried or stressed when your nails look unusual or when a scan "
            "mentions a serious-sounding condition.\n\n"
            "KuCognition can help you learn about common nail patterns, but it cannot confirm or rule out "
            "any medical diagnosis. If a change is new, painful, spreading, or simply worrying you, "
            "the safest step is to talk with a healthcare professional who can examine you in person."
        )

    # --- farewell ---
    if intent == "farewell":
        return (
            "Thank you for using KuBot. Remember, a healthcare provider is the best resource for "
            "serious or persistent nail concerns. Take care!"
        )

    return (
        "I can help with:\n"
        "• Nail symptoms\n"
        "• Scan result explanations\n"
        "• App navigation\n"
        "• Accuracy and limitation questions"
    )


# ============================================================
# 8. MAIN ENDPOINT
# ============================================================

@app.post("/predict_intent", response_model=ChatResponse)
def predict_intent(req: ChatRequest) -> ChatResponse:
    global LAST_CONDITION

    user_text = req.message

    # 0) Learn-More / DiseaseDetailsPage path: condition is known → DETAILED explanation
    if req.condition is not None:
        reply = explain_condition_detailed(req.condition)
        LAST_CONDITION = req.condition  # remember last detailed condition too
        return ChatResponse(
            intent="nail_condition_info_detailed",
            condition=req.condition,
            reply=reply,
        )

    cleaned = preprocess(user_text)

    # 0.3) FOLLOW-UP: user asks "tell me more / explain this more" → use LAST_CONDITION
    if is_followup_question(cleaned) and LAST_CONDITION is not None:
        reply = explain_condition_detailed(LAST_CONDITION)
        return ChatResponse(
            intent="nail_condition_info_detailed_followup",
            condition=LAST_CONDITION,
            reply=reply,
        )

    # 0.5) RULE OVERRIDE:
    # If user clearly typed a disease name:
    #   - with strong emotion → emotion-aware brief explanation
    #   - otherwise → normal brief explanation
    cond_from_keywords = match_known_condition(cleaned)
    if cond_from_keywords is not None:
        LAST_CONDITION = cond_from_keywords  # remember this condition
        if has_strong_emotion(cleaned):
            reply = explain_condition_with_emotion(cond_from_keywords)
            return ChatResponse(
                intent="emotion_support_condition",
                condition=cond_from_keywords,
                reply=reply,
            )
        else:
            reply = explain_condition_brief(cond_from_keywords)
            return ChatResponse(
                intent="nail_condition_info",
                condition=cond_from_keywords,
                reply=reply,
            )

    # 1) Otherwise, use ML intent classifier
    vec = vectorizer.transform([cleaned])
    pred_intent = intent_model.predict(vec)[0]

    # 2) If intent is condition-related, use symptom text classifier → BRIEF info
    if pred_intent in ["nail_condition_info", "scan_result_explanation"]:
        condition = classify_symptom(user_text)
        LAST_CONDITION = condition  # remember last brief condition
        reply = explain_condition_brief(condition)
        return ChatResponse(intent=pred_intent, condition=condition, reply=reply)

    # 3) Everything else → generic bot reply
    reply = build_reply(user_text, pred_intent)
    return ChatResponse(intent=pred_intent, condition=None, reply=reply)


# ============================================================
# 9. HEALTH CHECK
# ============================================================

@app.get("/health")
def health():
    return {"status": "ok", "service": "kubot_nlp"}
