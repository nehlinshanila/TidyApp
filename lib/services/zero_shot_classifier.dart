// lib/services/zero_shot_classifier.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ZeroShotClassifier {
  static const _apiToken =
      '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'; // Replace with your token
  static const _apiUrl =
      'https://api-inference.huggingface.co/models/facebook/bart-large-mnli';

  static Future<String> classify(String task) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': task,
        'parameters': {
          'candidate_labels': [
            'Appointment',
            'Homework',
            'Event',
            'Reminder',
            'Meeting',
          ],
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['labels'][0];
    } else {
      print('Error: ${response.body}');
      return 'Uncategorized';
    }
  }
}
