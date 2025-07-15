import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:easy_digital_security/services/content_service.dart';
import 'package:easy_digital_security/main.dart';
import 'package:easy_digital_security/screens/home_screen.dart';
import 'package:easy_digital_security/screens/quiz_screen.dart';
import 'package:easy_digital_security/screens/tools_screen.dart';
import 'package:easy_digital_security/screens/settings_screen.dart';
import 'package:easy_digital_security/models/article_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _searchController.addListener(_filterArticles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    try {
      await contentService!.syncContentFromGitHub();
      final articles = await contentService!.getAllArticles();
      setState(() {
        _articles = articles;
        _filteredArticles = _articles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading articles: $e'.tr())),
      );
    }
  }

  void _filterArticles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredArticles = _articles.where((article) {
        final title = (context.locale.languageCode == 'ar' ? article.titleAr : article.titleEn).toLowerCase();
        final matchesCategory = _selectedCategory == 'All' || article.category == _selectedCategory;
        final matchesQuery = title.contains(query);
        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        break;
      case 1:
        break; // Already on LearnScreen
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const QuizScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ToolsScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        break;
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url'.tr())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('📚 Learn Articles'.tr()),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withOpacity(0.8) ?? Colors.transparent,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
              height: 1.0,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {
                setState(() {
                  _selectedCategory = result;
                  _filterArticles();
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'All',
                  child: Text('All Categories'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
                PopupMenuItem<String>(
                  value: 'Passwords',
                  child: Text('Passwords'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
                PopupMenuItem<String>(
                  value: 'Phishing',
                  child: Text('Phishing'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
                PopupMenuItem<String>(
                  value: 'Authentication',
                  child: Text('Authentication'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
                PopupMenuItem<String>(
                  value: 'Privacy',
                  child: Text('Privacy'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
              ],
              icon: Icon(Icons.filter_list, color: Theme.of(context).appBarTheme.foregroundColor),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () async {
                await _loadArticles();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Content refreshed!'.tr())),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search articles...'.tr(),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredArticles.isEmpty
                  ? Center(child: Text('No articles available.'.tr(), style: Theme.of(context).textTheme.bodyLarge))
                  : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _filteredArticles.length + 1,
                itemBuilder: (context, index) {
                  if (index == _filteredArticles.length) {
                    return FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Text('End of content'.tr(), style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => _launchURL('https://github.com/your_repo/easy_digital_security'),
                              child: Text(
                                'View Content on GitHub'.tr(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final article = _filteredArticles[index];
                  final articleTitle = context.locale.languageCode == 'ar' ? article.titleAr : article.titleEn;
                  final articleSnippet = 'A brief overview of ${articleTitle.toLowerCase()}.'.tr();

                  final BorderRadius? cardBorderRadius = (Theme.of(context).cardTheme.shape is RoundedRectangleBorder)
                      ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius.resolve(Directionality.of(context))
                      : BorderRadius.circular(12);

                  return FadeInUp(
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: cardBorderRadius!),
                      elevation: 3,
                      color: Theme.of(context).cardTheme.color,
                      surfaceTintColor: Theme.of(context).cardTheme.surfaceTintColor,
                      child: InkWell(
                        borderRadius: cardBorderRadius,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => ArticleDetailScreen(
                                articleFileName: article.fileName,
                                articleTitle: articleTitle,
                              ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(_getCategoryIcon(article.category), color: Theme.of(context).colorScheme.secondary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      articleTitle,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                articleSnippet,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  'Read More'.tr(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book),
              label: 'Learn'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.quiz),
              label: 'Quiz'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.build),
              label: 'Tools'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'Settings'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Passwords':
        return Icons.lock_outline;
      case 'Phishing':
        return Icons.mail_outline;
      case 'Authentication':
        return Icons.security;
      case 'Privacy':
        return Icons.privacy_tip_outlined;
      default:
        return Icons.article_outlined;
    }
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final String articleFileName;
  final String articleTitle;

  const ArticleDetailScreen({super.key, required this.articleFileName, required this.articleTitle});

  @override
  Widget build(BuildContext context) {
    final String languageCode = EasyLocalization.of(context)!.locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(articleTitle),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withOpacity(0.8) ?? Colors.transparent,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
            height: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality (e.g., using share_plus package)
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Implement bookmark/save to favorites functionality
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: contentService!.getArticleContent(articleFileName, languageCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading article: ${snapshot.error}'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await contentService!.syncContentFromGitHub();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleDetailScreen(
                              articleFileName: articleFileName,
                              articleTitle: articleTitle,
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error syncing content: $e'.tr())),
                        );
                      }
                    },
                    child: Text('Retry'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Article content not found.'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await contentService!.syncContentFromGitHub();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleDetailScreen(
                              articleFileName: articleFileName,
                              articleTitle: articleTitle,
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error syncing content: $e'.tr())),
                        );
                      }
                    },
                    child: Text('Retry'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: MarkdownBody(
                  data: snapshot.data!,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    h1: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                    h2: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    h3: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    strong: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    em: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                    listBullet: Theme.of(context).textTheme.bodyLarge,
                    blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.secondary,
                      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                      wordSpacing: 8.0,
                    ),
                    code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Courier',
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}