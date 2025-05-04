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

        // Group by content-based category
        final Map<String, List<DocumentSnapshot>> grouped = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final category = data['category'] ?? 'Uncategorized';
          grouped.putIfAbsent(category, () => []).add(doc);
        }

        return ListView(
          children:
              grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entry.value.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        final todo = entry.value[index];
                        final data = todo.data() as Map<String, dynamic>;
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      data['task'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
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
