import 'dart:math';
import 'package:admin/constants.dart';
import 'package:admin/models/articles.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InsightScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final String uid;

  const InsightScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.uid,
  }) : super(key: key);

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  List<Article> recommendations = [];
  bool isLoading = true;
  final List<String> randomImages = [
    'assets/images/a.jpg',
    'assets/images/b.jpg',
    'assets/images/c.jpg',
    'assets/images/d.jpg',
  ];

  @override
  void initState() {
    super.initState();
    loadAllRecommendations();
  }

  Future<void> loadAllRecommendations() async {
    try {
      setState(() => isLoading = true);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('recommendations')
          .orderBy('createdAt', descending: true) // Added sorting
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final allRecommendations = querySnapshot.docs
          .map((doc) => Article.fromFirestore(doc))
          // .where((article) => article.title.isNotEmpty) // Filter invalid articles
          .toList();

      if (mounted) {
        setState(() {
          recommendations = allRecommendations;
          isLoading = false;
        });
      }

      debugPrint(
          'Successfully loaded ${recommendations.length} recommendations');
    } catch (e, stackTrace) {
      debugPrint('Error fetching recommendations: $e');
      debugPrint(stackTrace.toString());

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String getRandomImage() {
    final random = Random();
    return randomImages[random.nextInt(randomImages.length)];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(
              text: "Insight",
              name: widget.name,
              lastName: widget.lastName,
            ),
            SizedBox(height: defaultPadding),
            Text(
              'Recommendations from Experts',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
            SizedBox(height: defaultPadding),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (recommendations.isEmpty)
              Center(child: Text('No recommendations found'))
            else
              SizedBox(
                height: 900,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.isMobile(context) ? 1 : 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: Responsive.isMobile(context) ? 1.2 : 0.9,
                  ),
                  itemCount: recommendations.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final article = recommendations[index];
                    return GestureDetector(
                      onTap: () => showArticleDialog(context, article),
                      child: Card(
                        color: Color(0xFFF4FAFF),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.asset(
                                getRandomImage(),
                                height:
                                    Responsive.isMobile(context) ? 150 : 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[200],
                                  height:
                                      Responsive.isMobile(context) ? 150 : 120,
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                article.title,
                                style: TextStyle(
                                  fontSize:
                                      Responsive.isMobile(context) ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                article.text.length > 100
                                    ? '${article.text.substring(0, 100)}...'
                                    : article.text,
                                style: TextStyle(
                                  fontSize:
                                      Responsive.isMobile(context) ? 14 : 12,
                                  color: Colors.black54,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showArticleDialog(BuildContext context, Article article) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: Responsive.isMobile(context) ? screenHeight * 0.8 : 600,
            width: Responsive.isMobile(context) ? screenWidth * 0.9 : 800,
            child: Padding(
              padding:
                  EdgeInsets.all(Responsive.isMobile(context) ? 16.0 : 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      getRandomImage(),
                      height: Responsive.isMobile(context) ? 150 : 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    generateTitleFromText(article.text),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: Responsive.isMobile(context) ? 18 : 20,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'By ${article.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: Responsive.isMobile(context) ? 14 : 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        article.text,
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 14 : 16,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

String generateTitleFromText(String text) {
  // Remove any leading/trailing whitespace
  text = text.trim();

  // If the text is empty, return a default title
  if (text.isEmpty) return 'Expert Insight';

  // Try to find the first sentence
  final firstSentenceEnd = text.indexOf('.');
  if (firstSentenceEnd != -1) {
    String firstSentence = text.substring(0, firstSentenceEnd).trim();

    // If the first sentence is too long, take the first few words
    if (firstSentence.length > 50) {
      List<String> words = firstSentence.split(' ');
      if (words.length > 8) {
        return '${words.take(8).join(' ')}...';
      }
    }
    return firstSentence;
  }

  // If no period found, take the first 50 characters
  return text.length > 50 ? '${text.substring(0, 50)}...' : text;
}
