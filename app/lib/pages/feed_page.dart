import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../services/issue_service.dart';
import '../pages/report_detail_page.dart';
import '../widgets/slide_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final IssueService issueService = IssueService();

  final ScrollController _scrollController = ScrollController();
  final List<ReportData> _reports = [];

  int _totalCount = 0;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _isFetching = false;
  bool _hasMore = true;

  Set<String> _selectedCategories = {};
  Set<String> _selectedCities = {};

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String _userName = 'Utilizador';
  String? _profilePhotoUrl;

  // Sort mode: 'hot' | 'new' | 'top'
  String _sortMode = 'top';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
    _fetchTotalCount();
    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) return;

      final profile = await _supabase
          .from('profiles')
          .select('first_name, last_name, profile_photo')
          .eq('id', user.id)
          .maybeSingle();

      final firstName = profile?['first_name']?.toString().trim() ?? '';

      if (!mounted) return;

      setState(() {
        _userName = firstName.isEmpty
            ? user.email?.split('@').first ?? 'Utilizador'
            : firstName;

        _profilePhotoUrl = profile?['profile_photo']?.toString();
      });
    } catch (error) {
      debugPrint('LOAD FEED USER PROFILE ERROR: $error');
    }
  }

  Future<void> _fetchTotalCount() async {
    final int count = await issueService.fetchIssuesCount(
      categories: _selectedCategories.isEmpty
          ? null
          : _selectedCategories.toList(),
      cities: _selectedCities.isEmpty ? null : _selectedCities.toList(),
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      sortMode: _sortMode,
    );
    if (!mounted) return;
    setState(() => _totalCount = count);
  }

  Future<void> _loadMore() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    setState(() => _isLoading = true);

    try {
      final newData = await issueService.fetchIssues(
        page: _currentPage,
        categories: _selectedCategories.isEmpty
            ? null
            : _selectedCategories.toList(),
        cities: _selectedCities.isEmpty ? null : _selectedCities.toList(),
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        sortMode: _sortMode,
      );
      final List<ReportData> newReports = newData
          .map((item) => ReportData.fromMap(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _reports.addAll(newReports);
        _currentPage++;
        _hasMore = newReports.length == IssueService.pageSize;
        _isLoading = false;
        _isFetching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isFetching = false;
      });
    }
  }

  void _applySearch(String value) {
    setState(() {
      _searchQuery = value.trim();
      _reports.clear();
      _currentPage = 0;
      _hasMore = true;
      _isFetching = false;
    });
    _fetchTotalCount();
    _loadMore();
  }

  void _applyFilters({Set<String>? categories, Set<String>? cities}) {
    setState(() {
      _selectedCategories = categories ?? {};
      _selectedCities = cities ?? {};
      _reports.clear();
      _currentPage = 0;
      _hasMore = true;
      _isFetching = false;
    });
    _fetchTotalCount();
    _loadMore();
  }

  void _applySortMode(String mode) {
    if (_sortMode == mode) return;
    setState(() {
      _sortMode = mode;
      _reports.clear();
      _currentPage = 0;
      _hasMore = true;
      _isFetching = false;
    });
    _fetchTotalCount();
    _loadMore();
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
      ),
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D5DD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ordenar por',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSortOption(
                  mode: 'hot',
                  icon: Icons.local_fire_department_outlined,
                  label: 'Em alta',
                  description: 'Mais votadas recentemente',
                ),
                const SizedBox(height: 10),
                _buildSortOption(
                  mode: 'new',
                  icon: Icons.fiber_new_outlined,
                  label: 'Recentes',
                  description: 'Mais recentes primeiro',
                ),
                const SizedBox(height: 10),
                _buildSortOption(
                  mode: 'top',
                  icon: Icons.leaderboard_outlined,
                  label: 'Top',
                  description: 'Mais votadas de sempre',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required String mode,
    required IconData icon,
    required String label,
    required String description,
  }) {
    final bool isSelected = _sortMode == mode;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _applySortMode(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD6EED6) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF1A6B3A)
                  : const Color(0xFF667085),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1A6B3A)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 18, color: Color(0xFF1A6B3A)),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    Set<String> tempCategories = Set.from(_selectedCategories);
    Set<String> tempCities = Set.from(_selectedCities);
    final TextEditingController cityController = TextEditingController(
      text: tempCities.isNotEmpty ? tempCities.first : '',
    );

    const List<String> allCategories = [
      'Todos os tipos',
      'Infraestrutura',
      'Iluminação Pública',
      'Sinalização',
      'Meio Ambiente',
      'Lixo e Limpeza',
      'Outros',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
      ),
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.82,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD0D5DD),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Header row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filtros',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Por cidade ---
                            const Text(
                              'Por cidade',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: cityController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'Ex: Lisboa, Porto...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                ),
                                prefixIcon: const Icon(
                                  Icons.location_city_outlined,
                                  color: Color(0xFF9CA3AF),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  if (value.trim().isEmpty) {
                                    tempCities.clear();
                                  } else {
                                    tempCities = {value.trim()};
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            // --- Por tipo ---
                            const Text(
                              'Por tipo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...allCategories.map((cat) {
                              final bool isAll = cat == 'Todos os tipos';
                              final bool isSelected = isAll
                                  ? tempCategories.isEmpty
                                  : tempCategories.contains(cat);
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    if (isAll) {
                                      tempCategories.clear();
                                    } else if (isSelected) {
                                      tempCategories.remove(cat);
                                    } else {
                                      tempCategories.add(cat);
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFD6EED6)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? const Color(0xFF1A6B3A)
                                                : const Color(0xFF344054),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check,
                                          size: 18,
                                          color: Color(0xFF1A6B3A),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    // Footer buttons
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFEAEAEA)),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Clear button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  tempCategories.clear();
                                  tempCities.clear();
                                  cityController.clear();
                                });
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Limpar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Apply button
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _applyFilters(
                                  categories: tempCategories,
                                  cities: tempCities,
                                );
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D159),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Aplicar filtros',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _goToProfile() async {
    await Navigator.pushNamed(context, '/profile');

    if (!mounted) return;

    await _loadCurrentUserProfile();
  }

  ImageProvider? _getProfileImage() {
    if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
      return NetworkImage(_profilePhotoUrl!);
    }

    return null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDE5CB),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchAndFilter(),
              const SizedBox(height: 26),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(),
                        const SizedBox(height: 20),
                        if (_reports.isEmpty && _isLoading)
                          const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          )
                        else if (_reports.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text('Nenhuma denúncia encontrada.'),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: _reports.length + (_hasMore ? 1 : 0),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                if (index == _reports.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  );
                                }

                                return _buildReportCard(_reports[index]);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final profileImage = _getProfileImage();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _goToProfile,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImage,
                  child: profileImage == null
                      ? const Icon(
                          Icons.person,
                          size: 28,
                          color: Color(0xFFB0B0B0),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withValues(alpha: 0.55),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Viste algum problema\nna cidade?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final bool hasActiveFilters =
        _selectedCategories.isNotEmpty || _selectedCities.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF98A2B3)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _applySearch,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Buscar denúncias...',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF98A2B3),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _applySearch('');
                      },
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SlideCard(
            isActive: hasActiveFilters,
            onTap: _showFilterDialog,
            icon: Icons.tune,
            width: 52,
            height: 52,
            borderRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    // Label and icon for the current sort mode
    final Map<String, Map<String, dynamic>> sortMeta = {
      'hot': {'label': 'Em alta', 'icon': Icons.local_fire_department_outlined},
      'new': {'label': 'Recentes', 'icon': Icons.fiber_new_outlined},
      'top': {'label': 'Top', 'icon': Icons.leaderboard_outlined},
    };

    final current = sortMeta[_sortMode]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Denúncias',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_totalCount denúncias ativas',
              style: const TextStyle(fontSize: 14, color: Color(0xFF98A2B3)),
            ),
          ],
        ),
        SlideCard(
          isActive: false,
          onTap: _showSortSheet,
          borderRadius: 14,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  current['icon'] as IconData,
                  size: 16,
                  color: const Color(0xFF344054),
                ),
                const SizedBox(width: 6),
                Text(
                  current['label'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF344054),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Color(0xFF667085),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(ReportData report) {
    return SlideCard(
      isActive: false,
      onTap: () => _openReportDetails(report),
      borderRadius: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEAEA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportImage(report),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF475467),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF667085),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.address ?? 'Localização registada',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      VoteWidget(
                        issueId: report.id,
                        issueService: issueService,
                      ),
                      const Spacer(),

                      // Botão dos comentários
                      GestureDetector(
                        onTap: () => _openReportDetails(report),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          size: 24,
                          color: Color(0xFF344054),
                        ),
                      ),

                      const SizedBox(width: 6),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: issueService.fetchComments(report.id),
                        builder: (context, snapshot) {
                          final count = snapshot.hasData
                              ? snapshot.data!.length
                              : 0;

                          return Text(
                            count.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF344054),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReportDetails(ReportData report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
      ),
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D5DD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ReportDetailSheet(report: report),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportImage(ReportData report) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: 170,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: report.photos.isNotEmpty
                  ? Image.network(
                      report.photos.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(
                          icon: Icons.broken_image_outlined,
                          message: 'Erro ao carregar imagem',
                        );
                      },
                    )
                  : _buildImagePlaceholder(
                      icon: Icons.image_not_supported_outlined,
                      message: 'Sem imagem disponível',
                    ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Pendente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEC6A00),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({required IconData icon, String? message}) {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 38, color: const Color(0xFF98A2B3)),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
            ),
          ],
        ],
      ),
    );
  }
}

class VoteWidget extends StatefulWidget {
  final String issueId;
  final IssueService issueService;

  const VoteWidget({
    super.key,
    required this.issueId,
    required this.issueService,
  });

  @override
  State<VoteWidget> createState() => _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  int _score = 0;
  int _userVote = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVotes();
  }

  Future<void> _loadVotes() async {
    final voteInfo = await widget.issueService.fetchVoteInfo(widget.issueId);
    if (mounted) {
      setState(() {
        _score = voteInfo['score'];
        _userVote = voteInfo['userVote'];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVote(int voteType) async {
    final int previousScore = _score;
    final int previousUserVote = _userVote;

    setState(() {
      if (_userVote == voteType) {
        _score -= voteType;
        _userVote = 0;
      } else {
        if (_userVote != 0) {
          _score -= _userVote;
        }
        _score += voteType;
        _userVote = voteType;
      }
    });

    try {
      await widget.issueService.castVote(widget.issueId, voteType);
    } catch (e) {
      if (mounted) {
        setState(() {
          _score = previousScore;
          _userVote = previousUserVote;
        });
      }
      debugPrint('Falha ao votar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 60,
        height: 24,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF16A34A),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        GestureDetector(
          key: Key('upvote_${widget.issueId}'),
          onTap: () => _handleVote(1),
          child: Icon(
            Icons.arrow_upward,
            size: 22,
            color: _userVote == 1
                ? const Color(0xFF16A34A)
                : const Color(0xFF667085),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _score.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _userVote == 1
                ? const Color(0xFF16A34A)
                : (_userVote == -1
                      ? const Color(0xFFEC6A00)
                      : const Color(0xFF344054)),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          key: Key('downvote_${widget.issueId}'),
          onTap: () => _handleVote(-1),
          child: Icon(
            Icons.arrow_downward,
            size: 22,
            color: _userVote == -1
                ? const Color(0xFFEC6A00)
                : const Color(0xFF667085),
          ),
        ),
      ],
    );
  }
}
