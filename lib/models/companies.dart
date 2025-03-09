class CompaniesResponse {
  final bool success;
  final List<String> data;

  CompaniesResponse({required this.success, required this.data});

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) {
    return CompaniesResponse(
      success: json['success'],
      data: List<String>.from(json['data']),
    );
  }
}