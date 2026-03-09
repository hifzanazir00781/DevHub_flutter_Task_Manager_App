import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'profile_screen.dart';
import '../utils/constants.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';
  Timer? _debounce;
  bool _isLoading = true;

  final List<String> _filters = ['All', 'Today', 'Important', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = StorageService().getTasks();
    setState(() {
      _tasks = tasks;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    // First apply search
    List<Task> filtered = _tasks.where((task) {
      if (_searchQuery.isEmpty) return true;
      return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Then apply filter
    switch (_selectedFilter) {
      case 'Today':
        filtered = filtered.where((task) {
          if (task.dueDate == null) return false;
          final now = DateTime.now();
          return task.dueDate!.day == now.day &&
              task.dueDate!.month == now.month &&
              task.dueDate!.year == now.year;
        }).toList();
        break;
      case 'Important':
        filtered = filtered.where((task) => task.priority == 1).toList();
        break;
      case 'Completed':
        filtered = filtered.where((task) => task.isCompleted).toList();
        break;
      default:
        // 'All' - show all tasks
        break;
    }

    setState(() {
      _filteredTasks = filtered;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = query);
      _applyFilters();
    });
  }

  Future<void> _refreshTasks() async {
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storage = StorageService();
    
    // Get stats
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;
    final importantTasks = _tasks.where((t) => t.priority == 1 && !t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        centerTitle: true,
        actions: [
          // Profile button
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) => _loadTasks()); // Reload tasks when returning from profile
            },
            tooltip: 'Profile',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        color: theme.colorScheme.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Stats cards
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildStatCard(
                          'Total',
                          totalTasks.toString(),
                          Colors.deepPurple,
                          Icons.task_alt,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Pending',
                          pendingTasks.toString(),
                          Colors.orange,
                          Icons.pending_actions,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Done',
                          completedTasks.toString(),
                          Colors.green,
                          Icons.check_circle_outline,
                        ),
                      ],
                    ),
                  ),

                  // Important indicator if there are important tasks
                  if (importantTasks > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.priority_high, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'You have $importantTasks important pending task${importantTasks > 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedFilter = filter);
                              _applyFilters();
                            },
                            backgroundColor: Colors.grey.shade50,
                            selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? theme.colorScheme.primary : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tasks count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredTasks.length} task${_filteredTasks.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_selectedFilter != 'All')
                          TextButton(
                            onPressed: () {
                              setState(() => _selectedFilter = 'All');
                              _applyFilters();
                            },
                            child: const Text('Clear filter'),
                          ),
                      ],
                    ),
                  ),

                  // Tasks list
                  Expanded(
                    child: _filteredTasks.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = _filteredTasks[index];
                              return TaskTile(
                                task: task,
                                onTap: () => _showTaskDetails(task),
                                onDelete: () => _deleteTask(task.id),
                                onCheckboxChanged: (value) async {
                                  await storage.toggleTaskCompletion(task.id);
                                  _loadTasks();
                                },
                                onEdit: () => _editTask(task),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _selectedFilter != 'All' || _searchQuery.isNotEmpty;
    
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered ? Icons.search_off : Icons.task_alt,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No matching tasks' : 'No tasks yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered 
                  ? 'Try changing your search or filter'
                  : 'Tap + to add your first task',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'All';
                    _searchQuery = '';
                  });
                  _applyFilters();
                },
                child: const Text('Clear all filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addNewTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );
    if (result == true) {
      _loadTasks();
    }
  }

  Future<void> _editTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    );
    if (result == true) {
      _loadTasks();
    }
  }

  Future<void> _deleteTask(String taskId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService().deleteTask(taskId);
              _loadTasks();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task deleted'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: task.isCompleted 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        task.isCompleted ? 'Completed' : 'Pending',
                        style: TextStyle(
                          color: task.isCompleted ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.pop(context);
                        _editTask(task);
                      },
                    ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                _buildDetailRow(
                  Icons.access_time,
                  'Due Date',
                  task.dueDate != null
                      ? '${Constants.formatDate(task.dueDate!)} at ${Constants.formatTime(task.dueDate!)}'
                      : 'No due date',
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.flag,
                  'Priority',
                  task.priority == 1
                      ? 'High'
                      : task.priority == 2
                          ? 'Medium'
                          : 'Low',
                  priority: task.priority,
                ),
                if (task.category != null && task.category!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.folder_outlined,
                    'Category',
                    task.category!,
                  ),
                ],
                if (task.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.checklist,
                    'Subtasks',
                    '${task.subtasks.length} items',
                  ),
                ],
                if (task.notes != null && task.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.note_outlined,
                    'Notes',
                    task.notes!,
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Created ${Constants.formatDate(task.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {int? priority}) {
    Color? valueColor;
    if (priority != null) {
      switch (priority) {
        case 1:
          valueColor = Colors.red;
          break;
        case 2:
          valueColor = Colors.orange;
          break;
        case 3:
          valueColor = Colors.green;
          break;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}