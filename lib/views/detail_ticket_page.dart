import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DetailTicketPage extends StatelessWidget {
  final String ticketId;
  final String ticketName;

  const DetailTicketPage({super.key, required this.ticketId, required this.ticketName});

  @override
  Widget build(BuildContext context) {
    // Kita simpan referensi tema dan ukuran layar di awal build
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryRed = Color(0xFFE11D48);

    return Scaffold(
      backgroundColor: primaryRed,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Icon(Icons.stars_rounded, color: primaryRed, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      ticketName.toUpperCase(),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    Text(
                      "OFFICIAL PASS",
                      style: TextStyle(color: Colors.grey[500], letterSpacing: 3, fontSize: 10),
                    ),
                    const SizedBox(height: 20),
                    _buildDivider(primaryRed),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                      ),
                      child: QrImageView(data: ticketId, size: 200),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      ticketId,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () => _downloadQR(context),
                          icon: const Icon(Icons.file_download_rounded),
                          label: const Text("DOWNLOAD TICKET"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(Color bgColor) {
    return Row(
      children: [
        SizedBox(width: 15, height: 30, child: DecoratedBox(decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15))))),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            return Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                (constraints.constrainWidth() / 15).floor(),
                (index) => const Text("-", style: TextStyle(color: Colors.grey)),
              ),
            );
          }),
        ),
        SizedBox(width: 15, height: 30, child: DecoratedBox(decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))))),
      ],
    );
  }

  Future<void> _downloadQR(BuildContext context) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: ticketId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final painter = QrPainter.withQr(
          qr: qrValidationResult.qrCode!,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );

        final directory = await getTemporaryDirectory();
        final path = "${directory.path}/qr_$ticketId.png";
        final picData = await painter.toImageData(2048, format: ui.ImageByteFormat.png);
        
        if (picData != null) {
          await File(path).writeAsBytes(picData.buffer.asUint8List());
          await Gal.putImage(path);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Berhasil simpan ke galeri"), backgroundColor: Colors.green),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}