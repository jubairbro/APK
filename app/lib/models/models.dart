class AppSettings {
  final String siteName, siteTitle, siteDomain;
  final String resultDate, frTime, srTime, frResult, srResult;
  final String whatsapp, paymentInfo, notifText;
  final String footerOrg, footerLoc, footerReg;
  final List<VipLevel> levels;

  const AppSettings({
    this.siteName = 'ShillongTeer',
    this.siteTitle = 'SHILLONG TEER RESULT',
    this.siteDomain = 'shillongteeroffice.com',
    this.resultDate = 'Today',
    this.frTime = '04:00 PM',
    this.srTime = '05:00 PM',
    this.frResult = 'XX',
    this.srResult = 'XX',
    this.whatsapp = '',
    this.paymentInfo = 'Scan with Google Pay, PhonePe, or Paytm',
    this.notifText = 'Welcome to Shillong Teer VIP!',
    this.footerOrg = 'KHASI HILLS ARCHERY SPORTS INSTITUTE',
    this.footerLoc = 'SHILLONG',
    this.footerReg = '',
    this.levels = const [],
  });

  factory AppSettings.fromMap(Map<String, String> m) {
    final levels = List.generate(3, (i) {
      final n = i + 1;
      return VipLevel(
        level: n,
        name: m['level${n}_name'] ?? 'LEVEL ($n)',
        price: m['level${n}_price'] ?? '0',
        period: m['level${n}_period'] ?? 'One Month',
        frCount: int.tryParse(m['level${n}_fr_count'] ?? '1') ?? 1,
        srCount: int.tryParse(m['level${n}_sr_count'] ?? '1') ?? 1,
        likes: int.tryParse(m['level${n}_likes'] ?? '0') ?? 0,
        comments: int.tryParse(m['level${n}_comments'] ?? '0') ?? 0,
        joinText: m['level${n}_join_text'] ?? 'Join Level-$n',
        prevDate: m['level${n}_prev_date'] ?? '',
        prevFr: m['level${n}_prev_fr'] ?? '',
        prevSr: m['level${n}_prev_sr'] ?? '',
      );
    });
    return AppSettings(
      siteName: m['site_name'] ?? 'ShillongTeer',
      siteTitle: m['site_title'] ?? 'SHILLONG TEER RESULT',
      siteDomain: m['site_domain'] ?? 'shillongteeroffice.com',
      resultDate: m['result_date'] ?? 'Today',
      frTime: m['fr_time'] ?? '04:00 PM',
      srTime: m['sr_time'] ?? '05:00 PM',
      frResult: m['fr_result'] ?? 'XX',
      srResult: m['sr_result'] ?? 'XX',
      whatsapp: m['whatsapp_number'] ?? '',
      paymentInfo: m['payment_info_text'] ?? 'Scan with Google Pay, PhonePe, or Paytm',
      notifText: m['notification_text'] ?? 'Join VIP for guaranteed targets!',
      footerOrg: m['footer_org_name'] ?? 'KHASI HILLS ARCHERY SPORTS INSTITUTE',
      footerLoc: m['footer_org_location'] ?? 'SHILLONG',
      footerReg: m['footer_reg_no'] ?? '',
      levels: levels,
    );
  }

  bool get hasFr => frResult != 'XX' && frResult.isNotEmpty;
  bool get hasSr => srResult != 'XX' && srResult.isNotEmpty;
}

class VipLevel {
  final int level;
  final String name, price, period, joinText, prevDate, prevFr, prevSr;
  final int frCount, srCount, likes, comments;

  const VipLevel({
    required this.level, required this.name, required this.price,
    required this.period, required this.frCount, required this.srCount,
    required this.likes, required this.comments, required this.joinText,
    required this.prevDate, required this.prevFr, required this.prevSr,
  });

  List<String> get frList => prevFr.isEmpty ? [] : prevFr.split(',').map((e) => e.trim()).toList();
  List<String> get srList => prevSr.isEmpty ? [] : prevSr.split(',').map((e) => e.trim()).toList();
  int get total => frCount + srCount;
}

class TeerResult {
  final int id;
  final String date, fr, sr;

  const TeerResult({required this.id, required this.date, required this.fr, required this.sr});

  factory TeerResult.fromMap(Map<String, dynamic> m) => TeerResult(
    id: (m['id'] as num?)?.toInt() ?? 0,
    date: m['date']?.toString() ?? '',
    fr: m['fr']?.toString() ?? 'XX',
    sr: m['sr']?.toString() ?? 'XX',
  );

  DateTime get dt {
    try {
      final p = date.split('-');
      if (p.length == 3) return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {}
    return DateTime(1970);
  }

  String get fmtDate {
    final d = dt;
    if (d.year == 1970) return date;
    const ms = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${ms[d.month]} ${d.day.toString().padLeft(2,'0')}, ${d.year}';
  }

  String get dayName {
    const ds = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    return ds[dt.weekday % 7];
  }
}

class TeerNotif {
  final int id;
  final String message;
  const TeerNotif({required this.id, required this.message});
  factory TeerNotif.fromMap(Map<String, dynamic> m) => TeerNotif(
    id: (m['id'] as num?)?.toInt() ?? 0,
    message: m['message']?.toString() ?? '',
  );
}

class TeerMember {
  final int id;
  final String name, level;
  const TeerMember({required this.id, required this.name, required this.level});
  factory TeerMember.fromMap(Map<String, dynamic> m) => TeerMember(
    id: (m['id'] as num?)?.toInt() ?? 0,
    name: m['name']?.toString() ?? '',
    level: m['level']?.toString() ?? 'Level 1',
  );
  int get lv => int.tryParse(level.replaceAll(RegExp(r'\D'), '')) ?? 1;
}
