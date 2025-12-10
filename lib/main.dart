import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Import untuk kIsWeb dan TargetPlatform
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import untuk inisialisasi database non-mobile

import 'config/theme.dart';
import 'navigation_menu.dart';
import 'screens/intro/splash_screen.dart'; // Import splash screen

// 1. Definisikan Global Key ini di area global (di luar class apapun)
final GlobalKey<NavigationMenuState> navKey = GlobalKey<NavigationMenuState>();

void main() async {
  // Pastikan binding terinisialisasi sebelum akses SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 PERBAIKAN: INISIALISASI DATABASE UNTUK WEB DAN DESKTOP 🔥
  // Lakukan inisialisasi FFI hanya jika platformnya adalah Web, Windows, Linux, atau macOS.
  if (kIsWeb || 
      defaultTargetPlatform == TargetPlatform.windows || 
      defaultTargetPlatform == TargetPlatform.linux || 
      defaultTargetPlatform == TargetPlatform.macOS) {
    
    // Inisialisasi FFI (Foreign Function Interface)
    sqfliteFfiInit();
    // Ganti databaseFactory default (mobile) dengan databaseFactoryFfi (cross-platform)
    databaseFactory = databaseFactoryFfi;
    
    // Catatan: Inisialisasi ini aman dilewatkan di Android/iOS
  }
  // -----------------------------------------------------------
  
  // Muat preferensi tema yang tersimpan
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false; // Default Light (false)

  runApp(MyApp(initialIsDark: isDark));
}

class MyApp extends StatefulWidget {
  final bool initialIsDark;
  const MyApp({super.key, required this.initialIsDark});

  // Method statis agar bisa dipanggil dari mana saja untuk ganti tema
  static void toggleTheme(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.toggleTheme();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialIsDark;
  }

  Future<void> toggleTheme() async {
    setState(() {
      _isDark = !_isDark;
    });
    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Wisata Lokal',
      debugShowCheckedModeBanner: false,
      // Gunakan state _isDark untuk menentukan ThemeMode
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(), // Tampilkan SplashScreen terlebih dahulu
    );
  }
}