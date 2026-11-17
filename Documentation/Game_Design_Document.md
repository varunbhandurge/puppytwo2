# GAME DESIGN DOCUMENT (GDD)
# TWO PUPPIES: THE GREAT ADVENTURE

**Project Working Title:** Two Puppies: The Great Adventure  
**Genre:** Premium 3D Cooperative Adventure, Puzzle-Platformer, Action-Exploration  
**Target Platform:** Windows PC (Baseline: Ryzen 5 9600X, 32GB RAM, RTX 3060 12GB)  
**Future Platforms:** PlayStation 5, Xbox Series X|S, Nintendo Switch 2  
**Target Player Audience:** Co-op pairs (friends, couples, families, streamers), fans of *It Takes Two*, *Brothers*, *A Way Out*, and Pixar/Illumination animation films.  
**ESRB / PEGI Rating Target:** E10+ / PEGI 7 (Wholesome, humorous, emotionally resonant, mild cartoon peril).  

---

## 1. VISION & CORE PILLARS

### 1.1 Tagline & Promise
> *"Two Puppies. One Extraordinary Adventure. A Friendship that Makes the Impossible Possible."*

### 1.2 The Three Design Pillars
1. **Uncompromising Cooperative Interdependence:**  
   Every challenge requires both puppies. There is no passive "Player 2" riding along or holding a flashlight. Every puzzle, traversal gate, and boss encounter is designed as a complementary two-part lock where Bruno and Milo hold the distinct keys.
2. **Monumental Micro-Scale World:**  
   The world is experienced from the perspective of an 11-inch puppy. A lawn sprinkler is a rotating water cannon; a discarded garden glove is a bouncy hammock; an overflowing kitchen sink is a stormy Niagara Falls. Environments are vibrant, stylized, tactile, and full of animated character.
3. **Heartwarming Canine Physicality:**  
   The joy of play comes from authentic puppy behavior: tail-wagging, happy yawns, digging with dirt flying behind paws, sneezing after sniffing dust, joyful barking, ear flutters, and loving snuggles. The bond between the characters grows mechanically and emotionally.

---

## 2. THE PROTAGONISTS

### 2.1 Bruno — The Golden Retriever Pup
- **Visual Profile:** Golden-honey fluffy coat, slightly oversized paws, floppy triangular ears, warm brown expressive eyes, sturdy chest, athletic build.
- **Personality:** Brave, impulsive, warm-hearted, fiercely loyal, occasionally clumsy, always eager to protect Milo.
- **Signature Mechanics:**
  - *Mighty Dig:* Rapidly excavates soft earth, uncovering buried objects, tunnel mouths, and bone fragments.
  - *Heavy Push & Pull:* Uses snout and chest to push heavy crates, rocks, and logs; grips ropes in jaw to haul counterweights.
  - *Booming Bark:* A deep, cheerful, resonant bark that stuns small critters, activates acoustic switches, and draws enemy aggro away from Milo.
  - *Snout Boost:* Lowers head so Milo can leap onto his back and jump up to double height.

### 2.2 Milo — The Tri-Color Corgi Pup
- **Visual Profile:** Red, white, and black patterned coat, iconic large pointed bat-ears, short athletic legs, fluffy heart-shaped rear, bright amber observant eyes.
- **Personality:** Inquisitive, observant, cautious, clever, agile, meticulous problem-solver.
- **Signature Mechanics:**
  - *Keen Scent (Scent-o-Vision):* Activates olfactory focus to track colorful, aromatic scent trails in the air leading to hidden switches, buried treasures, and safe paths.
  - *Low Crawl:* Flattens belly to slip beneath fences, through drain pipes, between kitchen cabinet baseboards, and into animal burrows.
  - *Precision Leap & Scramble:* High agility, tight turning radius, ability to scramble across narrow fences and precarious balance beams.
  - *Mechanism Toggle:* Uses nose boops and paw presses to flick electrical switches, pull hanging pull-cords, and route gears.

---

## 3. GAMEPLAY LOOPS

### 3.1 Moment-to-Moment Core Loop (30 Seconds)
- Observe environmental obstacle → Identify complementary roles (Bruno strength/dig vs. Milo agility/scent) → Communicate with partner → Execute coordinated action (e.g., Bruno pushes crate to fence, Milo crawls through gap, pulls release lever) → Visual & audio celebration (tail-wagging, happy bark) → Progress to next zone.

### 3.2 Chapter Loop (60–90 Minutes)
- Narrative intro cutscene → Establish new environment & new chapter-specific mechanic → Environmental exploration & introductory puzzles → Escalating cooperative challenge & mini-game distraction → Climax boss confrontation requiring chapter mechanics → Emotional narrative payoff & transition to next world.

---

## 4. CONTROLS & INPUT SCHEME

The game supports simultaneous Dual Controller (XInput / DirectInput / DualSense / Xbox Controller) and Keyboard + Mouse / Split-Keyboard configurations.

| Action | Gamepad (Xbox / PS Layout) | Keyboard + Mouse (Default P1) | Keyboard Alternative (P2 Co-op) |
| :--- | :--- | :--- | :--- |
| **Move** | Left Stick | W / A / S / D | Up / Down / Left / Right |
| **Camera Orbit** | Right Stick | Mouse Move | I / J / K / L |
| **Jump** | Button South (A / Cross) | Spacebar | Numpad 0 |
| **Interact / Bite / Carry**| Button West (X / Square) | E / Left Mouse Click | Numpad 1 |
| **Bark / Vocalize** | Button North (Y / Triangle) | Q / Middle Mouse Click | Numpad 2 |
| **Special (Dig/Scent/Crawl)**| Button East (B / Circle) | Left Shift / Right Mouse | Numpad 3 |
| **Crouch / Low Crawl** | Left Trigger (LT / L2) | Left Ctrl | Numpad . |
| **Sprint** | Left Stick Click (L3) / RB | Left Shift (Hold) | Right Ctrl |
| **Emote / Hug / High-Five**| D-Pad Up / Down | 1 / 2 | Numpad 5 / 6 |
| **Pause Menu** | Start / Options | Escape | Numpad Enter |

---

## 5. DYNAMIC SPLIT-SCREEN & CAMERA SYSTEM

1. **Adaptive Split-Screen Modes:**
   - **Vertical Split (Default):** Screen divided down the middle (50% left for P1 Bruno, 50% right for P2 Milo). Ideal for broad horizontal exploration.
   - **Horizontal Split:** Screen divided into top (P1) and bottom (P2). Ideal for vertical platforming chapters (e.g., Mountain of Bones, Giant Kitchen shelves). User-switchable in settings at any time.
   - **Dynamic Fusion (Single Screen):** When both puppies are within 4.5 meters of each other in the same open space, the dividing bar smoothly dissolves and both viewports blend into a shared cinematic third-person framing. When players move apart, the divider softly reappears and rotates based on player orientation.
2. **Partner Silhouette & Out-of-Frame Indicator:**
   - If Bruno is occluded by a wall or terrain from Milo's view, Bruno is rendered with a warm golden rim outline through geometry.
   - Milo is rendered with a cyan-blue rim outline.
   - Off-screen arrows on the edge of each viewport indicate the direction and distance to the partner.

---

## 6. FULL CHAPTER SYNOPSIS & PROGRESSION

The game features **8 major chapters**, totaling 10–15 hours of narrative-driven cooperative gameplay:

1. **Chapter 1: The Backyard (Tutorial & Foundations)**
   - *Theme:* Domestic sanctuary, golden hour sunlight, overgrown grass, garden shed, patio.
   - *New Mechanics:* Basic movement, jumping, digging, pushing, barking, scent trail introduction.
   - *Boss:* The Mechanical Sprinkler (Rotating brass hazard with pressure-plate puzzle).
2. **Chapter 2: The Forgotten Garden (Wilderness Discovery)**
   - *Theme:* Dense flowerbeds, thick brambles, old greenhouse, broken wheelbarrows.
   - *New Mechanics:* Snout boosting, rope tugging, pollen cloud stealth, crawl tunnels.
   - *Boss:* Whiskers the Menace (The neighbor's terrifying, graceful calico cat).
3. **Chapter 3: The Giant Kitchen (Domestic Obstacle Course)**
   - *Theme:* Linoleum expanses, towering counters, bubbling soup pots, giant refrigerator.
   - *New Mechanics:* Magnetic refrigerator magnets, stovetop steam geysers, sponge slides.
   - *Boss:* The Kitchen Appliance Monster (Rogue robotic vacuum & blender fusion).
4. **Chapter 4: The Forest of Giants (Ancient Woods)**
   - *Theme:* Towering redwoods, mossy logs, rushing streams, hollow trees, fireflies.
   - *New Mechanics:* Swimming & log balancing, hollow log rolling, firefly light navigation.
   - *Boss:* The Ancient Forest Crow (Aerial menace dropping pinecone bombs).
5. **Chapter 5: The Riverlands (Aquatic Adventure)**
   - *Theme:* Whitewater rapids, lilypad cascades, weeping willows, beaver dams.
   - *New Mechanics:* Two-player raft paddling, water wheel powering, mud slides.
   - *Boss:* The Grand River Bullfrog (Territorial aquatic titan).
6. **Chapter 6: The Toy Factory (Mechanical Wonderland)**
   - *Theme:* Conveyor belts, clockwork gears, plush stuffing machines, toy trains.
   - *New Mechanics:* Magnetized spring-collars, wind-up key carrying, conveyor belt reversing.
   - *Boss:* The Clockwork Toy Titan (Multi-armed assembly-line guardian).
7. **Chapter 7: The Dark Underground (Mystery & Courage)**
   - *Theme:* Crystal caverns, glowing mushrooms, abandoned railway mine, deep echoes.
   - *New Mechanics:* Scent-guided subterranean trails, bioluminescent bulb illumination, acoustic echo triggers.
   - *Boss:* The Mole King (Subterranean burrower causing cave-ins).
8. **Chapter 8: The Mountain of Bones (Mythic Climax & Heart)**
   - *Theme:* Windswept alpine cliffs, golden aurora skies, ancient canine monument.
   - *New Mechanics:* Glider kite flight, extreme vertical cooperative scaling, mutual sacrifice and ultimate rescue.
   - *Final Encounter:* The Mountain Guardian & The True Secret of the Legendary Bone.

---

## 7. COLLECTIBLES & OPTIONAL CONTENT

1. **Golden Bone Artifacts (64 Total, 8 per chapter):**
   - Hidden in intricate cooperative secret alcoves. Unlocks concept art, puppy skin variants (bandanas, bowties, booties), and behind-the-scenes developer commentary.
2. **Wholesome Puppy Activities (Mini-Games):**
   - *Puppy Racing:* Obstacle sprint down garden terraces.
   - *Tug-of-War:* Dynamic button mash & rhythm contest with a squeaky rope toy.
   - *Fetch Mania:* Catch tennis balls launched from erratic ball machines.
   - *Mud Puddle Splashing:* Synchronized puddle stomping for highest splash score.
   - *Hide-and-Seek:* One puppy hides scent markers while the other uses Scent-o-Vision against the clock.

---

## 8. USER INTERFACE & EXPERIENCE (UI/UX)

- **Minimal Diegetic HUD:** No health bars or numbers cluttering the screen. Puppy state is communicated through physical posture: energetic bounce (full stamina/happy), panting/drooping ears (tired/alert), shivering (danger/chilled).
- **Objective Pointers:** A simple tap of the Bark button emits a subtle canine thought-bubble icon directing the player towards the current cooperative objective.
- **Full Settings Suite:**
  - Split-screen orientation: Vertical, Horizontal, or Dynamic Auto-Merge.
  - Subtitles with speaker color coding (Gold for Bruno, Cyan for Milo, White for Narrator).
  - Remappable controller & keyboard keys.
  - Camera sensitivity, invert X/Y axes, screen-shake toggle, colorblind filters (Protanopia, Deuteranopia, Tritanopia).
  - Assist Mode: Generous puzzle hint timers, infinite stamina, and reduced platforming fall penalties.
