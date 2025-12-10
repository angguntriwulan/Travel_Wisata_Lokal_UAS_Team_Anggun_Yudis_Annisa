import 'package:flutter/material.dart';
import '../../models/wisata_model.dart';
import '../../services/database_helper.dart';
import '../../widgets/common_card.dart';
import '../detail/detail_screen.dart';
import '../form/add_edit_screen.dart';
import '../../main.dart'; // Import main untuk toggle theme

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ["All", "Populer", "Rekomendasi"];

  List<Wisata> _allWisata = [];
  List<Wisata> _displayWisata = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    final data = await DatabaseHelper().getWisataList();
    setState(() {
      _allWisata = data;
      _filterData();
    });
  }

  void _filterData() {
    setState(() {
      if (_selectedCategoryIndex == 0) {
        _displayWisata = _allWisata;
      } else {
        String targetCategory = _categories[_selectedCategoryIndex];
        _displayWisata = _allWisata
            .where((w) => w.category == targetCategory)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil Tema Global
    final theme = Theme.of(context);

    // --- KUNCI PERUBAHAN ---
    // Pastikan colorScheme.primary mengambil warna utama dari Tema
    // Jika tema di main.dart sudah benar, ini otomatis Coklat.
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Warna background chip jika tidak dipilih (abu-abu muda/gelap)
    final unselectedChipColor = isDark ? Colors.grey[800] : Colors.grey[200];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Jelajah Indonesia",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey, // Warna teks subtitle
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Wisata Lokal",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                // Menggunakan onBackground agar kontras di Dark/Light mode
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: unselectedChipColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: theme.iconTheme.color,
              ),
              onPressed: () => MyApp.toggleTheme(context),
            ),
          ),
        ],
      ),

      // ==========================================
      // TOMBOL TAMBAH (FLOATING ACTION BUTTON)
      // ==========================================
      floatingActionButton: FloatingActionButton.extended(
        // Memaksa menggunakan warna Primary (Coklat)
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white, // Teks & Icon Putih
        elevation: 4,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditScreen()),
          );

          if (result == true) {
            _refreshData();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text("Wisata berhasil ditambahkan"),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text("Tambah"),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ==========================================
          // KATEGORI CHIPS (TOMBOL ALL)
          // ==========================================
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                      _filterData();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      // LOGIKA WARNA:
                      // Jika dipilih: Pakai Primary Color (Coklat)
                      // Jika tidak: Pakai abu-abu
                      color: isSelected
                          ? theme.primaryColor
                          : unselectedChipColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          // Bayangan sewarna dengan tombol (Coklat transparan)
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          // Warna Teks: Putih jika dipilih, Abu gelap jika tidak
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.grey[400] : Colors.grey[700]),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 2. GRID WISATA
          Expanded(
            child: _displayWisata.isEmpty
                ? _buildEmptyState(colorScheme, theme)
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
              physics: const BouncingScrollPhysics(),
              itemCount: _displayWisata.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final wisata = _displayWisata[index];
                return DestinationCard(
                  wisata: wisata,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailScreen(wisata: wisata),
                      ),
                    );
                    _refreshData();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk tampilan kosong
  Widget _buildEmptyState(ColorScheme colorScheme, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Belum ada destinasi",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Coba pilih kategori lain atau\ntambahkan data baru.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}