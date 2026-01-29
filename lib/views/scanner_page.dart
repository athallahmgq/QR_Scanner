import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  bool _isProcessing = false;
  MobileScannerController controller = MobileScannerController();
  
  // Animasi untuk garis scan
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0, end: 260).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _processCode(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await _api.scanTicket(code);
      if (!mounted) return;
      _showFeedback("REDEEM SUCCESS", "Ticket ID: $code", Colors.green);
      Navigator.pop(context, true); // Mengembalikan true agar HomePage tahu ada update
    } catch (e) {
      if (!mounted) return;
      _showFeedback("ERROR", "Invalid Ticket or Connection Issue", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showFeedback(String title, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(msg, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Scanner Layer
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              if (barcode.rawValue != null) _processCode(barcode.rawValue!);
            },
          ),

          // Custom Overlay Layer
          _buildOverlay(),

          // Top Control Buttons
          _buildTopControls(),

          // Loading Indicator Overlay
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE11D48)),
                    SizedBox(height: 16),
                    Text("Processing Ticket...", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close Button
            Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              ),
            ),
            // Actions
            Row(
              children: [
                _actionButton(
                  icon: Icons.flashlight_on_rounded,
                  onTap: () => controller.toggleTorch(),
                ),
                const SizedBox(width: 12),
                _actionButton(
                  icon: Icons.image_search_rounded,
                  onTap: _pickFromGallery,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "SCAN QR CODE",
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 2
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hold steady to scan the ticket",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
          const SizedBox(height: 40),
          
          // Scanner Frame
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              children: [
                // 4 Corners
                _Corner(top: 0, left: 0, rotation: 0),
                _Corner(top: 0, right: 0, rotation: 1.57),
                _Corner(bottom: 0, left: 0, rotation: -1.57),
                _Corner(bottom: 0, right: 0, rotation: 3.14),
                
                // Animated Scanning Line
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Positioned(
                      top: _animation.value,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48).withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 60),
          const Icon(Icons.qr_code_2_rounded, color: Colors.white24, size: 40),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final capture = await controller.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        _processCode(capture.barcodes.first.rawValue!);
      } else {
        _showFeedback("NO QR FOUND", "Could not find any QR code in the image", Colors.orange);
      }
    }
  }
}

class _Corner extends StatelessWidget {
  final double? top, bottom, left, right, rotation;
  const _Corner({this.top, this.bottom, this.left, this.right, this.rotation});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Transform.rotate(
        angle: rotation!,
        child: Container(
          width: 50, height: 50,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE11D48), width: 6),
              left: BorderSide(color: Color(0xFFE11D48), width: 6),
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}