import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Payload keys ─────────────────────────────────────────────────────────────
const _kSongId = 'songId';
const _kSongTitle = 'songTitle';
const _kSongArtist = 'songArtist';
const _kThumbnailUrl = 'thumbnailUrl';
const _kPositionMs = 'positionMs';
const _kDurationMs = 'durationMs';
const _kIsPlaying = 'isPlaying';
const _kSentAtMs = 'sentAtMs';

/// [ListenTogetherService] manages ephemeral Supabase Realtime Broadcast
/// channels to sync music playback between two devices — no login required.
///
/// Design:
///  • Host creates a room (6-char code) → broadcasts sync events periodically.
///  • Guest joins with the code → receives sync events and mirrors playback.
///  • Everything is ephemeral: no data is stored in any database.
class ListenTogetherService extends GetxService {
  RealtimeChannel? _channel;

  // Observables consumed by the UI controller.
  final roomCode = RxnString();
  final isHost = false.obs;
  final isInRoom = false.obs;
  final lastSync = Rxn<SyncPayload>();
  final membersOnline = 0.obs;

  // Callbacks wired by ListenTogetherController.
  void Function(SyncPayload)? onSyncReceived;
  VoidCallback? onHostEnded;

  SupabaseClient get _client => Supabase.instance.client;

  // ── Room creation (HOST) ─────────────────────────────────────────────────

  Future<String> createRoom() async {
    await leaveRoom();
    final code = _generateCode();
    roomCode.value = code;
    isHost.value = true;

    _channel = _client.channel('lt-$code',
        opts: const RealtimeChannelConfig(ack: false));

    // Track presence so we know how many members are in the room.
    _channel!
      ..onPresenceSync(callback: (_) {
        membersOnline.value = _channel!.presenceState().length;
      })
      ..subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await _channel!.track({'role': 'host'});
          isInRoom.value = true;
        }
      });

    return code;
  }

  // ── Room joining (GUEST) ─────────────────────────────────────────────────

  Future<void> joinRoom(String code) async {
    await leaveRoom();
    final upper = code.trim().toUpperCase();
    roomCode.value = upper;
    isHost.value = false;

    _channel = _client.channel('lt-$upper',
        opts: const RealtimeChannelConfig(ack: false));

    _channel!
      ..onBroadcast(
        event: 'sync',
        callback: (payload) {
          try {
            final parsed = SyncPayload.fromMap(payload);
            lastSync.value = parsed;
            onSyncReceived?.call(parsed);
          } catch (e) {
            debugPrint('ListenTogether: bad sync payload: $e');
          }
        },
      )
      ..onBroadcast(
        event: 'end',
        callback: (_) {
          onHostEnded?.call();
        },
      )
      ..onPresenceSync(callback: (_) {
        membersOnline.value = _channel!.presenceState().length;
      })
      ..subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await _channel!.track({'role': 'guest'});
          isInRoom.value = true;
        }
      });
  }

  // ── Broadcasting (HOST only) ─────────────────────────────────────────────

  Future<void> broadcastSync(SyncPayload payload) async {
    if (!isInRoom.value || !isHost.value || _channel == null) return;
    await _channel!
        .sendBroadcastMessage(event: 'sync', payload: payload.toMap());
  }

  // ── Leave / end ──────────────────────────────────────────────────────────

  Future<void> leaveRoom() async {
    if (_channel == null) return;
    try {
      if (isHost.value) {
        await _channel!.sendBroadcastMessage(event: 'end', payload: {});
      }
      await _client.removeChannel(_channel!);
    } catch (_) {}
    _channel = null;
    roomCode.value = null;
    isHost.value = false;
    isInRoom.value = false;
    lastSync.value = null;
    membersOnline.value = 0;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SyncPayload
// ─────────────────────────────────────────────────────────────────────────────

class SyncPayload {
  final String songId;
  final String songTitle;
  final String songArtist;
  final String thumbnailUrl;
  final int positionMs;
  final int durationMs;
  final bool isPlaying;
  final int sentAtMs;

  const SyncPayload({
    required this.songId,
    required this.songTitle,
    required this.songArtist,
    required this.thumbnailUrl,
    required this.positionMs,
    required this.durationMs,
    required this.isPlaying,
    required this.sentAtMs,
  });

  factory SyncPayload.fromMap(Map<String, dynamic> m) => SyncPayload(
        songId: m[_kSongId] as String? ?? '',
        songTitle: m[_kSongTitle] as String? ?? '',
        songArtist: m[_kSongArtist] as String? ?? '',
        thumbnailUrl: m[_kThumbnailUrl] as String? ?? '',
        positionMs: (m[_kPositionMs] as num?)?.toInt() ?? 0,
        durationMs: (m[_kDurationMs] as num?)?.toInt() ?? 0,
        isPlaying: m[_kIsPlaying] as bool? ?? false,
        sentAtMs: (m[_kSentAtMs] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toMap() => {
        _kSongId: songId,
        _kSongTitle: songTitle,
        _kSongArtist: songArtist,
        _kThumbnailUrl: thumbnailUrl,
        _kPositionMs: positionMs,
        _kDurationMs: durationMs,
        _kIsPlaying: isPlaying,
        _kSentAtMs: sentAtMs,
      };

  /// Position corrected for network latency since the host sent this payload.
  Duration get correctedPosition {
    final drift = DateTime.now().millisecondsSinceEpoch - sentAtMs;
    final adjusted = positionMs + (isPlaying ? drift : 0);
    return Duration(milliseconds: adjusted.clamp(0, durationMs));
  }
}
