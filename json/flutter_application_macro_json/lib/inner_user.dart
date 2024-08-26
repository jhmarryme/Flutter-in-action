import 'package:json/json.dart';

@JsonCodable()
class InnerUser {
  final String innerName;

  final int? innerAge;
}
