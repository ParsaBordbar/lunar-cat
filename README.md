# Lunar Cat

**A little cat. Two worlds. One pair of gravity boots.**

Lunar Cat is a small 2D platformer made with **Lua and [LÖVE](https://love2d.org/)**, built just for fun.

Help a space-exploring cat navigate through the lunar surface and an orbital station. Jump over obstacles, flip gravity to walk on ceilings, collect fish, and see how far you can survive.

## Gameplay

The game is built around a simple mechanic: **gravity is not always pointing down.**

Use your gravity boots to switch between the floor and ceiling, dodge obstacles, and keep moving as the world gets faster.

### Features

- **Gravity Flipping:** Switch gravity and move between floors and ceilings.
- **Double Jump:** Jump up to twice before landing.
- **Two Environments:** Explore the Lunar Surface and Orbital Station.
- **Procedural Obstacles:** Deal with dynamically spawned hazards, including spikes, walls, and meteors.
- **Collectibles:** Collect fish to increase your score.
- **Progressive Difficulty:** The game gradually increases its speed.
- **Particle Effects:** Enjoy animated particles, landing dust, screen shake, and score popups.
- **High Score:** Your best score is saved between sessions.
- **Gamepad Support:** Play with a compatible game controller.

## Controls

### Keyboard

| Action | Key |
|---|---|
| Move left | `A` / `←` |
| Move right | `D` / `→` |
| Jump | `Space` / `J` / `Z` |
| Flip gravity | `W` / `↑` / `Shift` / `K` / `X` |
| Pause / Resume | `Enter` / `P` |
| Back / Return to title | `Esc` |

### Gamepad

| Action | Button |
|---|---|
| Move | Left Stick / D-pad |
| Jump | A / B |
| Flip gravity | X / Y / L / R / D-pad Up |
| Pause / Resume | Start |
| Back / Return to title | Back |

## Getting Started

### Requirements

- [LÖVE (Love2D)](https://love2d.org/) installed on your system.
- Git (optional, for cloning the repository).

### Installation

Clone the repository:

```bash
git clone https://github.com/ParsaBordbar/lunar-cat.git
cd lunar-cat
```

### Run the game

Launch the project using LÖVE:

```bash
love .
```

That's it! The game should start.

## Project Structure

```text
lunar-cat/
├── assets/
│   └── player/          # Player sprites and animations
├── libraries/
│   └── anim8.lua        # Animation library
├── src/
│   ├── background.lua   # Background rendering
│   ├── fx.lua           # Particle effects and visual feedback
│   ├── input.lua        # Keyboard and gamepad input
│   ├── player.lua       # Player movement and gravity mechanics
│   ├── ui.lua           # HUD and game overlays
│   └── world/           # World generation, collisions and rendering
├── conf.lua             # LÖVE configuration
└── main.lua             # Game entry point and main game loop
```

## Built With

- [Lua](https://www.lua.org/) — Programming language.
- [LÖVE](https://love2d.org/) — 2D game framework.
- [Anim8](https://github.com/kikito/anim8) — Sprite animation library.

## Development
Lunar Cat is a personal project made for fun and experimentation with Lua and LÖVE.
The project is still evolving, so expect changes, improvements, and possibly a few bugs along the way.


## License

Copyright (c) 2026 Parsa Bordbar

Lunar Cat is licensed under the GNU General Public License v3.0.
See [LICENSE](LICENSE) for details.