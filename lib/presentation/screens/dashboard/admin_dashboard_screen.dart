import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/students.dart';
import '../../../core/models/teacher.dart';
import '../../../core/utils/app_theme.dart';
import '../../viewmodels/admin_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/loading_button.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 24),
            _buildStatsCards(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildSearchBar(context),
            const SizedBox(height: 16),
            _buildRecordsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        authViewModel.currentUser?.name ?? 'Admin',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: -0.3, delay: 200.ms);
      },
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        final students = adminViewModel.getStudents();
        final teachers = adminViewModel.getTeachers();
        final classes = adminViewModel.getClasses();

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Students',
                students.length.toString(),
                Icons.school,
                AppTheme.primaryColor,
              ).animate().scale(delay: 400.ms),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Teachers',
                teachers.length.toString(),
                Icons.person,
                AppTheme.secondaryColor,
              ).animate().scale(delay: 600.ms),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Classes',
                classes.length.toString(),
                Icons.class_,
                AppTheme.successColor,
              ).animate().scale(delay: 800.ms),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, 'Student'),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Student'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ).animate().slideX(begin: -0.3, delay: 1000.ms),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, 'Teacher'),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Teacher'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ).animate().slideX(begin: 0.3, delay: 1200.ms),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        return CustomTextField(
          controller: TextEditingController(text: adminViewModel.searchQuery),
          hintText: 'Search students, teachers, classes...',
          prefixIcon: Icons.search,
          onChanged: (value) {
            adminViewModel.searchQuery = value;
          },
        ).animate().slideY(begin: 0.3, delay: 1400.ms);
      },
    );
  }

  Widget _buildRecordsList(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: 'Students'),
              Tab(text: 'Teachers'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                _buildStudentsList(context),
                _buildTeachersList(context),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1600.ms);
  }

  Widget _buildStudentsList(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        final students = adminViewModel.filteredStudents;

        if (students.isEmpty) {
          return const Center(
            child: Text('No students found'),
          );
        }

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    student.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(student.name),
                subtitle: Text('${student.studentIdNumber} • ${student.className}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                      onPressed: () => _showEditDialog(context, student),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                      onPressed: () => _showDeleteDialog(context, student.id, 'Student'),
                    ),
                  ],
                ),
              ),
            ).animate().slideX(begin: 0.3, delay: (index * 100).ms);
          },
        );
      },
    );
  }

  Widget _buildTeachersList(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        final teachers = adminViewModel.filteredTeachers;

        if (teachers.isEmpty) {
          return const Center(
            child: Text('No teachers found'),
          );
        }

        return ListView.builder(
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                  child: Text(
                    teacher.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(teacher.name),
                subtitle: Text('${teacher.teacherIdNumber} • ${teacher.subject}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                      onPressed: () => _showEditDialog(context, teacher),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                      onPressed: () => _showDeleteDialog(context, teacher.id, 'Teacher'),
                    ),
                  ],
                ),
              ),
            ).animate().slideX(begin: 0.3, delay: (index * 100).ms);
          },
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, String type) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final idController = TextEditingController();
    final extraController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add $type'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: 'Full Name',
                    prefixIcon: Icons.person,
                    validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value?.isEmpty == true ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: idController,
                    hintText: '${type} ID',
                    prefixIcon: Icons.badge,
                    validator: (value) => value?.isEmpty == true ? 'ID is required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: extraController,
                    hintText: type == 'Student' ? 'Class' : 'Subject',
                    prefixIcon: type == 'Student' ? Icons.class_ : Icons.subject,
                    validator: (value) => value?.isEmpty == true ? 'Field is required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            LoadingButton(
              text: 'Add',
              isLoading: isLoading,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                setState(() => isLoading = true);

                try {
                  final adminViewModel = context.read<AdminViewModel>();

                  if (type == 'Student') {
                    await adminViewModel.addStudent(
                      email: emailController.text.trim(),
                      password: 'default123',
                      name: nameController.text.trim(),
                      className: extraController.text.trim(),
                      studentIdNumber: idController.text.trim(),
                    );
                  } else {
                    await adminViewModel.addTeacher(
                      email: emailController.text.trim(),
                      password: 'default123',
                      name: nameController.text.trim(),
                      subject: extraController.text.trim(),
                      teacherIdNumber: idController.text.trim(),
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$type added successfully!'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    setState(() => isLoading = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic record) {
    final isStudent = record is Student;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: record.name);
    final emailController = TextEditingController(text: record.email);
    final idController = TextEditingController(
      text: isStudent ? record.studentIdNumber : record.teacherIdNumber,
    );
    final extraController = TextEditingController(
      text: isStudent ? record.className : record.subject,
    );
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit ${isStudent ? 'Student' : 'Teacher'}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: 'Full Name',
                    prefixIcon: Icons.person,
                    validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value?.isEmpty == true ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: idController,
                    hintText: '${isStudent ? 'Student' : 'Teacher'} ID',
                    prefixIcon: Icons.badge,
                    validator: (value) => value?.isEmpty == true ? 'ID is required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: extraController,
                    hintText: isStudent ? 'Class' : 'Subject',
                    prefixIcon: isStudent ? Icons.class_ : Icons.subject,
                    validator: (value) => value?.isEmpty == true ? 'Field is required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            LoadingButton(
              text: 'Save',
              isLoading: isLoading,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                setState(() => isLoading = true);

                try {
                  final adminViewModel = context.read<AdminViewModel>();

                  if (isStudent) {
                    final updatedStudent = Student(
                      id: record.id,
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      studentIdNumber: idController.text.trim(),
                      className: extraController.text.trim(),
                    );
                    await adminViewModel.updateStudent(updatedStudent);
                  } else {
                    final updatedTeacher = Teacher(
                      id: record.id,
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      teacherIdNumber: idController.text.trim(),
                      subject: extraController.text.trim(),
                    );
                    await adminViewModel.updateTeacher(updatedTeacher);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${isStudent ? 'Student' : 'Teacher'} updated successfully!'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    setState(() => isLoading = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, String type) {
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Delete $type'),
          content: Text('Are you sure you want to delete this $type?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            LoadingButton(
              text: 'Delete',
              isLoading: isLoading,
              backgroundColor: AppTheme.errorColor,
              onPressed: () async {
                setState(() => isLoading = true);

                try {
                  final adminViewModel = context.read<AdminViewModel>();

                  if (type == 'Student') {
                    await adminViewModel.deleteStudent(id);
                  } else {
                    await adminViewModel.deleteTeacher(id);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$type deleted successfully!'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    setState(() => isLoading = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await context.read<AuthViewModel>().logout();
      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
