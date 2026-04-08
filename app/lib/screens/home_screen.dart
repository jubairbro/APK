import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _live = 0; Timer? _t;

  @override void initState() {
    super.initState();
    _live = 1100 + Random().nextInt(400);
    _t = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _live += Random().nextInt(5) - 2);
    });
  }
  @override void dispose() { _t?.cancel(); super.dispose(); }

  Future<void> _wa(String n, {String msg='Hello! Need VIP info.'}) async {
    final clean = n.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override Widget build(BuildContext context) => Consumer<AppProvider>(builder: (ctx, p, _) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        body: p.state == S.loading ? _skel()
            : p.state == S.error && !p.ok ? ErrView(msg: p.err, onRetry: p.refresh)
            : _body(p),
      ),
    );
  });

  Widget _body(AppProvider p) {
    final s = p.settings;
    return PullRefresh(
      onRefresh: p.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _bar(s, p),
          SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (p.notifs.isNotEmpty) Ticker(msgs: p.notifs.map((n)=>n.message).toList()).animate().fadeIn(),
            _resultSec(s).animate().fadeIn(delay: 50.ms),
            _statBar(p).animate().fadeIn(delay: 100.ms),
            _recent(p).animate().fadeIn(delay: 150.ms),
            _contact(s).animate().fadeIn(delay: 200.ms),
            _footer(s).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 90),
          ])),
        ],
      ),
    );
  }

  SliverAppBar _bar(AppSettings s, AppProvider p) => SliverAppBar(
    pinned: true, expandedHeight: 96,
    backgroundColor: AppColors.bgHeader, surfaceTintColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        color: AppColors.bgHeader,
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(width: 42, height: 42,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(s.siteTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
              Text(s.siteDomain, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ])),
            if (p.bgRefresh)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38))
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(Icons.circle, color: Colors.white, size: 6),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ]),
              ),
          ]),
        )),
      ),
    ),
  );

  Widget _resultSec(AppSettings s) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: AppColors.bgHeader, borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 14),
          const SizedBox(width: 8),
          Text('DATE: ${s.resultDate}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.3)),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: ResultCard(label: 'F/R', time: s.frTime, result: s.frResult)),
        const SizedBox(width: 12),
        Expanded(child: ResultCard(label: 'S/R', time: s.srTime, result: s.srResult)),
      ]),
    ]),
  );

  Widget _statBar(AppProvider p) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _stat('${_live.clamp(900,2000)}', 'Online', Icons.people_rounded, Colors.green),
        Container(width: 1, height: 32, color: AppColors.border),
        _stat('${p.members.length}+', 'VIP', Icons.verified_rounded, AppColors.gold),
        Container(width: 1, height: 32, color: AppColors.border),
        _stat('${p.results.length}', 'Results', Icons.bar_chart_rounded, AppColors.primary),
      ]),
    ),
  );

  Widget _stat(String v, String l, IconData i, Color c) => Column(children: [
    Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, color: c, size: 14), const SizedBox(width: 4), Text(v, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 15))]),
    Text(l, style: const TextStyle(color: AppColors.textMut, fontSize: 10)),
  ]);

  Widget _recent(AppProvider p) {
    final items = p.results.take(6).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SecTitle(title: 'Latest Results', sub: 'Last ${items.length} entries'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
          child: Column(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
              child: Row(children: const [
                Expanded(flex: 3, child: Text('DATE', style: TextStyle(color: AppColors.textMut, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1))),
                Expanded(child: Center(child: Text('F/R', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)))),
                Expanded(child: Center(child: Text('S/R', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)))),
              ]),
            ),
            const Divider(color: AppColors.border, height: 1),
            ...items.asMap().entries.map((e) => Column(children: [
              _RRow(r: e.value, even: e.key.isEven),
              if (e.key < items.length - 1) const Divider(color: AppColors.divider, height: 1, indent: 16, endIndent: 16),
            ])),
          ]),
        ),
      ),
    ]);
  }

  Widget _contact(AppSettings s) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.support_agent_rounded, color: AppColors.green, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Contact via WhatsApp', style: TextStyle(color: AppColors.textPri, fontWeight: FontWeight.w800, fontSize: 14)),
          Text(s.whatsapp, style: const TextStyle(color: AppColors.textSec, fontSize: 12)),
        ])),
        GestureDetector(
          onTap: () => _wa(s.whatsapp),
          child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.greenWA, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.chat_rounded, color: Colors.white, size: 20)),
        ),
      ]),
    ),
  );

  Widget _footer(AppSettings s) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.bgHeader, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Icon(Icons.track_changes_rounded, color: Colors.white30, size: 26),
        const SizedBox(height: 8),
        Text(s.footerOrg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 4),
        Text(s.footerLoc + (s.footerReg.isNotEmpty ? ' • ${s.footerReg}' : ''),
          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11)),
        const SizedBox(height: 8),
        Text('© ${DateTime.now().year} ${s.siteName}', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
      ]),
    ),
  );

  Widget _skel() => SingleChildScrollView(physics: const NeverScrollableScrollPhysics(),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(children: const [
      SizedBox(height: 100), Shim(h: 50), SizedBox(height: 12),
      Row(children: [Expanded(child: Shim(h: 165)), SizedBox(width: 12), Expanded(child: Shim(h: 165))]),
      SizedBox(height: 12), Shim(h: 60), SizedBox(height: 16), Shim(h: 250),
    ])),
  );
}

class _RRow extends StatelessWidget {
  final TeerResult r; final bool even;
  const _RRow({required this.r, required this.even});
  @override Widget build(BuildContext context) => Container(
    color: even ? Colors.transparent : AppColors.bgPage,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r.fmtDate, style: const TextStyle(color: AppColors.textPri, fontWeight: FontWeight.w600, fontSize: 13)),
        Text(r.dayName, style: const TextStyle(color: AppColors.textMut, fontSize: 10)),
      ])),
      Expanded(child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.primaryL, borderRadius: BorderRadius.circular(8)),
        child: Text(r.fr, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 15))))),
      Expanded(child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.goldL, borderRadius: BorderRadius.circular(8)),
        child: Text(r.sr, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w900, fontSize: 15))))),
    ]),
  );
}
