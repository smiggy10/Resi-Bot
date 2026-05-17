import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  const ReceiptProcessingScreen({
    super.key,
    required this.category,
    required this.imagePath,
  });

  @override
  State<ReceiptProcessingScreen> createState() =>
      _ReceiptProcessingScreenState();
}

class _ReceiptProcessingScreenState extends State<ReceiptProcessingScreen> {
  bool isProcessing = true;

  late String store;
  late String totalAmount;
  late String receiptDate;

  @override
  void initState() {
    super.initState();

    store = 'Processing...';
    totalAmount = 'Processing...';
    receiptDate = 'Processing...';

    _mockProcessReceipt();
  }

  Future<void> _mockProcessReceipt() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isProcessing = false;

      // Temporary sample values.
      // Later, these values will come from n8n AI extraction.
      store = 'Sample Store';
      totalAmount = '₱0.00';
      receiptDate = 'Pending AI Result';
    });
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
                        child: Image.file(
                          File(widget.imagePath),
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
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
                            : 'SAVE RECEIPT',
                        onTap: isProcessing
                            ? () {}
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'This will be connected to n8n later.',
                                    ),
                                  ),
                                );
                              },
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