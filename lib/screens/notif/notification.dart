import 'package:admin/constants.dart';
import 'package:admin/models/notifications.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotifictionScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final String uid;

  const NotifictionScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.uid,
  }) : super(key: key);

  @override
  State<NotifictionScreen> createState() => _NotifictionScreenState();
}

class _NotifictionScreenState extends State<NotifictionScreen> {
  // Fetch notifications from Firestore
  Stream<List<Notifications>> getNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: widget.uid) // Filter by userId
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notifications.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              text: "Notifications",
              name: widget.name,
              lastName: widget.lastName,
            ),
            SizedBox(height: defaultPadding),
            SizedBox(
              height: 900,
              child: StreamBuilder<List<Notifications>>(
                stream: getNotifications(), // Fetch notifications
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No notifications found.'));
                  }

                  final notifications = snapshot.data!;

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];

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
                                        notification.toggleReadStatus();
                                        // Update the read status in Firestore
                                        FirebaseFirestore.instance
                                            .collection('notifications')
                                            .doc(notification.notifId)
                                            .update({'isRead': notification.isRead});
                                      });
                                    },
                                    child: Text(
                                      notification.isRead ? 'Mark as Unread' : 'Mark as Read',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}