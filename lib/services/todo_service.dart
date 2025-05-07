import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chrono_dart/chrono_dart.dart';

class TodoService {
  static final CollectionReference todos = FirebaseFirestore.instance
      .collection('todos');

  static Future<void> addTodo(String text) async {
    try {
      final parsedDate = Chrono.parseDate(text);
      final now = DateTime.now();

      // TIME-BASED CATEGORY
      String timeCategory = "Uncategorized";
      if (parsedDate != null) {
        final diff = parsedDate.difference(
          DateTime(now.year, now.month, now.day),
        );
        if (diff.inDays == 0) {
          timeCategory = "Today";
        } else if (diff.inDays == 1) {
          timeCategory = "Tomorrow";
        } else if (diff.inDays <= 7) {
          timeCategory = "This Week";
        } else {
          timeCategory = "Later";
        }
      }

      // CONTENT-BASED CATEGORY
      String category = "Uncategorized";
      final lower = text.toLowerCase();
      if (lower.contains('homework') || lower.contains('assignment')) {
        category = 'Homework';
      } else if (lower.contains('call') ||
          lower.contains('meeting') ||
          lower.contains('appointment') ||
          lower.contains('meet') ||
          lower.contains('conference') ||
          lower.contains('council') ||
          lower.contains('session') ||
          lower.contains('discussion') ||
          lower.contains('gathering') ||
          lower.contains('assembly') ||
          lower.contains('zoom') ||
          lower.contains('interview')) {
        category = 'Appointments';
      } else if (lower.contains('buy') ||
          lower.contains('purchase') ||
          lower.contains('shopping') ||
          lower.contains('get') ||
          lower.contains('acquire') ||
          lower.contains('obtain') ||
          lower.contains('pickup') ||
          lower.contains('procure') ||
          lower.contains('add')) {
        category = 'Shopping';
      } else if (lower.contains('birthday') ||
          lower.contains('anniversary') ||
          lower.contains('graduation') ||
          lower.contains('wedding') ||
          lower.contains('babyshower') ||
          lower.contains('engagement') ||
          lower.contains('housewarming') ||
          lower.contains('christmas') ||
          lower.contains('eid') ||
          lower.contains('day') ||
          lower.contains('funeral') ||
          lower.contains('party') ||
          lower.contains('function') ||
          lower.contains('occasion') ||
          lower.contains('festival') ||
          lower.contains('jubilee')) {
        category = 'Events';
      }

      await todos.add({
        'task': text,
        'timestamp': parsedDate ?? FieldValue.serverTimestamp(),
        'timeCategory': timeCategory,
        'category': category,
      });
    } catch (e) {
      print("Error adding todo: $e");
    }
  }

  static Widget todoStreamWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: todos.orderBy('timestamp', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("No tasks available"));
        }

        final Map<String, List<DocumentSnapshot>> grouped = {};
        for (var doc in docs) {
          final category =
              (doc.data() as Map<String, dynamic>)['category'] ??
              'Uncategorized';
          grouped.putIfAbsent(category, () => []).add(doc);
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children:
              grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entry.value.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                      itemBuilder: (context, index) {
                        final todo = entry.value[index];
                        final data = todo.data() as Map<String, dynamic>;
                        final task = data['task'] ?? '';
                        final timeCategory = data['timeCategory'] ?? '';
                        final timestamp =
                            (data['timestamp'] as Timestamp?)?.toDate();

                        final dateStr =
                            timestamp != null
                                ? "${timestamp.day}/${timestamp.month}/${timestamp.year}"
                                : "No Date";
                        final timeStr =
                            timestamp != null
                                ? "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}"
                                : "No Time";

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Task Detail"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("📝 Task: $task"),
                                        const SizedBox(height: 6),
                                        Text("🕒 Time: $timeStr"),
                                        Text("📅 Date: $dateStr"),
                                        Text("🏷️ When: $timeCategory"),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Close"),
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "🕒 $timeStr",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      "📅 $dateStr",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      "📝 ${task.length > 30 ? task.substring(0, 30) + "..." : task}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "🏷️ $timeCategory",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () async {
                                          try {
                                            await todo.reference.delete();
                                          } catch (e) {
                                            print("Error deleting: $e");
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
        );
      },
    );
  }
}
