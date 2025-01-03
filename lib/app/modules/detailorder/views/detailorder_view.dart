import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../component/app_color.dart';
import '../../edittransaksi/views/edittransaksi_view.dart';
import '../../laporan/controllers/laporan_controller.dart';
import '../controllers/detailorder_controller.dart';

class DetailorderView extends GetView<LaporanController> {
    DetailorderView({super.key});

  final DetailorderController detailorderController =
      Get.put(DetailorderController());

  @override
  Widget build(BuildContext context) {
    var laporanController = Get.find<LaporanController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Order',
          style: TextStyle(
            fontSize: 20,
            color: Constants.secondColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Constants.secondColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Get.to(() => const EditTransaksiView());
              Get.toNamed('/edittransaksi');
            },
            icon: const Icon(
              Icons.edit_note_rounded,
              size: 40,
              color: Constants.secondColor,
            ),
          ),
        ],
      ),
      body: Obx(() {
        var laporan = laporanController.selectedLaporan.value;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('laporanTransaksi')
              .doc(laporan['id'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No Data Available'));
            }

            var updatedLaporan =
                snapshot.data!.data() as Map<String, dynamic>? ?? {};
            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  Screenshot(
                    controller: detailorderController.screenshotController,
                    child: buildCard(updatedLaporan),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor: Constants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await detailorderController.saveInvoiceAsImage();
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Constants.scaffoldbackgroundColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor: Constants.thirdColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      var nomorWhatsApp =
                          updatedLaporan['pelanggan']?['nomor WhatsApp'] ?? '';
                      detailorderController.saveInvoiceAndSendWhatsApp(
                          nomorWhatsApp,
                          'Hallo ini invoice pesanan laundry Anda');
                    },
                    child: const Text(
                      "Kirim WhatsApp",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Constants.scaffoldbackgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget buildCard(Map<String, dynamic> laporan) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    width: 400,
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nama : ${laporan['pelanggan']?['nama pelanggan'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Nomor WhatsApp : ${laporan['pelanggan']?['nomor WhatsApp'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Alamat : ${laporan['pelanggan']?['alamat'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 2, color: Constants.primaryColor),
                  const SizedBox(height: 10),
                  const Text(
                    "Laundry Perjam :",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  for (var produk in laporan['cuciPerjam'] ?? []) ...[
                    Text(
                      '${produk['nama'] ?? 'N/A'}\n'
                      'Berat : ${produk['berat']?.toStringAsFixed(0) ?? '0'} kg\n'
                      'Harga : ${produk['harga']?.toStringAsFixed(0) ?? '0'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Divider(height: 2, color: Constants.primaryColor),
                  const Text(
                    "Laundry Harian :",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  for (var produk in laporan['Service'] ?? []) ...[
                    Text(
                      '${produk['nama'] ?? 'N/A'}\n'
                      'Berat : ${produk['berat']?.toStringAsFixed(0) ?? '0'} kg\n'
                      'Harga : ${produk['harga']?.toStringAsFixed(0) ?? '0'} \n'
                      'Kategori : ${produk['kategori'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Divider(height: 2, color: Constants.primaryColor),
                  const SizedBox(height: 10),
                  // Servis satuan
                  const Text(
                    "Laundry Satuan :",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  for (var produk in laporan['Satuan'] ?? []) ...[
                    Text(
                      '${produk['nama'] ?? 'N/A'}\n'
                      'Jumlah : ${produk['jumlah']?.toStringAsFixed(0) ?? '0'} Pcs\n'
                      'Harga : ${produk['harga']?.toStringAsFixed(0) ?? '0'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Divider(height: 2, color: Constants.primaryColor),
                  const SizedBox(height: 10),
                  Text(
                    'Metode Pembayaran : ${laporan['metode_pembayaran'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  // Jika metode pembayaran adalah transfer bank maka tampilkan nomor rekening
                  if (laporan['metode_pembayaran'] == 'Transfer') ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Nomor Rekening BCA: NOMOR REKENING\nNomor Dana: 08xx-xxxx-xxxx\nAtas Nama : Owner Laundry',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                  // Jika metode pembayaran adalah QRIS maka tampilkan QR Code dalam bentuk gambar di local
                  if (laporan['metode_pembayaran'] == 'QRIS') ...[
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/images/qris-logo.jpg',
                      width: 200,
                      height: 200,
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Divider(height: 2, color: Constants.primaryColor),
                  const SizedBox(height: 10),
                  Text(
                    'Status Pembayaran : ${laporan['status_pembayaran'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 2, color: Constants.primaryColor),
                  const SizedBox(height: 10),
                  Text(
                    'Status Pesanan : ${laporan['status_pengambilan'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 2, color: Constants.primaryColor),
                  const SizedBox(height: 10),
                  Text(
                    'Total Harga : ${laporan['totalHarga']?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
