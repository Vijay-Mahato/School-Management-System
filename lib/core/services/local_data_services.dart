import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/students.dart';
import '../models/teacher.dart';
import '../models/user.dart';

class LocalDataService {
  static const String _credentialsKey = 'credentials';
  static const String _studentsKey = 'students';
  static const String _teachersKey = 'teachers';
  static const String _currentUserKey = 'currentUser';

  final Map<String, Map<String, String>> _credentials = {};
  final List<Student> _students = [];
  final List<Teacher> _teachers = [];

  Future<void> initialize() async {
    await _loadData();
    await _initializeDefaultData();
  }

  Future<void> _initializeDefaultData() async {
    if (_credentials.isEmpty) {
      // Add default admin
      _credentials['admin@school.com'] = {
        'password': 'password123',
        'role': 'admin',
        'name': 'Admin User',
        'uid': 'admin1',
      };

      // Add default teacher
      final teacherId = const Uuid().v4();
      _credentials['teacher@school.com'] = {
        'password': 'password123',
        'role': 'teacher',
        'name': 'Jane Smith',
        'uid': teacherId,
      };
      _teachers.add(Teacher(
        id: teacherId,
        name: 'Jane Smith',
        email: 'teacher@school.com',
        teacherIdNumber: 'TEA001',
        subject: 'Mathematics',
      ));

      // Add default student
      final studentId = const Uuid().v4();
      _credentials['student@school.com'] = {
        'password': 'password123',
        'role': 'student',
        'name': 'John Doe',
        'uid': studentId,
      };
      _students.add(Student(
        id: studentId,
        name: 'John Doe',
        email: 'student@school.com',
        studentIdNumber: 'STU001',
        className: 'Grade 10A',
      ));

      await _saveData();
    }
  }

  Future<String> signIn(String email, String password) async {
    final user = _credentials[email];
    if (user == null) {
      throw Exception('Email not found');
    }
    if (user['password'] != password) {
      throw Exception('Incorrect password');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, email);
    return user['role']!;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentUserKey);
    if (email != null && _credentials.containsKey(email)) {
      final userData = _credentials[email]!;
      return AppUser(
        uid: userData['uid']!,
        email: email,
        name: userData['name']!,
        role: userData['role']!,
      );
    }
    return null;
  }

  Future<String?> getUserRole() async {
    final user = await getCurrentUser();
    return user?.role;
  }

  List<Student> getStudents() => List.from(_students);
  List<Teacher> getTeachers() => List.from(_teachers);

  Future<void> addStudent({
    required String email,
    required String password,
    required String name,
    required String className,
    required String studentIdNumber,
  }) async {
    if (_credentials.containsKey(email)) {
      throw Exception('Email already exists');
    }

    final id = const Uuid().v4();
    _students.add(Student(
      id: id,
      name: name,
      email: email,
      studentIdNumber: studentIdNumber,
      className: className,
    ));

    _credentials[email] = {
      'password': password,
      'role': 'student',
      'name': name,
      'uid': id,
    };

    await _saveData();
  }

  Future<void> addTeacher({
    required String email,
    required String password,
    required String name,
    required String subject,
    required String teacherIdNumber,
  }) async {
    if (_credentials.containsKey(email)) {
      throw Exception('Email already exists');
    }

    final id = const Uuid().v4();
    _teachers.add(Teacher(
      id: id,
      name: name,
      email: email,
      teacherIdNumber: teacherIdNumber,
      subject: subject,
    ));

    _credentials[email] = {
      'password': password,
      'role': 'teacher',
      'name': name,
      'uid': id,
    };

    await _saveData();
  }

  Future<void> updateStudent(Student student) async {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index == -1) throw Exception('Student not found');

    final oldStudent = _students[index];
    _students[index] = student;

    if (oldStudent.email != student.email) {
      final userData = _credentials.remove(oldStudent.email);
      if (userData != null) {
        _credentials[student.email] = {
          ...userData,
          'name': student.name,
        };
      }
    } else {
      _credentials[student.email]?['name'] = student.name;
    }

    await _saveData();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    final index = _teachers.indexWhere((t) => t.id == teacher.id);
    if (index == -1) throw Exception('Teacher not found');

    final oldTeacher = _teachers[index];
    _teachers[index] = teacher;

    if (oldTeacher.email != teacher.email) {
      final userData = _credentials.remove(oldTeacher.email);
      if (userData != null) {
        _credentials[teacher.email] = {
          ...userData,
          'name': teacher.name,
        };
      }
    } else {
      _credentials[teacher.email]?['name'] = teacher.name;
    }

    await _saveData();
  }

  Future<void> deleteStudent(String id) async {
    final student = _students.firstWhere((s) => s.id == id);
    _students.removeWhere((s) => s.id == id);
    _credentials.remove(student.email);
    await _saveData();
  }

  Future<void> deleteTeacher(String id) async {
    final teacher = _teachers.firstWhere((t) => t.id == id);
    _teachers.removeWhere((t) => t.id == id);
    _credentials.remove(teacher.email);
    await _saveData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save credentials
    await prefs.setString(_credentialsKey, jsonEncode(_credentials));

    // Save students
    final studentsJson = _students.map((s) => s.toMap()).toList();
    await prefs.setString(_studentsKey, jsonEncode(studentsJson));

    // Save teachers
    final teachersJson = _teachers.map((t) => t.toMap()).toList();
    await prefs.setString(_teachersKey, jsonEncode(teachersJson));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load credentials
    final credentialsString = prefs.getString(_credentialsKey);
    if (credentialsString != null) {
      final Map<String, dynamic> credentialsMap = jsonDecode(credentialsString);
      _credentials.clear();
      credentialsMap.forEach((key, value) {
        _credentials[key] = Map<String, String>.from(value);
      });
    }

    // Load students
    final studentsString = prefs.getString(_studentsKey);
    if (studentsString != null) {
      final List<dynamic> studentsList = jsonDecode(studentsString);
      _students.clear();
      _students.addAll(studentsList.map((s) => Student.fromMap(s)));
    }

    // Load teachers
    final teachersString = prefs.getString(_teachersKey);
    if (teachersString != null) {
      final List<dynamic> teachersList = jsonDecode(teachersString);
      _teachers.clear();
      _teachers.addAll(teachersList.map((t) => Teacher.fromMap(t)));
    }
  }
}
