import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});
  @override State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  int _sel = 1;

  Future<void> _join(String num, VipLevel lv) async {
    final n = num.replaceAll(RegExp(r'\D'), '');
    final msg = Uri.encodeComponent('Hello Sir!\nI want to join ${lv.name}.\nPrice: ₹${lv.price} / ${lv.period}\nPlease guide me.');
    final uri = Uri.parse('https://wa.me/$n?text=$msg');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override Widget build(BuildContext context) => Consumer<AppProvider>(builder: (ctx, p, _) {
    final s = p.settings;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: p.state == S.loading ? _skel()
          : PullRefresh(
              onRefresh: p.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _bar(p),
                  SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _hero(s).animate().fadeIn(duration: 400.ms),
                    if (s.levels.isNotEmpty) ...[
                      _tabs(s).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 16),
                      _card(s.levels[_sel - 1], s.whatsapp).animate().fadeIn(delay: 150.ms),
                    ],
                    if (s.levels.length > 1) _compare(s).animate().fadeIn(delay: 200.ms),
                    _members(p).animate().fadeIn(delay: 250.ms),
                    _howItWorks().animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 90),
                  ])),
                ],
              ),
            ),
    );
  });

  SliverAppBar _bar(AppProvider p) => SliverAppBar(
    pinned: true,
    backgroundColor: AppColors.bgHeader, surfaceTintColor: Colors.transparent,
    title: const Text('VIP Membership', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
    actions: [
      if (p.bgRefresh) const Padding(padding: EdgeInsets.all(16),
        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38))),
    ],
  );

  // ── Hero ─────────────────────────────────────────────────────────────────────
  Widget _hero(AppSettings s) => Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgHeader, borderRadius: BorderRadius.circular(20)),
    child: Stack(children: [
      Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: CustomPaint(painter: _Dots()))),
      Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
            child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 28)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SHILLONG TEER', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
            Text('VIP MEMBERSHIP', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ])),
        ]),
        const SizedBox(height: 14),
        const Text('Get guaranteed daily targets for FR & SR.\nHigh accuracy • Expert guidance • Daily profit.',
          style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.6)),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _badge('✓ Daily Targets', AppColors.gold),
          _badge('✓ WhatsApp Delivery', AppColors.greenWA),
          _badge('✓ Expert Analyst', AppColors.primary),
          _badge('✓ 1 Month Plan', Colors.white60),
        ]),
      ])),
    ]),
  );

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.3))),
    child: Text(t, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
  );

  // ── Level Tabs ────────────────────────────────────────────────────────────────
  Widget _tabs(AppSettings s) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: s.levels.map((lv) {
      final sel = _sel == lv.level;
      final c = levelColor(lv.level);
      return Expanded(child: GestureDetector(
        onTap: () => setState(() => _sel = lv.level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: sel ? c : AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: sel ? c : AppColors.border, width: sel ? 2 : 1),
            boxShadow: sel ? [BoxShadow(color: c.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,4))] : AppColors.cardShadow,
          ),
          child: Column(children: [
            Text('Level ${lv.level}', style: TextStyle(color: sel ? Colors.white : AppColors.textPri, fontWeight: FontWeight.w900, fontSize: 14)),
            Text('₹${lv.price}', style: TextStyle(color: sel ? Colors.white70 : AppColors.textSec, fontSize: 12)),
          ]),
        ),
      ));
    }).toList()),
  );

  // ── Full Level Card ────────────────────────────────────────────────────────────
  Widget _card(VipLevel lv, String wa) {
    final c = levelColor(lv.level);
    final bg = levelBg(lv.level);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: Container(
          key: ValueKey(lv.level),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.25), width: 1.5), boxShadow: AppColors.cardShadow),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header strip
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))),
              child: Row(children: [
                LvBadge(lv: lv.level), const SizedBox(width: 10),
                Expanded(child: Text(lv.name, style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 14))),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹${lv.price}', style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 28)),
                  Text('/ ${lv.period}', style: const TextStyle(color: AppColors.textSec, fontSize: 11)),
                ]),
              ]),
            ),
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _st('${lv.frCount}', 'FR/day', AppColors.primary),
                Container(width: 1, height: 40, color: AppColors.border),
                _st('${lv.srCount}', 'SR/day', AppColors.gold),
                Container(width: 1, height: 40, color: AppColors.border),
                _st('${lv.total}', 'Total', c),
              ]),
            ),
            const Divider(color: AppColors.border, height: 1, indent: 20, endIndent: 20),
            // Previous results
            if (lv.prevDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.history_rounded, size: 13, color: AppColors.textSec),
                    const SizedBox(width: 6),
                    Text('Previous Targets — ${lv.prevDate}', style: const TextStyle(color: AppColors.textSec, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    if (lv.frList.isNotEmpty) Expanded(child: _tbox('F/R', lv.frList, AppColors.primary, AppColors.primaryL)),
                    if (lv.frList.isNotEmpty && lv.srList.isNotEmpty) const SizedBox(width: 10),
                    if (lv.srList.isNotEmpty) Expanded(child: _tbox('S/R', lv.srList, AppColors.gold, AppColors.goldL)),
                  ]),
                ]),
              ),
            // Social proof
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(children: [
                const Icon(Icons.favorite_rounded, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Text('${lv.likes} members', style: const TextStyle(color: AppColors.textSec, fontSize: 12)),
                const SizedBox(width: 14),
                const Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                const SizedBox(width: 4),
                Text('${lv.comments} reviews', style: const TextStyle(color: AppColors.textSec, fontSize: 12)),
              ]),
            ),
            // Join button
            Padding(
              padding: const EdgeInsets.all(20),
              child: WABtn(label: lv.joinText, onTap: () => _join(wa, lv), full: true),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _st(String v, String l, Color c) => Column(children: [
    Text(v, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 22)),
    Text(l, style: const TextStyle(color: AppColors.textMut, fontSize: 10)),
  ]);

  Widget _tbox(String label, List<String> nums, Color c, Color bg) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Wrap(spacing: 6, runSpacing: 4, children: nums.map((n) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
        child: Text(n, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 15)),
      )).toList()),
    ]),
  );

  // ── Comparison Table ──────────────────────────────────────────────────────────
  Widget _compare(AppSettings s) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SecTitle(title: 'Plan Comparison', sub: 'Choose what fits your budget'),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
        child: Column(children: [
          _tr(isH: true, lbl: '', vals: s.levels.map((l) => Text('Level ${l.level}', style: TextStyle(color: levelColor(l.level), fontWeight: FontWeight.w900, fontSize: 12))).toList()),
          _td(),
          _tr(lbl: 'Price', vals: s.levels.map((l) => Text('₹${l.price}', style: const TextStyle(fontWeight: FontWeight.w700))).toList()),
          _td(),
          _tr(lbl: 'FR/day', vals: s.levels.map((l) => Text('${l.frCount}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))).toList()),
          _td(),
          _tr(lbl: 'SR/day', vals: s.levels.map((l) => Text('${l.srCount}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700))).toList()),
          _td(),
          _tr(lbl: 'Total/day', vals: s.levels.map((l) => Text('${l.total}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))).toList()),
          _td(),
          _tr(lbl: '❤️ Members', vals: s.levels.map((l) => Text('${l.likes}+', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700))).toList()),
        ]),
      ),
    ),
  ]);

  Widget _tr({required String lbl, required List<Widget> vals, bool isH = false}) => Container(
    color: isH ? AppColors.bgPage : null,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    child: Row(children: [
      Expanded(flex: 2, child: lbl.isEmpty ? const SizedBox.shrink() : Text(lbl, style: const TextStyle(color: AppColors.textSec, fontSize: 12, fontWeight: FontWeight.w600))),
      ...vals.map((v) => Expanded(child: Center(child: v))),
    ]),
  );

  Widget _td() => const Divider(color: AppColors.divider, height: 1, indent: 16, endIndent: 16);

  // ── Members Row ───────────────────────────────────────────────────────────────
  Widget _members(AppProvider p) {
    if (p.members.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SecTitle(title: 'Active Members', sub: '${p.members.length} verified subscribers'),
      SizedBox(
        height: 86,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: p.members.length,
          itemBuilder: (_, i) {
            final m = p.members[i];
            final c = levelColor(m.lv); final bg = levelBg(m.lv);
            return Container(
              width: 74, margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CircleAvatar(radius: 18, backgroundColor: bg,
                  child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?', style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 16))),
                const SizedBox(height: 4),
                Text(m.name.split(' ').first, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSec, fontSize: 9, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                  child: Text('Lv ${m.lv}', style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w800))),
              ]),
            ).animate().fadeIn(delay: Duration(milliseconds: 40 * i), duration: 250.ms);
          },
        ),
      ),
    ]);
  }

  // ── How It Works ──────────────────────────────────────────────────────────────
  Widget _howItWorks() {
    final steps = [
      (AppColors.primary, 'Choose Your Plan', 'Level 1, 2, or 3 — based on your budget.'),
      (AppColors.greenWA, 'Message on WhatsApp', 'We confirm your order and payment details.'),
      (AppColors.gold, 'Pay via UPI', 'Google Pay, PhonePe, or Paytm — instant.'),
      (Colors.orange, 'Get Daily Targets', 'FR & SR numbers on WhatsApp every day.'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SecTitle(title: 'How It Works', sub: '4 steps to start winning'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: steps.asMap().entries.map((e) {
          final st = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
              child: Row(children: [
                Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: st.$1.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: st.$1.withOpacity(0.3))),
                  child: Center(child: Text('${e.key + 1}', style: TextStyle(color: st.$1, fontWeight: FontWeight.w900, fontSize: 16)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(st.$2, style: const TextStyle(color: AppColors.textPri, fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(st.$3, style: const TextStyle(color: AppColors.textSec, fontSize: 11, height: 1.4)),
                ])),
              ]),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 70 * e.key), duration: 280.ms);
        }).toList()),
      ),
    ]);
  }

  Widget _skel() => Scaffold(
    backgroundColor: AppColors.bgPage,
    body: Padding(padding: const EdgeInsets.all(16), child: Column(children: const [
      SizedBox(height: 80), Shim(h: 180), SizedBox(height: 16), Shim(h: 50), SizedBox(height: 16), Shim(h: 320),
    ])),
  );
}

class _Dots extends CustomPainter {
  @override void paint(Canvas c, Size s) {
    final p = Paint()..color = Colors.white.withOpacity(0.04);
    for (double x = 0; x < s.width; x += 22) {
      for (double y = 0; y < s.height; y += 22) {
        c.drawCircle(Offset(x, y), 1.5, p);
      }
    }
  }
  @override bool shouldRepaint(_) => false;
}
