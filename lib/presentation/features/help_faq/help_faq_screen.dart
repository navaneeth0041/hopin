import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/help_faq/faq_data_provider.dart';
import 'package:hopin/data/models/help_faq/faq_item.dart';
import 'package:hopin/presentation/features/help_faq/widgets/contact_support_dialog.dart';
import 'widgets/faq_search_bar.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/faq_expansion_tile.dart';
import 'widgets/contact_support_card.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<FaqItem> get _filteredFaqs {
    var faqs = FaqDataProvider.allFaqs;

    if (_selectedCategory != 'All') {
      faqs = faqs.where((faq) => faq.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      faqs = faqs
          .where(
            (faq) =>
                faq.question.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                faq.answer.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return faqs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            const SizedBox(height: 16),
            _buildCategoryFilter(),
            const SizedBox(height: 24),
            _buildFaqList(),
            _buildContactSupportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          Text(
            'Help & FAQ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: FaqSearchBar(
        controller: _searchController,
        searchQuery: _searchQuery,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onClear: () {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return CategoryFilterChips(
      categories: FaqDataProvider.categories,
      selectedCategory: _selectedCategory,
      onCategorySelected: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  Widget _buildFaqList() {
    return Expanded(
      child: _filteredFaqs.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              itemCount: _filteredFaqs.length,
              itemBuilder: (context, index) {
                return FaqExpansionTile(faq: _filteredFaqs[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupportButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: ContactSupportCard(
        onTap: () {
          ContactSupportDialog.show(context);
        },
      ),
    );
  }
}
