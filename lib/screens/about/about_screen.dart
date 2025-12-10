import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisikan data di sini agar aman
    final List<Map<String, String>> members = [
      {"name": "Yudistira Aitya Putra", "nim": "STI202303625"},
      {"name": "Anggun Tri Wulan", "nim": "STI202303646"},
      {"name": "Annisa Nur Rahmah", "nim": "STI202303687"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Tentang Kami")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        separatorBuilder: (c, i) => const Divider(),
        itemBuilder: (context, index) {
          final m = members[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 8,
            ),
            leading: CircleAvatar(
              radius: 20, // Sedikit diperbesar avatarnya
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                m["name"] != null && m["name"]!.isNotEmpty
                    ? m["name"]![0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // Huruf inisial diperbesar
                ),
              ),
            ),
            title: Text(
              m["name"] ?? "Tanpa Nama",
              // --- PENGATURAN TEKS NAMA DI SINI ---
              style: const TextStyle(
                fontSize: 13, // Ukuran font diperbesar (standar biasanya 14-16)
                fontWeight: FontWeight.w700, // Agak tebal (Semi-bold)
              ),
              // ------------------------------------
            ),
            trailing: Chip(
              label: Text(
                m["nim"] ?? "-",
                style: TextStyle(
                  // Jangan pakai 'const' karena kita ambil warna dari Theme
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  // Gunakan 'onSurface' agar teks hitam di Light Mode & putih di Dark Mode
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              // Gunakan 'surfaceContainerHighest' untuk warna background chip yang netral (abu-abu muda di light, abu-abu tua di dark)
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,

              // Opsional: Hilangkan border agar lebih bersih
              side: BorderSide.none,

              // Hapus 'labelStyle' yang memaksa warna hitam tadi
            ),
          );
        },
      ),
    );
  }
}
