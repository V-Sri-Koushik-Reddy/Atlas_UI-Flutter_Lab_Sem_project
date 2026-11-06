import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ATLAS Travel Planner - everything in one file.
// Needs: flutter pub add shared_preferences crypto

// ═══════════════ theme ═══════════════

const muted = Color(0xFF777D77);

/// One selectable colour palette. Each works in light and dark mode.
@immutable
class AtlasPalette {
  final String name;
  final Color deep;
  final Color accent;
  final Color lightBg;
  final Color darkBg;
  final Color darkCard;

  const AtlasPalette({
    required this.name,
    required this.deep,
    required this.accent,
    required this.lightBg,
    required this.darkBg,
    required this.darkCard,
  });
}

const palettes = <AtlasPalette>[
  AtlasPalette(
    name: 'Forest',
    deep: Color(0xFF173D32),
    accent: Color(0xFFD6A85B),
    lightBg: Color(0xFFF7F6F1),
    darkBg: Color(0xFF111714),
    darkCard: Color(0xFF1B2420),
  ),
  AtlasPalette(
    name: 'Ocean',
    deep: Color(0xFF0E3A5B),
    accent: Color(0xFF4FC3D9),
    lightBg: Color(0xFFF1F6F9),
    darkBg: Color(0xFF0C1319),
    darkCard: Color(0xFF16212B),
  ),
  AtlasPalette(
    name: 'Sunset',
    deep: Color(0xFF6B2D3C),
    accent: Color(0xFFF2994A),
    lightBg: Color(0xFFFAF3EF),
    darkBg: Color(0xFF160F11),
    darkCard: Color(0xFF241A1D),
  ),
  AtlasPalette(
    name: 'Violet',
    deep: Color(0xFF3B2F7A),
    accent: Color(0xFFB892FF),
    lightBg: Color(0xFFF5F3FA),
    darkBg: Color(0xFF110F19),
    darkCard: Color(0xFF1C1928),
  ),
];

/// Extra colours that follow the active palette. Read with `context.ac`.
@immutable
class AtlasColors extends ThemeExtension<AtlasColors> {
  final Color deep;
  final Color accent;
  final Color accentInk; // readable accent for small text
  final Color card;

  const AtlasColors({
    required this.deep,
    required this.accent,
    required this.accentInk,
    required this.card,
  });

  @override
  AtlasColors copyWith(
          {Color? deep, Color? accent, Color? accentInk, Color? card}) =>
      AtlasColors(
        deep: deep ?? this.deep,
        accent: accent ?? this.accent,
        accentInk: accentInk ?? this.accentInk,
        card: card ?? this.card,
      );

  @override
  AtlasColors lerp(ThemeExtension<AtlasColors>? other, double t) {
    if (other is! AtlasColors) return this;
    return AtlasColors(
      deep: Color.lerp(deep, other.deep, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      card: Color.lerp(card, other.card, t)!,
    );
  }
}

extension AtlasContext on BuildContext {
  AtlasColors get ac => Theme.of(this).extension<AtlasColors>()!;
}

ThemeData buildTheme(AtlasPalette p, Brightness b) {
  final dark = b == Brightness.dark;
  final base = ColorScheme.fromSeed(seedColor: p.deep, brightness: b);
  final scheme = base.copyWith(
    primary: dark ? p.accent : p.deep,
    onPrimary: dark ? p.darkBg : Colors.white,
    secondary: p.accent,
    surface: dark ? p.darkBg : p.lightBg,
    surfaceTint: Colors.transparent,
  );
  final card = dark ? p.darkCard : Colors.white;
  final ink = dark
      ? p.accent
      : HSLColor.fromColor(p.accent).withLightness(.34).toColor();
  final outline = (dark ? Colors.white : Colors.black).withValues(alpha: .07);

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [
      AtlasColors(deep: p.deep, accent: p.accent, accentInk: ink, card: card),
    ],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: outline),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.accent.withValues(alpha: .28),
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w500,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: outline),
      selectedColor: p.accent.withValues(alpha: .28),
      checkmarkColor: scheme.onSurface,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.accent, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD64545)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD64545), width: 1.8),
      ),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: dark ? p.accent : p.deep,
      thumbColor: p.accent,
      inactiveTrackColor: (dark ? Colors.white : Colors.black)
          .withValues(alpha: .12),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dividerTheme: DividerThemeData(color: outline, space: 24),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}

// ═══════════════ widgets ═══════════════


String money(num n) {
  final value = n.round().toString();
  final formatted = value.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '₹$formatted';
}

/// Fades and slides its child up once, when first built.
/// Higher [index] values take slightly longer, giving a staggered entrance.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index.clamp(0, 6) * 80),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 20),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Small spaced-out label that sits above page titles.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: context.ac.accentInk,
          fontSize: 12,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
        ),
      );
}

class PageTitle extends StatelessWidget {
  final String text;
  final double size;
  const PageTitle(this.text, {super.key, this.size = 34});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          letterSpacing: -.5,
        ),
      );
}

// ═══════════════ scenes ═══════════════


enum SceneKind { mountains, beach, tea, fort, river, lake }

class ScenePainter extends CustomPainter {
  final SceneKind kind;

  /// Loops from 0 to 1. Drives clouds, waves, boat and sun.
  final double t;
  const ScenePainter(this.kind, this.t);

  static const Map<SceneKind, List<Color>> _sky = {
    SceneKind.mountains: [Color(0xFF7FB8E8), Color(0xFFF6E3C8)],
    SceneKind.beach: [Color(0xFF6E78B8), Color(0xFFF6B27A)],
    SceneKind.tea: [Color(0xFFB8D8C8), Color(0xFFEAF3EA)],
    SceneKind.fort: [Color(0xFFF4B27A), Color(0xFFFBE3B8)],
    SceneKind.river: [Color(0xFF8EC9E8), Color(0xFFE3F2E8)],
    SceneKind.lake: [Color(0xFF9FB8D8), Color(0xFFE4ECF4)],
  };

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset.zero & s;
    canvas.clipRect(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _sky[kind]!,
        ).createShader(rect),
    );
    _sun(canvas, s);
    _clouds(canvas, s);
    switch (kind) {
      case SceneKind.mountains:
        _mountains(canvas, s);
      case SceneKind.beach:
        _beach(canvas, s);
      case SceneKind.tea:
        _tea(canvas, s);
      case SceneKind.fort:
        _fort(canvas, s);
      case SceneKind.river:
        _river(canvas, s);
      case SceneKind.lake:
        _lake(canvas, s);
    }
  }

  // helpers ------------------------------------------------------------------

  Path _poly(Size s, List<List<double>> pts) {
    final p = Path()..moveTo(0, s.height);
    for (final o in pts) {
      p.lineTo(o[0] * s.width, o[1] * s.height);
    }
    return p
      ..lineTo(s.width, s.height)
      ..close();
  }

  Path _wave(Size s, double base, double amp, double freq, double phase) {
    final p = Path()..moveTo(0, s.height);
    for (double x = 0; x <= s.width; x += 4) {
      p.lineTo(
        x,
        s.height * base +
            math.sin(x / s.width * freq * 2 * math.pi + phase) *
                amp *
                s.height,
      );
    }
    return p
      ..lineTo(s.width, s.height)
      ..close();
  }

  void _fill(Canvas c, Path p, Color col) =>
      c.drawPath(p, Paint()..color = col);

  void _sun(Canvas c, Size s) {
    final pos = switch (kind) {
      SceneKind.beach => Offset(s.width * .3, s.height * .52),
      SceneKind.fort => Offset(s.width * .8, s.height * .25),
      _ => Offset(s.width * .78, s.height * .2),
    };
    final pulse = 1 + math.sin(t * 2 * math.pi) * .04;
    final r = s.height * .1 * pulse;
    c.drawCircle(pos, r * 2.4,
        Paint()..color = Colors.white.withValues(alpha: .18));
    c.drawCircle(pos, r * 1.6,
        Paint()..color = Colors.white.withValues(alpha: .28));
    c.drawCircle(pos, r, Paint()..color = const Color(0xFFFFF1C2));
  }

  void _clouds(Canvas c, Size s) {
    final p = Paint()..color = Colors.white.withValues(alpha: .75);
    const bases = [0.0, .35, .7];
    const ys = [.14, .26, .1];
    const scales = [1.0, .7, .85];
    for (var i = 0; i < 3; i++) {
      final x = (((bases[i] + t) % 1.0) * 1.4 - .2) * s.width;
      final y = ys[i] * s.height;
      final k = scales[i] * s.height * .09;
      c.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: k * 4, height: k * 1.4),
          p);
      c.drawOval(
          Rect.fromCenter(
              center: Offset(x + k, y - k * .5),
              width: k * 2.6,
              height: k * 1.6),
          p);
      c.drawOval(
          Rect.fromCenter(
              center: Offset(x - k * 1.1, y - k * .2),
              width: k * 2.2,
              height: k * 1.2),
          p);
    }
  }

  // scenes -------------------------------------------------------------------

  void _mountains(Canvas c, Size s) {
    const peaks = [
      [0.0, .62], [.15, .36], [.3, .56], [.5, .26], [.7, .56],
      [.85, .4], [1.0, .62],
    ];
    _fill(c, _poly(s, peaks), const Color(0xFF8CA7C4));

    final snow = Paint()..color = Colors.white.withValues(alpha: .92);
    for (final i in [1, 3, 5]) {
      final x = peaks[i][0] * s.width;
      final y = peaks[i][1] * s.height;
      final w = s.width * .055;
      final h = s.height * .1;
      c.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x - w, y + h)
          ..lineTo(x - w * .4, y + h * .8)
          ..lineTo(x, y + h * 1.1)
          ..lineTo(x + w * .5, y + h * .8)
          ..lineTo(x + w, y + h)
          ..close(),
        snow,
      );
    }

    _fill(
      c,
      _poly(s, const [
        [0.0, .82], [.2, .64], [.4, .8], [.62, .62], [.82, .78], [1.0, .66],
      ]),
      const Color(0xFF3F6B58),
    );

    final pine = Paint()..color = const Color(0xFF1F4034);
    for (var i = 0; i < 9; i++) {
      final x = (i + .5) / 9 * s.width;
      final base = s.height * (.9 + (i.isEven ? 0 : .03));
      final h = s.height * (.2 + (i % 3) * .04);
      final w = h * .45;
      for (var k = 0; k < 3; k++) {
        final top = base - h + k * h * .28;
        final bw = w * (.55 + k * .25);
        c.drawPath(
          Path()
            ..moveTo(x, top)
            ..lineTo(x - bw, top + h * .4)
            ..lineTo(x + bw, top + h * .4)
            ..close(),
          pine,
        );
      }
    }
    _fill(c, _wave(s, .96, .01, 2, 0), const Color(0xFF173D32));
  }

  void _beach(Canvas c, Size s) {
    final horizon = s.height * .58;
    final sea = Rect.fromLTRB(0, horizon, s.width, s.height);
    c.drawRect(
      sea,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0A36B), Color(0xFF1E7F8C)],
        ).createShader(sea),
    );

    final line = Paint()
      ..color = Colors.white.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (var r = 0; r < 4; r++) {
      final y = horizon + s.height * (.06 + r * .07);
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= s.width; x += 4) {
        path.lineTo(
          x,
          y +
              math.sin(x / s.width * 6 * math.pi +
                      t * 2 * math.pi * (r.isEven ? 1 : -1) +
                      r) *
                  3,
        );
      }
      c.drawPath(path, line);
    }

    _fill(c, _wave(s, .86, .02, 1.2, 1), const Color(0xFFF1D9A5));

    final trunk = Paint()
      ..color = const Color(0xFF6B4A2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * .014
      ..strokeCap = StrokeCap.round;
    final base = Offset(s.width * .8, s.height * .95);
    final top = Offset(s.width * .74, s.height * .4);
    c.drawPath(
      Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(s.width * .84, s.height * .65, top.dx, top.dy),
      trunk,
    );

    final leaf = Paint()
      ..color = const Color(0xFF2E7D4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * .012
      ..strokeCap = StrokeCap.round;
    final sway = math.sin(t * 2 * math.pi) * s.width * .01;
    const ends = [
      [-.17, .08], [-.1, .0], [.0, -.02], [.1, .0], [.16, .08],
    ];
    for (final e in ends) {
      final end = top + Offset(e[0] * s.width + sway, e[1] * s.height);
      final ctrl = top + Offset(e[0] * s.width * .5, -s.height * .14);
      c.drawPath(
        Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy),
        leaf,
      );
    }
  }

  void _tea(Canvas c, Size s) {
    _fill(c, _wave(s, .5, .05, 1.3, 0), const Color(0xFF9DC3A5));
    _fill(c, _wave(s, .62, .05, 1.8, 1.5), const Color(0xFF5E9A6B));
    _fill(c, _wave(s, .76, .05, 1.4, 3), const Color(0xFF2F6B45));

    final row = Paint()
      ..color = Colors.white.withValues(alpha: .14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 7; i++) {
      final y = s.height * (.8 + i * .035);
      final p = Path()..moveTo(0, y);
      for (double x = 0; x <= s.width; x += 6) {
        p.lineTo(x, y + math.sin(x / s.width * 5 + i * .6) * 4);
      }
      c.drawPath(p, row);
    }

    final mist = Rect.fromLTWH(0, s.height * .45, s.width, s.height * .2);
    c.drawRect(
      mist,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: .45),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(mist),
    );
  }

  void _fort(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;
    _fill(
      c,
      _poly(s, const [
        [0.0, .7], [.25, .62], [.5, .68], [.75, .6], [1.0, .7],
      ]),
      const Color(0xFFD9A377),
    );

    final wall = Paint()..color = const Color(0xFFD98A6A);
    final dark = Paint()..color = const Color(0xFFB5654A);

    c.drawRect(Rect.fromLTRB(w * .22, h * .45, w * .78, h * .88), wall);
    final cw = w * .56 / 14;
    for (var i = 0; i < 14; i++) {
      c.drawRect(
          Rect.fromLTWH(w * .22 + i * cw + 1, h * .41, cw - 3, h * .04), wall);
    }

    for (final x in [.16, .84]) {
      c.drawRect(
          Rect.fromLTRB(w * (x - .06), h * .38, w * (x + .06), h * .88), dark);
      c.drawArc(
        Rect.fromCenter(
            center: Offset(w * x, h * .38), width: w * .14, height: h * .16),
        math.pi,
        math.pi,
        true,
        wall,
      );
    }

    c.drawArc(
      Rect.fromCenter(
          center: Offset(w * .5, h * .45), width: w * .2, height: h * .34),
      math.pi,
      math.pi,
      true,
      dark,
    );

    final win = Paint()..color = const Color(0xFF6E3A2B);
    for (var r = 0; r < 2; r++) {
      for (var i = 0; i < 6; i++) {
        final x = w * (.27 + i * .083);
        final y = h * (.56 + r * .14);
        c.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x, y, w * .035, h * .09),
            topLeft: Radius.circular(w * .02),
            topRight: Radius.circular(w * .02),
          ),
          win,
        );
      }
    }
    _fill(c, _wave(s, .93, .01, 2, 0), const Color(0xFFC98E62));
  }

  void _river(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;
    _fill(
      c,
      _poly(s, const [
        [0.0, .55], [.2, .4], [.4, .52], [.6, .36], [.8, .5], [1.0, .42],
      ]),
      const Color(0xFF6FA67F),
    );
    _fill(c, _wave(s, .62, .04, 1.5, 2), const Color(0xFF3F7D55));

    final river = Rect.fromLTWH(0, h * .68, w, h * .32);
    c.drawRect(
      river,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5DB2C9), Color(0xFF2B7FA0)],
        ).createShader(river),
    );

    final flow = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 4; i++) {
      final y = h * (.74 + i * .06);
      final p = Path()..moveTo(0, y);
      for (double x = 0; x <= w; x += 4) {
        p.lineTo(
            x, y + math.sin(x / w * 8 - t * 2 * math.pi * (i.isEven ? 1 : 2)) * 2.5);
      }
      c.drawPath(p, flow);
    }

    // suspension bridge
    final steel = Paint()
      ..color = const Color(0xFF3B2F2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    for (final x in [.18, .82]) {
      c.drawLine(Offset(w * x, h * .3), Offset(w * x, h * .68), steel);
    }
    c.drawPath(
      Path()
        ..moveTo(w * .18, h * .3)
        ..quadraticBezierTo(w * .5, h * .7, w * .82, h * .3),
      steel,
    );
    c.drawLine(Offset(w * .18, h * .58), Offset(w * .82, h * .58), steel);
    final hanger = Paint()
      ..color = const Color(0xFF3B2F2F)
      ..strokeWidth = 1;
    for (var i = 1; i < 12; i++) {
      final u = i / 12;
      final x = w * (.18 + .64 * u);
      final cableY = (1 - u) * (1 - u) * h * .3 +
          2 * (1 - u) * u * h * .7 +
          u * u * h * .3;
      c.drawLine(Offset(x, cableY), Offset(x, h * .58), hanger);
    }
  }

  void _lake(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;
    _fill(
      c,
      _poly(s, const [
        [0.0, .5], [.25, .34], [.5, .48], [.75, .3], [1.0, .46],
      ]),
      const Color(0xFF6F8FB0),
    );
    _fill(c, _wave(s, .52, .03, 1.6, 1), const Color(0xFF4F7F6A));

    final lake = Rect.fromLTRB(0, h * .6, w, h);
    c.drawRect(
      lake,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7FB3D5), Color(0xFF2F6F96)],
        ).createShader(lake),
    );

    final ripple = Paint()
      ..color = Colors.white.withValues(alpha: .3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < 4; i++) {
      final y = h * (.66 + i * .08);
      final p = Path()..moveTo(0, y);
      for (double x = 0; x <= w; x += 4) {
        p.lineTo(x, y + math.sin(x / w * 7 + t * 2 * math.pi + i) * 2);
      }
      c.drawPath(p, ripple);
    }

    // boat
    final bob = math.sin(t * 2 * math.pi * 2) * 3;
    final bx = w * .45 + math.sin(t * 2 * math.pi) * w * .04;
    final by = h * .78 + bob;
    c.drawPath(
      Path()
        ..moveTo(bx - w * .07, by)
        ..lineTo(bx + w * .07, by)
        ..lineTo(bx + w * .05, by + h * .05)
        ..lineTo(bx - w * .05, by + h * .05)
        ..close(),
      Paint()..color = const Color(0xFFB5543A),
    );
    c.drawPath(
      Path()
        ..moveTo(bx, by - h * .2)
        ..lineTo(bx, by - 2)
        ..lineTo(bx + w * .06, by - 2)
        ..close(),
      Paint()..color = Colors.white,
    );

    // trees
    final leaf = Paint()..color = const Color(0xFF2F6B45);
    final bark = Paint()..color = const Color(0xFF5B4030);
    for (final x in [.06, .14, .9, .96]) {
      c.drawRect(
          Rect.fromLTWH(w * x - 2, h * .6, 4, h * .08), bark);
      c.drawCircle(Offset(w * x, h * .58), w * .045, leaf);
    }
  }

  @override
  bool shouldRepaint(ScenePainter old) => old.t != t || old.kind != kind;
}

/// A painted scene.
///
/// PERFORMANCE: by default the scene is painted once and cached by the
/// raster cache (no per-frame work), so scrolling and page switches stay
/// smooth. Pass [animate] = true only for a single large hero image.
class SceneArt extends StatefulWidget {
  final SceneKind kind;
  final bool animate;
  const SceneArt({super.key, required this.kind, this.animate = false});

  @override
  State<SceneArt> createState() => _SceneArtState();
}

class _SceneArtState extends State<SceneArt>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 24),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) {
      return RepaintBoundary(
        child: CustomPaint(
          painter: ScenePainter(widget.kind, .15),
          isComplex: true,
          willChange: false,
          size: Size.infinite,
        ),
      );
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) => CustomPaint(
          painter: ScenePainter(widget.kind, c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

// ═══════════════ data ═══════════════


class Destination {
  final String name;
  final String country;
  final String category;
  final String description;
  final String emoji;
  final SceneKind scene;

  /// Optional real photo. Leave empty to show only the painted scene.
  final String photoUrl;
  final String bestSeason;
  final String tip;
  final int dailyCost;
  final double rating;
  final int days;
  final List<String> activities;

  const Destination({
    required this.name,
    required this.country,
    required this.category,
    required this.description,
    required this.emoji,
    required this.scene,
    required this.bestSeason,
    required this.tip,
    required this.dailyCost,
    required this.rating,
    required this.days,
    required this.activities,
    this.photoUrl = '',
  });

  int estimate(int travellers, int tripDays) =>
      dailyCost * travellers * tripDays;
}

const places = <Destination>[
  Destination(
    name: 'Manali',
    country: 'Himachal Pradesh',
    category: 'Mountains',
    description: 'Pine forests, mountain roads and Himalayan views.',
    emoji: '🏔️',
    scene: SceneKind.mountains,
    bestSeason: 'Mar – Jun, Dec – Feb',
    tip: 'Carry warm layers, even for summer evenings.',
    dailyCost: 2400,
    rating: 4.8,
    days: 4,
    activities: ['Solang Valley', 'Old Manali walk', 'Mountain café',
      'Rohtang-area sightseeing'],
  ),
  Destination(
    name: 'Goa',
    country: 'India',
    category: 'Beach',
    description: 'Sunsets, colourful streets and relaxed beach days.',
    emoji: '🏝️',
    scene: SceneKind.beach,
    bestSeason: 'Nov – Feb',
    tip: 'Book beach stays early during peak season.',
    dailyCost: 2800,
    rating: 4.7,
    days: 3,
    activities: ['Beach sunrise', 'Old Goa heritage walk',
      'Local food tour', 'Sunset by the sea'],
  ),
  Destination(
    name: 'Munnar',
    country: 'Kerala',
    category: 'Nature',
    description: 'Tea gardens, misty hills and quiet scenic drives.',
    emoji: '🌿',
    scene: SceneKind.tea,
    bestSeason: 'Sep – May',
    tip: 'Start early to catch the misty viewpoints.',
    dailyCost: 2100,
    rating: 4.6,
    days: 3,
    activities: ['Tea garden visit', 'Scenic viewpoint',
      'Tea museum', 'Nature walk'],
  ),
  Destination(
    name: 'Jaipur',
    country: 'Rajasthan',
    category: 'Culture',
    description: 'Royal architecture, markets and local cuisine.',
    emoji: '🏰',
    scene: SceneKind.fort,
    bestSeason: 'Oct – Mar',
    tip: 'Visit forts in the morning to avoid the midday heat.',
    dailyCost: 1900,
    rating: 4.7,
    days: 2,
    activities: ['Amber Fort', 'City Palace',
      'Hawa Mahal viewpoint', 'Local bazaar'],
  ),
  Destination(
    name: 'Rishikesh',
    country: 'Uttarakhand',
    category: 'Adventure',
    description: 'River views, yoga, trails and outdoor activities.',
    emoji: '🌊',
    scene: SceneKind.river,
    bestSeason: 'Sep – Nov, Feb – May',
    tip: 'Check activity availability before planning rafting days.',
    dailyCost: 1800,
    rating: 4.5,
    days: 3,
    activities: ['Riverfront walk', 'Café by the Ganges',
      'Nature trail', 'Evening aarti'],
  ),
  Destination(
    name: 'Ooty',
    country: 'Tamil Nadu',
    category: 'Nature',
    description: 'Cool weather, gardens and winding hill roads.',
    emoji: '🚞',
    scene: SceneKind.lake,
    bestSeason: 'Mar – Jun, Sep – Nov',
    tip: 'Reserve scenic train tickets in advance.',
    dailyCost: 2200,
    rating: 4.5,
    days: 3,
    activities: ['Botanical Garden', 'Tea factory',
      'Scenic train experience', 'Lake walk'],
  ),
];

/// Destination picture: a cached painted scene, plus an optional real photo
/// that fades in on top. Set [animate] only for one big hero image.
class PlaceImage extends StatelessWidget {
  final Destination place;
  final double? height;
  final double? width;
  final bool animate;

  const PlaceImage({
    super.key,
    required this.place,
    this.height,
    this.width,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SceneArt(kind: place.scene, animate: animate),
          if (place.photoUrl.isNotEmpty)
            Image.network(
              Uri.encodeFull(place.photoUrl),
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSync) {
                if (wasSync) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

// ═══════════════ auth ═══════════════



// ─────────────────────────────────────────────────────────────────────────────
// AUTH SERVICE (local, on-device)
// Accounts are stored on this device only, with salted SHA-256 password
// hashes. This is a demo-grade system, not a replacement for a real backend.
// ─────────────────────────────────────────────────────────────────────────────

enum AuthIssue { none, emailTaken, noAccount, wrongPassword }

class AuthResult {
  final bool ok;
  final AuthIssue issue;
  final String message;
  final String? name;
  final String? email;

  const AuthResult.success(this.message, {this.name, this.email})
      : ok = true,
        issue = AuthIssue.none;

  const AuthResult.failure(this.message, this.issue)
      : ok = false,
        name = null,
        email = null;
}

class AuthService {
  AuthService(this.prefs) {
    _load();
  }

  final SharedPreferences prefs;
  Map<String, Map<String, String>> _users = {};

  static const _usersKey = 'atlas_users';
  static const _sessionKey = 'atlas_session';

  String _norm(String email) => email.trim().toLowerCase();

  void _load() {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _users = decoded.map(
        (k, v) => MapEntry(k, Map<String, String>.from(v as Map)),
      );
    } catch (_) {
      _users = {};
    }
  }

  Future<void> _save() => prefs.setString(_usersKey, jsonEncode(_users));

  String _salt() {
    final r = math.Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  bool emailExists(String email) => _users.containsKey(_norm(email));

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required bool remember,
  }) async {
    final key = _norm(email);
    if (_users.containsKey(key)) {
      return const AuthResult.failure(
        'An account with this email already exists.',
        AuthIssue.emailTaken,
      );
    }
    final salt = _salt();
    _users[key] = {
      'name': name.trim(),
      'salt': salt,
      'hash': _hash(password, salt),
    };
    await _save();
    if (remember) await prefs.setString(_sessionKey, key);
    return AuthResult.success(
      'Account created successfully! Signing you in…',
      name: name.trim(),
      email: key,
    );
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
    required bool remember,
  }) async {
    final key = _norm(email);
    final user = _users[key];
    if (user == null) {
      return const AuthResult.failure(
        'No account found for this email.',
        AuthIssue.noAccount,
      );
    }
    if (_hash(password, user['salt']!) != user['hash']) {
      return const AuthResult.failure(
        'Incorrect password. Please try again.',
        AuthIssue.wrongPassword,
      );
    }
    if (remember) {
      await prefs.setString(_sessionKey, key);
    } else {
      await prefs.remove(_sessionKey);
    }
    return AuthResult.success(
      'Signed in. Welcome back, ${user['name']}!',
      name: user['name'],
      email: key,
    );
  }

  /// Returns the remembered user, if there is one.
  AuthResult? restoreSession() {
    final key = prefs.getString(_sessionKey);
    final user = key == null ? null : _users[key];
    if (user == null) return null;
    return AuthResult.success('Restored', name: user['name'], email: key);
  }

  Future<void> signOut() => prefs.remove(_sessionKey);

  // Per-user saved places ----------------------------------------------------

  Set<String> favourites(String email) =>
      (prefs.getStringList('fav:$email') ?? const <String>[]).toSet();

  Future<void> saveFavourites(String email, Set<String> names) =>
      prefs.setStringList('fav:$email', names.toList());
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH PAGE
// ─────────────────────────────────────────────────────────────────────────────

class _Banner {
  final bool ok;
  final String text;
  final String? actionLabel;
  final VoidCallback? action;
  const _Banner(this.ok, this.text, {this.actionLabel, this.action});
}

class AuthPage extends StatefulWidget {
  final AuthService auth;
  final void Function(String name, String? email) onEnter;
  const AuthPage({super.key, required this.auth, required this.onEnter});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool register = false;
  bool hide = true;
  bool remember = true;
  bool loading = false;
  _Banner? banner;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _setMode(bool toRegister) {
    setState(() {
      register = toRegister;
      banner = null;
    });
  }

  double _strength(String p) {
    var s = 0;
    if (p.length >= 6) s++;
    if (p.length >= 10) s++;
    if (RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s / 5;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) {
      setState(() =>
          banner = const _Banner(false, 'Please fix the highlighted fields.'));
      return;
    }
    setState(() {
      loading = true;
      banner = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final res = register
        ? await widget.auth.register(
            name: _name.text,
            email: _email.text,
            password: _password.text,
            remember: remember,
          )
        : await widget.auth.signIn(
            email: _email.text,
            password: _password.text,
            remember: remember,
          );
    if (!mounted) return;

    if (res.ok) {
      setState(() {
        loading = false;
        banner = _Banner(true, res.message);
      });
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
      widget.onEnter(res.name ?? 'Traveler', res.email);
      return;
    }

    setState(() {
      loading = false;
      banner = switch (res.issue) {
        AuthIssue.emailTaken => _Banner(false, res.message,
            actionLabel: 'Sign in instead', action: () => _setMode(false)),
        AuthIssue.noAccount => _Banner(false, res.message,
            actionLabel: 'Create account', action: () => _setMode(true)),
        _ => _Banner(false, res.message),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;

    final hero = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          const Positioned.fill(
            child: SceneArt(kind: SceneKind.mountains),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    ac.deep.withValues(alpha: .92),
                  ],
                  stops: const [.25, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 150, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.explore, color: ac.accent, size: 36),
                const SizedBox(height: 10),
                const Text('ATLAS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5)),
                Text('TRAVEL, YOUR WAY',
                    style: TextStyle(
                        color: ac.accent,
                        fontSize: 12,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text(
                  'Discover places, set your budget, and shape a trip that feels like yours.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 18),
                _perk(Icons.wallet_outlined, 'Plan around your own budget'),
                _perk(Icons.route_outlined, 'Build a day-by-day itinerary'),
                _perk(Icons.favorite_border, 'Save places you love'),
              ],
            ),
          ),
        ],
      ),
    );

    final form = Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  key: ValueKey(register),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(register ? 'CREATE ACCOUNT' : 'WELCOME BACK'),
                    const SizedBox(height: 10),
                    PageTitle(
                      register ? 'Start exploring.' : 'Your next story awaits.',
                      size: 28,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: register
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: TextFormField(
                          controller: _name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Your name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) {
                            if (!register) return null;
                            final t = (v ?? '').trim();
                            if (t.isEmpty) return 'Enter your name';
                            if (t.length < 2) return 'Name is too short';
                            return null;
                          },
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Enter your email';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: hide,
                textInputAction:
                    register ? TextInputAction.next : TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) {
                  if (!register) _submit();
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => hide = !hide),
                    icon: Icon(hide
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
                validator: (v) {
                  final t = v ?? '';
                  if (t.isEmpty) return 'Enter your password';
                  if (register && t.length < 6) {
                    return 'Use at least 6 characters';
                  }
                  return null;
                },
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: register
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _strengthMeter(),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirm,
                            obscureText: hide,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              labelText: 'Confirm password',
                              prefixIcon: Icon(Icons.lock_reset_outlined),
                            ),
                            validator: (v) {
                              if (!register) return null;
                              if (v != _password.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                value: remember,
                onChanged: (v) => setState(() => remember = v ?? true),
                title: const Text('Keep me signed in on this device'),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: banner == null
                    ? const SizedBox(width: double.infinity)
                    : _bannerView(banner!),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : _submit,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: loading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : Text(
                            register ? 'Create account' : 'Sign in',
                            key: ValueKey(register),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: loading ? null : () => _setMode(!register),
                  child: Text(register
                      ? 'Already have an account? Sign in'
                      : 'New to ATLAS? Create an account'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: loading
                      ? null
                      : () => widget.onEnter('Guest', null),
                  child: const Text('Continue as guest'),
                ),
              ),
              const Text(
                'Accounts are stored on this device only.',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: LayoutBuilder(builder: (context, constraints) {
                final wide = constraints.maxWidth > 700;
                return wide
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: FadeSlideIn(child: hero)),
                            const SizedBox(width: 22),
                            Expanded(
                                child: FadeSlideIn(index: 2, child: form)),
                          ],
                        ),
                      )
                    : Column(children: [
                        SizedBox(
                          height: 420,
                          child: FadeSlideIn(child: hero),
                        ),
                        const SizedBox(height: 20),
                        FadeSlideIn(index: 2, child: form),
                      ]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _perk(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Icon(icon, color: context.ac.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text, style: const TextStyle(color: Colors.white))),
        ]),
      );

  Widget _strengthMeter() {
    final s = _strength(_password.text);
    final (label, color) = switch (s) {
      0 => ('Enter a password', muted),
      < .4 => ('Weak', const Color(0xFFD64545)),
      < .7 => ('Fair', const Color(0xFFE0A030)),
      _ => ('Strong', const Color(0xFF3E9B5F)),
    };
    return Row(children: [
      Expanded(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: s),
          duration: const Duration(milliseconds: 300),
          builder: (context, v, _) => LinearProgressIndicator(
            value: v,
            minHeight: 6,
            color: color,
            backgroundColor: muted.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _bannerView(_Banner b) {
    final color = b.ok ? const Color(0xFF3E9B5F) : const Color(0xFFD64545);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Row(children: [
        Icon(b.ok ? Icons.check_circle : Icons.error_outline, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(b.text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        if (b.actionLabel != null)
          TextButton(onPressed: b.action, child: Text(b.actionLabel!)),
      ]),
    );
  }
}

// ═══════════════ main ═══════════════



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(AtlasApp(prefs: prefs));
}

// ─────────────────────────────────────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────────────────────────────────────

class AtlasApp extends StatefulWidget {
  final SharedPreferences prefs;
  const AtlasApp({super.key, required this.prefs});

  @override
  State<AtlasApp> createState() => _AtlasAppState();
}

class _AtlasAppState extends State<AtlasApp> {
  late final AuthService auth = AuthService(widget.prefs);
  late ThemeMode mode;
  late int paletteIndex;
  late ThemeData _light;
  late ThemeData _dark;

  bool signedIn = false;
  String userName = 'Traveler';
  String? userEmail;

  @override
  void initState() {
    super.initState();
    mode = ThemeMode.values[(widget.prefs.getInt('mode') ?? 0).clamp(0, 2)];
    paletteIndex =
        (widget.prefs.getInt('palette') ?? 0).clamp(0, palettes.length - 1);
    _rebuildThemes();

    final restored = auth.restoreSession();
    if (restored != null) {
      signedIn = true;
      userName = restored.name ?? 'Traveler';
      userEmail = restored.email;
    }
  }

  // Themes are built once per palette change, not on every frame.
  void _rebuildThemes() {
    final p = palettes[paletteIndex];
    _light = buildTheme(p, Brightness.light);
    _dark = buildTheme(p, Brightness.dark);
  }

  void setMode(ThemeMode m) {
    setState(() => mode = m);
    widget.prefs.setInt('mode', m.index);
  }

  void setPalette(int i) {
    setState(() {
      paletteIndex = i;
      _rebuildThemes();
    });
    widget.prefs.setInt('palette', i);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ATLAS Travel Planner',
      theme: _light,
      darkTheme: _dark,
      themeMode: mode,
      themeAnimationDuration: const Duration(milliseconds: 350),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: signedIn
            ? AtlasHome(
                key: ValueKey('home-$userEmail'),
                userName: userName,
                userEmail: userEmail,
                auth: auth,
                mode: mode,
                paletteIndex: paletteIndex,
                onMode: setMode,
                onPalette: setPalette,
                onSignOut: () async {
                  await auth.signOut();
                  if (mounted) setState(() => signedIn = false);
                },
              )
            : AuthPage(
                key: const ValueKey('auth'),
                auth: auth,
                onEnter: (name, email) => setState(() {
                  userName = name;
                  userEmail = email;
                  signedIn = true;
                }),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APPEARANCE SHEET
// ─────────────────────────────────────────────────────────────────────────────

void showAppearanceSheet(
  BuildContext context, {
  required ThemeMode mode,
  required int palette,
  required ValueChanged<ThemeMode> onMode,
  required ValueChanged<int> onPalette,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _AppearanceSheet(
      mode: mode,
      palette: palette,
      onMode: onMode,
      onPalette: onPalette,
    ),
  );
}

class _AppearanceSheet extends StatefulWidget {
  final ThemeMode mode;
  final int palette;
  final ValueChanged<ThemeMode> onMode;
  final ValueChanged<int> onPalette;
  const _AppearanceSheet({
    required this.mode,
    required this.palette,
    required this.onMode,
    required this.onPalette,
  });

  @override
  State<_AppearanceSheet> createState() => _AppearanceSheetState();
}

class _AppearanceSheetState extends State<_AppearanceSheet> {
  late ThemeMode mode = widget.mode;
  late int palette = widget.palette;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle('Appearance', size: 26),
            const SizedBox(height: 18),
            const Text('Mode', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto),
                      label: Text('System')),
                  ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Light')),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Dark')),
                ],
                selected: {mode},
                onSelectionChanged: (s) {
                  setState(() => mode = s.first);
                  widget.onMode(s.first);
                },
              ),
            ),
            const SizedBox(height: 22),
            const Text('Colour palette',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < palettes.length; i++)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => palette = i);
                      widget.onPalette(i);
                    },
                    child: Column(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [palettes[i].deep, palettes[i].accent],
                          ),
                          border: Border.all(
                            color: palette == i
                                ? palettes[i].accent
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: palette == i ? 1 : 0,
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(palettes[i].name,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: palette == i
                                  ? FontWeight.w800
                                  : FontWeight.w500)),
                    ]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DONUT CHART
// ─────────────────────────────────────────────────────────────────────────────

class DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double progress;
  final Color track;

  const DonutPainter({
    required this.values,
    required this.colors,
    required this.progress,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: math.min(size.width, size.height) / 2 - stroke / 2,
    );
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2 * progress;
      if (sweep <= 0) continue;
      final gap = sweep > .12 ? .05 : 0.0;
      canvas.drawArc(
        rect,
        start + gap / 2,
        sweep - gap,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = colors[i],
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) =>
      old.progress != progress ||
      old.values != values ||
      old.track != track;
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURED CAROUSEL
// ─────────────────────────────────────────────────────────────────────────────

class FeaturedCarousel extends StatefulWidget {
  final List<Destination> items;
  final ValueChanged<Destination> onTap;
  const FeaturedCarousel({super.key, required this.items, required this.onTap});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final _pc = PageController(viewportFraction: .86);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    return SizedBox(
      height: 210,
      child: PageView.builder(
        controller: _pc,
        itemCount: widget.items.length,
        itemBuilder: (context, i) {
          final place = widget.items[i];
          // The heavy picture is built once and reused while scaling.
          final card = GestureDetector(
            onTap: () => widget.onTap(place),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PlaceImage(place: place),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: .6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      bottom: 16,
                      right: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place.category.toUpperCase(),
                              style: TextStyle(
                                  color: ac.accent,
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(place.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900)),
                          Text(
                              '${place.country} • from ${money(place.dailyCost)}/day',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          return RepaintBoundary(
            child: AnimatedBuilder(
              animation: _pc,
              child: card,
              builder: (context, child) {
                var scale = i == 0 ? 1.0 : .9;
                if (_pc.hasClients && _pc.position.haveDimensions) {
                  final page = _pc.page ?? 0;
                  scale =
                      (1 - (page - i).abs() * .1).clamp(.88, 1.0).toDouble();
                }
                return Center(
                    child: Transform.scale(scale: scale, child: child));
              },
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESTINATION DETAIL PAGE
// ─────────────────────────────────────────────────────────────────────────────

class DestinationPage extends StatefulWidget {
  final Destination place;
  final String? heroTag;
  final bool saved;
  final int tripDays;
  final int travellers;
  final VoidCallback onToggleSave;
  final VoidCallback onPlan;

  const DestinationPage({
    super.key,
    required this.place,
    required this.heroTag,
    required this.saved,
    required this.tripDays,
    required this.travellers,
    required this.onToggleSave,
    required this.onPlan,
  });

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  late bool saved = widget.saved;

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    final p = widget.place;
    final est = p.estimate(widget.travellers, widget.tripDays);

    // Only this single large header animates (clouds, waves, sun).
    Widget image = PlaceImage(place: p, animate: true);
    if (widget.heroTag != null) {
      image = Hero(tag: widget.heroTag!, child: image);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: ac.deep,
            foregroundColor: Colors.white,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton.filledTonal(
                  tooltip: saved ? 'Remove saved place' : 'Save place',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    widget.onToggleSave();
                    setState(() => saved = !saved);
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      saved ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(saved),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              title: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  image,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: .55),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        child: Row(children: [
                          Text('${p.emoji}  ${p.country}',
                              style: const TextStyle(color: muted)),
                          const Spacer(),
                          Icon(Icons.star, color: ac.accent, size: 18),
                          Text(' ${p.rating}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        index: 1,
                        child: Text(p.description,
                            style: const TextStyle(fontSize: 17, height: 1.6)),
                      ),
                      const SizedBox(height: 20),
                      FadeSlideIn(
                        index: 2,
                        child: Row(children: [
                          _InfoTile(
                              icon: Icons.payments_outlined,
                              label: 'Per person / day',
                              value: money(p.dailyCost)),
                          const SizedBox(width: 10),
                          _InfoTile(
                              icon: Icons.wb_sunny_outlined,
                              label: 'Best season',
                              value: p.bestSeason),
                          const SizedBox(width: 10),
                          _InfoTile(
                              icon: Icons.schedule,
                              label: 'Ideal stay',
                              value: '${p.days} days'),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      const FadeSlideIn(
                          index: 3, child: SectionLabel('HIGHLIGHTS')),
                      const SizedBox(height: 10),
                      FadeSlideIn(
                        index: 3,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final a in p.activities)
                              Chip(
                                avatar: Icon(Icons.place_outlined,
                                    size: 16, color: ac.accentInk),
                                label: Text(a),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeSlideIn(
                        index: 4,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: ac.deep,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'ESTIMATE • ${widget.tripDays} DAYS • ${widget.travellers} TRAVELLERS',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      letterSpacing: 1.2)),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: est.toDouble()),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, v, _) => Text(money(v),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                  'Based on your current trip settings. Change them in My trip.',
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeSlideIn(
                        index: 5,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ac.accent.withValues(alpha: .16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(children: [
                            Icon(Icons.lightbulb_outline, color: ac.accentInk),
                            const SizedBox(width: 12),
                            Expanded(child: Text(p.tip)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPlan();
            },
            icon: const Icon(Icons.route),
            label: const Text('Plan this trip'),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: context.ac.accentInk, size: 20),
                const SizedBox(height: 8),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(color: muted, fontSize: 10)),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME
// ─────────────────────────────────────────────────────────────────────────────

class AtlasHome extends StatefulWidget {
  final String userName;
  final String? userEmail;
  final AuthService auth;
  final ThemeMode mode;
  final int paletteIndex;
  final ValueChanged<ThemeMode> onMode;
  final ValueChanged<int> onPalette;
  final VoidCallback onSignOut;

  const AtlasHome({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.auth,
    required this.mode,
    required this.paletteIndex,
    required this.onMode,
    required this.onPalette,
    required this.onSignOut,
  });

  @override
  State<AtlasHome> createState() => _AtlasHomeState();
}

class _AtlasHomeState extends State<AtlasHome> {
  int tab = 0;
  int previousTab = 0;
  String query = '';
  String category = 'All';
  String sort = 'Recommended';
  bool savedOnly = false;
  bool withinBudgetOnly = false;
  final Set<String> favourites = {};
  final Set<String> completed = {};
  final List<String> customActivities = [];

  Destination selected = places.first;
  int tripDays = 3;
  int travellers = 2;

  double budget = 30000;
  double accommodation = 0.35;
  double transport = 0.25;
  double food = 0.20;
  double activities = 0.20;

  final budgetController = TextEditingController(text: '30000');
  final daysController = TextEditingController(text: '3');
  final peopleController = TextEditingController(text: '2');
  final customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final email = widget.userEmail;
    if (email != null) favourites.addAll(widget.auth.favourites(email));
  }

  @override
  void dispose() {
    budgetController.dispose();
    daysController.dispose();
    peopleController.dispose();
    customController.dispose();
    super.dispose();
  }

  int get estimate => selected.estimate(travellers, tripDays);
  int get remaining => budget.round() - estimate;

  void goToTab(int v) {
    if (v == tab) return;
    setState(() {
      previousTab = tab;
      tab = v;
    });
  }

  void toggleSave(Destination place) {
    HapticFeedback.selectionClick();
    setState(() {
      favourites.contains(place.name)
          ? favourites.remove(place.name)
          : favourites.add(place.name);
    });
    final email = widget.userEmail;
    if (email != null) widget.auth.saveFavourites(email, favourites);
  }

  void updateBudget(String value) {
    final n = int.tryParse(value.replaceAll(',', '').trim());
    if (n != null && n >= 0) setState(() => budget = n.toDouble());
  }

  void setBudgetFromSlider(double value) {
    setState(() {
      budget = value;
      budgetController.text = value.round().toString();
      budgetController.selection =
          TextSelection.collapsed(offset: budgetController.text.length);
    });
  }

  void notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void plan(Destination place) {
    setState(() {
      selected = place;
      tripDays = place.days;
      daysController.text = '$tripDays';
      previousTab = tab;
      tab = 2;
    });
  }

  void openDetail(Destination place, {String? heroTag}) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, _, _) => DestinationPage(
          place: place,
          heroTag: heroTag,
          saved: favourites.contains(place.name),
          tripDays: tripDays,
          travellers: travellers,
          onToggleSave: () => toggleSave(place),
          onPlan: () => plan(place),
        ),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  void openAppearance() {
    showAppearanceSheet(
      context,
      mode: widget.mode,
      palette: widget.paletteIndex,
      onMode: widget.onMode,
      onPalette: widget.onPalette,
    );
  }

  List<Destination> _filtered() {
    final list = places.where((p) {
      final matchesQuery =
          '${p.name} ${p.country}'.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'All' || p.category == category;
      final matchesSaved = !savedOnly || favourites.contains(p.name);
      final matchesBudget =
          !withinBudgetOnly || p.estimate(travellers, tripDays) <= budget;
      return matchesQuery && matchesCategory && matchesSaved && matchesBudget;
    }).toList();

    if (sort == 'Lowest cost') {
      list.sort((a, b) => a.dailyCost.compareTo(b.dailyCost));
    } else if (sort == 'Top rated') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goingRight = tab >= previousTab;

    // Only the visible page is built (the other three cost nothing).
    final page = switch (tab) {
      0 => _buildExplore(_filtered()),
      1 => _buildSaved(),
      2 => _buildPlanner(),
      _ => _buildBudget(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.explore, color: ac.accent),
          const SizedBox(width: 8),
          const Text('ATLAS',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Appearance',
            onPressed: openAppearance,
            icon: const Icon(Icons.palette_outlined),
          ),
          IconButton(
            tooltip: 'Switch light / dark',
            onPressed: () =>
                widget.onMode(isDark ? ThemeMode.light : ThemeMode.dark),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              tooltip: 'Account',
              onSelected: (v) {
                if (v == 'logout') widget.onSignOut();
                if (v == 'summary') showSummary();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    widget.userEmail ?? 'Guest session',
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                ),
                const PopupMenuItem(
                    value: 'summary', child: Text('Trip summary')),
                const PopupMenuItem(value: 'logout', child: Text('Sign out')),
              ],
              child: CircleAvatar(
                backgroundColor: ac.deep,
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : 'T',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (current, previous) => Stack(
                  fit: StackFit.expand,
                  children: [...previous, ?current],
                ),
                transitionBuilder: (child, animation) {
                  final incoming = child.key == ValueKey(tab);
                  final begin = incoming
                      ? Offset(goingRight ? 0.05 : -0.05, 0)
                      : Offset(goingRight ? -0.05 : 0.05, 0);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: begin, end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(tab),
                  child: RepaintBoundary(child: page),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: goToTab,
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore'),
          NavigationDestination(
              icon: Badge.count(
                count: favourites.length,
                isLabelVisible: favourites.isNotEmpty,
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: const Icon(Icons.favorite),
              label: 'Saved'),
          const NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route),
              label: 'My trip'),
          const NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Budget'),
        ],
      ),
    );
  }

  // ── EXPLORE ────────────────────────────────────────────────────────────────

  Widget _buildExplore(List<Destination> destinations) {
    final trending = places.where((p) => p.rating >= 4.7).toList();
    final first = widget.userName.split(' ').first;
    final greeting =
        widget.userEmail == null ? 'Where to next?' : 'Where to next, $first?';

    return CustomScrollView(
      primary: false,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('FIND YOUR NEXT ESCAPE'),
              const SizedBox(height: 10),
              PageTitle(greeting),
              const SizedBox(height: 8),
              const Text(
                  'Discover places that fit your travel style and budget.'),
              const SizedBox(height: 20),
              FeaturedCarousel(items: trending, onTap: openDetail),
              const SizedBox(height: 20),
              TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: const InputDecoration(
                  hintText: 'Search places or regions...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in [
                    'All', 'Mountains', 'Beach', 'Nature', 'Culture',
                    'Adventure'
                  ])
                    ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setState(() => category = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilterChip(
                    label: const Text('Saved only'),
                    selected: savedOnly,
                    onSelected: (v) => setState(() => savedOnly = v),
                  ),
                  FilterChip(
                    label: const Text('Within my budget'),
                    selected: withinBudgetOnly,
                    onSelected: (v) => setState(() => withinBudgetOnly = v),
                  ),
                  const SizedBox(width: 6),
                  const Text('Sort:', style: TextStyle(color: muted)),
                  for (final s in ['Recommended', 'Lowest cost', 'Top rated'])
                    ChoiceChip(
                      label: Text(s),
                      selected: sort == s,
                      onSelected: (_) => setState(() => sort = s),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text('${destinations.length} destinations',
                  style: const TextStyle(color: muted)),
              const SizedBox(height: 12),
            ],
          ),
        ),
        if (destinations.isEmpty)
          const SliverToBoxAdapter(
            child: _EmptyState(
              icon: Icons.search_off,
              title: 'No matches',
              detail: 'Try another category or budget.',
            ),
          )
        else
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisExtent: 375,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: destinations.length,
            itemBuilder: (context, i) => FadeSlideIn(
              key: ValueKey(destinations[i].name),
              index: i,
              child: RepaintBoundary(child: _destinationCard(destinations[i])),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _destinationCard(Destination place) {
    final isSaved = favourites.contains(place.name);
    final cost = place.estimate(travellers, tripDays);
    final tag = 'place-${place.name}';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openDetail(place, heroTag: tag),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: tag, child: PlaceImage(place: place)),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: .45),
                          ],
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filledTonal(
                      tooltip: isSaved ? 'Remove saved place' : 'Save place',
                      onPressed: () => toggleSave(place),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isSaved),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Chip(
                      label: Text(place.category),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(place.name,
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w800))),
                      Icon(Icons.star, color: context.ac.accent, size: 17),
                      Text(' ${place.rating}'),
                    ]),
                    Text(place.country,
                        style: const TextStyle(color: muted, fontSize: 12)),
                    const SizedBox(height: 7),
                    Text(place.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    const Text('ESTIMATE FOR YOUR TRIP',
                        style: TextStyle(
                            color: muted,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    Text(money(cost),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => plan(place),
                        child: const Text('Plan this trip'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SAVED ──────────────────────────────────────────────────────────────────

  Widget _buildSaved() {
    final saved = places.where((p) => favourites.contains(p.name)).toList();

    return ListView(primary: false, children: [
      const SectionLabel('YOUR COLLECTION'),
      const SizedBox(height: 8),
      const PageTitle('Saved places', size: 32),
      const SizedBox(height: 18),
      if (saved.isEmpty)
        const _EmptyState(
          icon: Icons.favorite_border,
          title: 'Nothing saved yet',
          detail: 'Tap the heart on a destination to keep it here.',
        )
      else
        for (int i = 0; i < saved.length; i++)
          FadeSlideIn(
            key: ValueKey('saved-${saved[i].name}'),
            index: i,
            child: Card(
              margin: const EdgeInsets.only(bottom: 10),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () => openDetail(saved[i]),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PlaceImage(place: saved[i], width: 56, height: 56),
                ),
                title: Text(saved[i].name),
                subtitle: Text(
                    '${saved[i].country} • ${money(saved[i].dailyCost)}/person/day'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Plan trip',
                      onPressed: () => plan(saved[i]),
                      icon: const Icon(Icons.route),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () => toggleSave(saved[i]),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
    ]);
  }

  // ── PLANNER ────────────────────────────────────────────────────────────────

  Widget _buildPlanner() {
    final ac = context.ac;
    final visibleKeys = <String>[
      for (int j = 0;
          j < math.min(tripDays * 2, selected.activities.length);
          j++)
        '${selected.name}-$j',
      for (int i = 0; i < customActivities.length; i++) 'custom-$i',
    ];
    final done = visibleKeys.where(completed.contains).length;
    final total = visibleKeys.length;

    return ListView(primary: false, children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: ClipRRect(
          key: ValueKey(selected.name),
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              PlaceImage(
                place: selected,
                height: 200,
                width: double.infinity,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 12,
                child: Chip(
                  label: Text(selected.category),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      const SectionLabel('YOUR JOURNEY'),
      const SizedBox(height: 8),
      PageTitle(selected.name),
      Text('${selected.country} • ${money(estimate)} estimated trip total',
          style: const TextStyle(color: muted)),
      const SizedBox(height: 20),
      _panel(
        title: 'Trip details',
        child: Column(children: [
          _counterRow(
            label: 'Number of days',
            controller: daysController,
            value: tripDays,
            max: 30,
            onChanged: (n) => setState(() {
              tripDays = n;
              daysController.text = '$n';
            }),
            onTyped: (n) => setState(() => tripDays = n),
          ),
          _counterRow(
            label: 'Travellers',
            controller: peopleController,
            value: travellers,
            max: 20,
            onChanged: (n) => setState(() {
              travellers = n;
              peopleController.text = '$n';
            }),
            onTyped: (n) => setState(() => travellers = n),
          ),
          const Divider(),
          _stat('Estimated total', money(estimate)),
          _stat('Budget remaining', money(remaining),
              color: remaining < 0 ? Colors.red : null),
          _stat('Per person', money(estimate / travellers)),
          _stat('Per day, group', money(estimate / tripDays)),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: remaining < 0
                ? const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                        'This plan is above your budget. Adjust your trip or budget.',
                        style: TextStyle(color: Colors.red)),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      _panel(
        title: 'Day-by-day itinerary',
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 34,
            height: 34,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: total == 0 ? 0.0 : done / total),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: v,
                    strokeWidth: 4,
                    backgroundColor: ac.accent.withValues(alpha: .2),
                    color: ac.accent,
                  ),
                  Text('${(v * 100).round()}',
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$done/$total done', style: const TextStyle(color: muted)),
        ]),
        child: Column(children: [
          for (int day = 0; day < tripDays; day++) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text('DAY ${day + 1}',
                    style: TextStyle(
                        color: ac.accentInk,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4)),
              ),
            ),
            for (int j = day * 2;
                j < (day * 2 + 2) && j < selected.activities.length;
                j++)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: completed.contains('${selected.name}-$j'),
                onChanged: (v) => setState(() {
                  v == true
                      ? completed.add('${selected.name}-$j')
                      : completed.remove('${selected.name}-$j');
                }),
                title: Text(selected.activities[j]),
                subtitle: Text(
                    j.isEven ? 'Morning / afternoon' : 'Afternoon / evening'),
              ),
          ],
          const Divider(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('CUSTOM ACTIVITIES',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                controller: customController,
                decoration: const InputDecoration(
                  hintText: 'Add your own activity',
                ),
                onSubmitted: (_) => addActivity(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: addActivity,
              icon: const Icon(Icons.add),
            ),
          ]),
          for (int i = 0; i < customActivities.length; i++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: completed.contains('custom-$i'),
              onChanged: (v) => setState(() {
                v == true
                    ? completed.add('custom-$i')
                    : completed.remove('custom-$i');
              }),
              title: Text(customActivities[i]),
              secondary: IconButton(
                onPressed: () => setState(() {
                  customActivities.removeAt(i);
                  completed.remove('custom-$i');
                }),
                icon: const Icon(Icons.close),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: showSummary,
        icon: const Icon(Icons.ios_share),
        label: const Text('View and share trip summary'),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _counterRow({
    required String label,
    required TextEditingController controller,
    required int value,
    required int max,
    required ValueChanged<int> onChanged,
    required ValueChanged<int> onTyped,
  }) {
    return Row(children: [
      Expanded(child: Text(label)),
      IconButton(
        onPressed: value > 1 ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove_circle_outline),
      ),
      SizedBox(
        width: 56,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null && n >= 1 && n <= max) onTyped(n);
          },
        ),
      ),
      IconButton(
        onPressed: value < max ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add_circle_outline),
      ),
    ]);
  }

  void addActivity() {
    final text = customController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      customActivities.add(text);
      customController.clear();
    });
    notify('Activity added to your itinerary.');
  }

  // ── BUDGET ─────────────────────────────────────────────────────────────────

  Widget _buildBudget() {
    final ac = context.ac;
    final cost = estimate.toDouble();
    final allocation = [
      ('Accommodation', accommodation, Icons.hotel_outlined),
      ('Transport', transport, Icons.directions_car_outlined),
      ('Food', food, Icons.restaurant_outlined),
      ('Activities', activities, Icons.local_activity_outlined),
    ];
    final donutColors = [
      ac.accent,
      ac.deep,
      const Color(0xFF779B82),
      const Color(0xFFC96F4A),
    ];
    final allocated = accommodation + transport + food + activities;
    final progress = budget <= 0 ? 1.0 : (cost / budget).clamp(0, 1).toDouble();

    return ListView(primary: false, children: [
      const SectionLabel('YOUR MONEY, YOUR RULES'),
      const SizedBox(height: 8),
      const PageTitle('Trip budget'),
      const SizedBox(height: 8),
      const Text('Enter a budget or move the slider. Estimates update instantly.'),
      const SizedBox(height: 20),
      _panel(
        title: 'Set your spending limit',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Total budget in Indian rupees',
                prefixText: '₹ ',
                helperText: 'Example: 30000',
              ),
              onChanged: updateBudget,
            ),
            const SizedBox(height: 14),
            Row(children: [
              const Text('₹5,000'),
              Expanded(
                child: Slider(
                  value: budget.clamp(5000, 250000),
                  min: 5000,
                  max: 250000,
                  divisions: 49,
                  label: money(budget),
                  onChanged: setBudgetFromSlider,
                ),
              ),
              const Text('₹2.5L'),
            ]),
            Wrap(
              spacing: 8,
              children: [10000, 20000, 30000, 50000, 100000]
                  .map((v) => ActionChip(
                        label: Text(money(v)),
                        onPressed: () {
                          setState(() {
                            budget = v.toDouble();
                            budgetController.text = '$v';
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ac.deep, Color.lerp(ac.deep, ac.accent, .35)!],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YOUR CURRENT TRIP ESTIMATE',
                      style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 1.2,
                          fontSize: 10)),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: cost),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => Text(money(v),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900)),
                  ),
                  Text(
                      '${selected.name} • $tripDays days • $travellers travellers',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      color: cost > budget ? Colors.redAccent : ac.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    budget <= 0
                        ? 'Enter a budget greater than zero to compare.'
                        : remaining >= 0
                            ? '${money(remaining)} remaining'
                            : '${money(-remaining)} over budget',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _panel(
        title: 'Allocate your budget',
        trailing: Text('${(allocated * 100).round()}%'),
        child: Column(children: [
          Row(children: [
            SizedBox(
              width: 130,
              height: 130,
              child: RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => CustomPaint(
                    painter: DonutPainter(
                      values: [for (final a in allocation) a.$2],
                      colors: donutColors,
                      progress: v,
                      track: muted.withValues(alpha: .15),
                    ),
                    child: Center(
                      child: Text(money(budget),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(children: [
                for (int i = 0; i < allocation.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: donutColors[i],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(allocation[i].$1)),
                      Text(money(budget * allocation[i].$2),
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ]),
                  ),
              ]),
            ),
          ]),
          const Divider(height: 28),
          for (final item in allocation) ...[
            Row(children: [
              Icon(item.$3, color: ac.accentInk),
              const SizedBox(width: 8),
              Expanded(child: Text(item.$1)),
              Text('${(item.$2 * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            Slider(
              value: item.$2,
              min: 0,
              max: 1,
              onChanged: (v) => setState(() {
                switch (item.$1) {
                  case 'Accommodation':
                    accommodation = v;
                  case 'Transport':
                    transport = v;
                  case 'Food':
                    food = v;
                  case 'Activities':
                    activities = v;
                }
              }),
            ),
          ],
          const Divider(),
          _stat('Total allocated', '${(allocated * 100).round()}%'),
          if ((allocated - 1).abs() > 0.001)
            const Text(
                'Tip: adjust the sliders until your allocation totals 100%.',
                style: TextStyle(color: muted)),
          TextButton.icon(
            onPressed: () => setState(() {
              accommodation = .35;
              transport = .25;
              food = .20;
              activities = .20;
            }),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset allocation'),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      _panel(
        title: 'Budget tips',
        child: Column(children: [
          _tip('Choose quieter dates',
              'Flexible dates can reduce transport and stay costs.'),
          _tip('Set your group size',
              'Per-person costs help you compare trips fairly.'),
          _tip('Keep a buffer', 'Reserve 10% for unexpected expenses.'),
        ]),
      ),
      const SizedBox(height: 24),
    ]);
  }

  // ── SHARED WIDGETS ─────────────────────────────────────────────────────────

  Widget _tip(String title, String description) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.lightbulb_outline, color: context.ac.accentInk),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      );

  Widget _panel({
    required String title,
    required Widget child,
    Widget? trailing,
  }) =>
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800))),
                ?trailing,
              ]),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      );

  Widget _stat(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(child: Text(label)),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w800)),
        ]),
      );

  void showSummary() {
    final text = '''
ATLAS TRIP SUMMARY
------------------
Destination: ${selected.name}, ${selected.country}
Duration: $tripDays days
Travellers: $travellers
Estimated trip cost: ${money(estimate)}
Total budget: ${money(budget)}
Remaining: ${money(remaining)}
Activities completed: ${completed.length}
Saved destinations: ${favourites.length}

Estimates are illustrative, not live travel quotes.
''';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your trip summary'),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(dialogContext);
              notify('Trip summary copied. You can paste and share it.');
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy summary'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(35),
        child: Column(children: [
          Icon(icon, size: 45, color: context.ac.accent),
          const SizedBox(height: 12),
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted)),
        ]),
      );
}