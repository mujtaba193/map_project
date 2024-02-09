// ignore_for_file: public_member_api_docs, sort_constructors_first

class UsersMarkers {
  late String username;
  late double latitude;
  late double longitude;
  UsersMarkers({
    required this.username,
    required this.latitude,
    required this.longitude,
  });
  UsersMarkers.fromJson(Map<String, dynamic> json) {
    username = json["username"];
    latitude = json["latitude"];
    longitude = json["longitude"];
  }
}
