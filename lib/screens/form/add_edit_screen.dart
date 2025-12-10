import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk input formatter
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
// IMPORT BARU UNTUK PERSISTENCE:
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../models/wisata_model.dart';
import '../../services/database_helper.dart';
import 'location_picker_screen.dart';

class AddEditScreen extends StatefulWidget {
  final Wisata? wisata;
  const AddEditScreen({super.key, this.wisata});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  List<String> _imagePaths = [];

  double _rating = 3.0;
  TimeOfDay _openTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 17, minute: 0);
  LatLng? _selectedCoordinates;

  String _selectedCategory = "Populer";
  final List<String> _categoryOptions = ["Populer", "Rekomendasi", "Lainnya"];

  @override
  void initState() {
    super.initState();
    if (widget.wisata != null) {
      _nameController.text = widget.wisata!.name;
      _locationController.text = widget.wisata!.location;
      _descController.text = widget.wisata!.description;
      _priceController.text = widget.wisata!.price;

      _imagePaths = List.from(widget.wisata!.imagePaths);

      _rating = widget.wisata!.rating;
      _openTime = widget.wisata!.openTime;
      _closeTime = widget.wisata!.closeTime;

      if (_categoryOptions.contains(widget.wisata!.category)) {
        _selectedCategory = widget.wisata!.category;
      } else {
        _selectedCategory = "Lainnya";
      }

      _selectedCoordinates = LatLng(
        widget.wisata!.latitude,
        widget.wisata!.longitude,
      );
    }
  }

  // --- FUNGSI BARU: MENYALIN GAMBAR KE FOLDER PERMANEN ---
  Future<String> _saveImagePermanently(String imagePath) async {
    // 1. Cek apakah ini gambar network/internet (tidak perlu disalin)
    if (imagePath.startsWith('http')) return imagePath;

    try {
      // 2. Dapatkan lokasi folder dokumen aplikasi
      final directory = await getApplicationDocumentsDirectory();

      // 3. Ambil nama file aslinya (misal: image_picker_123.jpg)
      final name = path.basename(imagePath);

      // 4. Buat path tujuan baru
      final newPath = '${directory.path}/$name';

      // 5. Salin file dari Cache ke Dokumen
      final imageFile = File(imagePath);
      final newImage = await imageFile.copy(newPath);

      return newImage.path; // Kembalikan path baru yang permanen
    } catch (e) {
      // Jika gagal (misal file sudah terhapus), kembalikan path lama
      return imagePath;
    }
  }
  // --------------------------------------------------------

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(images.map((e) => e.path).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LocationPickerScreen(initialPosition: _selectedCoordinates),
      ),
    );
    if (result != null) setState(() => _selectedCoordinates = result);
  }

  Future<void> _pickTime(bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
    );
    if (picked != null) {
      setState(() => isOpenTime ? _openTime = picked : _closeTime = picked);
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCoordinates == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mohon pilih lokasi di peta")),
        );
        return;
      }

      if (_imagePaths.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mohon pilih minimal 1 foto wisata")),
        );
        return;
      }

      // --- PROSES PERMANENSI GAMBAR SEBELUM SIMPAN ---
      // Kita loop semua path gambar, lalu copy satu per satu
      List<String> permanentImages = [];
      for (String imgPath in _imagePaths) {
        // Cek apakah path ini sudah ada di folder dokumen aplikasi (artinya sudah pernah disimpan)
        final directory = await getApplicationDocumentsDirectory();
        if (imgPath.contains(directory.path)) {
          // Sudah permanen (kasus Edit data lama), biarkan saja
          permanentImages.add(imgPath);
        } else {
          // Belum permanen (masih di cache), salin sekarang
          String newPath = await _saveImagePermanently(imgPath);
          permanentImages.add(newPath);
        }
      }
      // -----------------------------------------------

      final isEdit = widget.wisata != null;

      final wisataBaru = Wisata(
        id: isEdit
            ? widget.wisata!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        location: _locationController.text,
        description: _descController.text,

        // GUNAKAN LIST YANG SUDAH PERMANEN
        imagePaths: permanentImages,

        rating: _rating,
        price: _priceController.text,
        latitude: _selectedCoordinates!.latitude,
        longitude: _selectedCoordinates!.longitude,
        openTime: _openTime,
        closeTime: _closeTime,
        category: _selectedCategory,
      );

      if (isEdit) {
        await DatabaseHelper().updateWisata(wisataBaru);
      } else {
        await DatabaseHelper().insertWisata(wisataBaru);
      }
      if (mounted) Navigator.pop(context, true);
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.Hm();
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wisata == null ? "Tambah Wisata" : "Edit Wisata"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. IMAGE PICKER
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text("Tambah Foto Galeri (Bisa Banyak)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Area Preview Gambar
                  _imagePaths.isEmpty
                      ? Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                              Text(
                                "Belum ada foto dipilih",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagePaths.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      image: DecorationImage(
                                        image:
                                            _imagePaths[index].startsWith(
                                              'http',
                                            )
                                            ? NetworkImage(_imagePaths[index])
                                            : FileImage(
                                                    File(_imagePaths[index]),
                                                  )
                                                  as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 12,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Wisata",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Alamat Singkat",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Harga Tiket (Rp)",
                  border: OutlineInputBorder(),
                  prefixText: "Rp ",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  if (val == null || val.isEmpty) return "Harga wajib diisi";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Kategori Wisata",
                  border: OutlineInputBorder(),
                ),
                items: _categoryOptions.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedCategory = newValue!);
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Text(
                    "Rating: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _rating.toString(),
                      onChanged: (val) => setState(() => _rating = val),
                    ),
                  ),
                  Text(
                    _rating.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.amber),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text("Buka: ${_formatTime(_openTime)}"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(false),
                      icon: const Icon(Icons.access_time_filled),
                      label: Text("Tutup: ${_formatTime(_closeTime)}"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _pickLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCoordinates == null
                      ? Colors.grey
                      : Colors.green,
                ),
                icon: Icon(
                  _selectedCoordinates == null
                      ? Icons.location_off
                      : Icons.location_on,
                  color: Colors.white,
                ),
                label: Text(
                  _selectedCoordinates == null
                      ? "Pilih Lokasi di Peta (Wajib)"
                      : "Lokasi Terpilih (Ketuk untuk ubah)",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Lengkap",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  "SIMPAN DATA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
