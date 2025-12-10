import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  // Koordinat awal (opsional, jika edit)
  final LatLng? initialPosition;
  const LocationPickerScreen({super.key, this.initialPosition});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    // Jika ada posisi awal (mode edit), gunakan itu. Jika tidak, default Purwokerto.
    _pickedLocation = widget.initialPosition ?? const LatLng(-7.4167, 109.2333);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ketuk Peta untuk Pilih Lokasi"),
        actions: [
          // Tombol "Centang" di pojok kanan atas untuk Simpan
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Simpan Lokasi",
            onPressed: _pickedLocation == null
                ? null
                : () {
                    // Kembalikan koordinat yang dipilih ke halaman Form
                    Navigator.pop(context, _pickedLocation);
                  },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pickedLocation!,
          zoom: 12.0,
        ),
        myLocationEnabled: true, // Tombol lokasi saya (biru)
        myLocationButtonEnabled: true,
        mapToolbarEnabled: false, // Matikan toolbar bawaan google biar rapi
        zoomControlsEnabled: true,
        // Ketika peta di-tap, pindahkan marker
        onTap: (position) {
          setState(() {
            _pickedLocation = position;
          });
        },

        // Tampilkan marker di posisi yang dipilih
        markers: _pickedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('picked'),
                  position: _pickedLocation!,
                  infoWindow: const InfoWindow(title: "Lokasi Terpilih"),
                ),
              },
      ),
    );
  }
}
