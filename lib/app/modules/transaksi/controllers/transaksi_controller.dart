import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TransaksiController extends GetxController {
  var selectedPelanggan = {}.obs;
  var selectedcuciSetrika = <Map<String, dynamic>>[].obs;
  var selectedService = <Map<String, dynamic>>[].obs;
  var metodePembayaran = 'Cash'.obs;
  var statusPembayaran = 'Lunas'.obs;
  var statusPengiriman = 'Diantar'.obs;
  var totalHarga = 0.0.obs;

  // Select pelanggan
  void selectPelanggan(Map<String, dynamic> pelanggan) {
    selectedPelanggan.value = pelanggan;
  }

  // Add and remove cuciSetrika with berat cucian
  void addcuciSetrika(Map<String, dynamic> cuciSetrika) {
    cuciSetrika['berat'] = 1.0; // Default berat adalah 1 kg
    selectedcuciSetrika.add(cuciSetrika);
    _hitungTotalHarga();
  }

  void removecuciSetrika(int index) {
    selectedcuciSetrika.removeAt(index);
    _hitungTotalHarga();
  }

  void updateBeratCuciSetrika(int index, double berat) {
    selectedcuciSetrika[index]['berat'] = berat;
    _hitungTotalHarga();
  }

  // Add, remove, and update jumlah Service
  void addService(Map<String, dynamic> service) {
    // Tambahkan kategori berdasarkan nama koleksi
    service['kategori'] = service['kategori'] ?? 'N/A'; // Jika kategori belum ditentukan
    service['berat'] = 1.0; // Default berat adalah 1
    selectedService.add(service);
    _hitungTotalHarga();
  }


  void removeService(int index) {
    selectedService.removeAt(index);
    _hitungTotalHarga();
  }

  void updateJumlahService(int index, double jumlah) {
    selectedService[index]['berat'] = jumlah;
    _hitungTotalHarga();
  }

  // Hitung total harga
  void _hitungTotalHarga() {
    double total = 0;

    // Hitung total dari cuci setrika
    for (var item in selectedcuciSetrika) {
      double harga = item['harga'] != null && item['harga'] is num
          ? (item['harga'] as num).toDouble()
          : 0.0;
      double berat = item['berat'] != null && item['berat'] is num
          ? (item['berat'] as num).toDouble()
          : 1.0;
      total += harga * berat;
    }

    // Hitung total dari services
    for (var item in selectedService) {
      double harga = item['harga'] != null && item['harga'] is num
          ? (item['harga'] as num).toDouble()
          : 0.0;
      double jumlah = item['berat'] != null && item['berat'] is num
          ? (item['berat'] as num).toDouble()
          : 1.0;
      total += harga * jumlah;
    }

    totalHarga.value = total;
  }

  Future<List<Map<String, dynamic>>> fetchServices() async {
    List<Map<String, dynamic>> services = [];
    // Fetch dari koleksi 'service_cuciLipat'
    var cuciLipatSnapshot = await FirebaseFirestore.instance
        .collection('service_cuciLipat')
        .get();

    for (var doc in cuciLipatSnapshot.docs) {
      services.add({
        'id': doc.id,
        ...doc.data(),
        'kategori': 'cuciLipat', // Tambahkan kategori
      });
    }

    // Fetch dari koleksi 'service_cuciSetrika'
    var cuciSetrikaSnapshot = await FirebaseFirestore.instance
        .collection('service_cuciSetrika')
        .get();

    for (var doc in cuciSetrikaSnapshot.docs) {
      services.add({
        'id': doc.id,
        ...doc.data(),
        'kategori': 'cuciSetrika', // Tambahkan kategori
      });
    }

    return services;
  }


  // Simpan transaksi
  Future<void> saveTransaksi() async {
    try {
      var transaksiData = {
        'pelanggan': selectedPelanggan.value,
        'cuciSetrika': selectedcuciSetrika
            .map((e) => {
                  'nama': e['nama'],
                  'harga': e['harga'],
                  'berat': e['berat'], // Tambahkan berat di data transaksi
                })
            .toList(),
        'Service': selectedService
            .map((e) => {
                  'nama': e['nama'],
                  'harga': e['harga'],
                  'berat': e['berat'],
                  'kategori': e['kategori'],
                })
            .toList(),
        'metode_pembayaran': metodePembayaran.value,
        'status_pembayaran': statusPembayaran.value,
        'status_pengiriman': statusPengiriman.value,
        'totalHarga': totalHarga.value,
        'tanggal': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('laporanTransaksi')
          .add(transaksiData);
      Get.snackbar('Success', 'Transaksi berhasil disimpan');
      clearSelections();
    } catch (e) {
      throw Exception('Failed to save transaction: $e');
    }
  }

  // Reset semua data
  void clearSelections() {
    selectedPelanggan.value = {};
    selectedcuciSetrika.clear();
    selectedService.clear();
    metodePembayaran.value = 'Cash';
    statusPembayaran.value = 'Lunas';
    statusPengiriman.value = 'Diantar';
    totalHarga.value = 0;
    totalHarga.refresh();
  }
}
