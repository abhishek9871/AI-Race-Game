# 2D Bike Racing Game

A simple 2D side-scrolling bike racing game built with Godot 4.

## Current Status

**Minimal Viable Product** - Basic playable prototype with core mechanics.

### Implemented Features:
- Basic bike physics with CharacterBody2D
- Simple movement controls (accelerate, brake, jump)
- Static ground collision
- Basic HUD showing speed and stamina
- Placeholder graphics using ColorRect

## How to Run

1. **Install Godot 4.x** (tested with 4.2+)
2. **Open the project** in Godot Editor
   - Import the project by selecting `project.godot`
3. **Press F5** or click the Play button
4. **Controls:**
   - **Right Arrow**: Accelerate
   - **Left Arrow**: Brake
   - **Space**: Jump

## Game Mechanics

- Control a blue bike (placeholder rectangle)
- Build up speed by holding the right arrow
- Jump over obstacles with spacebar
- The camera follows the player

## Technical Notes

- Uses **Godot 4.x** format (not compatible with Godot 3.x)
- Placeholder graphics (ColorRect) - no external assets needed
- Simple physics using CharacterBody2D and move_and_slide()
- Minimal dependencies for easy testing

## Next Steps

Future enhancements could include:
- AI opponents
- Multiple tracks
- Power-ups and obstacles
- Proper sprite graphics
- Sound effects and music
- Stamina system implementation
