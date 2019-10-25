#BRPG - Basic RPG

##Introductoin

Basic Role Playing Game (BRPG) is the first landmark game for the creation of RPGWNN.  It's aim is to produce a simple working game that others may build onto using the RPGWNN codebase.

##Functionality

Log in + char creation
Move around map
Basic player interactions
Basic items
Basic skills
Basic NPC/Quest Interaction


##Death Mechanic

When  player has 0hp they can only use one button "revive", costing 5ap it transports them to the campfire a player is bound to.


##Map Tiles

Grass - passable, can find stick 20%, stone 20% and gold coin 10%
Forest - passable, can find healing herb 10%, stick 30%, gold coin 20%
Stream - passable (double ap cost), can find stone 50%
Mountain - impassable world border
Campfire - passable, can find stick 10% and gold goin 15%

Movement should work identically to shartak for now.

##Map Items

Fist (unseen and non discardable) - 1 damage 20% base
Sword - 2 damage 20% base
Bow - 3 damage 20% base, costs 1 arrow per shot
Stone - No use
Stick - No use
Arrow - Used as ammo for shooting, can be crafted from 1 stick and 1 stone (makes 2) and 1ap, stacks
Healing Salve - Restores 5hp, can be crafted from 2 healing herbs and 1ap, grants 2exp when used on wounded player/npc (not self), 25% chance 1 exp granted for crafting
Healing Herb - Restores 2hp, stacks, grants 1exp when used on wounded player/npc (not self)
Gold Coin - No use, stacks



##NPCs

Wolf - 10hp, 2 damage 30% chance, exp per kill (2), drops 1gc per kills
Deer - 5hp, no damage, exp per kill (1), can start wounded (1hp)
Bob (Trader) - Cannot be attacked, offers items in exchange for gold.  Also offers "training quest"


##Skills (each costs 5 exp)

Sword Swinging - 10% bonus to hit with sword
-Sword Striking - 15% bonus to hit with sword
-Sword Charge - Special action, 1/2 hit chance double damage.

Bow Shooting - 10% hit bonus
-Fletching - Allows arrow crafting
-Aimed Shot - Special action, costs 2ap but doubles chance to hit

Salve Making - Allows salve crafting
-Healing - Increases salve heal amount bt 2
-Herb Hunting - Can use "herb hunt" option in forests (a new button).

-Specialrewardskill stamina - Grants +5ap max and +5hp max


##Base character info

20ap, 15hp, 10 inventory slots, option to "give", "attack", "speak", "search" and "drop"
1 ap granted per 5 mins


##Quests

Training
Visit each type of tile once, item of choice (Sword, bow and 5 arrows or 10 healing herbs)

Hunt A Deer (only gettable after training done)
Kill 1 deer, reward specialrewardskill stamina



##Trader

Sword - 5 gold coins
Bow - 5 gold coins
Arrow - 1 gold coin for 2
Healing salve- 2 gold coins


##Char creation

Name - Shartak style
Gender - M/F
Race - Human (no changes), Elf (+4% bow accuracy, -5% sword accuracy), Dwarf (+5% sword accuracy, -4% bow accuracy) or Pixie (+1 salve healing, -3 max hp)
Starting skill - Sword Swinging, Bow Shooting or Salve Making


##Actions

All actions have an ap cost, this is 1 unless otherwise indicated.  An AP check is performed before an action is takenm failure of the ap check results in no action being taken.  All actions save revival also check if the player is alive.

#Search
Checks if player inventory is full.  If not then: subtracts 1 ap; gets the current tile's item pool; does a random number generation based on that item pool max; awards item based on weighted table check.  Otherwise, gives error message.
#Give
Identical to shartak give function.
#Drop
0ap cost, identical to shartak drop function.
#Herb hunt action
Only visible on forest tiles.  Same as search but with a fixed item pool (50% herb find rate, 0% anything else).
#Speak
0.1ap cost, identical to shartak speak function (minus language complexity)
#Fletch
Checks player inventory contains a stick and a stone, if so subtracts one of each and gives the player two arrows.

#Attack
Identical to shartak attack function save that it can take 3 extra parameters.  AP modifier (for increased AP costs), accuracy modifier, damage modifier.  These all default to 1.
#Aimed Shot
Uses attack code but with a +1 ap modifier and a *2 accuracy modifier
#Sword Charge
Uses attack code but with a *2 damage modifier and a *2 accuracy modifier

#Rest
Can only be used on campfire tiles.  Costs 10ap and moves a player's spawn location to the campfire tile.
#Ask
Can only be used by NPCs with a quest.  Functionality should allow player to undertake quest, not too sure on how we will best do this.

##Some maths

Sword 0 skill 0.4 damage per ap (dwarf 0.5, elf 0.3)
Sword 1 skill 0.6 damage per ap (dwarf 0.8, elf 0.5)
Sword 2 skill 0.9 damage per ap (dwarf 1, elf 0.8)

Bow 0 skill 0.6 damage per ap (dwarf 0.48, elf 0.72)
Bow 1 skill 0.9 damage per ap (dwarf 0.78, elf 1.02)


