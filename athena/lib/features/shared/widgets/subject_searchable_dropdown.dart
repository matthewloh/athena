import 'package:flutter/material.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/shared/utils/subject_utils.dart';
import 'package:athena/domain/enums/subject.dart';

class SubjectSearchableDropdown extends StatefulWidget {
  final Subject? selectedSubject;
  final ValueChanged<Subject?> onChanged;
  final String? validator;

  const SubjectSearchableDropdown({
    super.key,
    this.selectedSubject,
    required this.onChanged,
    this.validator,
  });

  @override
  State<SubjectSearchableDropdown> createState() =>
      _SubjectSearchableDropdownState();
}

class _SubjectSearchableDropdownState extends State<SubjectSearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDropdownOpen = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.selectedSubject != null) {
      _searchController.text = SubjectUtils.getDisplayName(
        widget.selectedSubject!,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Map<String, List<Subject>> _getFilteredCategorizedSubjects() {
    return SubjectUtils.getFilteredCategorizedSubjects(_searchQuery);
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });

    if (_isDropdownOpen) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  void _selectSubject(Subject subject) {
    setState(() {
      _searchController.text = SubjectUtils.getDisplayName(subject);
      _isDropdownOpen = false;
      _searchQuery = '';
    });

    widget.onChanged(subject);
    _focusNode.unfocus();
  }

  void _clearSelection() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDropdownOpen ? AppColors.primary : Colors.grey.shade300,
              width: _isDropdownOpen ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: 'Subject (Optional)',
                    hintText: 'Search subjects...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSelection,
                            )
                            : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _isDropdownOpen = value.isNotEmpty || _focusNode.hasFocus;
                    });
                  },
                  onTap: () {
                    setState(() {
                      _isDropdownOpen = true;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: _toggleDropdown,
              ),
            ],
          ),
        ),

        // Dropdown list
        if (_isDropdownOpen) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildDropdownContent(),
          ),
        ],

        // Validation error
        if (widget.validator != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.validator!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownContent() {
    final filteredCategories = _getFilteredCategorizedSubjects();

    if (filteredCategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No subjects found',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Add "No Subject" option at the top
        ListTile(
          leading: const Icon(Icons.clear, color: Colors.grey),
          title: const Text('No Subject'),
          onTap: () {
            _clearSelection();
            setState(() {
              _isDropdownOpen = false;
            });
          },
        ),
        const Divider(height: 1),

        // Categorized subjects
        ...filteredCategories.entries.map((categoryEntry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.grey.shade50,
                child: Text(
                  categoryEntry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),

              // Subjects in this category
              ...categoryEntry.value.map((subject) {
                final isSelected = widget.selectedSubject == subject;
                return ListTile(
                  title: Text(
                    SubjectUtils.getDisplayName(subject),
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : null,
                      fontWeight: isSelected ? FontWeight.w500 : null,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(Icons.check, color: AppColors.primary)
                          : null,
                  onTap: () => _selectSubject(subject),
                );
              }),
            ],
          );
        }),
      ],
    );
  }
}