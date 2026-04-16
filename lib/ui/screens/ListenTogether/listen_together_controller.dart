import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '/services/audio_handler.dart';
import '/services/listen_together_service.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/snackbar.dart';

class ListenTogetherController extends GetxController {
  final _service = Get.find<ListenTogetherService>();

  // ── UI state forwarded from service ──────────────────────────────────────
  RxnString get roomCode => _service.roomCode;
  RxBool get isHost => _service.isHost;
  RxBool get isInRoom => _service.isInRoom;
  Rxn<SyncPayload> get lastSync => _service.lastSync;
  RxInt get membersOnline => _service.membersOnline;

  // Local UI state
  final isConnecting = false.obs;
  final codeInputController = TextEditingController();
  final autoSync = true.obs; // guest auto-syncs on new song

  // Host sync timer
  Timer? _hostTimer;

  // Track last synced song for guest so we only load on change
  String? _lastSyncedSongId;

  @override
  void onInit() {
    super.onInit();
    _service.onSyncReceived = _handleGuestSync;
    _service.onHostEnded = _handleHostEnded;
  }

  @override
  void onClose() {
    codeInputController.dispose();
    _stopHostTimer();
    super.onClose();
  }

  // ── HOST actions ─────────────────────────────────────────────────────────

  Future<void> createRoom() async {
    isConnecting.value = true;
    try {
      await _service.createRoom();
      _startHostTimer();
      // Immediately broadcast current state if something is playing
      _broadcastNow();
    } catch (e) {
      _showSnack('ltConnectError'.tr);
    } finally {
      isConnecting.value = false;
    }
  }

  /// Manually trigger an immediate sync broadcast (called on play/pause/seek).
  void _broadcastNow() {
    if (!_service.isInRoom.value || !_service.isHost.value) return;
    final player = _tryGetPlayer();
    if (player == null) return;
    final song = player.currentSong.value;
    if (song == null) return;

    final payload = SyncPayload(
      songId: song.id,
      songTitle: song.title,
      songArtist: song.artist ?? '',
      thumbnailUrl: song.artUri?.toString() ?? '',
      positionMs: player.progressBarStatus.value.current.inMilliseconds,
      durationMs: player.progressBarStatus.value.total.inMilliseconds,
      isPlaying: player.buttonState.value == PlayButtonState.playing,
      sentAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    _service.broadcastSync(payload);
  }

  void _startHostTimer() {
    _stopHostTimer();
    _hostTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _broadcastNow();
    });
  }

  void _stopHostTimer() {
    _hostTimer?.cancel();
    _hostTimer = null;
  }

  // ── GUEST actions ────────────────────────────────────────────────────────

  Future<void> joinRoom() async {
    final code = codeInputController.text.trim().toUpperCase();
    if (code.length != 6) {
      _showSnack('ltInvalidCode'.tr);
      return;
    }
    isConnecting.value = true;
    try {
      await _service.joinRoom(code);
    } catch (e) {
      _showSnack('ltConnectError'.tr);
    } finally {
      isConnecting.value = false;
    }
  }

  /// Manually sync guest to the host's last known position.
  Future<void> syncNow() async {
    final sync = _service.lastSync.value;
    if (sync == null) return;
    await _applySync(sync, force: true);
    _showSnack('ltSyncedNow'.tr);
  }

  void _handleGuestSync(SyncPayload payload) {
    if (!autoSync.value) return;
    _applySync(payload, force: false);
  }

  Future<void> _applySync(SyncPayload payload, {required bool force}) async {
    if (payload.songId.isEmpty) return;
    final player = _tryGetPlayer();
    if (player == null) return;
    final handler = _tryGetHandler();

    // Load a different song if needed.
    if (payload.songId != _lastSyncedSongId || force) {
      final current = player.currentSong.value;
      if (current?.id != payload.songId) {
        // Build a MediaItem from the sync payload and play it.
        final mediaItem = MediaItem(
          id: payload.songId,
          title: payload.songTitle,
          artist: payload.songArtist,
          artUri: payload.thumbnailUrl.isNotEmpty
              ? Uri.tryParse(payload.thumbnailUrl)
              : null,
          duration: payload.durationMs > 0
              ? Duration(milliseconds: payload.durationMs)
              : null,
        );
        await player.pushSongToQueue(mediaItem);
        // Wait briefly for playback to start before seeking.
        await Future.delayed(const Duration(milliseconds: 800));
      }
      _lastSyncedSongId = payload.songId;
    }

    // Seek to the corrected position.
    if (handler != null) {
      final target = payload.correctedPosition;
      final total = Duration(milliseconds: payload.durationMs);
      if (total > Duration.zero && target <= total) {
        await handler.seek(target);
      }
    }

    // Match play/pause state.
    if (handler != null) {
      if (payload.isPlaying) {
        await handler.play();
      } else {
        await handler.pause();
      }
    }
  }

  void _handleHostEnded() {
    _showSnack('ltHostEnded'.tr);
    _service.leaveRoom();
  }

  // ── Leave ────────────────────────────────────────────────────────────────

  Future<void> leaveRoom() async {
    _stopHostTimer();
    _lastSyncedSongId = null;
    await _service.leaveRoom();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void copyCode() {
    final code = _service.roomCode.value;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    _showSnack('ltCodeCopied'.tr);
  }

  PlayerController? _tryGetPlayer() {
    try {
      return Get.find<PlayerController>();
    } catch (_) {
      return null;
    }
  }

  AudioHandler? _tryGetHandler() {
    try {
      return Get.find<AudioHandler>();
    } catch (_) {
      return null;
    }
  }

  void _showSnack(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        snackbar(Get.context!, message, size: SanckBarSize.MEDIUM),
      );
    }
  }
}
