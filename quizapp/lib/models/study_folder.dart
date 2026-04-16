class StudyFolder {
  final String id;
  final String name;
  final DateTime createdAt;

  StudyFolder({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory StudyFolder.fromJson(Map<String, dynamic> json) {
    return StudyFolder(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt.toIso8601String(),
      };
}