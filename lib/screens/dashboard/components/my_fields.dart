import 'package:admin/models/company.dart';
import 'package:admin/models/my_files.dart';
import 'package:admin/models/notifications.dart';
import 'package:admin/models/tickers.dart';
import 'package:admin/responsive.dart';
import 'package:admin/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants.dart';
import 'file_info_card.dart';

class MyFiles extends StatefulWidget {
  final String uid;
  const MyFiles({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<MyFiles> createState() => _MyFilesState();
}

class _MyFilesState extends State<MyFiles> {
  final ApiService apiService = ApiService();
  late Future<List<Company>> futureCompanies;
  List<bool> isSelected = []; // To track selected companies
  List<Company> companies = [];

  // final prefs = await SharedPreferences.getInstance();

  //  final uid = prefs.getString('uid');

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    futureCompanies = apiService.fetchCompanies();
  }

  void updateSelection(int index, bool value) {
    setState(() {
      isSelected[index] = value;
    });
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
              onPressed: () {
                showDataDialog(
                  context,
                  futureCompanies,
                  isSelected,
                  updateSelection,
                  apiService,
                  widget.uid, // Pass the uid
                );
              },
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

class FileInfoCardGridView extends StatefulWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  State<FileInfoCardGridView> createState() => _FileInfoCardGridViewState();
}

class _FileInfoCardGridViewState extends State<FileInfoCardGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: demoStockData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemBuilder: (context, index) =>
          StockInfoCard(info: demoStockData[index]),
    );
  }
}

void showDataDialog(
  BuildContext context,
  Future<List<Company>> futureCompanies,
  List<bool> isSelected,
  Function(int index, bool value) updateSelection,
  ApiService apiService,
  String uid,
) {
  List<Company> companies = []; // Local companies list

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // This ensures we can use setState
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              height: 600,
              width: 600,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Companies',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    SizedBox(
                      height: 400,
                      child: FutureBuilder<List<Company>>(
                        future: futureCompanies,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(child: Text('No companies found'));
                          } else {
                            companies = snapshot.data!;
                            if (isSelected.isEmpty) {
                              isSelected =
                                  List<bool>.filled(companies.length, false);
                            }

                            return ListView.builder(
                              itemCount: companies.length,
                              itemBuilder: (context, index) {
                                final company = companies[index];
                                return Row(
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.all(defaultPadding * 0.75),
                                      height: 36.h,
                                      width: 10.w,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEFEFE),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/icons/sprout.svg",
                                        colorFilter: ColorFilter.mode(
                                            primaryColor, BlendMode.srcIn),
                                      ),
                                    ),
                                    Expanded(
                                      child: CheckboxListTile(
                                        value: isSelected[index],
                                        onChanged: (value) {
                                          setState(() {
                                            // StatefulBuilder allows state updates here
                                            isSelected[index] = value ?? false;
                                          });
                                        },
                                        title: Text(company.name),
                                        subtitle: Text(
                                            'Symbol: ${generateTicker(company.symbol)}'),
                                      ),
                                    ),
                                  ],
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
                  Navigator.of(context).pop();
                },
                child:
                    Text('Cancel', style: TextStyle(color: Colors.redAccent)),
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
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                onPressed: () async {
                  //  final prefs = await SharedPreferences.getInstance();

                  // final userid = prefs.getString('uid') ?? 'test';
                  final selectedCompanies = <Company>[];
                  for (int i = 0; i < isSelected.length; i++) {
                    if (isSelected[i]) {
                      selectedCompanies.add(companies[i]);
                    }
                  }
                  print("Your data:");

                  for (var company in selectedCompanies) {
                    print(company.name);
                  }
                  try {
                    print("This is the uid: ${uid}");
                    await apiService.addCompaniesToUser(uid, selectedCompanies);
                    final notifID =
                        'notif_${DateTime.now().millisecondsSinceEpoch}';
                    for (var company in selectedCompanies) {
                      final notification = Notifications(
                        message:
                            'Company ${company.name} was added successfully to your portfolio',
                        timestamp: DateTime.now(),
                        title: 'Company Added to Your Watchlist',
                        userId: uid,
                        notifId: notifID,
                      );

                      await apiService.addNotificationToUser(uid, notification);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Companies added successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add companies: $e')),
                    );
                  }

                  Navigator.of(context).pop();
                },
                label: Text("Select", style: TextStyle(color: Colors.white)),
              )
            ],
          );
        },
      );
    },
  );
}
