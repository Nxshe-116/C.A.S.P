class AppUser {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;

  final List<String> selectedCompanies;

  AppUser( {
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.email,
    this.selectedCompanies = const [],
  });

 
  Map<String, dynamic> toMap() {
    return {
      'firstName':firstName,
      'lastName':lastName,
      'email': email,
      'selectedCompanies': selectedCompanies,
    };
  }


  
  final userID= 'user${DateTime.now().millisecondsSinceEpoch}';


  factory AppUser.fromMap(String userId, Map<String, dynamic> map) {
    return AppUser(
      firstName: map['firstName'],
       lastName: map['lastName'],
      userId: userId,
      email: map['email'],
      selectedCompanies: List<String>.from(map['selectedCompanies'] ?? []), 
    );
  }
}