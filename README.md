# Strain

Hyper-casual gravity-flip runner with in-run evolution and cross-run progression. Built with Flutter.

## Run

```bash
flutter pub get
flutter run
```

## Architecture

| Path | Purpose |
|------|---------|
| `lib/config/game_config.dart` | Physics and world tuning (single source of truth) |
| `lib/game/game_controller.dart` | Run loop, evolution, collisions |
| `lib/game/path_calculator.dart` | Safe vs temptation collectible placement |
| `lib/services/achievement_service.dart` | Persistent stats and Codex unlocks |
| `lib/screens/` | Main menu, game, field Codex |

Physics constants never change from upgrades — only world/challenge rules modify gravity, gaps, or cooldowns.

## Worlds

1. **Microverse** — baseline static gaps  
2. **Deep Ocean** — oscillating gap position  
3. **Neural** — 0.3s gravity-flip cooldown  
4. **Cosmic** — 60% gravity, narrower gaps  
5. **Viral** — shrinking gap height over time  

Clear a world by reaching **Organism** tier and surviving the 10-second countdown ring.
