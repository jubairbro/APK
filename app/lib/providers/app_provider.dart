import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

enum S { idle, loading, loaded, error }

class AppProvider extends ChangeNotifier {
  final _api = Api();
  S state = S.idle;
  String err = '';
  bool bgRefresh = false;

  AppSettings settings = const AppSettings();
  List<TeerResult> results = [];
  List<TeerNotif> notifs = [];
  List<TeerMember> members = [];

  Timer? _t;

  bool get ok => state == S.loaded;

  Future<void> init() async {
    await load();
    _t = Timer.periodic(Duration(seconds: K.refreshSec), (_) => _bg());
  }

  Future<void> load() async {
    state = S.loading; err = ''; notifyListeners();
    try {
      await _fetch();
      state = S.loaded;
    } catch (e) {
      err = _msg(e); state = S.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => load();

  Future<void> _bg() async {
    if (bgRefresh) return;
    bgRefresh = true; notifyListeners();
    try { await _fetch(); if (state == S.error) state = S.loaded; } catch (_) {}
    bgRefresh = false; notifyListeners();
  }

  Future<void> _fetch() async {
    final r = await Future.wait([
      _api.settings(), _api.results(), _api.notifs(), _api.members(),
    ]);
    settings = r[0] as AppSettings;
    results  = r[1] as List<TeerResult>;
    notifs   = r[2] as List<TeerNotif>;
    members  = r[3] as List<TeerMember>;
  }

  List<TeerResult> filter({int? month, int? year, String q = ''}) {
    return results.where((r) {
      final d = r.dt;
      if (month != null && d.month != month) return false;
      if (year  != null && d.year  != year)  return false;
      if (q.isNotEmpty) {
        final ql = q.toLowerCase();
        if (!r.date.contains(ql) && !r.fr.contains(ql) && !r.sr.contains(ql)) return false;
      }
      return true;
    }).toList();
  }

  List<int> get years {
    final y = results.map((r) => r.dt.year).toSet().toList()..sort((a,b)=>b.compareTo(a));
    return y;
  }

  @override
  void dispose() { _t?.cancel(); _api.close(); super.dispose(); }

  String _msg(Object e) {
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('Failed host')) return 'No internet connection.';
    if (s.contains('TimeoutException')) return 'Request timed out. Try again.';
    return 'Failed to load. Pull down to retry.';
  }
}
