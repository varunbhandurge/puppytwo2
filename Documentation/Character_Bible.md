# CHARACTER DESIGN BIBLE
# TWO PUPPIES: THE GREAT ADVENTURE

**Document Version:** 1.0.0  
**Artistic Target:** Stylized 3D Animated Feature Film Quality (Pixar / Illumination aesthetic)  
**Characters:** Bruno (Golden Retriever Pup) & Milo (Tri-Color Corgi Pup)  

---

## 1. CHARACTER PROFILES & PSYCHOLOGY

### 1.1 Bruno — "The Brave Heart"
- **Breed:** Golden Retriever Puppy (approx. 4 months old).
- **Physical Proportions:** Sturdy, barrel-chested, slightly oversized floppy paws that he hasn't fully grown into, warm rounded snout, long soft feathered tail with an expressive upward curl, floppy triangular ears.
- **Color Palette:**
  - Primary Coat: Warm Golden Wheat (`#F4C46A`)
  - Chest & Belly Undercoat: Cream Ivory (`#FFF4DD`)
  - Nose & Paw Pads: Soft Matte Charcoal Charcoal (`#2B2A29`)
  - Eyes: Deep Liquid Amber Brown (`#5A3112`) with oversized catchlights.
  - Collar: Royal Red Woven Nylon with polished brass bell (`#D12E2E`).
- **Personality & Arc:**
  - Bruno is enthusiastic, intensely loyal, instinctively courageous, but prone to comedic clumsiness. If a fence looks high, he tries to leap over it and tumbles over his own paws.
  - He deeply admires Milo's sharp intellect and feels a protective duty toward his smaller companion.
  - *Character Flaw:* Impatience. He acts before thinking, often getting stuck in tight spots that Milo must solve.
- **Signature Canine Behaviors:**
  - Whole-body tail wagging when excited.
  - Head tilts (left, then right) when puzzled.
  - Heavy puppy sigh when lying down to wait.
  - Shakes fur vigorously after digging or swimming, spraying particles everywhere.

### 1.2 Milo — "The Little Genius"
- **Breed:** Cardigan Welsh Corgi / Border Collie mix (approx. 4 months old).
- **Physical Proportions:** Compact, low-slung cylindrical body, sturdy short legs, oversized erect bat-ears that twitch independently, rounded heart-shaped fluffy rear, expressive whiskered muzzle.
- **Color Palette:**
  - Primary Coat: Rich Fox Russet (`#C65D29`)
  - Markings: Crisp Snow White blaze on muzzle, chest collar, socks, and tail-tip (`#FFFFFF`)
  - Accent Patches: Velvety Black saddle patch over spine (`#1E1E20`)
  - Eyes: Bright Hazel-Gold (`#D69E2E`) filled with curious luminescence.
  - Collar: Sky Blue woven band with silver bone-shaped tag (`#3A9BDC`).
- **Personality & Arc:**
  - Milo is analytical, observant, cautious, methodical, and wonderfully resourceful. Where Bruno sees a wall to smash, Milo sees a scent trail leading to an unlatched gate.
  - *Character Flaw:* Over-cautiousness. Milo hesitates to make big leaps alone; he relies on Bruno's brave presence to give him courage in dangerous, dark places.
- **Signature Canine Behaviors:**
  - Independent ear swivels reacting to subtle world noises.
  - Intensely focused sniffing posture with nose twitching and sniffing audio cadence.
  - Happy "sploot" (lying flat on belly with back legs stretched out behind).
  - Joyful "tippy-taps" with front paws when anticipating an interaction.

---

## 2. ARTISTIC SPECIFICATIONS & 3D ASSET PIPELINE

### 2.1 3D Model Specifications
- **Poly Budget Target:** 25,000–35,000 triangles per character model (optimized for dual-viewport real-time rendering on RTX 3060).
- **Stylized Proportions:** 1.3x head-to-body scale ratio (evoking animated film appeal without entering chibi territory), 1.2x paw scale for grounded physical presence.
- **Facial Rigging Topology:** Edge loops surrounding eye sockets and muzzle allowing extreme squash-and-stretch cartoon deformers (wide surprise eyes, squinty happy smiles, drooping sorrowful brows).

### 2.2 Material & Shader Architecture
1. **Fluffy Stylized Fur Shader:**
   - Multi-pass shell/fin rendering or custom stylized PBR with anisotropic specular highlight and subsurface scattering (SSS) for warm light bleed through ears and coat contours.
2. **Eye Shader:**
   - Parallax refraction for deep cornea, oversized specular catchlight, dynamic pupil dilation (widens in dark areas, constricts in bright sunlight), dynamic eye-tracking to look towards partner or points of interest.
3. **Dynamic Wetness & Dirt Shading:**
   - Dynamic vertex-color mask: Paws and snout gain mud/dirt during digging; fur gains wet specular gloss when emerging from water, drying off with a fur shake.

---

## 3. FULL ANIMATION MATRIX (25 CORE ANIMATIONS + CO-OP INTERACTIONS)

| Animation Name | Description & Emotional Expression | Bruno Specifics | Milo Specifics |
| :--- | :--- | :--- | :--- |
| **1. Idle (Calm)** | Gentle breathing, subtle tail swish | Panting tongue, heavy blinks | Alert head, twitching ears |
| **2. Idle (Fidget)** | Canine natural idle behavior | Scratches ear with hind paw | Sniffs ground, does a tippy-tap |
| **3. Walk** | 4-beat lateral quadruped gait | Sturdy, buoyant stride | Rapid, brisk, adorable waddle |
| **4. Run / Trot** | 2-beat diagonal suspension gait | Athletic, long bounding strides | High-cadence energetic hustle |
| **5. Sprint** | Full gallop with spine flexing | Powerful leaps, ears flying back | Streamlined low sprint |
| **6. Jump (Takeoff)** | Coils hind legs and springs | Deep squat, heavy launch | Snappy, spring-loaded hop |
| **7. Fall / In-Air** | Paw paddling, ears fluttering | Wide splayed legs | Aerodynamic forward dive |
| **8. Land** | Soft deceleration with weight squash | Thuds slightly, recovers clumsily | Crisp 4-paw stick |
| **9. Dig** | Alternating front paws excavating dirt | Dirt sprays 3 meters backwards | Precision targeted scratch |
| **10. Bark / Vocalize** | Chest expansion and vocal impulse | Deep resonant forward "Woof!" | Sharp, cheerful "Yip-Yap!" |
| **11. Sniff / Scent** | Nose down to terrain, rhythmic twitch | Casual inquisitive sniff | Deep tracking posture, glow FX |
| **12. Sit** | Haunches resting on ground | Relaxed sit with leaning posture | Upright, regal, poised sit |
| **13. Sleep / Rest** | Curled up or stretched out | Curled into a golden donut | Complete belly-flat "sploot" |
| **14. Swim** | Doggy paddle in water volume | Strong chest stroke, high head | Rapid paddle, buoyant tail rudder|
| **15. Slide** | Sliding down mud or polished slope | Slides on hindquarters smiling | Surfs on belly with ears pinned |
| **16. Climb** | Scrambling up low ledge | Muscle pull with chin resting | Scrambles with quick back kicks |
| **17. Push** | Forepaws against heavy object | Leans entire body weight forward | Braces back legs, grunts softly |
| **18. Pull** | Teeth clenched on rope or handle | Backpedals with braced hind legs | Tugs in rhythmic backward jerks |
| **19. Carry** | Holding object in jaws | Carries large sticks proudly | Carries small keys delicately |
| **20. Help (Revival)** | Nudges fallen partner with snout | Gentle, persistent muzzle nudges | Frantic licking and whines |
| **21. Celebrate** | Joyful victory dance | Spontaneous spin and bow | Front-paw stomps and tail blur |
| **22. Hug / Snuggle** | Mutual cooperative embrace | Wraps neck over Milo gently | Nuzzles into Bruno's chest |
| **23. Fear / Caution** | Back arched, tail tucked | Low stance, watchful growl | Crouched low, wide fearful eyes |
| **24. Surprise / Startle** | All 4 paws leave ground vertically | Comic backward stumble | Crisp vertical popcorn hop |
| **25. Sadness / Whimper** | Ears dropped flat, sorrowful eyes | Slow head droop, soft whimper | Sits close to Bruno, paw on leg |

---

## 4. TACTILE COOPERATIVE INTERACTIONS

1. **Snout Boost (Vertical Ascension):**
   - Bruno enters a lowered braced stance (`Interact` hold).
   - Milo approaches Bruno's rear/back and presses `Jump`.
   - Bruno thrusts his head/back upward, launching Milo an additional 2.5 meters vertically to reach high shelves, ledges, or rope cords.
2. **Synchronized Rope Haul:**
   - Both puppies clamp teeth onto paired rope handles.
   - Players coordinate rhythmic tugging (matching audio prompts) to raise a heavy garden gate or bucket.
3. **Mutual Nuzzle (Revival Mechanic):**
   - If either puppy is stunned or trapped by an enemy/hazard, the surviving puppy approaches and presses `Interact`.
   - An affectionate nuzzle and tail wag dispels the stun in 1.2 seconds, restoring full stamina and granting a brief speed boost.
4. **Partner Look-At & Proximity Awareness:**
   - Procedural head-look inverse kinematics (IK) automatically turns each puppy's head toward the other when within 6 meters, reinforcing the constant emotional connection between them.
