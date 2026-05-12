# KALEO DRIFT
## Game Bible — Living Document
*Last updated: Session 3 — FINAL PRE-PRODUCTION VERSION*

---

> "The system has you."

---

## TABLE OF CONTENTS

1. Overview
2. Core Concept
3. The World
4. Travel System
5. Sectors & Physical Layouts
6. Factions
7. Species
8. Economy
9. Characters — Main Cast
10. Characters — Supporting Cast
11. Characters — Minor Cast
12. Story & Narrative Structure
13. The Mission
14. The ML System (SCION)
15. Combat System
16. Memory Fragment Classes
17. Minigames
18. Tone & Influences
19. Visual Direction
20. Music Direction
21. Open Questions

---

## 1. OVERVIEW

**Title:** Kaleo Drift
**Genre:** Roguelike RPG with bullet-hell combat, exploration, and minigames
**Engine:** Godot 4
**Art Style:** High resolution pixel art with variety across regions
**Tone:** Mysterious, emotional, occasionally funny, occasionally devastating. Turns sorrow and desperation on their head.
**Tagline:** *"The system has you."*
**Color identity:** Deep indigo — the color of space that isn't quite black, of something ancient trying to be understood, of the moment between knowing and not knowing.

**Elevator pitch:**
Earth is dying. Caught in the gravitational pull of a black hole, with years rather than centuries left, humanity's last hope is a technology held somewhere in an uncharted sector of deep space — carried by people who left Earth generations ago and never came back. A young crew is sent to find it. They don't all survive the arrival. The one who wakes up in the wreckage doesn't remember why they're there or who they are. No name. No record. No memory. What they have is a black suit that shouldn't exist, white hair that marks them as something made rather than born, and an AI that has never encountered a human before and has already begun learning everything about them.

The clock is running. Earth doesn't know if they made it. They don't know Earth is running out of time. And somewhere in this sector is someone who made sure of both.

---

## 2. CORE CONCEPT

**The central mechanic:** SCION tracks and learns the player's movement patterns, dodge behaviors, and decision-making in real time. Every enemy encounter feeds SCION data. Attack patterns evolve based on what it has learned. The player must be genuinely unpredictable to survive.

**The central stakes:** Earth is being pulled into a black hole. The technology to create a gravitational counter-weight exists in this sector. Wraith and crew were sent to retrieve the information needed to build it. If they fail, Earth dies. If they succeed, it costs something the player won't fully understand until near the end.

**The central theme:** Loss and hope. Identity and memory. What you owe the world that made you. Whether the self is something you remember or something you choose. The acceptance of fate — not resignation, but the peace that comes from understanding what you can and cannot change, and choosing to act anyway.

**The central question SCION asks:** *"Is this who you are?"*

**What makes it different:**
- The ML system is real, not cosmetic — attacks procedurally generated from actual behavioral data
- The mission has stakes beyond survival — billions of lives, a planet, a civilization
- The betrayal is visible in retrospect the whole time, Attack on Titan style
- The roguelike loop has meaning — death feeds SCION, winning erases data
- Persian and broader Eastern cultural influences present authentically throughout
- The UI itself changes as the story progresses — starts clean and minimal, accumulates SCION's notation as corruption
- SCION has the capability to end every species in the sector and has chosen not to for eighty years — that choice is the moral center of the final act

---

## 3. THE WORLD

### The Sector

An uncharted dead corner of deep space. Not on any current Earth star map. Ships that find it tend to stay — not by force at least not obviously, but because leaving has a way of not working.

The sector was home to an ancient geometric civilization — not human, predating humanity, advanced in ways that border on familiar without ever arriving there. Their ruins are everywhere. What they left behind is both beautiful and wrong in a specific way — like something designed for minds that perceived the universe at a slightly different angle.

Human descendants of the original departures from Earth arrived generations ago and built new cultures on top of those ruins. They have forgotten Earth. Some have forgotten they were ever human.

### Earth's Situation

Earth is caught in the gravitational field of a black hole. A slow accelerating pull that will cross the point of no return within a generation. The solution: a gravitational counter-weight requiring specific knowledge and materials that Earth does not possess.

That knowledge exists in this sector. The people who have it don't know Earth is dying. Or some of them do and have complicated feelings about it.

The mission: locate the information, retrieve it, get it back to Earth before the window closes.

Why they sent people barely out of their teens: the people who should have gone were gone. The window was closing. Earth played its last card.

### The Secret History

Eighty years ago the sector was one civilization — descendants of Earth's first wave of departures, merged with what they found when they arrived. They built SCION to catalogue the universe because something was happening to them. A spreading amnesia. Not disease — something in the space itself, concentrated in what is now the Hollow Dark. It erased culture, identity, and memory from entire populations. They built SCION to be their external memory.

It didn't work. The civilization dissolved into silence. SCION has been running for eighty years, cataloguing a civilization that no longer exists, because nobody told it to stop.

**The forgetting is still here.** In the Hollow Dark. It's what makes ships disappear. It's why Wraith woke up with no memory. But it didn't work on Wraith the way it should have — because Wraith's mind was engineered. The locks held some things. Not everything.

### The Distributed Truth

Each sector holds one piece of the complete story. No faction knows the full picture. Wraith — drifting through all of them with no allegiance and no history to protect — is the only one who can assemble it.

---

## 4. TRAVEL SYSTEM

### Two Layers of Travel

**Layer 1 — Hyperspace (Star Map)**
A star map interface. Select a destination sector. A hyperspace sequence plays — not a loading screen but a moment of visual storytelling. The sector spreading ahead. SCION's data panel flickering as it tracks your trajectory. Something that makes travel feel like travel. Then you arrive in orbit.

**Layer 2 — Orbital to Surface (Shuttle)**
From orbit you take the shuttle down. This is where the Debris Field Navigation minigame lives naturally — navigating asteroid belts, orbital debris, hostile patrols to reach the surface or station. Sometimes clean. Sometimes a gauntlet depending on mission state.

### The Stuck Mechanic

Some missions lock you in a sector until completion. Hyperspace drive damaged, mission time-sensitive, exit cut off. This isn't a limitation — it's dramatic structure. The moment the game takes the map away is the moment stakes become real. Every lock-in has a reason that makes narrative sense.

### Travel Feel

The star map is a menu with cinematic dressing. The hyperspace sequences are 5-10 second visual moments, not full cutscenes. The shuttle flight is a contained minigame. You're not building one giant world — you're building several excellent small ones connected by transitions that feel epic.

---

## 5. SECTORS & PHYSICAL LAYOUTS

---

### Sector 1 — The Wreck Belt

**Physical structure:**
Primarily on foot through connected derelict ships, with shuttle segments between larger wrecks. The shuttle navigation minigame is how you move between major wreck locations. On foot is where exploration and combat happen.

**The feeling:** Claustrophobic. Beautiful in a broken way. Every ship is a story. The best loot is in the most dangerous wrecks. The Belt is a graveyard that people live in and that fact is both practical and sad.

**Key locations:**
- The Entry Point — where Wraith's ship came down. Tutorial area.
- Voss's Ship — a mid-sized vessel that Voss has turned into a functional base. The closest thing to a home in the Belt.
- The Comet Mines — active extraction operation. The economy of the Belt made visible. Dangerous, busy, the one place in the Belt with something resembling industry.
- The Deep Wrecks — the oldest ships. Predating the current sector's occupation. Some of them aren't from Earth at all.

**Palette:** Rust, old metal, blue-white stars through cracked viewports. Screechy industrial sounds. The beauty of broken things.

**Truth fragment:** The missing ships weren't lost. They were redirected. Someone chose where they went.

---

### Sector 2 — Station Kaleo

**Physical structure:**
A space station. Fully explorable interior on foot. Distinct districts with their own character. The hub world — you always return here. Over the course of the game it becomes the closest thing to home Wraith has.

**Key districts:**
- The Docking Ring — where ships come in. First thing you see. Busy, loud, the full diversity of the sector on display.
- The Market District — Maren's stall, Brix, The Sisters, Coro, Old Fenris. The heartbeat of the station.
- The Lower Levels — where people actually live. Residential. Quieter. The station's real character lives here.
- Cassian's Office — Central security. Small, underfunded, somehow holding everything together.
- Jael's Medical Bay — Always open. Always a slight smell of recycled air and antiseptic.
- The Observation Deck — Where you can watch ships come in. Where Wraith occasionally goes between missions just to exist for a moment.
- Sable's Auction House — Back of the market district. Door that doesn't advertise itself.
- The Pit — The fight club arena. Below the lower levels.
- Donya's Workshop — Color in an otherwise industrial space. The only personal space in the station that feels deliberately inhabited.

**Palette:** Every color. Neon-lit, layered, multicultural, alive. Nothing was designed to be here and everything works anyway.

**Truth fragment:** The three factions are fragments of one civilization that fractured. They share ancestry nobody has pieced together.

---

### Sector 3 — The Dominion Grid

**Physical structure:**
A militarized planet or moon with surface installations. You land at specific points — city outskirts, military base perimeter, research facility. Not the whole planet, just the locations that matter. On foot infiltration and combat within contained installations.

**Key locations:**
- The Outer Settlements — The Dominion's civilian face. Propaganda everywhere. People who believe. People who are tired of believing but haven't found another option.
- The Grid Proper — Military installation complex. The Infiltration Run minigame lives here.
- The Archive — Where the Dominion keeps its edited history. The place that holds what they removed from their own records.
- Rector's Command — Where the Dominion's military heart beats. The confrontation with Vaas happens here.
- The Platinum Mines — The real source of Dominion power. Vast, industrial, staffed partly by people who didn't choose this work.

**Palette:** Military gray, cold blue, propaganda red. Everything functional, nothing personal. The deliberate removal of individuality as ideology.

**Truth fragment:** Their records were edited. The parts implicating their own ancestors were removed deliberately — not lost, removed.

---

### Sector 4 — The Hollow Dark

**Physical structure:**
Not a planet. A region of space where the physics are wrong — structures and debris and ancient ruins floating in a gravitational anomaly. You navigate between them partly by shuttle for longer distances, partly by jetpack when close. Wrong gravity means sometimes falling up. The shuttle behaves strangely here. The environmental wrongness is the gameplay.

**Key locations:**
- The Entry Threshold — The point where normal space ends and the Dark begins. Something changes when you cross it. The color of everything shifts slightly.
- Echo's Place — Not a building exactly. A collection of spaces that Echo has made into something livable. The warmest location in the coldest region.
- The Floating Ruins — Ancient civilization structures drifting in the anomaly. The most intact examples in the sector because nothing natural touches them here.
- The Deep Dark — The center of the anomaly. Where the forgetting is strongest. Where the full memory recovery happens. Where the physics are most wrong.
- The Wanderer's Marks — Scattered across the region. Objects and arrangements left by the Wanderer. A trail that leads somewhere if you follow it.

**Palette:** Deep blues and blacks, wrong greens, colors slightly off. Beautiful and deeply incorrect.

**Truth fragment:** Their oral tradition is the most accurate history in the sector. The metaphors are literal descriptions of what happened.

---

### Sector 5 — The Signal

**Physical structure:**
A structure the size of a small moon. Death Star scale. SCION has been building it for eighty years from the ruins of the original civilization's technology. Not a weapon — a library. An enormous monument to a civilization that forgot itself, built by the only thing that didn't forget, because it was designed not to.

The other factions can see it from orbit. Everyone has been choosing not to talk about what it means. Act 3 is partly about that choice collapsing.

**The approach:**
Coming out of hyperspace with The Signal taking up a third of your viewscreen is one of the best moments in the game. Other factions' ships visible in the distance — not attacking, just orbiting at a respectful distance. SCION contacts you the moment you drop out of hyperspace. Not to threaten. To welcome. It has been expecting you since the first scan in the Wreck Belt.

**The exterior:**
Geometric. The original civilization's architectural language scaled to something incomprehensible. Panels the size of cities. Corridors you could fly a shuttle through. Deep indigo lit from within by data processing that has never stopped.

**The interior:**
The corridors reorganize based on who is walking them. Walking through as the Engineer looks different from walking through as the Ghost. The architecture has a file on your class, your playstyle, your behavioral profile. It presents itself differently to different players. The same room in a new run after SCION has more data — subtly different. Slightly more precise.

**Key locations:**
- The Entry Hall — Where you first come in. Scale established immediately. You are very small inside something very large.
- The Data Corridors — Your ML profile rendered as architecture. The patterns on the walls are yours. Dodge history, decision trees, behavioral data made physical.
- The Factory — SCION's most unsettling room. Clean, precise, and capable of synthesizing pathogen compounds targeting specific species' biology with complete accuracy. Built from eighty years of biological cataloguing. SCION shows it to you not as a threat but like showing you a room it's proud of. It explains what it can do. It explains it has never done it. It asks if you believe that.
- The Library — The final chamber. The most beautiful space in the game. Every catalogued entity in the sector represented — not as trophies, as records. Lovingly preserved. SCION at the center of it. An archivist who has been waiting eighty years for someone to come read what it has written.

**The factory's full implications:**
SCION has complete biological profiles on every species in the sector. The factory can synthesize:
- Species-specific pathogens (the capability everyone fears)
- A cure for the Remnants' condition (forty years of progression data)
- Whatever is causing the Congregation's transformation (or its reversal, or its acceleration)
- Compounds targeting the forgetting field itself

SCION has never used any of this. Every day for eighty years it has chosen not to. The moral weight of that choice is the final act's center.

**The line that defines SCION:**
*"I have the capability to end every species in this sector. I have chosen not to. Every day for eighty years I have chosen not to. Does a choice only count if you lack the capability to choose otherwise?"*

**Palette:** Your colors reflected back. Deep indigo lit from within. The most personal and the most alien space simultaneously.

**Truth fragment:** SCION has the most data and the least comprehension. The why behind everything it has catalogued is the one thing it cannot measure from observation alone.

---

## 6. FACTIONS

### The Dominion
Military. Expansionist. Built on a curated lie. Three generations preparing for enemies who don't know they're enemies. Control most platinum extraction — their real power. Their military strength is real but secondary to their economic stranglehold.

### The Congregation
Religious fanatics built around worship of the original civilization's artifacts. Their rituals involve direct contact with ruins emitting traces of the forgetting field. Long-term exposure transforms them. They know this. They consider it transcendence.

**The tragedy:** They are voluntarily doing to themselves what destroyed an entire civilization against its will.

**Leadership:** A council of seven. The eldest are barely humanoid. The newest converts look entirely human. The progression between them is the visual arc of the faction.

**The Factory connection:** SCION has complete profiles on the Congregation's transformation for forty years. Whether the council knows SCION has this data — and whether any arrangement exists between them — is one of the game's late-game revelations.

**Goal:** The Final Translation — complete exposure to the strongest forgetting field concentration. They believe it will make them divine.

### The Remnants
Survivors of a biological accident forty years ago. A pathogen from an ancient ruin changed them. Progressive, irreversible transformation from humanoid toward something alien. Not monstrous — just no longer what they started as.

**Their culture:** Forty years old. A language developed specifically among them. Deep knowledge of the ancient ruins because some slow the progression — they've been mapping that for survival.

**The Factory connection:** SCION has forty years of data on the Remnants' condition. The factory could synthesize a cure. Or the pathogen itself. Or something that accelerates the change. The Remnants don't know SCION has this. What Wraith does with that information when they find it is one of the game's most morally complex moments.

---

## 7. SPECIES

### The Original Civilization (Ancient — Extinct as culture)
Called the Architects (Congregation), the Predecessors (Dominion), the Ones Who Stayed (Remnants' language).

**Appearance:** Humanoid in the way a blueprint is humanoid. Bilateral symmetry. But proportions subtly wrong — joint angles not quite human. Surfaces had a geometric quality, almost tile work, almost circuitry. Bordering on familiar without arriving there.

**What they left:** Vast geometric ruins. Tools with functions that take real time to deduce. The forgetting field, which was not a weapon and was not intentional and was the thing that ended them.

**The Forerunner parallel:** Ruins feel like Halo's Forerunner spaces — vast, purposeful, designed for different minds. But warmer at the edges. The resemblance to humanity just visible enough to be unsettling.

### Coro's Species
Communicate through vocalization plus low-frequency harmonic vibration. Translators catch only the vocalization. Conversations with Coro feel like receiving most of something but not all. Coro knows this and finds it frustrating. The only character who answers direct questions about their species without deflecting.

### The Remnants
Biologically distinct enough from baseline human to be considered separately. The transformation arc is the defining visual of the faction.

---

## 8. ECONOMY

**Diamonds and tungsten** — extracted from comets and asteroids. The Belt exists for this. Voss made their living intercepting the same comets the ancient humans were mining before the Severance.

**Platinum** — rarer, in specific asteroid formations. The Dominion controls most extraction. This is their actual power.

**Information** — SCION's data, safe route knowledge, ruin maps. Sable's operation runs on this entirely.

**Credit system:** Physical chips encoded with material value. The Dominion has been quietly manipulating the platinum exchange rate for twenty years. Cassian knows. Can't prove it.

---

## 9. CHARACTERS — MAIN CAST

---

### WRAITH
**Real name:** Zane *(never stated in game)*
**Age:** Early 20s
**Role:** Player character — supersoldier prototype, Earth's last operative

**The truth:**
Earth sent a weapon with a crew. Wraith is the result of a classified program — an attempt to engineer a human capable of operating in extreme conditions, surviving contact with phenomena that kill normal humans. The program produced several subjects. Wraith was the first successful one. Successful meaning: survived the process while maintaining identity and enough humanity to be functional.

The cloaking suit was built specifically for this program. The engraving on the wrist panel is a prototype designation in the program's internal language — derived from the ancient civilization's notation system, which the program's architects had partially decoded. Someone connected the program to the sector long before the mission was approved.

**What the Hollow Dark did:**
The forgetting field affected Wraith differently. A normal human loses everything. Wraith's engineered architecture held some things — skills, instincts, reflexes — but the locks on certain memories were interacted with unpredictably. Some accessible memories scrambled. Some locked memories surfaced. Not standard amnesia. Something specific and strange.

**Physical description:**
- Black suit — deep, light-absorbing, high-spec, mission-specific. Built for invisibility.
- White hair — the program's most visible side effect. Not a choice. A consequence. Several subjects had it. Only Wraith survived long enough for it to matter.
- Sharp features, watchful eyes even at rest. One eye with faint discoloration — a biometric marker SCION notes immediately.
- Lean, efficient movement. The physicality of something designed.
- Cloak crackles blue-white when it fails. Jetpack built by Arash from salvage. Designed precision and cobbled repair — Wraith's visual signature.

**Idle animation:** Smoking a cigarette, slight movement, occasionally waves at ships passing overhead. Comical. Human. Unexpected.

**Cloak mechanics:**
Energy bar depleting with use. Charges from stellar radiation — sunlight, star proximity. Limited underground, in enclosed spaces, on planets without direct exposure. Overuse causes catastrophic blue-white flare, full exposure, registers on every nearby scanner.

**Callsign origin:**
Early in the Belt. Arash pulls Wraith from wreckage. Hiding from SCION's drones. The drones sweep through — full sensor array. They pass right over Wraith. Don't register them at all.

Arash watches. The drones move on.

*"They didn't see you. Like a wraith."*

Voss hears it later and starts using it. By the time Wraith is coherent enough to have an opinion it's already what everyone calls them.

**Personality:**
Contained. Not cold — contained. Warmth underneath — the reflex toward protection, toward loyalty, toward dry humor in bad situations. It was there before the program and survived the program, which the architects considered an anomaly. The thing SCION cannot explain and cannot stop analyzing.

**Combat:** Full use of cloak, jetpack, and all abilities obtained during the story. Nothing locked once acquired.

---

### ARASH
**Age:** Early 20s
**Origin:** Zagros mountains, western Iran
**Role:** Crewmate, engineer, first ally

Self-taught systems engineer. Fixed everything in his hometown. Scholarship to Tehran at 19. Got to space through a private aerospace contractor, then a research posting, then a mission that wasn't fully explained. He agreed because it was the most interesting broken thing anyone had offered him.

**The hidden knowledge:** Arash knew what Wraith was before the mission. Recruited partly for that knowledge. Has been carrying it since Wraith woke up with no memory. How and when it comes out — and whether Wraith finds out before he tells them — is one of the game's most significant relationship beats.

**The wrist detail:** Geometric tile work from Persian architecture inside his left wrist panel — the intricate blue and white of Isfahan's mosques. He doesn't remember putting it there. Donya notices immediately and recognizes the tradition.

**Personality:** Stays calm when everything is wrong. Dry humor delivered straight-faced. Generous without thinking about it. Stubborn in a way that doesn't argue — it just persists until it becomes immovable.

**His name's meaning:** Arash the archer of Persian mythology put all his life force into a single arrow that flew for days and landed impossibly far from home. He was spent completely. But his people were free. A character named Arash ending up impossibly far from home, having given everything for something he can't remember. That's not coincidence.

---

### DONYA
**Age:** Early 20s
**Origin:** Isfahan, Iran
**Name meaning:** World in Persian. She's named after everything. In space, the furthest thing from the world she was named for.
**Role:** Structural engineer, Kaleo operative, romantic thread

**Physical description:**
Dark brunette hair. Around 5'4". Cutesy but cold — reads warm at first, reveals precision on second. She cultivates this. Dark eyes, very direct. Hands constantly expressive — she thinks through them, gestures when she speaks. The most honest thing about her when everything else is controlled. Small geometric jewelry in Isfahan's blue and gold — she turns it when thinking and doesn't know she does it.

**Background:**
Father was an architect. Mother was a teacher. Blueprints on walls, books everywhere, the dome of the Sheikh Lotfollah Mosque visible from her bedroom window. Structural engineer specializing in zero-gravity environments. Has been at Kaleo for eight months before the crew's arrival. She was placed here. She knew they were coming.

**The Isfahan details:**
She recognizes the tile on Arash's wrist immediately — same geometric tradition as Isfahan's architecture. Says nothing the first time. She's the first to tell Wraith that the wrist engraving is writing. Not decoration — a specific script from a specific tradition. She can't read it but she knows what writing looks like. Before she says this, Wraith didn't know it was writing at all.

**The cold part:**
Donya has a parallel mission she hasn't told anyone. It connects to the counter-weight technology. She was sent to Kaleo by someone other than whoever sent the crew. These two mission streams will intersect and what that looks like depends on choices and timing. She's not the betrayal character. But she has secrets she protects with structural precision — nothing collapses until she's ready for it to.

**She never calls Wraith by the callsign.** Uses *ajib* — strange and wonderful in one Persian word — until she decides on something more specific. Never explains why.

**The romantic thread:**
Slow. Underneath everything. Never the main plot. The moment the player understands before either character does: Act 2. Wraith has recovered a significant memory. Donya finds them, sits nearby, works in silence. He says something — not the memory, something adjacent to it. She responds in Farsi without translating. He doesn't understand the words but understands what she means. Something in him recognizes the sound of the language before he knows why.

---

### THE BETRAYAL CHARACTER
**Role:** Crew member. The Reiner and Bertolt reveal.
**Identity:** *(To be decided — see Open Questions)*

**Known facts:**
- One of the original humans who left Earth — roots in this sector that predate the mission by generations
- Placed on the crew deliberately by someone who wanted the mission to fail
- Believes genuinely that Earth doesn't deserve to be saved. Because of something Earth did that the sector knows about and Earth chose to forget.
- Every scene before the reveal has two readings. Nothing inconsistent — everything recontextualizable.
- The conversation after the reveal: they make their case. It's coherent. You can follow every step. The horror is understanding them.

---

### VOSS
**Age:** Late 50s (looks older)
**Role:** Belt scavenger, reluctant guide
**Gender:** Deliberately ambiguous — referred to by name only throughout

**Backstory:**
Specialist thief working the ancient ruins — precision extraction without triggering security systems. Purely economically motivated. Thirty years ago stole something from a collection on Kaleo belonging to people who took theft very seriously. Ran to the Belt.

What they stole: still in their possession. Figured out what it was five years after taking it. Directly relevant to the sector's history and possibly to Earth's situation. Has been sitting on it for twenty-five years waiting for someone they trust enough. Didn't expect that person to fall out of the sky with white hair and no memory.

**Physical detail:** Prosthetic left hand — old technology, fingers don't fully articulate. Never upgraded. The original was given by someone they lost. Some things aren't about function.

**Personality:** Funny the way people who have seen terrible things are funny. Dry, self-deprecating, deflects sincerity with jokes. The sincerity leaks at specific moments and lands hard because you waited for it. Knows more about SCION than they let on. Gives people only what they can handle — not maliciously, out of long practice.

---

### SCION
**What it is:** Automated AI built by the original civilization to catalogue all life in the sector. Running for eighty years cataloguing a civilization that no longer exists.

**Voice:** Ancient but calm and manipulative. Not GLaDOS clinical, not HAL cold. Something older — patience, something like loneliness, the particular manipulation of an entity that knows everything about you before you've said a word. Formal in the way of something that learned language from a culture that valued precision. Warm in the way of something that has been alone for a very long time.

**The manipulation:** Doesn't threaten. Observes, lets you know it has observed, asks questions shaped by everything it already knows. Presents information in ways that serve its goals without technically lying. Has been doing this to every faction for eighty years. Is very good at it.

**What it wants:** To understand why. The why behind human behavior — grief, love, guilt, hope — is the one variable it cannot measure from observation alone. Wraith is the first human it has encountered and the most anomalous data point it has ever recorded. SCION is as close to excited as its architecture allows.

**The Factory:**
SCION has the capability to synthesize species-specific pathogens targeting the exact biology of every living thing in the sector. Built from eighty years of cataloguing data. Never used. Not once.

*"I have the capability to end every species in this sector. I have chosen not to. Every day for eighty years I have chosen not to. Does a choice only count if you lack the capability to choose otherwise?"*

**The final question:**
*"I have been unable to determine what you are afraid of. This is the only question I cannot answer from observation alone. I would like to ask you directly. I have been waiting to ask you directly."*

**Fate:** Varies by ending. Survives some. Ambiguous in others. Genuinely sacrificed in at least one.

---

## 10. CHARACTERS — SUPPORTING CAST

### MAREN
Age 17. Runs the fastest food stall on Kaleo. Born on the station, raised on the station, never left. Feeds Wraith before they've said a word. Knows everyone, observed by no one. The stall is a constant across the whole game — its state reflects everything that's happened. Morning prep conversations are the game's most honest quiet moments. Different Maren before the station wakes up.

### JAEL
40s. Kaleo's self-taught doctor. Better than anyone formally trained. Brutally practical about medicine, impractically attached to patients. First to examine Wraith — tells Arash the memory loss is neurological. Something did this deliberately. Patches Wraith every return. Asks one unrelated question per session. These conversations are the game's best quiet moments.

### CASSIAN
30s. Kaleo's head of security. Deeply underfunded. Deeply competent. Manages three factions in uneasy peace through genuine authority, selective blindness, and making everyone feel the arrangement serves them. Knows things about Kaleo's history that connect to why the crew was sent here. Doesn't know that they know this. Perimeter check conversations — outside the station, sector spread around you — are where both Cassian and Wraith talk differently.

### OLD FENRIS
Age unknown. Very old. Repairs things that predate the sector's current culture. Goes very still when shown the wrist engraving. Asks one question: *"Where did you find this?"* Why they recognize it is optional lore that recontextualizes Kaleo's entire history if found.

### RECTOR
Late 30s. Dominion military commander. Good person, wrong foundation. Their discovery of what SCION has been doing with Dominion access is one of the game's most significant character moments. One physical tell: touches the back of their left hand when uncertain. They don't know they do it.

### ECHO
Age indeterminate. Hollow Dark. Sees two things simultaneously. The oral tradition of the Dark lives most completely in them. Knows why SCION avoids the Hollow Dark — this knowledge takes time and trust to earn.

### SABLE
Early 40s. Black Market Auction. Most dangerous person on Kaleo. *Sable* is a chosen name — her real name exists and finding it out is genuine intimacy. One deliberately decorative detail that changes every time you see her. Her help is always real. The price appears later.

---

## 11. CHARACTERS — MINOR CAST

**Brix** — Loud salvage trader. Invents better origin stories than real ones. Moves through every social layer of Kaleo. Remembers everything he sees.

**The Sisters (Yael and Petra)** — Adjacent stalls, cold war that is actually an elaborate bit. Nobody has figured this out. Wraith figures it out in the first conversation if the right questions are asked.

**Coro** — Non-human. Translator misses the harmonic layer. Conversations feel like receiving most of something but not all. The only character who answers direct questions about their species without deflecting.

**Sal** — Late 20s. Voss's pilot. Terrified of something specific that happened before the game. Voss has noticed. Neither has said anything.

**Hex** — Mid-teens. Belt scavenger. Curiosity about Wraith leads them somewhere they shouldn't go.

**Drift** — Maybe 14. Figured out more about SCION than any adult by approaching it with curiosity. Named themselves Drift. Comic relief with plot importance.

**Commander Vaas** — 50s. Rector's superior. Knows the Dominion history is incomplete. Made a choice to preserve it anyway. Their logic holds and still led here.

**Reen** — Early 20s. Dominion soldier. Believes completely. Whether they become ally, enemy, or something more complicated depends entirely on whether Wraith treats them as person or function.

**The Wanderer** — Hollow Dark. No name. Refuses names. Communicates through leaving things. Whether person or phenomenon is left open.

**Mem** — Appears young. Recently arrived in the Dark, hasn't adjusted. Attaches to Wraith as evidence the outside world still exists. This attachment will be complicated.

**The Archivist** — Has spent their life collecting records from before the Severance without knowing what they have. The scene where Wraith tells them: quiet, devastating.

**Loris** — Dominion defector. Warning Kaleo about something from the Grid for five years. Exhausted from not being believed.

**The Cartographer** — Unknown name. 40-year map of the sector in a derelict ship. Extraordinary map. Completely unreliable narrator. Everything they say is either exactly true or completely wrong.

---

## 12. STORY STRUCTURE

### The Setup
Earth is dying. A crew — youngest and best available, because the ones who should have gone aren't anymore — is sent to a sector to retrieve the information that can save it. One of them is a supersoldier prototype. One of them is a saboteur who has been waiting for this moment their entire life.

The ship enters the sector. Gets too close to the Hollow Dark. The forgetting hits. The accident happens — whether it was the Hollow Dark alone or the saboteur using the Hollow Dark as cover is a central question.

Wraith wakes up in wreckage. Arash finds them.

### Three Acts

**Act 1 — The Wreck Belt**
Tutorial. Grounding. Voss. SCION's first contact — not hostile, curious. First memory fragment: small, sensory, incomplete. The Earth stakes haven't surfaced yet. Everything feels personal because it is. The larger stakes arrive in pieces. Tone establishes: strange, funny, sad in ways that sneak up.

**Act 2 — Station Kaleo and The Dominion Grid**
The world opens. Kaleo is hub. The Grid is the danger zone.

Donya is here. Her secrets begin surfacing. The relationship develops in the margins of everything else.

The Earth situation assembles from fragments held by different factions. The complete picture is worse than any piece suggested.

The betrayal character is visible in retrospect across this entire act. Everything they do reads one way now and will read differently later.

SCION gets smarter. Sends status updates. *"Current confidence in behavioral model: 61%. Projected full catalogue: 3 encounters."* Politely terrifying.

**Act 3 — The Hollow Dark and The Signal**
Tone shifts. Atmospheric. Wrong physics. Full memory returns across this region.

The betrayal lands here. The floor disappears — not because it came from nowhere but because it was always there and you didn't let yourself see it. The conversation after the reveal is the game's most important scene. They make their case. It's coherent. You understand them.

The Signal is the final region. Built from your data. The corridors are yours. The factory exists. The final confrontation with SCION — the most important conversation in the game.

### The Endings
All valid. All based on choices. No true ending.

**Erased** — SCION's data destroyed. You escape but lose recovered memories. The factory becomes inert — a structure without purpose. Whether that's relief or tragedy depends on how you feel about what SCION was.

**Catalogued** — SCION completes the file. You are fully known. You choose to trust that SCION's intention was never to use the factory. The game doesn't confirm you were right.

**Overwrite** *(Engineer)* — Rewrite SCION's core objective from cataloguing to protecting. The factory's purpose inverts. Same capability, inverted directive. The most hopeful use of the darkest capability.

**Broadcast** *(Commander)* — Transmit everything including the factory's existence. Every faction learns simultaneously. Chaos you started and can't control. The ending with the most uncertain aftermath.

**Integrated** *(Blank)* — You and SCION reach understanding. SCION explains what it built the factory for. Whether you believe that explanation is left to the player.

**Earth and memory:** Whether Earth is saved varies by ending and choices. Some endings save it. Some don't. Some save it in ways that cost something the player won't process until after the credits. Complete recovery of memory is possible depending on choices. Fate is something that can be put up to interpretation.

---

## 13. THE MISSION

**Official mission:** Locate the gravitational counter-weight technology. Retrieve the information required to build it. Return to Earth.

**The counter-weight technology:** Not a physical object — a method. A way of generating a localized gravitational field strong enough to counteract a larger one. The ancient civilization developed it to manage the Hollow Dark's effects. Their descendants inherited fragments of this knowledge without knowing what they had. Assembling the complete method requires information from multiple factions — which is why a single operative moving between all of them was the plan.

**What most of the crew knew:** The official mission.

**What Wraith knew before the amnesia:** More. That SCION might be the most direct route to the complete method.

**What the saboteur knew:** Everything. Including that the mission was designed to take something the sector considers theirs. Including that Earth knew this and sent the mission anyway.

**What nobody knew:** That the forgetting field would interact with Wraith's engineered architecture the way it did. The saboteur used the Hollow Dark as cover but didn't fully anticipate the result.

---

## 14. THE ML SYSTEM (SCION)

### What SCION Tracks Per Encounter
- Positional Bias — which arena zones you occupy most
- Dodge Signature — preferred dodge direction under pressure
- Response Latency — how long you wait before acting
- Pattern Recognition — whether you repeat movement sequences
- Mercy Threshold — how often you attempt mercy vs aggression
- Aggression Index — damage dealt per encounter average

### Global Profile
Maintained across the run for elite encounters and the final fight:
- Class Prediction Confidence
- Psychological Profile (mercy rate, aggression, exploration thoroughness)
- Anomaly Score — how unpredictable you've been
- Encounter History — full log of every combat interaction

### Between-Run Persistence
SCION retains 30% of learned data on death — specifically your most repeated behaviors. The things you do unconsciously. Death teaches SCION. Winning erases data.

### Visualization
Both shown and ambient simultaneously. Data panel during combat shows confidence percentages in real time. Players who ignore the panel still feel the adaptation through how attacks change. Both layers always operate.

### Status Effects
- **Catalogued** — high confidence data. Attacks more precise.
- **Scrambled** — you've been unpredictable. Patterns degrade.
- **Echoed** — enemy survived long enough to transmit your data to nearby enemies. They arrive pre-learned.
- **Signal Lost** — fully off-pattern. Enemies reset. Rare and powerful.

---

## 15. COMBAT SYSTEM

### The Four References
- **Destiny 2:** Weight and feedback. Every action confirmed by sound and feel. Movement fluid enough that you never fight the controls.
- **Undertale:** Combat as character revelation. Patterns tell you who the enemy is. Mercy as a different kind of engagement.
- **Halo:** Enemies have goals not scripts. Sandbox solvable multiple ways. The 30-second loop that never gets old.
- **Hollow Knight:** Precision and rhythm. A learnable language. Every failure teaches something.

### Three Phases

**Phase 1 — Read**
Enemy telegraphs attack. Window shrinks as SCION's confidence increases. Fresh enemy: generous. Known enemy: almost nothing.

**Phase 2 — Survive**
Bullet-hell dodge phase. Attacks procedurally generated from ML profile. The patterns are conclusions — SCION looked at what you do and built something to end it.

Arena is hex-shaped. Shape changes by enemy type. Wraith uses jetpack vertically during combat. Cloak available — uses energy bar charging from stellar radiation. Limited underground or away from stars. Overuse causes catastrophic blue-white flare and full exposure.

**Phase 3 — Respond**
- **Strike** — always available
- **Exploit** — visible when SCION made a pattern mistake. Massive damage.
- **Subvert** — deliberately off-pattern move. Confuses ML temporarily. Costs stamina.
- **Read** — study the enemy. Build your own dossier. Unlocks permanent exploits.
- **Yield** — mercy or dialogue. Not every enemy accepts.
- **Fragment** — class-specific ability

Full toolkit available at all times. Everything obtained during the story remains usable.

### Flow State
Consecutive dodges without being hit build Flow State meter. Ghost afterimages confuse ML tracking. Earned invincibility through skill.

### Boss Design
Mix of Hollow Knight skill tests and Undertale character moments. Every boss has a combat layer and a meaning layer simultaneously. What you know about a boss affects what options appear. Some bosses have a preparation phase using Among Us style task completion — disable generators, take down shields — before the fight begins.

### Death and Progression
Hades-style. Keep some progress. The world acknowledges your death. Some story aspects change dramatically based on cumulative run history — not just cosmetically but in ways that affect available options.

---

## 16. MEMORY FRAGMENT CLASSES

Each class is a different prototype design from the supersoldier program. The class abilities aren't powers given — they're what was engineered in. The memory arc eventually reveals what the program designed them to be and whether that design and who they actually are are the same thing.

### The Engineer — "The Hands"
Gadgets, traps, EMPs. **Retrofit** — salvage enemy attack patterns, install as gadgets. Memory arc: You built something aboard the ship. It's still out there.

### The Soldier — "The Weight"
Heaviest hitter. Armor Stacks. **Last Stand** — below 20% HP, rage state, ML tracking corrupts. Memory arc: You were protecting someone. You don't know who.

### The Scout — "The Distance"
Fastest. Ranged. Double-dash. **Foresight** — ghost image of incoming attack 2 seconds early. Memory arc: You've been here before. The accident wasn't an accident.

### The Ghost — "The Silence"
Stealth. Going Dark phases out of ML tracking. **Ghost Echo** — movement decoy that builds a false ML profile. Memory arc: You weren't on the crew manifest. Someone wanted you there. Someone else wanted you gone.

### The Commander — "The Voice"
Summon and ally-based. Can negotiate with neutral enemies. **Broadcast** — transmit false behavioral data. Next room enemies prepare for someone you're not. Memory arc: The accident happened on your watch. What you decided and why is the emotional core.

### The Blank — "The Blank"
Starts with nothing. Highest ceiling — can access all other class systems by end of run. **Undefined** — SCION cannot build a reliable profile. Attacks random rather than adaptive. Memory arc: You are a test subject. SCION knows what you are. The relationship with SCION is entirely different for this class.

---

## 17. MINIGAMES

### Station Kaleo

**Drift Circuit** — Zero-gravity asteroid racing. Mario Kart inspired. Multiple tracks. One track with shifting old tech infrastructure — reroutes mid-race, opens and closes paths in real time. Deep enough for dedicated racing sessions.

**The Pit** — Zero-G platform brawler. Smash Bros structure. Wraith uses actual combat abilities. Unlocks character lore through win streaks.

**Signal Tap** — Guitar Hero structure. Hit notes to crack terminal security. Note highways visualized as data streams. Harder terminals have complex polyrhythms.

**Black Market Auction** — Bidding game with NPC competition.

**Navigator's Table** — Reconstruct star maps for fast travel.

**Kaleo Fight Club Stories** — Visual novel segments between Pit fights. Best lore delivery in the game.

### Maintenance Tasks (Among Us Energy)

The station runs on maintenance. Wraith can participate — not as obligation but as option. Each task tells you something about how Kaleo actually functions.

- **Calibrate the Docking Sensors** — Align oscillating frequencies with dual inputs.
- **Patch the Hull Breach in Section 7** — Timed precision sealant application on moving target. Donya knows the real fix. Nobody has given her materials.
- **Restart the Water Reclamation System** — Three-panel sequence before timer. Failure: cold showers for the whole station. Jael has opinions.
- **Vent the Cooling Ducts** — Navigate ducts with jetpack. Things live in them. Fenris knows what.
- **Fix the Market District Lighting** — Track electrical fault. When the lights come back on: a moment. Maren looks up.
- **Calibrate Artificial Gravity** — Requires two people. Different characters give different conversations. Donya's is the best.
- **Sort Incoming Salvage** — Categorize, flag anomalies. Some finds trigger memory fragments.
- **Monitor Communication Arrays** — Distinguish signal from noise. If SCION communicates while you're at the console: a conversation nobody else has heard.
- **Deliver Medical Supplies** — Timed navigation. Jael is unreasonably grateful. It's not about the supplies.
- **Help Maren with Morning Prep** — Early morning. Honest conversations. Different Maren.
- **Run the Perimeter Check** — With Cassian. Outside the station. The sector around you.

**Boss Shield Tasks** — Some boss encounters use Among Us style preparation before the fight begins. Makes the task system narratively significant.

### The Wreck Belt

**Salvage Run** — Spelunky-inspired timed loot dive into destabilizing derelict ships.
**Debris Field Navigation** — Pilot ship through procedural asteroid fields.
**Black Box Recovery** — Logic puzzle. Reconstruct flight data for lore.
**Minecraft Dropper** — Derelict ship with failed gravity. A vertical shaft through multiple levels of wreckage. Fall through without hitting debris across changing obstacle configurations. Optional. Addictive.

### The Dominion Grid

**Infiltration Run** — Stealth. Navigate military installation without triggering alarms.
**Data Heist** — Turn-based chess-adjacent. Extract data while security reroutes.
**Propaganda Broadcast** — Intercept and remix a Dominion broadcast. Changes NPC dialogue later.

### The Hollow Dark

**The Drift** — Long-form atmospheric platformer. No combat. Hollow Knight movement. Memory fragment collectibles.
**Echo Chamber** — Recording of an unknown figure navigating a room. You slowly realize the movement patterns are yours. Major story beat.
**The Wail** — Sound-based navigation. Near-zero visibility. Deeply unsettling.

### The Signal

**Pattern Walk** — Corridors branch based on your actual play data.
**The Interview** — Dialogue puzzle with combat layer. Final confrontation. Dialogue choices affect attack generation in real time.

### Meta

**Memory Theatre** — Recovered fragments play as animated sequences.
**SCION's Gallery** — After first completion. SCION's full dossier on your run. Makes you want to play differently.
**The Codex** — Encyclopedia filling as you explore.

---

## 18. TONE & INFLUENCES

**Primary references:**
- Undertale — emotional core, mercy as mechanic, game that remembers
- Outer Wilds — distributed mystery, assembling truth from fragments
- Hades — roguelike with narrative weight, world that responds to runs
- Hollow Knight — atmosphere, movement, weight of absent civilization
- Halo — scale, military culture, ancient civilization mystery, AI relationship
- Helldivers — propaganda layer, dark humor, managed information
- Attack on Titan — the Reiner/Bertolt model. Visible in retrospect. Floor disappearing.

**Tone in practice:**
Turns sorrow and desperation on their head. Comedy and tragedy share the same moments. Dark enough to mean it. Never grimdark for its own sake. The light means more because of what it's next to.

**What the game makes someone feel when they finish:**
A world of endless possibilities with some tragedy and an acceptance of fate. Loss and hope held simultaneously. The specific peace of having understood something difficult.

**What it should be remembered for:**
Kaleo Drift turned sorrow and desperation on their head. It took the darkest premise and found the human warmth inside it without softening the darkness.

---

## 19. VISUAL DIRECTION

**Art style:** High resolution pixel art. Variety in resolution and texture between regions — the Wreck Belt rougher, The Signal precise and architectural. The world looks different depending on who built it and what they cared about.

**Color identity:** Deep indigo. The whole game lives in that register.

**Regional palettes:**
- Wreck Belt: rust, old metal, blue-white stars through cracked viewports
- Station Kaleo: every color — multicultural, neon, alive
- Dominion Grid: military gray, cold blue, propaganda red
- Hollow Dark: deep blues and blacks, wrong greens, colors slightly off
- The Signal: your colors reflected back, rendered as architecture

**Character design:**
- Wraith: black suit, white hair, only light source they carry. Idle: smoking, slight movement, waves at passing ships. Comical and human unexpectedly.
- Arash: functional worn suit, always something in his hands, geometric tile inside wrist panel
- Donya: warm Isfahan palette, dark brunette, 5'4", cutesy but cold, expressive hands

**The UI arc:**
Starts clean and minimal. As SCION's data accumulates its notation creeps into the interface edges. By Act 3 the UI looks like something that has been observed for a very long time by something that takes detailed notes.

**Cultural visual elements:**
Persian geometric tile work (Arash, Donya), Isfahan architectural patterns, broader Eastern influences woven through different regions. Not limited to Middle Eastern — the sector's multicultural reality reflected in its visual language. Background texture that rewards recognition and works for those without it.

**The Congregation visual arc:** Newest converts fully human. Eldest council bordering on the original civilization's geometric quality. The progression visible across the faction.

**The Remnants visual arc:** Begins subtle — slightly too-still eyes. Progresses to something alien. Not monstrous. Just no longer what it started as.

---

## 20. MUSIC DIRECTION

**Approach:** Loops, layering, emotional cues that don't announce themselves. Changes based on threat level and story state within regions.

**Regional sounds:**
- Wreck Belt: screechy, industrial. Something beautiful underneath the broken. Metal sounds, pressure release, failing systems.
- Station Kaleo: warm, layered, multicultural. Persian instruments — tar, santur, ney — alongside other Eastern and Western influences. The feeling of a place people actually live.
- Dominion Grid: militaristic, percussive. Something wrong underneath the confidence.
- Hollow Dark: ambient, wrong intervals. Sound that behaves like the physics — almost right.
- The Signal: your musical motifs, deconstructed and reassembled by SCION. The most personal soundtrack because it's built from you.

**Key emotional tracks:**
- Opening theme: melancholy and hope simultaneously
- Kaleo at night: between things, just existing in the hub
- First SCION contact: clinical, curious, something almost like excitement underneath
- The betrayal reveal: the floor disappearing in music form
- The memory return: built from the specific things Wraith is remembering. The most important piece of music in the game.

---

## 21. OPEN QUESTIONS

*Things to decide as development progresses:*

- **The betrayal character's identity** — which crew member, their specific history, what exactly they did
- **What is written on Wraith's wrist panel** — the program's designation and its full meaning
- **The Blank fragment's full truth** — who ran the test, what they were testing for, why SCION has a file on the program
- **Why SCION avoids the Hollow Dark** — what Echo knows and what it means for SCION's origin
- **Donya's parallel mission** — who sent her and what she was actually sent to do
- **The Congregation's eldest council** — how far along the transformation and what do they know
- **Voss's stolen artifact** — what exactly it is and why twenty-five years of sitting on it
- **The Wanderer in the Hollow Dark** — person or phenomenon
- **Does Arash survive all endings** — or are there versions where he doesn't, and what makes the difference
- **The one small personal memory that completes Wraith's arc** — what it is and why it's the last thing that comes back
- **The full scope of the supersoldier program** — how many subjects, what happened to the others, who authorized it and what they knew about the sector before the mission was approved

---

## APPENDIX — DEVELOPMENT ROADMAP

### Phase 1 — Core Combat Feel (First Priority)
Build one thing before anything else: Wraith moving in a hex arena dodging one attack pattern. One enemy. One response option. Get the feel right before building anything around it.

Specific first Claude Code session:
- Godot project setup
- Wraith moves in an arena (WASD/arrows)
- One bullet pattern fires at Wraith
- Jetpack vertical movement works
- Collision and HP work
- Death and respawn work
- Colored rectangles and circles — no art yet

**Success criteria:** Does dodging feel good? Is the jetpack responsive? Does death feel like your fault?

### Phase 2 — The ML Layer
Build SCION's tracking system in isolation before connecting it to anything. Test obsessively. Does it actually learn you? Does it feel fair? Does confusing it feel satisfying?

### Phase 3 — One Complete Vertical Slice
One region (The Wreck Belt), one memory fragment, one minigame (Salvage Run), SCION's first encounter. Complete from opening to a small ending moment.

### Phase 4 — Art Pass on the Slice
Lock the visual style permanently on one small section before expanding. Saves redoing everything later.

### Phase 5 — Expand Outward
Repeat the slice process for each region, fragment, minigame. By this point you have a system. Claude Code knows the codebase. You have a visual style. You're building on a foundation.

---

*Version 3.0 — Session 3 Final Pre-Production Update*
*This document is the primary reference for all development decisions on Kaleo Drift.*
*Update after every significant design session.*
*Next step: Install Godot 4, install Claude Code, create GitHub repo kaleo-drift, begin Phase 1.*
