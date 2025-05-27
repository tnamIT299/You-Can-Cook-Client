import 'package:flutter/material.dart';
import 'package:you_can_cook/services/ReportService.dart';

class ReportDialog extends StatefulWidget {
  final String reporterUid;
  final String reportedUid;
  final String? pid;
  final String? reel_id;

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
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedViolationType;

  // Danh sách các tiêu chí vi phạm
  final List<Map<String, String>> _violationTypes = [
    {
      'value': 'spam',
      'label': 'Spam hoặc nội dung rác',
      'description': 'Đăng nhiều nội dung không liên quan hoặc quảng cáo spam',
    },
    {
      'value': 'harassment',
      'label': 'Quấy rối hoặc bắt nạt',
      'description': 'Hành vi quấy rối, đe dọa hoặc bắt nạt người khác',
    },
    {
      'value': 'hate_speech',
      'label': 'Ngôn từ thù địch',
      'description':
          'Sử dụng ngôn từ phân biệt chủng tộc, tôn giáo hoặc giới tính',
    },
    {
      'value': 'inappropriate_content',
      'label': 'Nội dung không phù hợp',
      'description':
          'Nội dung khiêu dâm, bạo lực hoặc không phù hợp với cộng đồng',
    },
    {
      'value': 'false_information',
      'label': 'Thông tin sai lệch',
      'description': 'Chia sẻ thông tin không chính xác hoặc gây hiểu lầm',
    },
    {
      'value': 'copyright',
      'label': 'Vi phạm bản quyền',
      'description': 'Sử dụng nội dung có bản quyền mà không có sự cho phép',
    },
    {
      'value': 'impersonation',
      'label': 'Mạo danh',
      'description': 'Giả mạo danh tính của người khác hoặc tổ chức',
    },
    {
      'value': 'violence',
      'label': 'Bạo lực hoặc nguy hiểm',
      'description': 'Nội dung khuyến khích bạo lực hoặc hành vi nguy hiểm',
    },
    {
      'value': 'privacy',
      'label': 'Vi phạm quyền riêng tư',
      'description': 'Chia sẻ thông tin cá nhân mà không có sự đồng ý',
    },
    {
      'value': 'other',
      'label': 'Lý do khác',
      'description': 'Vi phạm khác không thuộc các danh mục trên',
    },
  ];

  Future<void> _submitReport() async {
    if (_selectedViolationType == null) {
      setState(() => _errorMessage = 'Vui lòng chọn lý do báo cáo');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Tìm label và description của violation type được chọn
      final selectedViolation = _violationTypes.firstWhere(
        (violation) => violation['value'] == _selectedViolationType,
      );

      await _userService.reportUser(
        reporterUid: widget.reporterUid,
        reportedUid: widget.reportedUid,
        content: selectedViolation['label']!,
        pid: widget.pid,
        reel_id: widget.reel_id,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi báo cáo thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi khi gửi báo cáo: $e';
        });
      }
      print('Error submitting report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Báo cáo vi phạm',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6, // Giới hạn chiều cao
        child: SingleChildScrollView(
          // Thêm scroll view
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vui lòng chọn lý do báo cáo:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text('Chọn lý do báo cáo'),
                    value: _selectedViolationType,
                    isExpanded: true,
                    // Giảm chiều cao của dropdown items
                    items:
                        _violationTypes.map((violation) {
                          return DropdownMenuItem<String>(
                            value: violation['value'],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    violation['label']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    violation['description']!,
                                    style: TextStyle(
                                      fontSize: 11, // Giảm font size
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1, // Giảm từ 2 xuống 1 dòng
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedViolationType = newValue;
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              if (_selectedViolationType != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lý do được chọn:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _violationTypes.firstWhere(
                          (v) => v['value'] == _selectedViolationType,
                        )['label']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _violationTypes.firstWhere(
                          (v) => v['value'] == _selectedViolationType,
                        )['description']!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    Navigator.of(context).pop(false);
                  },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text('Gửi báo cáo'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
