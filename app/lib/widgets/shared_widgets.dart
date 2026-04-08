import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

// ── Notification ticker ────────────────────────────────────────────────────────
class Ticker extends StatefulWidget {
  final List<String> msgs;
  const Ticker({super.key, required this.msgs});
  @override State<Ticker> createState() => _TickerState();
}
class _TickerState extends State<Ticker> {
  final _ctrl = PageController();
  int _i = 0; Timer? _t;
  @override void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.msgs.isEmpty) return;
      _i = (_i + 1) % widget.msgs.length;
      _ctrl.animateToPage(_i, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }
  @override void dispose() { _t?.cancel(); _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    if (widget.msgs.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 40,
      color: AppColors.primaryL,
      child: Row(children: [
        Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
          child: const Row(children: [
            Icon(Icons.campaign_rounded, size: 11, color: Colors.white),
            SizedBox(width: 4),
            Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
          ]),
        ),
        Expanded(
          child: PageView.builder(
            controller: _ctrl, scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(widget.msgs[i % widget.msgs.length], maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Result card ────────────────────────────────────────────────────────────────
class ResultCard extends StatelessWidget {
  final String label, time, result;
  const ResultCard({super.key, required this.label, required this.time, required this.result});
  bool get _has => result != 'XX' && result.isNotEmpty;
  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(color: AppColors.primaryL, borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 4),
        Text('($time)', style: const TextStyle(fontSize: 11, color: AppColors.textSec)),
        const SizedBox(height: 10),
        _has
            ? Text(result.padLeft(2,'0'), style: const TextStyle(fontSize: 58, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.0))
            : const SizedBox(width: 50, height: 50, child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary)),
        const SizedBox(height: 6),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: _has ? AppColors.green : AppColors.textMut, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(_has ? 'Published' : 'Awaited', style: TextStyle(fontSize: 11, color: _has ? AppColors.green : AppColors.textMut, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

// ── Shimmer ────────────────────────────────────────────────────────────────────
class Shim extends StatefulWidget {
  final double h; final double? w; final double r;
  const Shim({super.key, this.h = 60, this.w, this.r = 12});
  @override State<Shim> createState() => _ShimState();
}
class _ShimState extends State<Shim> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Container(
      height: widget.h, width: widget.w ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.r),
        gradient: LinearGradient(
          colors: const [Color(0xFFE2E8F0), Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          stops: [(_c.value-.3).clamp(0,1), _c.value, (_c.value+.3).clamp(0,1)],
        ),
      ),
    ),
  );
}

// ── Section title ──────────────────────────────────────────────────────────────
class SecTitle extends StatelessWidget {
  final String title; final String? sub; final Widget? trailing;
  const SecTitle({super.key, required this.title, this.sub, this.trailing});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Row(children: [
      Container(width: 4, height: sub!=null?36:20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppColors.textPri, fontWeight: FontWeight.w900, fontSize: 16)),
        if (sub != null) Text(sub!, style: const TextStyle(color: AppColors.textSec, fontSize: 12)),
      ])),
      if (trailing != null) trailing!,
    ]),
  );
}

// ── Level badge ────────────────────────────────────────────────────────────────
class LvBadge extends StatelessWidget {
  final int lv;
  const LvBadge({super.key, required this.lv});
  @override Widget build(BuildContext context) {
    final c = levelColor(lv); final bg = levelBg(lv);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.3))),
      child: Text('Level $lv', style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

// ── WhatsApp button ────────────────────────────────────────────────────────────
class WABtn extends StatelessWidget {
  final String label; final VoidCallback onTap; final bool full;
  const WABtn({super.key, required this.label, required this.onTap, this.full = false});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: full ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.greenWA,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.greenWA.withOpacity(0.25), blurRadius: 10, offset: const Offset(0,4))],
      ),
      child: Row(mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.chat_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
      ]),
    ),
  );
}

// ── Pull-to-refresh wrapper ────────────────────────────────────────────────────
class PullRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh; final Widget child;
  const PullRefresh({super.key, required this.onRefresh, required this.child});
  @override Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh, color: AppColors.primary, backgroundColor: AppColors.bgCard, strokeWidth: 2.5, child: child,
  );
}

// ── Error view ─────────────────────────────────────────────────────────────────
class ErrView extends StatelessWidget {
  final String msg; final VoidCallback onRetry;
  const ErrView({super.key, required this.msg, required this.onRetry});
  @override Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off_rounded, color: AppColors.textMut, size: 64),
      const SizedBox(height: 16),
      Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSec, fontSize: 15)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    ]),
  ));
}
