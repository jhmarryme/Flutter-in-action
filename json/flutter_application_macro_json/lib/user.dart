import 'package:flutter_application_macro_json/inner_user.dart';
import 'package:json/json.dart';

@JsonCodable()
class User {
  final String name;

  final int? age;

  final InnerUser innerUser;
}
