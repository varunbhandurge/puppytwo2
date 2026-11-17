# WORLD DESIGN SPECIFICATION
# TWO PUPPIES: THE GREAT ADVENTURE

**Document Version:** 1.0.0  
**Visual Target:** Stylized Animated Film Realism (Grounded physics + Whimsical warmth + Vibrant painterly palettes)  
**Atmospheric Engine:** Godot 4 Forward+ (Volumetric Fog, SDFGI Dynamic Global Illumination, Custom Light Scattering)  

---

## 1. THE MICRO-SCALE WORLD PHILOSOPHY

The foundational rule of world design in *Two Puppies* is **The Puppy Perspective Shift**:
Every environment must be conceptualized not as human spaces, but as mythic landscapes viewed from an eye height of 10–12 inches off the ground.

| Ordinary Human Object | Puppy Perspective Reality | Gameplay Function |
| :--- | :--- | :--- |
| **Lawn Sprinkler** | A rotating bronze fortress spraying geysers of water | Hazard zone requiring timed pressure-plate neutralization |
| **Garden Hose** | An enormous serpentine python coiled across the yard | Traversal walkway; biting the nozzle opens water jets |
| **Flower Pots** | Colossal terra-cotta ziggurats | Vertical platforming tiers requiring snout-boosting |
| **Kitchen Baseboard Gap** | A secret cavernous crawl tunnel | Milo-only shortcut leading behind human counters |
| **Cardboard Box** | A multi-chamber dungeon fortress | Physics push puzzle; opening flaps creates ramps |
| **Drainage Culvert** | A roaring subterranean echo-chamber | Acoustic puzzle where Bruno's bark resonates to trigger echoes |
| **Fallen Pinecone** | A spike-studded boulder | Movable counterweight or throwable projectile |

---

## 2. COLOR SCRIPT & LIGHTING ARCHITECTURE

The emotional arc of the game is mirrored directly in the world's color script and lighting conditions:

1. **Acts I & II (Backyard & Forgotten Garden):**
   - *Lighting:* Warm golden hour sunlight (3200K), soft dappled shadows through giant ferns, floating dust motes and dandelion fluff.
   - *Palette:* Emerald greens, dandelion yellows, terra-cotta reds, warm golden amber.
2. **Act III (The Giant Kitchen):**
   - *Lighting:* High-key domestic interior, bright morning kitchen window beams, warm incandescent pendant lamps, cool reflections off polished stainless steel.
   - *Palette:* Checkerboard cream-and-navy linoleum, chrome silver, strawberry jam reds, copper pots.
3. **Acts IV & V (Forest of Giants & Riverlands):**
   - *Lighting:* Twilight turning to moonlit silver, bioluminescent fireflies, sparkling sunbursts through river mist.
   - *Palette:* Deep moss green, cedar bark brown, sapphire water, electric cyan fireflies.
4. **Acts VI & VII (Toy Factory & Dark Underground):**
   - *Lighting:* Dramatic contrasting industrial warm neon vs. deep violet subterranean crystals, warm glowing lantern checkpoints.
   - *Palette:* Brass gold, cobalt steel, glowing amethyst, luminescent mushroom teal.
5. **Act VIII (The Mountain of Bones):**
   - *Lighting:* Ethereal alpine sunrise, golden solar flare breaking through swirling violet clouds, iridescent aurora trails.
   - *Palette:* Pristine snow white, twilight violet, radiant golden sunrise glow.

---

## 3. ENVIRONMENTAL INTERACTION & PHYSICS PROPERTIES

1. **Deformable Terrains & Surfaces:**
   - *Soft Soil / Loam:* Depresses under paw-steps; Bruno can excavate holes up to 1.5 meters deep.
   - *Mud Puddles:* Reduces movement speed by 25%; causes comedic sliding when sprinting; leaves muddy paw-prints on clean surfaces for 15 seconds.
   - *Water Volumes:* Shallow water (paws submerged) causes splashing audio; deep water triggers doggy-paddling buoyancy physics.
2. **Tactile Foliage & Physics Props:**
   - Giant blades of grass bend and part smoothly as puppies walk through them using vertex-shader wind and player-proximity push vectors.
   - Dandelion heads burst into floating seed particles when touched or barked at.
   - Piles of autumn leaves scatter dynamically when dashed into.
