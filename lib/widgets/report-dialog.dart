import 'package:flutter/material.dart';
import 'package:you_can_cook/services/ReportService.dart';

class ReportDialog extends StatefulWidget {
  final String reporterUid;
  final String reportedUid; // UID của người bị báo cáo
  final String? pid; // ID của bài post (nếu có)
  final String? reel_id; // ID của bình luận (nếu có)

  const ReportDialog({
    required this.reporterUid,
    required this.reportedUid,
    this.pid,
    this.reel_id,
    super.key,
  });

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final UserService _userService = UserService();
  final TextEditingController _reportController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitReport() async {
    if (_reportController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập nội dung báo cáo');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _userService.reportUser(
        reporterUid:
            widget.reporterUid, // UID của người báo cáo (người dùng hiện tại)
        reportedUid: widget.reportedUid,
        content: _reportController.text.trim(),
        pid: widget.pid,
        reel_id: widget.reel_id,
      );
      Navigator.of(
        context,
      ).pop(true); // Đóng dialog và trả về true nếu thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi báo cáo thành công')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khi gửi báo cáo: $e';
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Báo cáo người dùng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _reportController,
            decoration: InputDecoration(
              labelText: 'Nội dung báo cáo',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Đóng dialog, trả về false
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitReport,
          child:
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Gửi'),
        ),
      ],
    );
  }
}
