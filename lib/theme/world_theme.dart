import 'package:flutter/material.dart';
import '../models/world_id.dart';

class WorldThemeData {
  const WorldThemeData({
    required this.background,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.buttonFill,
    required this.obstacle,
    required this.collectible,
    required this.player,
    required this.playfield,
  });

  final Color background;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color text;
  final Color buttonFill;
  final Color obstacle;
  final Color collectible;
  final Color player;
  final Color playfield;

  static WorldThemeData forWorld(WorldId world) {
    switch (world) {
      case WorldId.microverse:
        return const WorldThemeData(
          background: Color(0xFF0D1B2A),
          primary: Color(0xFF1B998B),
          secondary: Color(0xFF7B2D8E),
          accent: Color(0xFF2EC4B6),
          text: Color(0xFFE0FBFC),
          buttonFill: Color(0xFF1B998B),
          obstacle: Color(0xFF415A77),
          collectible: Color(0xFF80FFDB),
          player: Color(0xFFFFD166),
          playfield: Color(0xFF14213D),
        );
      case WorldId.deepOcean:
        return const WorldThemeData(
          background: Color(0xFF001219),
          primary: Color(0xFF005F73),
          secondary: Color(0xFF0A9396),
          accent: Color(0xFF94D2BD),
          text: Color(0xFFE9D8A6),
          buttonFill: Color(0xFF0A9396),
          obstacle: Color(0xFF023047),
          collectible: Color(0xFFEE9B00),
          player: Color(0xFFCA6702),
          playfield: Color(0xFF001E2B),
        );
      case WorldId.neural:
        return const WorldThemeData(
          background: Color(0xFF10002B),
          primary: Color(0xFF7B2CBF),
          secondary: Color(0xFF9D4EDD),
          accent: Color(0xFFE0AAFF),
          text: Color(0xFFF8F9FA),
          buttonFill: Color(0xFF7B2CBF),
          obstacle: Color(0xFF3C096C),
          collectible: Color(0xFFC77DFF),
          player: Color(0xFFFF6D00),
          playfield: Color(0xFF240046),
        );
      case WorldId.cosmic:
        return const WorldThemeData(
          background: Color(0xFF0B0C10),
          primary: Color(0xFF66FCF1),
          secondary: Color(0xFF45A29E),
          accent: Color(0xFFC5C6C7),
          text: Color(0xFFF5F5F5),
          buttonFill: Color(0xFF45A29E),
          obstacle: Color(0xFF1F2833),
          collectible: Color(0xFF66FCF1),
          player: Color(0xFFFFD700),
          playfield: Color(0xFF1F2833),
        );
      case WorldId.viral:
        return const WorldThemeData(
          background: Color(0xFF1A0A0A),
          primary: Color(0xFFD00000),
          secondary: Color(0xFF9D0208),
          accent: Color(0xFFFFBA08),
          text: Color(0xFFFFF3E0),
          buttonFill: Color(0xFFD00000),
          obstacle: Color(0xFF370617),
          collectible: Color(0xFF06D6A0),
          player: Color(0xFFEF476F),
          playfield: Color(0xFF2D0A0A),
        );
    }
  }
}
