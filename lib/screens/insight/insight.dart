import 'package:admin/constants.dart';
import 'package:admin/models/articles.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';

class InsightScreen extends StatelessWidget {
  final String name;
  final String lastName;
  final String uid;

  const InsightScreen({
    Key? key,
    required this.name,
    required this.lastName, required this.uid,
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
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.9,
                ),
                itemCount: articles.length,
                shrinkWrap: true, // Makes the GridView adapt to its content

                itemBuilder: (context, index) {
                  final article = articles[index];
                  return GestureDetector(
                    onTap: () => showArticleDialog(context, article),
                    child: Container(
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
                                height: 120, // Reduced image height
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                article.title,
                                style: TextStyle(
                                  fontSize: 14, // Smaller font size for titles
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
                                  fontSize: 12, // Smaller font size for content
                                  color: Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'By ${article.author}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
            height: 1500,
            width: 2000,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      article.imagePath,
                      height: 300, // Reduced image height
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    article.title,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                  Text(
                    article.author,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.grey),
                  ),
                  SizedBox(height: defaultPadding),
                  Container(
                    height: 230,
                    child: SingleChildScrollView(
                      child: Text(
                        article.content,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6, // Increased line height for readability
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
