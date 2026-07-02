class Movimentacao {
  final int id;
  final int processoId;
  final String description;
  final DateTime? createdAt;

  Movimentacao({
    required this.id,
    required this.processoId,
    required this.description,
    this.createdAt,
  });

  factory Movimentacao.fromJson(Map<String, dynamic> json) {
    return Movimentacao(
      id: json['id'],
      processoId: json['processo_id'],
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'processo_id': processoId,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Processo {
  final int id;
  final int leadId;
  final String? leadName;
  final String title;
  final String? description;
  final String status;
  final List<Movimentacao> movimentacoes;

  Processo({
    required this.id,
    required this.leadId,
    this.leadName,
    required this.title,
    this.description,
    required this.status,
    this.movimentacoes = const [],
  });

  factory Processo.fromJson(Map<String, dynamic> json) {
    var movsList = json['movimentacoes'] as List?;
    List<Movimentacao> movs = movsList != null
        ? movsList.map((m) => Movimentacao.fromJson(m)).toList()
        : [];

    return Processo(
      id: json['id'],
      leadId: json['lead_id'],
      leadName: json['lead_name'],
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'open',
      movimentacoes: movs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'lead_name': leadName,
      'title': title,
      'description': description,
      'status': status,
      'movimentacoes': movimentacoes.map((m) => m.toJson()).toList(),
    };
  }
}
