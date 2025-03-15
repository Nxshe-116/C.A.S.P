import 'package:admin/models/company.dart';
import 'package:admin/models/my_files.dart';
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
              onPressed: () => showDataDialog(
                context,
                futureCompanies,
                isSelected,
                updateSelection,
                apiService,
                widget.uid, // Pass the uid
              ),
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
                                return CheckboxListTile(
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
                  final selectedCompanies = <Company>[];
                  for (int i = 0; i < isSelected.length; i++) {
                    if (isSelected[i]) {
                      selectedCompanies.add(companies[i]);
                    }
                  }

                  try {
                    await apiService.addCompaniesToUser(uid, selectedCompanies);
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


// void showDataDialog(
//   BuildContext context,
//   Future<List<Company>> futureCompanies,
//   List<bool> isSelected,
//   Function(int index, bool value) updateSelection,
//   ApiService apiService,
//   String uid,
// ) {
//   List <Company> companies=[];
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
//           height: 600, // Set a fixed height
//           width: 600, // Set a fixed width
//           child: Padding(
//             padding: const EdgeInsets.all(30.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Select Companies',
//                   style: Theme.of(context).textTheme.headlineLarge,
//                 ),
//                 SizedBox(
//                   height: 400.h,
//                   child:
//                   FutureBuilder<List<Company>>(
//   future: futureCompanies,
//   builder: (context, snapshot) {
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return Center(child: CircularProgressIndicator());
//     } else if (snapshot.hasError) {
//       return Center(child: Text('Error: ${snapshot.error}'));
//     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//       return Center(child: Text('No companies found'));
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         // Update external `companies` list when data is available
//         setState(() {
//           companies = snapshot.data!;
//           if (isSelected.isEmpty) {
//             isSelected = List<bool>.filled(companies.length, false);
//           }
//         });
//       });

//       return ListView.builder(
//         itemCount: companies.length,
//         itemBuilder: (context, index) {
//           final company = companies[index];
//           return CheckboxListTile(
//             value: isSelected[index],
//             onChanged: (value) {
//               setState(() {
//                 updateSelection(index, value ?? false);
//               });
//             },
//             title: Text(company.name),
//             subtitle: Text('Symbol: ${generateTicker(company.symbol)}'),
//           );
//         },
//       );
//     }
//   },
// )

                  
                  
//                   //  FutureBuilder<List<Company>>(
//                   //   future: futureCompanies,
//                   //   builder: (context, snapshot) {
//                   //     if (snapshot.connectionState == ConnectionState.waiting) {
//                   //       return Center(child: CircularProgressIndicator());
//                   //     } else if (snapshot.hasError) {
//                   //       return Center(child: Text('Error: ${snapshot.error}'));
//                   //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   //       return Center(child: Text('No companies found'));
//                   //     } else {
//                   //       final companies = snapshot.data!;

//                   //       if (isSelected.isEmpty) {
//                   //         isSelected =
//                   //             List<bool>.filled(companies.length, false);
//                   //       }

//                   //       return ListView.builder(
//                   //         itemCount: companies.length,
//                   //         itemBuilder: (context, index) {
//                   //           final company = companies[index];
//                   //           return Container(
//                   //             width: MediaQuery.of(context).size.width,
//                   //             child: Row(
//                   //               children: [
//                   //                 Checkbox(
//                   //                   value: isSelected[index],
//                   //                   onChanged: (value) {
//                   //                     updateSelection(index,
//                   //                         value ?? false); // Update the state
//                   //                   },
//                   //                 ),
//                   //                 Expanded(
//                   //                   child: Padding(
//                   //                     padding: const EdgeInsets.all(8.0),
//                   //                     child: Container(
//                   //                       decoration: BoxDecoration(
//                   //                         color: const Color(0xFFFEFEFE),
//                   //                         borderRadius: BorderRadius.all(
//                   //                             Radius.circular(10)),
//                   //                       ),
//                   //                       child: Row(
//                   //                         children: [
//                   //                           Container(
//                   //                             padding: EdgeInsets.all(
//                   //                                 defaultPadding * 0.75),
//                   //                             height: 60,
//                   //                             width: 60,
//                   //                             decoration: BoxDecoration(
//                   //                               color: Color(0xFFF4FAFF),
//                   //                               borderRadius: BorderRadius.all(
//                   //                                   Radius.circular(10)),
//                   //                             ),
//                   //                             child: SvgPicture.asset(
//                   //                               "assets/icons/sprout.svg",
//                   //                               colorFilter: ColorFilter.mode(
//                   //                                   primaryColor,
//                   //                                   BlendMode.srcIn),
//                   //                             ),
//                   //                           ),
//                   //                           SizedBox(
//                   //                             width: 5.w,
//                   //                           ),
//                   //                           Expanded(
//                   //                             child: Column(
//                   //                               crossAxisAlignment:
//                   //                                   CrossAxisAlignment.start,
//                   //                               mainAxisAlignment:
//                   //                                   MainAxisAlignment.center,
//                   //                               children: [
//                   //                                 Text(
//                   //                                   company.name,
//                   //                                   style: TextStyle(
//                   //                                       fontSize:
//                   //                                           16), // Adjust size as needed
//                   //                                 ),
//                   //                                 Text(
//                   //                                   'Symbol: ${generateTicker(company.symbol)}',
//                   //                                   style: TextStyle(
//                   //                                       fontSize: 12,
//                   //                                       color: Colors.grey),
//                   //                                 ),
//                   //                               ],
//                   //                             ),
//                   //                           ),
//                   //                         ],
//                   //                       ),
//                   //                     ),
//                   //                   ),
//                   //                 ),
//                   //               ],
//                   //             ),
//                   //           );
//                   //         },
//                   //       );
//                   //     }
//                   //   },
//                   // ),
            
            
            
            
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the dialog
//                 },
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.redAccent),
//                 ),
//               ),
//               ElevatedButton.icon(
//                 style: TextButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   padding: EdgeInsets.symmetric(
//                     horizontal: defaultPadding * 1.5,
//                     vertical:
//                         defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(6.0), // Slightly rounded corners
//                   ),
//                 ),
//                 onPressed: () async {
//                   final selectedCompanies = <Company>[];
//                   for (int i = 0; i < isSelected.length; i++) {
//                     if (isSelected[i]) {
//                       selectedCompanies.add(companies[i]);
//                     }
//                   }

//                   // Call the Firestore update method
//                   try {
//                     await apiService.addCompaniesToUser(uid, selectedCompanies);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Companies added successfully!')),
//                     );
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Failed to add companies: $e')),
//                     );
//                   }

//                   // Close the dialog
//                   Navigator.of(context).pop();
//                 },
//                 label: Text(
//                   "Select",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               )
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }
