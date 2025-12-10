import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../navigation_menu.dart';
import '../../main.dart'; // tempat navKey

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  final String title = "TRAVEL WISATA LOKAL";

  @override
  void initState() {
    super.initState();

    // Durasi total splash screen
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    // Pindah halaman setelah animasi selesai
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => NavigationMenu(key: navKey)),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mengambil warna merah dari icon (approx) untuk aksen
    final accentColor = const Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ======================
            //   LOGO ICON (IMAGE)
            // ======================
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _mainController,
                // Animasi membal (Elastic) agar terlihat hidup
                curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
              ),
              child: Container(
                width: 180, // Sesuaikan ukuran icon di sini
                height: 180,
                decoration: BoxDecoration(
                  // Opsional: Bayangan halus di bawah globe
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                // Ganti nama file sesuai lokasi aset Anda
                child: Image.asset(
                  'assets/logo/icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ======================
            //   ANIMASI TEKS PER HURUF
            // ======================
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              children: List.generate(title.length, (i) {
                if (title[i] == " ") return const SizedBox(width: 12);

                double start = (0.4 + i * 0.03).clamp(0.0, 1.0);
                double end = (start + 0.15).clamp(0.0, 1.0);

                final anim = CurvedAnimation(
                  parent: _mainController,
                  curve: Interval(start, end, curve: Curves.easeOutBack),
                );

                return AnimatedBuilder(
                  animation: anim,
                  builder: (_, __) {
                    final v = anim.value.clamp(0.0, 1.0);
                    // Efek putar sedikit saat muncul
                    final angle = (1 - v) * pi;

                    return Opacity(
                      opacity: v,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: Text(
                          title[i],
                          style: TextStyle(
                            fontFamily: 'AppFont',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            // Warna teks menyesuaikan tema
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // ======================
            //   SUBTITLE
            // ======================
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _mainController,
                curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Kelilingi dunia, jelajahi lokal.", // Slogan disesuaikan icon
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'AppFont',
                    fontSize: 14,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ======================
            //   DOT LOADER (RED ACCENT)
            // ======================
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _mainController,
                curve: const Interval(0.8, 1.0),
              ),
              child: DotLoader(color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// DOT LOADER (WAVE SCALE)
// =========================================================

class DotLoader extends StatefulWidget {
  final Color color;
  const DotLoader({super.key, required this.color});

  @override
  State<DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController c;

  @override
  void initState() {
    super.initState();
    c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: c,
          builder: (_, __) {
            double wave = sin((c.value * 2 * pi) - (i * 0.8));
            double scale = 0.4 + (0.6 * ((wave + 1) / 2));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale.clamp(0.4, 1.0),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.color, // Menggunakan warna merah dari parameter
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}