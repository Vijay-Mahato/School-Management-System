class Teacher {
  final String id;
  final String name;
  final String email;
  final String teacherIdNumber;
  final String subject;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.teacherIdNumber,
    required this.subject,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'teacherIdNumber': teacherIdNumber,
      'subject': subject,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      teacherIdNumber: map['teacherIdNumber'] ?? '',
      subject: map['subject'] ?? '',
    );
  }
}
