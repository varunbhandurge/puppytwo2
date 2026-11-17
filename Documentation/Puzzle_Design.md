# PUZZLE DESIGN SPECIFICATION: 30+ COOPERATIVE PUZZLES
# TWO PUPPIES: THE GREAT ADVENTURE

**Document Version:** 1.0.0  
**Framework:** Reusable Data-Driven State Machine (`PuzzleBase.gd`)  
**Design Mandate:** Zero passive spectator roles. Both players must actively participate in every stage.  

---

## 1. THE DATA-DRIVEN PUZZLE ARCHITECTURE

All puzzles in the game inherit from `PuzzleBase.gd` and maintain an explicit state machine:
- `STATE_IDLE`: Initial dormant state awaiting player proximity.
- `STATE_ACTIVE`: In progress; tracking stage counters and player inputs.
- `STATE_STAGE_SUCCESS`: A sub-stage is resolved; triggers audio chime and partial environmental animation.
- `STATE_SOLVED`: Final completion; unlocks progression gate, disables hazards, drops reward.
- `STATE_RESETTING`: Graceful rollback if a player falls or a timed sequence expires; zero instant kill or punitive soft-locks.

---

## 2. THE 10 PUZZLE CATEGORIES & 32 ORIGINAL CONCEPTS

### CATEGORY 1: WEIGHT & BALANCE PUZZLES

#### Puzzle 01: The Sunken Bone Crate (Chapter 1)
- **Objective:** Raise a waterlogged wooden crate trapped in a mud pit to breach a high garden fence.
- **Required Abilities:** Bruno Mighty Dig & Heavy Push; Milo Precision Jump & Snout Boost.
- **Player A (Bruno) Role:** Digs out clay suction around the crate base, then pushes a stone counterweight.
- **Player B (Milo) Role:** Climbs the raised seesaw arm, jumps onto the crate, and unlatches the rusted top clasp.
- **Stages:**
  1. Bruno digs 3 mud spots around crate base (Mud particle burst).
  2. Bruno pushes a heavy cobblestone onto the lowered seesaw beam.
  3. Milo is propelled up to the crate lid, releasing the latch.
- **Feedback:** Thudding stone audio, splashing mud, wooden creak, triumphant brass bell chime.
- **Failure Handling:** If Milo falls, soft mud cushions him; seesaw stays locked in position.
- **Completion Condition:** Crate lid pops open, revealing a ramp leading over the fence.

#### Puzzle 02: The Terracotta Seesaw (Chapter 2)
- **Objective:** Balance a wooden plank across a broken flowerpot to reach a hanging garden trellis.
- **Required Abilities:** Bruno Heavy Push; Milo Scent Tracking.
- **Bruno Role:** Hauls two heavy clay pot shards to counter-balance the heavy end.
- **Milo Role:** Scents the weak point of the plank and stands on the elevated tip.
- **Stages:** Scent reveal → Bruno hauls weight → Milo steps onto the balanced platform.

#### Puzzle 03: The Kitchen Scale Counterweight (Chapter 3)
- **Objective:** Weigh down a giant vintage mechanical kitchen scale to lift an upper spice shelf.
- **Required Abilities:** Bruno Push; Milo Crawl & Object Carry.
- **Bruno Role:** Pushes a solid bag of flour onto the weighing pan.
- **Milo Role:** Crawls through the cupboard to drop three apples from above onto the pan.

---

### CATEGORY 2: TIMING & SYNCHRONIZATION PUZZLES

#### Puzzle 04: The Mechanical Sprinkler Bridge (Chapter 1)
- **Objective:** Cross an open stone patio swept by high-pressure rotating water jets.
- **Required Abilities:** Bruno Snout Boost & Pressure Plate Hold; Milo Agile Dash & Valve Toggle.
- **Bruno Role:** Holds down a heavy brass shutoff pedal, temporarily cutting 50% of the water pressure for 8 seconds.
- **Milo Role:** Sprints through the reduced water spray to bite and turn the brass hose cock, shutting the valve permanently.
- **Stages:** Step onto pressure plate → Milo sprints and avoids remaining jet → Valve turned → Spray ceases.
- **Feedback:** Gushing water audio, warning whistle before pressure re-engages, satisfying valve clunk.
- **Failure Handling:** Water jet pushes Milo back to the start without damage; Bruno simply re-steps on the pedal.
- **Completion Condition:** Sprinkler stops spinning; safe crossing opened.

#### Puzzle 05: The Stovetop Steam Geysers (Chapter 3)
- **Objective:** Time leaps across four steaming saucepans on a glowing range top.
- **Required Abilities:** Bruno Bark distraction; Milo Precision Hop.
- **Bruno Role:** Barks at temperature knobs below the counter to cycle steam venting intervals.
- **Milo Role:** Memorizes the venting rhythm and hops across lid handles during cooling windows.

#### Puzzle 06: The Clockwork Gear Synchronizer (Chapter 6)
- **Objective:** Align three rotating brass gears to bridge a factory chasm.
- **Required Abilities:** Synchronized dual-button holds.
- **Bruno & Milo Role:** Each puppy bites an opposing clutch lever, holding them down simultaneously within a 0.5s window to lock the gear teeth.

---

### CATEGORY 3: SCENT & STEALTH PUZZLES

#### Puzzle 07: The Bramble Maze & Scent Trail (Chapter 1 / 2)
- **Objective:** Navigate an impenetrable maze of thorny blackberry vines in thick morning fog.
- **Required Abilities:** Milo Scent-o-Vision; Bruno Booming Bark & Obstacle Shove.
- **Milo Role:** Activates Scent-o-Vision to reveal a vibrant violet aromatic ribbon through safe openings.
- **Bruno Role:** Follows Milo's barking calls; smashes through dead, brittle thorn patches blocking Milo's path.
- **Stages:** Scent path tracking → Call partner → Clear brittle obstruction → Reach maze exit.
- **Feedback:** Glowing shimmering particle ribbons, sniffing audio, crumbling dry thorn sound.
- **Failure Handling:** Touching live brambles causes a startled yelp and backs puppy up 1 meter.
- **Completion Condition:** Both puppies reach the greenhouse archway.

#### Puzzle 08: The Sleeping Hound's Blanket (Chapter 2)
- **Objective:** Retrieve a gate key resting on a sleeping Saint Bernard’s paws without waking him.
- **Required Abilities:** Milo Low Crawl & Silent Step; Bruno Distraction Bark.
- **Bruno Role:** Barks from the far end of the yard when the hound stirs, drawing his sleepy gaze away.
- **Milo Role:** Crawls silently across the wooden deck to grasp the key in his teeth.

#### Puzzle 09: The Subterranean Crystal Sniff (Chapter 7)
- **Objective:** Find the single unstable crystal wall in a pitch-black cave using scent.
- **Required Abilities:** Milo Olfactory Tracking; Bruno Sonic Bark.
- **Milo Role:** Scents the sulfur aroma leaking from the cracked vein and marks it with a scratch.
- **Bruno Role:** Delivers a maximum-volume sonic bark directly at the marked point to shatter the wall.

---

### CATEGORY 4: ACOUSTIC & SOUND PUZZLES

#### Puzzle 10: The Resonance Culvert Pipes (Chapter 1)
- **Objective:** Tune three corrugated drainage pipes to open an acoustic pressure gate.
- **Required Abilities:** Bruno Pitch Bark; Milo Pipe Plugger.
- **Bruno Role:** Barks into the main pipe intake to generate acoustic standing waves.
- **Milo Role:** Crawls into side inspection ports to drop rubber ball baffles, tuning the pitch.

#### Puzzle 11: The Greenhouse Windchimes (Chapter 2)
- **Objective:** Play a 4-note melodic sequence to awaken a sleepy barn owl who holds a rope ladder.
- **Required Abilities:** Synchronized running and jumping into hanging brass rods.

#### Puzzle 12: The Crystal Cavern Echo (Chapter 7)
- **Objective:** Trigger crystal bells in a timed echo sequence across a wide subterranean chasm.

---

### CATEGORY 5: LIGHT & SHADOW PUZZLES

#### Puzzle 13: The Firefly Acorn Lantern (Chapter 4)
- **Objective:** Navigate a pitch-dark hollow trunk infested with shadow spiders.
- **Required Abilities:** Milo Scent Gathering; Bruno Lantern Carrier.
- **Milo Role:** Catches bioluminescent fireflies in an acorn cup using quick pounces.
- **Bruno Role:** Carries the glowing lantern in his jaws, projecting a 6-meter safety radius of light that disperses spiders.

#### Puzzle 14: The Solar Mirror Prism (Chapter 2)
- **Objective:** Direct sunlight through broken greenhouse glass to burn away a thick weed net.
- **Bruno Role:** Pushes a brass mirror stand.
- **Milo Role:** Cleans dust off the focusing magnifying lens with tail swishes.

#### Puzzle 15: The Crystal Light Refraction (Chapter 7)
- **Objective:** Align four rotating crystal prisms to bounce a beam of colored light onto a door sigil.

---

### CATEGORY 6: WATER & FLUID DYNAMICS

#### Puzzle 16: The Beaver Sluice Gate (Chapter 5)
- **Objective:** Divert a raging river torrent into a side canal to expose a stepping-stone path.
- **Required Abilities:** Bruno Heavy Tug; Milo Sluice Pin Puller.
- **Bruno Role:** Pulls a heavy submerged driftwood log against the river current.
- **Milo Role:** Slips between narrow rocks to pull the wooden locking pin.

#### Puzzle 17: The Leaky Garden Hose Siphon (Chapter 1)
- **Objective:** Fill an empty bucket to raise a floating wooden toy boat platform.
- **Bruno Role:** Bites down on the kink in the hose to build water pressure.
- **Milo Role:** Aims the brass nozzle directly into the bucket until full.

#### Puzzle 18: The Kitchen Sink Overflow (Chapter 3)
- **Objective:** Stop an overflowing sink drain to float a sponge raft to the soap dispenser counter.

---

### CATEGORY 7: ENVIRONMENTAL MANIPULATION

#### Puzzle 19: The Hollow Redwood Treadmill (Chapter 4)
- **Objective:** Roll an enormous hollow log across a ravine to span a 10-meter gap.
- **Required Abilities:** Simultaneous coordinated running inside/on top of the log.
- **Bruno & Milo Role:** Both run forward inside the cylindrical log, keeping pace to prevent it from stalling on rocks.

#### Puzzle 20: The Toy Factory Conveyor Inverter (Chapter 6)
- **Objective:** Reverse high-speed conveyor belts carrying dangerous crushing hammers.
- **Bruno Role:** Uses teeth to pull a heavy overhead power cable.
- **Milo Role:** Squeezes into the electrical fuse box to swap the polarity plugs.

#### Puzzle 21: The Cardboard Fortress Drawbridge (Chapter 1)
- **Objective:** Knock down the cardboard flaps of an appliance box to create ascending ramps.

---

### CATEGORY 8: COOPERATIVE PLATFORMING & BOOSTING

#### Puzzle 22: The Tool Shed High Shelf (Chapter 1)
- **Objective:** Reach a hanging rope ladder 3 meters off the shed floor.
- **Required Abilities:** Snout Boost & Ladder Drop.
- **Bruno Role:** Braces posture; launches Milo up to the shelf rim.
- **Milo Role:** Scrambles along the narrow shelf and kicks down a coiled coil of yellow twine.

#### Puzzle 23: The Refrigerator Door Swing (Chapter 3)
- **Objective:** Swing the giant refrigerator door open using puppy momentum.
- **Bruno Role:** Grasp the magnetic towel hanging from the handle.
- **Milo Role:** Jump onto the door edge, adding weight to break the magnetic seal.

#### Puzzle 24: The Willow Vine Swing (Chapter 5)
- **Objective:** Swing across a raging river chasm using tangled weeping willow vines.

---

### CATEGORY 9: PHYSICS & TRAJECTORY

#### Puzzle 25: The Wheelbarrow Catapult (Chapter 1)
- **Objective:** Launch Bruno onto a raised brick planter bed.
- **Milo Role:** Climbs high onto a wooden trellis and drops a heavy brick onto the wheelbarrow handle.
- **Bruno Role:** Sits in the wheelbarrow bucket, launching into the air at the apex.

#### Puzzle 26: The Wind-Up Toy Springboard (Chapter 6)
- **Objective:** Wind up a giant toy frog spring to catapult both puppies over a safety barricade.
- **Bruno Role:** Turns the heavy iron key 3 full rotations.
- **Milo Role:** Pulls the quick-release catch when both are seated on the frog's back.

#### Puzzle 27: The Kitchen Spatula Trampoline (Chapter 3)
- **Objective:** Bounce in rhythm on a flexible silicone spatula to gain maximum launch height.

---

### CATEGORY 10: COMPLEX MULTI-STAGE COOPERATIVE GATES

#### Puzzle 28: The Greenhouse Irrigation Engine (Chapter 2)
- 4-stage puzzle combining water valves, seed weight, sunlight refraction, and door unlatching.

#### Puzzle 29: The Clockwork Titan Power Cores (Chapter 6)
- Multi-tier puzzle requiring conveyor routing, gear locking, and simultaneous battery insertion.

#### Puzzle 30: The Subterranean Minecart Junction (Chapter 7)
- Dynamic moving puzzle requiring brake management, track switching, and acoustic obstacle clearing.

#### Puzzle 31: The Blizzard Beacon Harmonic (Chapter 8)
- Synchronized thermal huddling, wind resistance, and dual ancient bell ringing.

#### Puzzle 32: The Shrine of the Eternal Bone (Chapter 8)
- The ultimate cooperative trial: Dual pedestal activation where neither puppy can step off without the other; mutual trust unlocks the final sanctum.
