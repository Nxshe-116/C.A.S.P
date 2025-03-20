import 'package:admin/constants.dart';
import 'package:admin/models/articles.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';

class InsightScreen extends StatelessWidget {
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
              name: name,
              lastName: lastName,
            ),
            SizedBox(height: defaultPadding),
            Text(
              'News Around the World',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
            SizedBox(height: defaultPadding),
            SizedBox(
              height: 900,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      Responsive.isMobile(context) ? 1 : 4, // Dynamic columns
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: Responsive.isMobile(context)
                      ? 1.2
                      : 0.9, // Adjust aspect ratio
                ),
                itemCount: articles.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final article = articles[index];
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
                              article.imagePath,
                              height: Responsive.isMobile(context)
                                  ? 150
                                  : 120, // Adjust image height
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              article.title,
                              style: TextStyle(
                                fontSize: Responsive.isMobile(context)
                                    ? 16
                                    : 14, // Adjust font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              article.content,
                              style: TextStyle(
                                fontSize: Responsive.isMobile(context)
                                    ? 14
                                    : 12, // Adjust font size
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'By ${article.author}',
                                  style: TextStyle(
                                    fontSize: Responsive.isMobile(context)
                                        ? 12
                                        : 10, // Adjust font size
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
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
            height: Responsive.isMobile(context)
                ? screenHeight * 0.8
                : 600, // Adjust height
            width: Responsive.isMobile(context)
                ? screenWidth * 0.9
                : 800, // Adjust width
            child: Padding(
              padding:
                  EdgeInsets.all(Responsive.isMobile(context) ? 16.0 : 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      article.imagePath,
                      height: Responsive.isMobile(context)
                          ? 150
                          : 300, // Adjust image height
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    article.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: Responsive.isMobile(context)
                          ? 18
                          : 20, // Adjust font size
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'By ${article.author}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: Responsive.isMobile(context)
                          ? 14
                          : 16, // Adjust font size
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        article.content,
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context)
                              ? 14
                              : 16, // Adjust font size
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
                Navigator.of(context).pop(); // Close the dialog
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
