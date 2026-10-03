import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({
    super.key,
  });

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState
    extends State<AdminNotificationScreen> {
  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController messageController =
  TextEditingController();

  bool loading = false;

  Future<void> sendNotification() async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Title and message are required',
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final response = await ApiService.sendNotification(
        title: title,
        message: message,
      );

      if (!mounted) return;

      if (response.data['success'] == true) {
        titleController.clear();
        messageController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification sent successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.data['message'] ??
                  'Failed to send notification',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Failed to send notification';

      if (e.toString().isNotEmpty) {
        errorMessage = 'Failed to send notification';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Notification',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Send a notification to all users.',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              Text(
                'Notification Title',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: titleController,
                maxLength: 150,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Enter notification title',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Notification Message',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: messageController,
                maxLines: 6,
                maxLength: 5000,
                decoration: const InputDecoration(
                  hintText: 'Enter notification message',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : sendNotification,
                  child: loading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Send Notification',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}