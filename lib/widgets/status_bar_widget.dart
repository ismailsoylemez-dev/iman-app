import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum _ConnState { online, offline, syncing }

/// Ekranın üstünde çevrimiçi/çevrimdışı/senkronize oluyor durumunu gösteren ince şerit.
class StatusBarWidget extends StatefulWidget {
  const StatusBarWidget({super.key});

  @override
  State<StatusBarWidget> createState() => _StatusBarWidgetState();
}

class _StatusBarWidgetState extends State<StatusBarWidget> {
  _ConnState _state = _ConnState.online;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkInitial();
    _subscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _checkInitial() async {
    final results = await Connectivity().checkConnectivity();
    _onConnectivityChanged(results);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final isOnline = !results.contains(ConnectivityResult.none);
    if (!mounted) return;
    if (isOnline) {
      setState(() => _state = _ConnState.syncing);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _state = _ConnState.online);
    } else {
      setState(() => _state = _ConnState.offline);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (_state) {
      _ConnState.online => (const Color(0xFF2E7D32), Icons.wifi_rounded, 'Çevrimiçi'),
      _ConnState.offline => (const Color(0xFFD32F2F), Icons.wifi_off_rounded, 'Çevrimdışı'),
      _ConnState.syncing => (const Color(0xFFF9A825), Icons.sync_rounded, 'Senkronize ediliyor'),
    };

    if (_state == _ConnState.online) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: color.withValues(alpha: 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
