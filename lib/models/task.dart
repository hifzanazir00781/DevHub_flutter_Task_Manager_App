class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime? dueDate;
  String? category;
  int priority; // 1: High, 2: Medium, 3: Low
  DateTime createdAt;
  List<String> subtasks;
  String? notes;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
    this.category,
    this.priority = 2,
    required this.createdAt,
    this.subtasks = const [],
    this.notes,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'dueDate': dueDate?.toIso8601String(),
        'category': category,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
        'subtasks': subtasks,
        'notes': notes,
      };

  // Create from JSON
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
        dueDate: json['dueDate'] != null 
            ? DateTime.parse(json['dueDate']) 
            : null,
        category: json['category'],
        priority: json['priority'] ?? 2,
        createdAt: DateTime.parse(json['createdAt']),
        subtasks: List<String>.from(json['subtasks'] ?? []),
        notes: json['notes'],
      );

  // Copy with method for updates
  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    String? category,
    int? priority,
    List<String>? subtasks,
    String? notes,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      subtasks: subtasks ?? this.subtasks,
      notes: notes ?? this.notes,
    );
  }
}