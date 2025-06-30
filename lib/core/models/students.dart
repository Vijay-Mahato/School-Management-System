class Student {
  final String id;
  final String name;
  final String email;
  final String studentIdNumber;
  final String className;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.studentIdNumber,
    required this.className,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'studentIdNumber': studentIdNumber,
      'className': className,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      studentIdNumber: map['studentIdNumber'] ?? '',
      className: map['className'] ?? '',
    );
  }
}
