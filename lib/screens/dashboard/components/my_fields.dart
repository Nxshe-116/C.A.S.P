import 'package:admin/models/company.dart';
import 'package:admin/models/my_files.dart';
import 'package:admin/responsive.dart';
import 'package:admin/services/services.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'file_info_card.dart';

class MyFiles extends StatefulWidget {
  const MyFiles({
    Key? key,
  }) : super(key: key);

  @override
  State<MyFiles> createState() => _MyFilesState();
}

class _MyFilesState extends State<MyFiles> {
  final ApiService _apiService = ApiService();
  late Future<List<Company>> futureCompanies;

  @override
  void initState() {
    super.initState();
    futureCompanies = _apiService.fetchCompanies();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Overview",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6.0), // Slightly rounded corners
                ),
              ),
              onPressed: () => showDataDialog(context, futureCompanies),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: Text(
                "Add New",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 && _size.width > 350 ? 1.3 : 1,
          ),
          tablet: FileInfoCardGridView(),
          desktop: FileInfoCardGridView(
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
          ),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: demoStockData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) =>
          StockInfoCard(info: demoStockData[index]),
    );
  }
}

// void showDataDialog(
//     BuildContext context, Future<List<Company>> futureCompanies) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         contentPadding: EdgeInsets.zero,
//         content: Container(
//           height: 1500,
//           width: 2000,
//           child: Padding(
//             padding: const EdgeInsets.all(30.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Companies',
//                   style: Theme.of(context).textTheme.headlineLarge,
//                 ),
//               FutureBuilder<List<Company>>(
//   future: futureCompanies,
//   builder: (context, snapshot) {
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return Center(child: CircularProgressIndicator());
//     } else if (snapshot.hasError) {
//       return Center(child: Text('Error: ${snapshot.error}'));
//     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//       return Center(child: Text('No companies found'));
//     } else {
//       final companies = snapshot.data!;
//       return SizedBox(
//         height: 300, // Set a fixed height
//         child: ListView.builder(
//           itemCount: companies.length,
//           itemBuilder: (context, index) {
//             final company = companies[index];
//             return ListTile(
//               title: Text(company.name),
//               subtitle: Text('Symbol: ${company.symbol}'),
//             );
//           },
//         ),
//       );
//     }
//   },
// )

//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: Text(
//               'Close',
//               style: TextStyle(color: primaryColor),
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }
void showDataDialog(
    BuildContext context, Future<List<Company>> futureCompanies) {
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
          height: 500, // Set a fixed height
          width: 500, // Set a fixed width
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Companies',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Expanded(
                  // Use Expanded to give ListView a bounded height
                  child: FutureBuilder<List<Company>>(
                    future: futureCompanies,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No companies found'));
                      } else {
                        final companies = snapshot.data!;
                        return ListView.builder(
                          itemCount: companies.length,
                          itemBuilder: (context, index) {
                            final company = companies[index];
                            return ListTile(
                              title: Text(company.name),
                              subtitle: Text('Symbol: ${company.symbol}'),
                            );
                          },
                        );
                      }
                    },
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
