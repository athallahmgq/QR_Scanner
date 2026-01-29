import 'package:flutter/material.dart';
import 'package:qrscanner1/main.dart';
import 'package:qrscanner1/views/detail_ticket_page.dart';
import 'package:qrscanner1/views/history_page.dart';
import 'package:qrscanner1/views/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import 'scanner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  List<Ticket> _allTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Mengambil data terbaru dari server
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getTickets();
      setState(() {
        _allTickets = List<Ticket>.from(data);
      });
    } catch (e) {
      _showSnackBar("Gagal memuat data: ${e.toString()}", Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryRed = Color(0xFFE11D48);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryRed.withOpacity(0.1),
              child: const Icon(Icons.person, color: primaryRed),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Halo, Admin", style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text("Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => MyApp.of(context)?.changeTheme(!isDark),
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: primaryRed,
        child: _isLoading && _allTickets.isEmpty
            ? const Center(child: CircularProgressIndicator(color: primaryRed))
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 32),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGridMenu(primaryRed),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Navigasi ke scanner dan refresh data saat kembali
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScannerPage()),
          );
          _fetchData();
        },
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text("SCAN NOW", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatsCard() {
    int total = _allTickets.length;
    // Menghitung tiket yang sudah diredeem
    int redeemed = _allTickets.where((t) => t.status.toLowerCase() == 'redeemed').length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.circle, size: 150, color: Colors.white.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Text("TICKET REDEMPTION STATUS",
                    style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem("Total", total.toString()),
                    _statItem("Redeemed", redeemed.toString()),
                    _statItem("Remaining", (total - redeemed).toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildGridMenu(Color color) {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 1.2,
    children: [
      _menuCard("New Ticket", Icons.add_box_outlined, Colors.blueAccent, _showAddTicketDialog),
      _menuCard("Active List", Icons.receipt_long_rounded, Colors.orangeAccent, _showTicketListModal),
      
      // UPDATE DISINI: Menuju ke HistoryPage
      _menuCard("History", Icons.history_rounded, Colors.purpleAccent, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryPage()),
        ).then((_) => _fetchData()); // Refresh data saat kembali
      }),
      
      _menuCard("Sync Data", Icons.sync_rounded, Colors.teal, _fetchData),
    ],
  );
}

  Widget _menuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketListModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    children: [
                      const Text("Daftar Tiket", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text("${_allTickets.length} Items", style: const TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: _allTickets.isEmpty
                      ? const Center(child: Text("Tidak ada tiket"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _allTickets.length,
                          itemBuilder: (context, index) {
                            final t = _allTickets[index];
                            bool isRedeemed = t.status.toLowerCase() == 'redeemed';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isRedeemed ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: isRedeemed ? Colors.green : Colors.grey,
                                  child: const Icon(Icons.confirmation_number, color: Colors.white, size: 20),
                                ),
                                title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("ID: ${t.id}"),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailTicketPage(ticketId: t.id, ticketName: t.name),
                                    ),
                                  );
                                  _fetchData(); // Refresh data setelah kembali dari detail
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  void _showAddTicketDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Tambah Peserta"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Nama Lengkap",
            hintText: "Contoh: Budi Santoso",
            border: UnderlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  await _api.addTicket(nameController.text);
                  if (!mounted) return;
                  Navigator.pop(context);
                  _fetchData(); // Refresh data otomatis
                  _showSnackBar("Peserta berhasil ditambahkan", Colors.green);
                } catch (e) {
                  _showSnackBar("Gagal menambah peserta", Colors.redAccent);
                }
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}