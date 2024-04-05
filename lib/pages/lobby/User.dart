class User {
  final String ur_id;
  final String req_id;
  final String req_first_name;
  final String req_profile;
  final String room_id;
  final String room_name;
  final int no_of_people;
  final int code;

  User({this.ur_id, this.req_id, this.req_first_name, this.req_profile,
      this.room_id, this.room_name, this.no_of_people, this.code});
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      ur_id: json["ur_id"] as String,
      req_id: json["req_id"] as String,
      req_first_name: json["req_first_name"] as String,
      room_id: json["room_id"] as String,
      room_name: json["room_name"] as String,
      no_of_people: json["no_of_people"] as int,
      code: json["code"] as int,
    );
  }
}