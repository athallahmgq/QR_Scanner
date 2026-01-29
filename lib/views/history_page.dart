import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import 'detail_ticket_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ApiService _api = ApiService();
  List<Ticket> _historyTickets = [];
  List<Ticket> _filteredHistory = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getTickets();
      setState(() {
        // Filter hanya yang sudah diredeem
        _historyTickets = data.where((t) => t.status.toLowerCase() == 'redeemed').toList() as List<Ticket>;
        _filteredHistory = _historyTickets;
      });
    } catch (e) {
      _showSnackBar("Gagal memuat riwayat", Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredHistory = _historyTickets
          .where((t) => t.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFE11D48);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Redemption History", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar Modern
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: "Cari nama peserta...",
                prefixIcon: const Icon(Icons.search, color: primaryRed),
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchHistory,
              color: primaryRed,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryRed))
                  : _filteredHistory.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _filteredHistory.length,
                          itemBuilder: (context, index) {
                            final t = _filteredHistory[index];
                            return _buildHistoryCard(t, isDark);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView( // Gunakan ListView agar RefreshIndicator bekerja
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Center(
          child: Text("Belum ada riwayat scan", 
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Ticket t, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: Colors.green),
        ),
        title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("ID: ${t.id} • Sukses", style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailTicketPage(ticketId: t.id, ticketName: t.name),
            ),
          );
        },
      ),
    );
  }
}