import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});
  @override State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int? _month, _year;
  String _q = '';
  bool _search = false;
  final _sc = TextEditingController();

  static const _ms = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  static const _mf = ['','January','February','March','April','May','June','July','August','September','October','November','December'];

  @override void initState() {
    super.initState();
    final n = DateTime.now(); _year = n.year; _month = n.month;
    _sc.addListener(() => setState(() => _q = _sc.text.trim()));
  }
  @override void dispose() { _sc.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Consumer<AppProvider>(builder: (ctx, p, _) {
    final items = p.filter(month: _search ? null : _month, year: _search ? null : _year, q: _q);
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _bar(p, items.length),
      body: Column(children: [
        if (!_search) _monthBar(),
        Expanded(child: p.state == S.loading ? _skel()
            : PullRefresh(onRefresh: p.refresh, child: items.isEmpty ? _empty() : _list(items))),
      ]),
    );
  });

  AppBar _bar(AppProvider p, int count) => AppBar(
    backgroundColor: AppColors.bgHeader, foregroundColor: Colors.white, surfaceTintColor: Colors.transparent,
    title: _search
        ? TextField(controller: _sc, autofocus: true,
            style: const TextStyle(color: Colors.white), cursorColor: Colors.white70,
            decoration: InputDecoration(hintText: 'Search date, FR or SR number...', hintStyle: const TextStyle(color: Colors.white38), border: InputBorder.none,
              suffixIcon: _q.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.white54), onPressed: () { _sc.clear(); setState(() => _q=''); }) : null))
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Previous Results', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            Text('$count results', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
    actions: [
      if (p.bgRefresh) const Padding(padding: EdgeInsets.all(16),
        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38))),
      IconButton(icon: Icon(_search ? Icons.close_rounded : Icons.search_rounded, color: Colors.white),
        onPressed: () { setState(() { _search = !_search; if (!_search) { _sc.clear(); _q=''; } }); }),
      if (!_search)
        Builder(builder: (ctx) => PopupMenuButton<int>(
          color: AppColors.bgCard,
          icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
          onSelected: (y) => setState(() => _year = y),
          itemBuilder: (_) => context.read<AppProvider>().years.map((y) => PopupMenuItem(value: y,
            child: Text('$y', style: TextStyle(color: y == _year ? AppColors.primary : AppColors.textPri, fontWeight: FontWeight.w700)))).toList(),
        )),
    ],
  );

  Widget _monthBar() => Container(
    height: 46, color: AppColors.bgHeader,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: 13,
      itemBuilder: (_, i) {
        final isAll = i == 0; final sel = isAll ? _month == null : _month == i;
        return GestureDetector(
          onTap: () => setState(() => _month = isAll ? null : i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: sel ? Colors.white : Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(isAll ? 'All' : _ms[i], style: TextStyle(color: sel ? AppColors.primary : Colors.white60, fontWeight: FontWeight.w700, fontSize: 12))),
          ),
        );
      },
    ),
  );

  Widget _list(List<TeerResult> items) {
    final grouped = <String, List<TeerResult>>{};
    for (final r in items) { final d = r.dt; grouped.putIfAbsent('${_mf[d.month]} ${d.year}', () => []).add(r); }
    final gs = grouped.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: gs.length,
      itemBuilder: (_, gi) {
        final g = gs[gi];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(children: [
              Container(width: 3, height: 16, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(g.key, style: const TextStyle(color: AppColors.textPri, fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primaryL, borderRadius: BorderRadius.circular(10)),
                child: Text('${g.value.length}', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
              child: Column(children: g.value.asMap().entries.map((e) {
                final isLast = e.key == g.value.length - 1;
                return Column(children: [
                  _Row(r: e.value, even: e.key.isEven).animate().fadeIn(delay: Duration(milliseconds: 20 * e.key), duration: 220.ms),
                  if (!isLast) const Divider(color: AppColors.divider, height: 1, indent: 16, endIndent: 16),
                ]);
              }).toList()),
            ),
          ),
          const SizedBox(height: 4),
        ]);
      },
    );
  }

  Widget _empty() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.search_off_rounded, color: AppColors.textMut, size: 56),
    const SizedBox(height: 12),
    Text(_q.isNotEmpty ? 'No results for "$_q"' : 'No results for ${_mf[_month ?? 0]} $_year',
      textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSec, fontSize: 15)),
  ]));

  Widget _skel() => ListView.builder(padding: const EdgeInsets.all(16), itemCount: 8,
    itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Shim(h: 64, r: 12)));
}

class _Row extends StatelessWidget {
  final TeerResult r; final bool even;
  const _Row({required this.r, required this.even});
  @override Widget build(BuildContext context) {
    final d = r.dt;
    return Container(
      color: even ? Colors.transparent : AppColors.bgPage,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(width: 50, height: 50,
          decoration: BoxDecoration(color: AppColors.primaryL, borderRadius: BorderRadius.circular(12)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(d.day.toString().padLeft(2,'0'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18, height: 1)),
            Text(['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month],
              style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
          ])),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.dayName, style: const TextStyle(color: AppColors.textPri, fontWeight: FontWeight.w700, fontSize: 14)),
          Text('${d.year}', style: const TextStyle(color: AppColors.textMut, fontSize: 11)),
        ])),
        _nb(r.fr, AppColors.primary, AppColors.primaryL, 'F/R'),
        const SizedBox(width: 10),
        _nb(r.sr, AppColors.gold, AppColors.goldL, 'S/R'),
      ]),
    );
  }
  Widget _nb(String v, Color c, Color bg, String l) => Column(children: [
    Text(l, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    const SizedBox(height: 2),
    Container(width: 46, padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.2))),
      child: Text(v, textAlign: TextAlign.center, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 17))),
  ]);
}
