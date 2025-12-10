import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/wisata_model.dart';
import '../../services/database_helper.dart';
import '../detail/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Wisata> _allWisata = [];
  List<Wisata> _foundWisata = [];

  // FocusNode untuk mengatur fokus keyboard (tambahan kecil untuk UX)
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadData();
    // Otomatis fokus ke keyboard saat halaman dibuka (opsional, bagus untuk UX search)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper().getWisataList();
    setState(() {
      _allWisata = data;
      _foundWisata = data;
    });
  }

  // LOGIKA PENCARIAN (TIDAK BERUBAH)
  void _runFilter(String keyword) {
    List<Wisata> results = [];
    if (keyword.isEmpty) {
      results = _allWisata;
    } else {
      results = _allWisata
          .where(
            (item) =>
                item.name.toLowerCase().contains(keyword.toLowerCase()) ||
                item.location.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    }
    setState(() {
      _foundWisata = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Temukan Destinasi",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR AREA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: colorScheme.surface,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) => _runFilter(value),
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Cari nama tempat atau lokasi...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.6),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded penuh
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _runFilter('');
                          // Tetap fokus setelah clear agar user bisa ketik ulang
                          FocusScope.of(context).requestFocus(_searchFocusNode);
                        },
                      )
                    : null,
              ),
            ),
          ),

          // 2. HASIL PENCARIAN
          Expanded(
            child: _foundWisata.isEmpty
                ? _buildEmptyState(theme, colorScheme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _foundWisata.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final wisata = _foundWisata[index];
                      return _buildResultCard(wisata, theme, colorScheme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // WIDGET CARD HASIL PENCARIAN (DESAIN BARU)
  Widget _buildResultCard(
    Wisata wisata,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow, // Warna card yang halus
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(wisata: wisata),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Gambar Thumbnail
                Hero(
                  tag: wisata.imagePaths.isNotEmpty
                      ? wisata.imagePaths[0]
                      : 'empty',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surfaceContainerHighest,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            wisata.imagePaths.isNotEmpty &&
                                wisata.imagePaths[0].startsWith('http')
                            ? NetworkImage(wisata.imagePaths[0])
                            : (wisata.imagePaths.isNotEmpty
                                      ? FileImage(File(wisata.imagePaths[0]))
                                      : const AssetImage(
                                          'assets/placeholder.png',
                                        ))
                                  as ImageProvider,
                        onError: (_, __) {}, // Handle error silent
                      ),
                    ),
                    // Jika gambar gagal load atau kosong
                    child: wisata.imagePaths.isEmpty
                        ? Icon(
                            Icons.image_not_supported,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wisata.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              wisata.location,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          wisata.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Panah Forward
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colorScheme.outline.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET SAAT DATA KOSONG
  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 60,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Wisata tidak ditemukan",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Coba gunakan kata kunci lain\nseperti 'Pantai' atau 'Bandung'",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
