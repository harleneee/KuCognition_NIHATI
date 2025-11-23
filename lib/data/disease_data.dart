class DiseaseInfo {
  final String name;
  final String description;
  final List<String> signs;
  final String image;

  DiseaseInfo({
    required this.name,
    required this.description,
    required this.signs,
    required this.image,
  });
}

final Map<String, DiseaseInfo> diseaseDatabase = {
  "Blue Finger/Bluish nail (Cyanosis)": DiseaseInfo(
    name: "Blue Finger / Cyanosis",
    image: "assets/images/cyanosis.jpg",
    description:
        "Cyanosis is a bluish discoloration of the fingertips, indicating a reduced oxygen level in the blood. This condition typically arises from circulation problems, heart issues, or lung disease. Severe cold exposure can also trigger cyanosis by reducing blood flow to the extremities, causing oxygen deprivation. Cyanosis may be a sign of underlying respiratory.",
    signs: [
      "Bluish or purplish nail beds",
      "Cold fingers",
      "Reduced oxygen circulation",
      "Possible numbness or tingling",
    ],
  ),

  "Clubbing": DiseaseInfo(
    name: "Nail Clubbing",
    image: "assets/images/clubbing.jpg",
    description:
        "Nail clubbing is characterized by rounded, bulb-like fingertips and downward-curving nails. It is commonly associated with heart disease, lung cancer, chronic lung infections, or gastrointestinal disorders. The condition is often linked to reduced oxygen levels in the blood and impaired circulation.",
    signs: [
      "Rounded, bulb-like fingertips",
      "Increased nail curvature",
      "Soft nail beds",
      "Warm, swollen fingertips",
    ],
  ),

  "Onychomycosis": DiseaseInfo(
    name: "Onychomycosis",
    image: "assets/images/onychomycosis.jpg",
    description:
        "Onychomycosis is a fungal infection of the nails that is often linked to conditions like diabetes or a weakened immune system. This infection causes nail thickening, discoloration, and the buildup of debris beneath the nail. This can also cause nail separation from the nail bed (onycholysis) and are more common in people with diabetic neuropathy.",
    signs: [
      "Yellow, brown, or white discoloration",
      "Thickened or distorted nails",
      "Crumbling or brittle nail edges",
      "Separation of nail from nail bed",
      "Debris buildup under nail",
    ],
  ),

  "Psoriasis": DiseaseInfo(
    name: "Nail Psoriasis",
    image: "assets/images/psoriasis.jpg",
    description:
        "Nail psoriasis is a chronic inflammatory disorder often seen in people with psoriasis or psoriatic arthritis. It causes pitting, discoloration, and nail separation. Psoriasis affects the immune system, leading to abnormal nail growth and the formation of small pits or depressions on the surface of the nails. This condition can cause discomfort and may lead to nail damage if left untreated.",
    signs: [
      "Small pits on the nail surface",
      "Yellow-red discoloration (oil-drop sign)",
      "Crumbling nails",
      "Nail separation (onycholysis)",
    ],
  ),

  "Healthy Nail": DiseaseInfo(
    name: "Healthy Nail",
    image: "assets/images/healthy.jpg",
    description:
        "Healthy nails are a reflection of good nutrition, proper circulation, and overall systemic health. They appear smooth, with no ridges or pits, and have a natural pinkish color. If nails become brittle or develop abnormalities, it may signal an underlying health issue such as nutritional deficiencies or poor circulation.",
    signs: [
      "Smooth texture",
      "Uniform pinkish color",
      "No ridges or pits",
      "Firm attachment to nail bed",
    ],
  ),

  "Acral Lentiginous Melanoma": DiseaseInfo(
    name: "Acral Lentiginous Melanoma",
    image: "assets/images/melanoma.jpg",
    description:
        "Acral lentiginous melanoma is a rare form of skin cancer that often appears under the nails. Early detection is critical, as it can spread quickly if left untreated. This type of melanoma tends to have dark streaks under the nail and is more common in individuals with darker skin tones. Irregular borders and color changes are warning signs, and it may bleed or cause nail separation.",
    signs: [
      "Dark streak under the nail",
      "Pigmented spot that expands over time",
      "Irregular borders or color changes",
      "Nail separation or bleeding",
    ],
  ),

  "Onychogryphosis": DiseaseInfo(
    name: "Onychogryphosis",
    image: "assets/images/onychogryphosis.jpg",
    description:
        "Onychogryphosis, also known as ram's horn nails, results in extreme thickening and curvature of the nails. It may be linked to poor circulation, trauma, or long-term neglect of nail care. This condition causes the nails to become disfigured, and the thickened nails may cause pain when wearing shoes or performing tasks that involve pressure on the toes.",
    signs: [
      "Severely thickened nails",
      "Curved or twisted nail shape",
      "Yellow-brown color",
      "Pain when wearing shoes",
    ],
  ),

  "Pitting": DiseaseInfo(
    name: "Nail Pitting",
    image: "assets/images/pitting.jpg",
    description:
        "Nail pitting refers to the development of small depressions or pits on the nail surface. It is most commonly associated with psoriasis, eczema, or alopecia areata. Pitting is thought to result from disrupted keratin production and may be linked to other skin conditions or systemic diseases. People with nail pitting may also experience brittle nails and thinning of the nail plate.",
    signs: [
      "Multiple small pits on nails",
      "Rough or brittle nail surface",
      "Discoloration",
      "Possible thinning of nail",
    ],
  ),

  "Yellow Nail": DiseaseInfo(
    name: "Yellow Nail",
    image: "assets/images/yellownail.jpg",
    description:
        "Yellow nail syndrome is associated with respiratory disease, lymphedema, and systemic conditions that impair circulation and immune function. It is characterized by yellow discoloration of the nails, along with slow growth and thickened curvature. This syndrome may be a sign of underlying chronic respiratory conditions, such as bronchiectasis or asthma.",
    signs: [
      "Strong yellow discoloration",
      "Slow nail growth",
      "Thickened curvature",
      "Possible swelling of legs or arms",
    ],
  ),

  "White Nail": DiseaseInfo(
    name: "White Nail",
    image: "assets/images/whitenail.jpg",
    description:
        "White nails (leukonychia) are often a sign of liver disease, anemia, or zinc deficiency. The nails may develop white patches or become entirely white, indicating a possible systemic condition. Brittle nails and slow recovery are common, and white nails can also result from trauma or nail infections. It’s important to monitor changes in nail color as they can signal serious health problems.",
    signs: [
      "White patches or full nail whitening",
      "Brittle nail texture",
      "Possible ridges",
      "Slow nail recovery",
    ],
  ),

  "Beau’s line": DiseaseInfo(
    name: "Beau’s Lines",
    image: "assets/images/beausline.jpg",
    description:
        "Beau's lines are horizontal indentations that form across the nail plate, often caused by trauma, illness, or nutritional deficiencies. These lines appear when nail growth is temporarily halted due to a health crisis. They may span the entire width of the nail and could indicate a systemic condition such as severe infection, fever, or stress-induced changes.",
    signs: [
      "Deep horizontal grooves",
      "Interrupted nail growth",
      "Ridges spanning nail width",
      "History of illness or stress",
    ],
  ),

  "Koilonychia": DiseaseInfo(
    name: "Koilonychia",
    image: "assets/images/koilonychia.jpg",
    description:
        "Koilonychia, commonly known as spoon nails, is often associated with iron deficiency anemia or chronic conditions that affect nutrition. The nails appear concave or spoon-shaped and may become thin or fragile. Koilonychia is a visible indicator of an underlying health condition, and is often accompanied by symptoms like fatigue, dizziness, or pallor.",
    signs: [
      "Spoon-shaped nail curvature",
      "Thin fragile nails",
      "Pale or whitish color",
      "Possible fatigue (connected symptom)",
    ],
  ),
};