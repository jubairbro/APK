import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/models.dart';

class Api {
  static final Api _i = Api._();
  factory Api() => _i;
  Api._();

  final _c = http.Client();
  static const _t = Duration(seconds: 15);

  Future<AppSettings> settings() async {
    final r = await _c.get(Uri.parse('${K.apiBase}/settings')).timeout(_t);
    final raw = (json.decode(r.body) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v?.toString() ?? ''));
    return AppSettings.fromMap(raw);
  }

  Future<List<TeerResult>> results() async {
    final r = await _c.get(Uri.parse('${K.apiBase}/results')).timeout(_t);
    return (json.decode(r.body) as List)
        .map((e) => TeerResult.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TeerNotif>> notifs() async {
    final r = await _c.get(Uri.parse('${K.apiBase}/notifications')).timeout(_t);
    return (json.decode(r.body) as List)
        .map((e) => TeerNotif.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TeerMember>> members() async {
    final r = await _c.get(Uri.parse('${K.apiBase}/members')).timeout(_t);
    return (json.decode(r.body) as List)
        .map((e) => TeerMember.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  void close() => _c.close();
}
