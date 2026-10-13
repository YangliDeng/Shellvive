Shellvive

Eat jellyfish. Dodge plastic. Stay alive.

Shellvive is a single-player 2D survival game about a turtle living in a polluted ocean. We are making it for the Game Developments for Social Good seminar at the University of Latvia. Through the game, we want players to think about how plastic pollution affects sea life.

Planned gameplay

Move forward, backward, up, and down while the ocean background keeps scrolling.

Eat normal and big jellyfish to refill one survival bar. The bar slowly drains, and the run ends when it reaches zero.

Avoid choking plastic, which reduces the bar and slows the turtle. The slowdown can stack.

Avoid plastic bags: one covers half the gameplay view, and two cover the whole view.

At score milestones, choose between two cards: a cleanup boat that clears nearby plastic and removes bags, or a rescue boat that refills the survival bar.

Survive as long as possible while polluting boats add more plastic and increase the difficulty.

We hope to add more card types later. A third plastic type is also being discussed.

Tools

Engine: Godot

Language: GDScript

Version control and teamwork: GitHub

Planned platform: Windows PC

Developers

Yangli Deng

Sarah Ali

Project status

The project is currently at the proposal stage. Some details may change during development and playtesting.

Read the full game proposal for more details.

# Shellvive

Shellvive is a single-player 2D survival game about ocean plastic pollution.

Developed by Yangli Deng and Sarah Ali for the Game Development for Social Good course at the University of Latvia.

Engine: Godot 4.6  
Language: GDScript  
Platform: Windows PC

## Download and Run

1. Open the Releases page:
   https://github.com/YangliDeng/Shellvive/releases
2. Download the attached Windows game ZIP.
3. Extract the entire ZIP into a folder.
4. Open Shellvive.exe.

Keep all extracted files together. Godot is not required to play the exported Windows version.

GitHub's automatically generated "Source code" downloads contain the project files, not the Windows executable.

## How to Play

Your goal is to survive for as long as possible and collect points.

- Move the turtle using WASD or the arrow keys.
- Eat jellyfish to restore the survival bar and increase your score.
- Larger jellyfish provide greater rewards.
- Avoid choking plastic, which slows the turtle.
- Avoid survival-reducing plastic, which lowers the survival bar.
- Collect floating boxes to open the card selection interface.
- Keep up to three assistance cards.
- When your inventory is full, replace an existing card or skip the new card.
- Use the on-screen card controls to activate stored assistance.
- Rescue assistance removes attached plastic effects.
- Cleanup assistance removes plastic from the sea.
- Each assistance card is consumed when used.

The survival bar decreases over time. When it reaches zero, the run ends. Use the restart button to play again.

## Run from Source

1. Download or clone this repository.
2. Import project.godot into Godot 4.6.
3. Wait for the assets to finish importing.
4. Press F5 to run the project.

## Prototype Status

This first prototype tests movement, food collection, survival management, plastic hazards and assistance cards.

Gameplay values and difficulty progression are provisional and will be adjusted after playtesting.

Boat animations, the death sequence and final artwork are planned for later development.

## AI Usage

AI was used to generate placeholder visuals and to assist with drafting and troubleshooting GDScript.

The team reviews, adapts, integrates and tests the generated code and assets.
