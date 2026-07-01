class Lead {
  final int id;
  final String name;
  final String? email;
  final String? documento;
  final String? phone;
  final String? origin;
  final String status;
  final String? triageSummary;
  final String? triageClassification;

  Lead({
    required this.id,
    required this.name,
    this.email,
    this.documento,
    this.phone,
    this.origin,
    required this.status,
    this.triageSummary,
    this.triageClassification,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
      documento: json['documento'],
      phone: json['phone'],
      origin: json['origin'],
      status: json['status'] ?? 'new',
      triageSummary: json['triage_summary'],
      triageClassification: json['triage_classification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'documento': documento,
      'phone': phone,
      'origin': origin,
      'status': status,
      'triage_summary': triageSummary,
      'triage_classification': triageClassification,
    };
  }
}
