import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/wisata_model.dart';
import '../../services/database_helper.dart';
import '../detail/detail_screen.dart';

class AllMapsScreen extends StatefulWidget {
  const AllMapsScreen({super.key});

  @override
  State<AllMapsScreen> createState() => _AllMapsScreenState();
}

// 1. Tambahkan Mixin 'AutomaticKeepAliveClientMixin' di sini
class _AllMapsScreenState extends State<AllMapsScreen>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? mapController;
  // marker semua wisata di purwokerto
  final Set<Marker> _markers = {};
  LatLng _center = const LatLng(-7.4316, 109.2465);

  // 2. Wajib override wantKeepAlive menjadi true
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _loadMarkers();
  }

  Future<void> _requestPermission() async {
    await Permission.location.request();
  }

  Future<void> _loadMarkers() async {
    final List<Wisata> wisataList = await DatabaseHelper().getWisataList();
    if (!mounted) return; // Cek mounted agar aman

    setState(() {
      _markers.clear();
      for (var wisata in wisataList) {
        _markers.add(
          Marker(
            markerId: MarkerId(wisata.id),
            position: LatLng(wisata.latitude, wisata.longitude),
            infoWindow: InfoWindow(
              title: wisata.name,
              snippet: "Ketuk untuk detail",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(wisata: wisata),
                  ),
                );
              },
            ),
          ),
        );
      }
      if (wisataList.isNotEmpty) {
        _center = LatLng(wisataList.first.latitude, wisataList.first.longitude);
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(_center, 10));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 3. Wajib panggil super.build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Wisata'),
        actions: [
          IconButton(onPressed: _loadMarkers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) => mapController = controller,
        initialCameraPosition: CameraPosition(target: _center, zoom: 10.5),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        // Tambahkan ini untuk performa lebih stabil di Android
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
      ),
    );
  }
}
