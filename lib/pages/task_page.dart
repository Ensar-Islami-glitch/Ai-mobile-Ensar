import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _titleController = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _tasks = <Map<String, dynamic>>[];
  bool _supportsIsDone = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
    });
    try {
      final List<dynamic> data = await _supabase
          .from('tasks')
          .select()
          .order('id', ascending: false);
      setState(() {
        _tasks = data.cast<Map<String, dynamic>>();
        // Infer schema support for 'is_done' from first row
        if (_tasks.isNotEmpty) {
          _supportsIsDone = _tasks.first.containsKey('is_done');
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tasks: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _addTask() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) return;
    try {
      final Map<String, dynamic> payload = <String, dynamic>{'title': title};
      if (_supportsIsDone) {
        payload['is_done'] = false;
      }
      await _supabase.from('tasks').insert(payload);
      _titleController.clear();
      await _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $e')),
        );
      }
    }
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    if (!_supportsIsDone) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This table doesn't have an 'is_done' column.")),
        );
      }
      return;
    }
    try {
      await _supabase
          .from('tasks')
          .update(<String, dynamic>{'is_done': !(task['is_done'] as bool)})
          .eq('id', task['id']);
      await _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask(String id) async {
    try {
      await _supabase.from('tasks').delete().eq('id', id);
      await _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete task: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'New task',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addTask(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _tasks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> task = _tasks[index];
                        final bool isDone = _supportsIsDone
                            ? ((task['is_done'] as bool?) ?? false)
                            : false;
                        return Dismissible(
                          key: ValueKey<String>(task['id'] as String),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            _deleteTask(task['id'] as String);
                            return true;
                          },
                          child: ListTile(
                            title: Text(
                              (task['title'] as String?) ?? '',
                              style: TextStyle(
                                decoration: _supportsIsDone && isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            onTap: () => _toggleTask(task),
                            leading: _supportsIsDone
                                ? Icon(
                                    isDone
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: isDone ? Colors.green : null,
                                  )
                                : const Icon(Icons.task_alt_outlined),
                            subtitle: task['inserted_at'] != null
                                ? Text('${task['inserted_at']}')
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


