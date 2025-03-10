import 'package:admin/constants.dart';
import 'package:admin/models/notifications.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';

class NotifictionScreen extends StatefulWidget {
  final String name;
  final String lastName;

  const NotifictionScreen({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  State<NotifictionScreen> createState() => _NotifictionScreenState();
}

class _NotifictionScreenState extends State<NotifictionScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(text: "Notifications", name: widget.name, lastName: widget.name,),
            SizedBox(height: defaultPadding),
            SizedBox(
              height: 900,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: mockAgricultureNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = mockAgricultureNotifications[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        color: Color(0xFFF4FAFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 1.0,
                        child: InkWell(
                          onTap: () {
                            // Action for tapping the notification (e.g., show details)
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  color: primaryColor,
                                  size: 30,
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.title,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 6.0),
                                      Text(
                                        notification.message,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 12.0),
                                      Text(
                                        notification.getFormattedTimestamp(),
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      notification
                                          .toggleReadStatus(); // Toggle the read/unread state on tap
                                    });
                                  },
                                  child: Text(
                                    'Mark as Read',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
