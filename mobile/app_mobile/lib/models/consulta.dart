class Consulta {
  final int id;
  final int leadId;
  final DateTime? scheduledAt;
  final String status;

  Consulta({
    required this.id,
    required this.leadId,
    this.scheduledAt,
    required this.status,
  });

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      id: json['id'],
      leadId: json['lead_id'],
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at']) : null,
      status: json['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'status': status,
    };
  }
}
