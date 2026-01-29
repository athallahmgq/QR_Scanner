class Ticket {
  final String id;
  final String name;
  final String status;

  Ticket({required this.id, required this.name, required this.status});

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'].toString(), // Pastikan ID dikonversi ke String
      name: json['name'] ?? '',
      status: json['status'] ?? 'unredeemed',
    );
  }
}