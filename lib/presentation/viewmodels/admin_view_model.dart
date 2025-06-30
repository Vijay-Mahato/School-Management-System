import 'package:flutter/foundation.dart';
import '../../core/models/students.dart';
import '../../core/models/teacher.dart';
import '../../core/services/local_data_services.dart';

class AdminViewModel extends ChangeNotifier {
  final LocalDataService _localDataService;
  String _searchQuery = '';

  AdminViewModel(this._localDataService);

  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<Student> get filteredStudents {
    final students = _localDataService.getStudents();
    if (_searchQuery.isEmpty) return students;

    return students.where((student) {
      final query = _searchQuery.toLowerCase();
      return student.name.toLowerCase().contains(query) ||
          student.studentIdNumber.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.className.toLowerCase().contains(query);
    }).toList();
  }

  List<Teacher> get filteredTeachers {
    final teachers = _localDataService.getTeachers();
    if (_searchQuery.isEmpty) return teachers;

    return teachers.where((teacher) {
      final query = _searchQuery.toLowerCase();
      return teacher.name.toLowerCase().contains(query) ||
          teacher.teacherIdNumber.toLowerCase().contains(query) ||
          teacher.email.toLowerCase().contains(query) ||
          teacher.subject.toLowerCase().contains(query);
    }).toList();
  }

  List<Student> getStudents() => _localDataService.getStudents();
  List<Teacher> getTeachers() => _localDataService.getTeachers();

  List<String> getClasses() {
    return _localDataService.getStudents()
        .map((student) => student.className)
        .toSet()
        .toList();
  }

  Future<void> addStudent({
    required String email,
    required String password,
    required String name,
    required String className,
    required String studentIdNumber,
  }) async {
    await _localDataService.addStudent(
      email: email,
      password: password,
      name: name,
      className: className,
      studentIdNumber: studentIdNumber,
    );
    notifyListeners();
  }

  Future<void> addTeacher({
    required String email,
    required String password,
    required String name,
    required String subject,
    required String teacherIdNumber,
  }) async {
    await _localDataService.addTeacher(
      email: email,
      password: password,
      name: name,
      subject: subject,
      teacherIdNumber: teacherIdNumber,
    );
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    await _localDataService.updateStudent(student);
    notifyListeners();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    await _localDataService.updateTeacher(teacher);
    notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    await _localDataService.deleteStudent(id);
    notifyListeners();
  }

  Future<void> deleteTeacher(String id) async {
    await _localDataService.deleteTeacher(id);
    notifyListeners();
  }
}
