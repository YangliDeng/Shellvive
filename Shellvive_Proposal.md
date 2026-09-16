# Shellvive — Game Proposal

## 1. Game Title and Developers

| Item | Details |
| --- | --- |
| Title | Shellvive |
| Developers | Yangli Deng and Sarah Ali |
| Team | Two students |
| Course | Game Developments for Social Good, University of Latvia |
| Game type | Single-player 2D survival game with card choices |

The name combines "shell" and "survive".

## 2. Game Concept

Shellvive is a game about a sea turtle trying to survive in a polluted ocean. The player eats jellyfish to keep the turtle alive and avoids plastic floating in the water.

The game is shown from the side. The ocean background keeps moving from right to left, while the player can move the turtle forward, backward, up, and down. There is one survival bar. It slowly goes down over time, so the player needs to keep finding food.

A polluting boat brings more plastic into the water as the game continues. After reaching certain scores, the player can choose a card that calls a friendly boat to clean the area or heal the turtle.

## 3. Story / Theme

The turtle is travelling through the ocean and looking for food. At first, there is only a little plastic. More waste appears as the turtle continues its journey, making it harder to eat and stay alive.

The boats show how people can harm or help marine animals. We want to tell most of the story through what happens during play, with only a small amount of text.

## 4. Social Good Theme

The game focuses on plastic pollution in the ocean. Sea turtles can mistake plastic for food. Swallowing it can cause injuries or block their digestive system, making it difficult to feed. [WWF: sea turtles and plastic](https://www.worldwildlife.org/resources/explainers/what-do-sea-turtles-eat-unfortunately-plastic-bags/).

The project relates to two UN Sustainable Development Goals:

| Goal | How it connects to the game |
| --- | --- |
| **SDG 14: Life Below Water** | Target 14.1 includes reducing marine pollution and waste. This is our main theme: plastic makes the turtle's home more dangerous. [UN Goal 14](https://sdgs.un.org/goals/goal14). |
| **SDG 12: Responsible Consumption and Production** | Target 12.5 includes reducing waste through prevention, reuse, and recycling. The game shows that cleaning up helps, but the problem returns if people keep adding waste. [UN Goal 12](https://sdgs.un.org/goals/goal12). |

We chose this topic because it can be shown clearly through a simple game. Players can experience how pollution affects an animal while trying to keep it alive.

Our main audience is students and casual players. The game could help people understand the problem and support discussions about reducing waste. Marine animals and coastal communities could benefit if greater awareness leads people to take action.

## 5. Social Good Integration into Gameplay

The player needs food, but plastic makes reaching it harder. Swallowing plastic reduces the survival bar and slows the turtle. Plastic bags block the player's view, making it harder to see food and danger. Pollution therefore changes how the player moves and makes decisions.

Some plastic objects may look similar to food, but there will still be visible differences so players can learn to recognise them.

The boat cards also involve a choice. Cleaning makes the area safer, while healing helps the turtle immediately. The player cannot receive both benefits from the same reward. New waste can arrive after a cleanup, showing why stopping pollution also matters.

The game uses simple rules to show these problems. Eating food restores the survival bar for gameplay purposes; it does not mean that food can cure real plastic injuries. The polluting boat represents human waste, but boats are not the only real-world source of ocean pollution.

## 6. Intended Impact / Message

We want players to understand that plastic can make basic survival difficult for marine animals. Cleanup and rescue can help, but reducing the amount of waste entering the ocean is also important.

We plan to ask at least five people to test the game. Before playing, we will ask what problems they think ocean plastic causes. After playing, we will ask:

1. How did plastic affect the turtle and your view?
2. What was the difference between the cleaning and healing cards?
3. Why did pollution return after a cleanup, and what could people do to reduce it?

Our first goal is for at least four out of five testers to explain two harmful effects, understand the card choice, and name one useful real-world action. We will also watch for confusing controls or objects and use the feedback to improve the game. This checks whether the message is clear, not whether players change their long-term behaviour.

## 7. Gameplay and Rules

### Movement

| Action | Controls |
| --- | --- |
| Forward / right | D or Right Arrow |
| Backward / left | A or Left Arrow |
| Up | W or Up Arrow |
| Down | S or Down Arrow |

The turtle stays inside the screen. The ocean background scrolls continuously during play. Moving backward moves the turtle to the left; it does not reverse the background. Jellyfish and plastic drift through the play area.

### Survival Bar and Food

The turtle starts with a full survival bar. It slowly decreases while playing. Touching a jellyfish means eating it, which restores part of the bar and adds points. The bar cannot go above its maximum. There is no separate energy bar.

| Food | Effect |
| --- | --- |
| **Normal jellyfish** | Common and slow-moving. Restores a small amount of the bar and gives points. |
| **Big jellyfish** | Less common and faster-moving. Restores more of the bar and gives more points. It has a larger, clearly different shape. |

### Plastic Types

We plan to have three types of plastic. Two have been defined so far:

| Plastic | Effect |
| --- | --- |
| **Choking plastic** | Swallowing it removes a portion of the survival bar and slows the turtle. The slowing effect can stack: eating more pieces makes the turtle slower. Fragments, bottle caps, or straws can be different appearances of this type. |
| **Plastic bag** | One bag covers about half of the gameplay view. Two active bags cover the whole gameplay view. The turtle can still move, but the player cannot see the turtle or nearby objects when fully covered. Bags do not directly damage the survival bar. |
| **Third plastic type** | Still being discussed. We will add its name and effect once we decide. |

Each swallowed piece of plastic causes damage once and adds one slowdown stack, then disappears. The same piece will not keep damaging the turtle while touching it. We will test how strong the slowdown should be, how many stacks it can have, and how it wears off.

Each bag stays for a limited time unless a cleanup removes it earlier. The card menu will remain visible above the bags so the player can still make a choice.

We will adjust the numbers during testing. Eating one piece of harmful plastic should cost more survival value than one normal jellyfish restores.

### Boats and Cards

The polluting boat appears from time to time and drops plastic. Later visits add more pressure, but there should still be gaps to swim through and food the player can reach.

Eating jellyfish increases the score. At each new score milestone, the game pauses and shows two cards:

| Card | What it does |
| --- | --- |
| **Cleanup Boat** | Clears plastic near the turtle and removes all attached bags. It does not refill the survival bar. |
| **Rescue Boat** | Refills a large part of the survival bar, up to its maximum. It does not remove nearby plastic or attached bags. |

The player chooses one card, and the friendly boat provides that service. The other card is skipped for that reward, but can be chosen at a later milestone. Each milestone gives only one reward. The cards give help once when chosen, rather than a permanent upgrade.

The background, movement, and survival bar all pause while choosing. Play resumes after the choice. Healing should restore more than a normal jellyfish, so it is useful when the bar is low.

We hope to add more card types later if there is enough time and the first version works well. For now, we will build and test the cleaning and healing cards.

### Typical Round

1. Start with a full survival bar in fairly clear water.
2. Move around, eat jellyfish, and avoid plastic as the background scrolls.
3. Deal with damage, slower movement, or blocked vision if plastic is collected.
4. Face more pollution when the polluting boat returns.
5. Reach a score milestone and choose cleaning or healing.
6. Continue until the survival bar reaches zero, then see the score and survival time and try again.

The game is single-player and runs in real time, apart from pauses for card choices. Two people are developing it; it is not a two-player game.

## 8. Winning / Losing / Game Objectives

The goal is to survive as long as possible and get a higher score by eating jellyfish.

We plan an endless mode, so there is no final level or fixed winning screen. Players can aim to beat their previous score and survival time.

The game ends when the survival bar reaches zero, whether from not finding enough food, plastic damage, or both. The player can then start a new run.

## 9. Platform and Development Tools

| Purpose | Tool or platform |
| --- | --- |
| Initial platform | Windows PC |
| Game engine | **Godot** |
| Programming language | **GDScript** |
| Project files and teamwork | **GitHub** |
| Controls | Keyboard movement and a simple card menu |
| Proposal and notes | Markdown files in the public repository |

We will use Godot and GDScript to build the game. We will use GitHub to keep our files, track changes, and work together. Art and sound will be made by us or taken from assets we have permission to use, with credits included.

## 10. Originality / Existing Games

Two games are useful comparisons:

| Game | Similarities and differences |
| --- | --- |
| **Feeding Frenzy 2 Deluxe** | It also involves moving underwater, eating food, and avoiding danger. Shellvive focuses on plastic pollution, with a survival bar, slower movement after swallowing plastic, and bags that block the view. [Official game description](https://store.steampowered.com/app/3390/Feeding_Frenzy_2_Deluxe/). |
| **Google Chrome Dinosaur Game** | Its endless running and scrolling scenery are useful references for a simple survival game that players can keep retrying. Shellvive lets the player move in all four directions and adds food, plastic effects, and boat cards. [Google's article about the game](https://blog.google/products-and-platforms/products/chrome/chrome-dino/). |

The individual mechanics are not completely new. Our idea is to combine them so that ocean pollution affects what the player sees, how the turtle moves, and the choices needed to survive.

This is a classical game for the social-good topic. It does not include quantum mechanics.

## 11. Development Plan and Other Information

| Stage | What we plan to make |
| --- | --- |
| **Prototype I** | Scrolling ocean, movement in all four directions, normal jellyfish, survival bar, choking plastic with damage and stacking slowdown, score, and restart. |
| **Prototype II** | Big jellyfish, bags that can cover half or all of the view, the boats, and the two-card choice. |
| **Final version** | Better visuals and sound, short instructions, balanced difficulty, bug fixes, and testing with players. |

Both Yangli Deng and Sarah Ali will help with design, programming, and testing. We will divide the tasks as development progresses and keep track of our work on GitHub.

We will start with one ocean setting, two jellyfish types, and two cards. The third plastic type still needs a clear design before we add it to the plan. More cards may be added later, but our first aim is to make the main game easy to understand and enjoyable to play.
