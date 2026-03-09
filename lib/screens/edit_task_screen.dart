import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/custom_textfield.dart';
import '../utils/constants.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  late String _selectedCategory;
  late int _selectedPriority;

  final List<String> _categories = [
    'Default',
    'Personal',
    'Work',
    'Shopping',
    'Health',
    'Education',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _notesController = TextEditingController(text: widget.task.notes);
    
    _selectedDate = widget.task.dueDate;
    if (widget.task.dueDate != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.task.dueDate!);
    }
    _selectedCategory = widget.task.category ?? 'Default';
    _selectedPriority = widget.task.priority;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            CustomTextField(
              controller: _titleController,
              label: 'Task Title',
              hintText: 'Enter task title',
              prefixIcon: Icons.task_alt,
            ),
            
            const SizedBox(height: 20),
            
            // Description
            CustomTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              hintText: 'Add more details',
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
            ),
            
            const SizedBox(height: 20),
            
            // Due Date & Time
            const Text(
              'Due Date & Time',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDate != null
                                ? Constants.formatDate(_selectedDate!)
                                : 'No date',
                            style: TextStyle(
                              color: _selectedDate != null
                                  ? Colors.black
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectedDate == null
                        ? null
                        : _selectTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedDate == null
                              ? Colors.grey.shade200
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedDate == null
                            ? Colors.grey.shade50
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 18,
                              color: _selectedDate == null
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Select time',
                            style: TextStyle(
                              color: _selectedTime != null
                                  ? Colors.black
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Category
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            // Priority
            const Text(
              'Priority',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 1,
                  label: Text('High'),
                  icon: Icon(Icons.priority_high, color: Colors.red),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('Medium'),
                  icon: Icon(Icons.remove, color: Colors.orange),
                ),
                ButtonSegment(
                  value: 3,
                  label: Text('Low'),
                  icon: Icon(Icons.low_priority, color: Colors.green),
                ),
              ],
              selected: {_selectedPriority},
              onSelectionChanged: (Set<int> selected) {
                setState(() {
                  _selectedPriority = selected.first;
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            // Notes
            CustomTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              hintText: 'Add any additional notes',
              prefixIcon: Icons.note_outlined,
              maxLines: 2,
            ),
            
            const SizedBox(height: 30),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateTask,
                    child: const Text('Update Task'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Combine date and time
    DateTime? dueDate;
    if (_selectedDate != null) {
      dueDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime?.hour ?? 23,
        _selectedTime?.minute ?? 59,
      );
    }

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: dueDate,
      category: _selectedCategory,
      priority: _selectedPriority,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    await StorageService().updateTask(updatedTask);
    
    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}