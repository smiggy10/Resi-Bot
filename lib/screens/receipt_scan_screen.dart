import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../main.dart';

class ReceiptScanFlow {
  static const List<String> categories = [
    'Grocery',
    'Shopping',
    'Food',
    'Transportation',
    'Utilities',
    'Health',
    'Education',
    'Entertainment',
    'Other',
  ];

  static Future<void> start(BuildContext context) async {
    final selectedCategory = await _showCategoryDialog(context);

    if (selectedCategory == null || !context.mounted) return;

    final imageSource = await _showImageSourceSheet(context);

    if (imageSource == null || !context.mounted) return;

    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: imageSource,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (pickedImage == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptProcessingScreen(
          category: selectedCategory,
          imagePath: pickedImage.path,
          imageName: pickedImage.name,
        ),
      ),
    );
  }

  static Future<String?> _showCategoryDialog(BuildContext context) {
    String selectedCategory = categories.first;

    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(.72),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.card,
              insetPadding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Choose Receipt Category',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select the category where this receipt belongs before scanning or uploading it.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = selectedCategory == category;

                        return ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: AppColors.purple,
                          backgroundColor: AppColors.softCard,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.text,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.lightPurple
                                : Colors.white.withOpacity(.08),
                          ),
                          onSelected: (_) {
                            setState(() => selectedCategory = category);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'CONFIRM CATEGORY',
                      onTap: () => Navigator.pop(
                        dialogContext,
                        selectedCategory,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<ImageSource?> _showImageSourceSheet(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add Receipt Image',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Take a photo of the receipt or upload an existing image.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _ImageSourceOption(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Open camera and capture the receipt',
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
                const SizedBox(height: 10),
                _ImageSourceOption(
                  icon: Icons.photo_library,
                  title: 'Upload from Gallery',
                  subtitle: 'Choose an existing receipt image',
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.purple.withOpacity(.18),
              child: Icon(icon, color: AppColors.lightPurple),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptProcessingScreen extends StatefulWidget {
  final String category;
  final String imagePath;
  final String imageName;

  const ReceiptProcessingScreen({
    super.key,
    required this.category,
    required this.imagePath,
    required this.imageName,
  });

  @override
  State<ReceiptProcessingScreen> createState() =>
      _ReceiptProcessingScreenState();
}

class _ReceiptProcessingScreenState extends State<ReceiptProcessingScreen> {
  bool isProcessing = true;
  bool hasError = false;

  Uint8List? receiptImageBytes;

  late String store;
  late String totalAmount;
  late String receiptDate;

  @override
  void initState() {
    super.initState();

    store = 'Processing...';
    totalAmount = 'Processing...';
    receiptDate = 'Processing...';

    _processReceiptWithN8n();
  }

  String _getMimeType(String fileName) {
    final lowerName = fileName.toLowerCase();

    if (lowerName.endsWith('.png')) {
      return 'image/png';
    }

    if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    if (lowerName.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }

  Future<void> _processReceiptWithN8n() async {
    try {
      final user = AppSession.currentUser;

      if (user == null || user.userId.isEmpty) {
        throw Exception('No logged-in user found.');
      }

      final xFile = XFile(widget.imagePath);
      final imageBytes = await xFile.readAsBytes();

      if (!mounted) return;

      setState(() {
        receiptImageBytes = imageBytes;
      });

      final base64Image = base64Encode(imageBytes);
      final fileName = widget.imageName.isNotEmpty
          ? widget.imageName
          : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final mimeType = _getMimeType(fileName);

      final response = await http
          .post(
            Uri.parse(AppConfig.receiptUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': user.userId,
              'category': widget.category,
              'receiptImage': base64Image,
              'receiptImageName': fileName,
              'receiptImageType': mimeType,
            }),
          )
          .timeout(const Duration(seconds: 90));

      Map<String, dynamic> data = {};

      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Invalid response from n8n. Status: ${response.statusCode}. Body: ${response.body}',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw Exception(data['message'] ?? 'Receipt processing failed.');
      }

      final receipt = data['receipt'] ?? {};

      if (!mounted) return;

      setState(() {
        isProcessing = false;
        hasError = false;
        store = receipt['store']?.toString().isNotEmpty == true
            ? receipt['store'].toString()
            : 'Not detected';
        totalAmount = receipt['totalAmountSpent']?.toString().isNotEmpty == true
            ? receipt['totalAmountSpent'].toString()
            : 'Not detected';
        receiptDate = receipt['date']?.toString().isNotEmpty == true
            ? receipt['date'].toString()
            : 'Not detected';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
        hasError = true;
        store = 'Error';
        totalAmount = '-';
        receiptDate = '-';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt processing failed: $e'),
        ),
      );
    }
  }

  Future<void> _retryProcessing() async {
    setState(() {
      isProcessing = true;
      hasError = false;
      store = 'Processing...';
      totalAmount = 'Processing...';
      receiptDate = 'Processing...';
    });

    await _processReceiptWithN8n();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan Receipt',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Category',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.category,
                                  color: AppColors.purple,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Receipt Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: receiptImageBytes != null
                            ? Image.memory(
                                receiptImageBytes!,
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: double.infinity,
                                height: 300,
                                color: AppColors.card,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.purple,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 18),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'AI Extraction Result',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (isProcessing)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.purple,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _ResultLine(
                              label: 'Store',
                              value: store,
                            ),
                            _ResultLine(
                              label: 'Total Amount Spent',
                              value: totalAmount,
                            ),
                            _ResultLine(
                              label: 'Date',
                              value: receiptDate,
                            ),
                            _ResultLine(
                              label: 'Category',
                              value: widget.category,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: isProcessing
                            ? 'PROCESSING...'
                            : hasError
                                ? 'RETRY'
                                : 'DONE',
                        onTap: isProcessing
                            ? () {}
                            : hasError
                                ? _retryProcessing
                                : () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ),
                      ),
                    ],
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

class _ResultLine extends StatelessWidget {
  final String label;
  final String value;

  const _ResultLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}