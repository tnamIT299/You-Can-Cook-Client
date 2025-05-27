import 'package:flutter/material.dart';
import 'package:you_can_cook/services/ReportService.dart';

class ReportDialog extends StatefulWidget {
  final String reporterUid;
  final String reportedUid;

  const ReportDialog({
    required this.reporterUid,
    required this.reportedUid,
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
      'value': 'fake_account',
      'label': 'Tài khoản giả mạo',
      'description':
          'Sử dụng thông tin cá nhân hoặc ảnh đại diện của người khác',
    },
    {
      'value': 'spam_behavior',
      'label': 'Hành vi spam',
      'description':
          'Đăng quá nhiều nội dung lặp lại, quảng cáo hoặc liên kết spam',
    },
    {
      'value': 'harassment',
      'label': 'Quấy rối người dùng khác',
      'description': 'Bình luận tiêu cực, đe dọa hoặc quấy rối người dùng khác',
    },
    {
      'value': 'hate_speech',
      'label': 'Ngôn từ thù địch',
      'description': 'Sử dụng ngôn từ phân biệt đối xử, kỳ thị hoặc thù địch',
    },
    {
      'value': 'inappropriate_profile',
      'label': 'Hồ sơ không phù hợp',
      'description':
          'Ảnh đại diện, tên hiển thị hoặc mô tả chứa nội dung không phù hợp',
    },
    {
      'value': 'scam_fraud',
      'label': 'Lừa đảo hoặc gian lận',
      'description':
          'Cố gắng lừa đảo tiền bạc hoặc thông tin cá nhân của người khác',
    },
    {
      'value': 'selling_illegal',
      'label': 'Bán hàng trái phép',
      'description':
          'Quảng cáo bán sản phẩm không được phép hoặc vi phạm pháp luật',
    },
    {
      'value': 'copyright_violation',
      'label': 'Vi phạm bản quyền',
      'description':
          'Sử dụng công thức, hình ảnh hoặc video có bản quyền trái phép',
    },
    {
      'value': 'underage_user',
      'label': 'Người dùng dưới tuổi quy định',
      'description': 'Tài khoản được tạo bởi người dùng dưới 13 tuổi',
    },
    {
      'value': 'multiple_accounts',
      'label': 'Tạo nhiều tài khoản',
      'description':
          'Tạo nhiều tài khoản để thao túng hệ thống hoặc tránh khóa tài khoản',
    },
    {
      'value': 'inappropriate_username',
      'label': 'Tên người dùng không phù hợp',
      'description':
          'Tên đăng nhập chứa từ ngữ tục tĩu, phân biệt hoặc không phù hợp',
    },
    {
      'value': 'bot_account',
      'label': 'Tài khoản bot',
      'description': 'Tài khoản được điều khiển tự động, không phải người thật',
    },
    {
      'value': 'dangerous_content',
      'label': 'Chia sẻ nội dung nguy hiểm',
      'description':
          'Chia sẻ công thức hoặc lời khuyên nấu ăn có thể gây nguy hiểm',
    },
    {
      'value': 'privacy_violation',
      'label': 'Vi phạm quyền riêng tư',
      'description':
          'Chia sẻ thông tin cá nhân của người khác mà không có sự đồng ý',
    },
    {
      'value': 'off_topic_content',
      'label': 'Nội dung không liên quan',
      'description':
          'Liên tục đăng nội dung không liên quan đến nấu ăn và ẩm thực',
    },
    {
      'value': 'vote_manipulation',
      'label': 'Thao túng tương tác',
      'description':
          'Sử dụng các thủ đoạn để tăng like, follow hoặc comment giả',
    },
    {
      'value': 'self_harm',
      'label': 'Khuyến khích tự làm hại bản thân',
      'description':
          'Chia sẻ nội dung khuyến khích rối loạn ăn uống hoặc tự làm hại',
    },
    {
      'value': 'community_guidelines',
      'label': 'Vi phạm quy tắc cộng đồng',
      'description':
          'Hành vi không tuân thủ các quy tắc và nguyên tắc của cộng đồng',
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
