import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/help_faq/faq_item.dart';

class FaqExpansionTile extends StatefulWidget {
  final FaqItem faq;

  const FaqExpansionTile({
    super.key,
    required this.faq,
  });

  @override
  State<FaqExpansionTile> createState() => _FaqExpansionTileState();
}

class _FaqExpansionTileState extends State<FaqExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isExpanded
                  ? AppColors.primaryYellow.withOpacity(0.1)
                  : const Color(0xFF2C2C2E),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isExpanded ? Icons.remove : Icons.add,
              color: _isExpanded
                  ? AppColors.primaryYellow
                  : AppColors.textSecondary,
              size: 20,
            ),
          ),
          title: Text(
            widget.faq.question,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.faq.answer,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}