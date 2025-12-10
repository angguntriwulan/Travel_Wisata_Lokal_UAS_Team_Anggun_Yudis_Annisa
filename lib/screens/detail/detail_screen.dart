import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/wisata_model.dart';
import '../../services/database_helper.dart';
import '../form/add_edit_screen.dart';
import '../../main.dart';

class DetailScreen extends StatefulWidget {
  final Wisata wisata;
  const DetailScreen({super.key, required this.wisata});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Wisata _currentWisata; // Gunakan state lokal agar bisa diupdate setelah edit
  int _currentImageIndex = 0; // Untuk indikator slider

  @override
  void initState() {
    super.initState();
    _currentWisata = widget.wisata;
  }

  // Fungsi Hapus
  Future<void> _deleteWisata() async {
    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Wisata?"),
        content: Text("Yakin ingin menghapus ${_currentWisata.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper().deleteWisata(_currentWisata.id);
      if (mounted) {
        Navigator.pop(context); // Kembali ke Home
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
      }
    }
  }

  // Fungsi Edit
  Future<void> _editWisata() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditScreen(wisata: _currentWisata),
      ),
    );
    // Setelah kembali dari layar Edit, kita harus refresh data di layar detail ini
    // Cara paling gampang (tapi agak boros) adalah mengambil ulang data dari DB
    // Tapi karena kita tidak punya method getById di helper, kita pop saja agar home refresh
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Helper format jam simpel
    String formatTime(TimeOfDay tod) =>
        '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Stack(
        children: [
          // 1. IMAGE CAROUSEL (SLIDER)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: PageView.builder(
              itemCount: _currentWisata.imagePaths.length, // JUMLAH FOTO
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index; // Update posisi
                });
              },
              itemBuilder: (context, index) {
                String imgPath = _currentWisata.imagePaths[index];
                ImageProvider imageProvider;

                if (imgPath.startsWith('http')) {
                  imageProvider = NetworkImage(imgPath);
                } else {
                  imageProvider = FileImage(File(imgPath));
                }

                return Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image),
                  ),
                );
              },
            ),
          ),

          // 2. INDICATOR DOTS (TITIK-TITIK)
          // Hanya muncul jika foto lebih dari 1
          if (_currentWisata.imagePaths.length > 1)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_currentWisata.imagePaths.length, (
                  index,
                ) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentImageIndex == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index
                          ? theme.primaryColor
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

          // 2. CUSTOM APP BAR (Tombol Back & Menu Option)
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    // LOGIKA EDIT DAN HAPUS DISINI
                    onSelected: (value) {
                      if (value == 'edit') _editWisata();
                      if (value == 'delete') _deleteWisata();
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              ],
            ),
          ),

          // 3. INDICATOR SLIDER (Titik-titik slide)
          /*Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.primaryColor
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),*/

          // 4. KONTEN DETAIL (Draggable Sheet / Container Bawah)
          DraggableScrollableSheet(
            initialChildSize: 0.46, // Muncul 46% dari bawah
            minChildSize: 0.46,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor, // Ikut tema Light/Dark
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Garis kecil di tengah atas sheet (Grip)
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Judul Wisata
                    Text(
                      widget.wisata.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Lokasi
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: theme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.wisata.location,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 19, // Font lokasi
                              height: 1.3,
                            ),
                            maxLines: 2, // Batasi 2 baris jika terlalu panjang
                            overflow: TextOverflow
                                .ellipsis, // Tampilkan ... jika overflow
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Baris Info (Rating & Harga)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align ke atas
                      children: <Widget>[
                        // 1. KOLOM RATING
                        Column(
                          children: [
                            const Text(
                              "Rating",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildInfoBadge(
                              Icons.star,
                              "${_currentWisata.rating}",
                              Colors.orange,
                            ),
                          ],
                        ),

                        // 2. KOLOM HARGA TIKET
                        Column(
                          children: [
                            const Text(
                              "Tiket Masuk",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildInfoBadge(
                              null, // Ikon null karena pakai custom leading text
                              _currentWisata.price,
                              Colors.green,
                              leading: const Text(
                                "Rp",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green, // Pastikan warna sesuai
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 3. KOLOM JAM BUKA
                        Column(
                          children: [
                            const Text(
                              "Jam Buka",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildInfoBadge(
                              Icons.access_time,
                              "${formatTime(_currentWisata.openTime)} - ${formatTime(_currentWisata.closeTime)}",
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Deskripsi Title
                    Text(
                      "Deskripsi",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Deskripsi Isi
                    Text(
                      widget.wisata.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[800],
                        fontSize: 19,
                      ),
                    ),

                    const SizedBox(
                      height: 100,
                    ), // Space agar tombol bawah tidak menutupi teks
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // 5. TOMBOL LIHAT RUTE (Bottom Floating)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              //kembali ke layar utama)
              Navigator.pop(context);
              //Panggil fungsi changeTab menggunakan GlobalKey
              // Index 2 adalah tab Maps (0=Home, 1=Search, 2=Maps, 3=About)
              navKey.currentState?.changeTab(2);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Membuka Peta Wisata...")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.map),
            label: const Text(
              "Lihat Lokasi di Peta Aplikasi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Badge Info
  Widget _buildInfoBadge(
    IconData? icon,
    String text,
    Color color, {
    Widget? leading,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          leading ?? Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
