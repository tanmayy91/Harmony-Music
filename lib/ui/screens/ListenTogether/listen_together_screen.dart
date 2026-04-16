import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/listen_together_service.dart';
import '/ui/player/player_controller.dart';
import 'listen_together_controller.dart';

class ListenTogetherScreen extends StatelessWidget {
  const ListenTogetherScreen({super.key, this.isBottomNavActive = false});
  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ListenTogetherController());
    final topPadding = context.isLandscape ? 50.0 : 90.0;

    return Padding(
      padding: isBottomNavActive
          ? EdgeInsets.only(left: 20, top: topPadding, right: 15)
          : EdgeInsets.only(top: topPadding, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 6),
              const Icon(Icons.headphones_rounded, size: 28),
              const SizedBox(width: 10),
              Text(
                'listenTogether'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              'listenTogetherTagline'.tr,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.55),
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (ctrl.isInRoom.value) {
                return ctrl.isHost.value
                    ? _HostView(ctrl: ctrl)
                    : _GuestView(ctrl: ctrl);
              }
              return _LobbyView(ctrl: ctrl);
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lobby — before joining / creating a room
// ─────────────────────────────────────────────────────────────────────────────

class _LobbyView extends StatelessWidget {
  const _LobbyView({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // ── Tab bar ───────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
              tabs: [
                Tab(text: 'ltCreateRoom'.tr),
                Tab(text: 'ltJoinRoom'.tr),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Tab content ───────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              children: [
                _CreateTab(ctrl: ctrl),
                _JoinTab(ctrl: ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Create tab ──────────────────────────────────────────────────────────────

class _CreateTab extends StatelessWidget {
  const _CreateTab({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Illustration
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primaryContainer.withOpacity(0.6),
                  cs.secondaryContainer.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(Icons.wifi_tethering_rounded,
                    size: 72, color: cs.primary),
                const SizedBox(height: 16),
                Text('ltCreateTitle'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'ltCreateDesc'.tr,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: cs.onSurface.withOpacity(0.65),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _HowItWorks(
            steps: [
              _Step(
                  icon: Icons.add_circle_outline_rounded,
                  text: 'ltStep1Create'.tr),
              _Step(
                  icon: Icons.share_outlined, text: 'ltStep2Share'.tr),
              _Step(
                  icon: Icons.sync_rounded, text: 'ltStep3Sync'.tr),
            ],
          ),
          const SizedBox(height: 32),
          Obx(() => FilledButton.icon(
                onPressed:
                    ctrl.isConnecting.value ? null : ctrl.createRoom,
                icon: ctrl.isConnecting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text('ltStartSession'.tr),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Join tab ─────────────────────────────────────────────────────────────────

class _JoinTab extends StatelessWidget {
  const _JoinTab({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Illustration
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.tertiaryContainer.withOpacity(0.6),
                  cs.secondaryContainer.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(Icons.group_add_rounded, size: 72, color: cs.tertiary),
                const SizedBox(height: 16),
                Text('ltJoinTitle'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'ltJoinDesc'.tr,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: cs.onSurface.withOpacity(0.65),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Code input
          TextField(
            controller: ctrl.codeInputController,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                    color: cs.primary),
            decoration: InputDecoration(
              labelText: 'ltEnterCode'.tr,
              hintText: 'ABCDEF',
              counterText: '',
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: cs.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: cs.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => FilledButton.icon(
                onPressed:
                    ctrl.isConnecting.value ? null : ctrl.joinRoom,
                icon: ctrl.isConnecting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login_rounded),
                label: Text('ltJoinSession'.tr),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Host view — in room as host
// ─────────────────────────────────────────────────────────────────────────────

class _HostView extends StatelessWidget {
  const _HostView({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 200),
      children: [
        // ── Room code card ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer,
                cs.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_tethering_rounded,
                      color: cs.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('ltHosting'.tr,
                      style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'ltShareCode'.tr,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: cs.onSurface.withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    ctrl.roomCode.value ?? '------',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10,
                          color: cs.primary,
                        ),
                  )),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: ctrl.copyCode,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text('ltCopyCode'.tr),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline_rounded,
                          size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${ctrl.membersOnline.value} ${'ltOnline'.tr}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Currently playing ─────────────────────────────────────────
        _NowPlayingCard(),
        const SizedBox(height: 20),

        // ── Sync status ───────────────────────────────────────────────
        _InfoTile(
          icon: Icons.sync_rounded,
          title: 'ltSyncStatus'.tr,
          subtitle: 'ltAutoSync5s'.tr,
        ),
        const SizedBox(height: 16),

        // ── End session ───────────────────────────────────────────────
        OutlinedButton.icon(
          onPressed: ctrl.leaveRoom,
          icon: const Icon(Icons.stop_circle_outlined),
          label: Text('ltEndSession'.tr),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.error,
            side: BorderSide(color: cs.error.withOpacity(0.5)),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Guest view — in room as guest
// ─────────────────────────────────────────────────────────────────────────────

class _GuestView extends StatelessWidget {
  const _GuestView({required this.ctrl});
  final ListenTogetherController ctrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 200),
      children: [
        // ── Room info card ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.tertiaryContainer,
                cs.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.headphones_rounded,
                      color: cs.tertiary, size: 20),
                  const SizedBox(width: 8),
                  Text('ltListeningWith'.tr,
                      style: TextStyle(
                          color: cs.tertiary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'ltRoom'.tr,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: cs.onSurface.withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    ctrl.roomCode.value ?? '------',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10,
                          color: cs.tertiary,
                        ),
                  )),
              const SizedBox(height: 12),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline_rounded,
                          size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${ctrl.membersOnline.value} ${'ltOnline'.tr}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Host's current song ───────────────────────────────────────
        Obx(() {
          final sync = ctrl.lastSync.value;
          if (sync == null) {
            return _InfoTile(
              icon: Icons.hourglass_empty_rounded,
              title: 'ltWaitingForHost'.tr,
              subtitle: 'ltWaitingDesc'.tr,
            );
          }
          return _SyncSongCard(sync: sync);
        }),
        const SizedBox(height: 16),

        // ── Auto-sync toggle ──────────────────────────────────────────
        Obx(() => SwitchListTile.adaptive(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              tileColor: cs.surfaceContainerHighest.withOpacity(0.4),
              title: Text('ltAutoSync'.tr),
              subtitle: Text('ltAutoSyncDesc'.tr),
              value: ctrl.autoSync.value,
              onChanged: (v) => ctrl.autoSync.value = v,
            )),
        const SizedBox(height: 14),

        // ── Sync Now button ───────────────────────────────────────────
        FilledButton.tonal(
          onPressed: ctrl.syncNow,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sync_rounded),
              const SizedBox(width: 8),
              Text('ltSyncNow'.tr),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Leave session ─────────────────────────────────────────────
        OutlinedButton.icon(
          onPressed: ctrl.leaveRoom,
          icon: const Icon(Icons.logout_rounded),
          label: Text('ltLeaveSession'.tr),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.error,
            side: BorderSide(color: cs.error.withOpacity(0.5)),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the host's currently playing song (pulled live from PlayerController).
class _NowPlayingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<_PlayerObserver>(
      init: _PlayerObserver(),
      builder: (obs) {
        final song = obs.songTitle.value;
        if (song.isEmpty) {
          return _InfoTile(
            icon: Icons.music_note_rounded,
            title: 'ltNothingPlaying'.tr,
            subtitle: 'ltNothingPlayingDesc'.tr,
          );
        }
        final cs = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              obs.thumbnailUrl.value.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: obs.thumbnailUrl.value,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _FallbackThumb(size: 56),
                      ),
                    )
                  : _FallbackThumb(size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (obs.songArtist.value.isNotEmpty)
                      Text(obs.songArtist.value,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                obs.isPlaying.value
                    ? Icons.play_circle_rounded
                    : Icons.pause_circle_rounded,
                color: cs.primary,
                size: 32,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Lightweight GetxController that reads PlayerController state reactively.
class _PlayerObserver extends GetxController {
  final songTitle = ''.obs;
  final songArtist = ''.obs;
  final thumbnailUrl = ''.obs;
  final isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    _sync();
    ever(Get.find<PlayerController>().currentSong, (_) => _sync());
    ever(Get.find<PlayerController>().buttonState, (_) => _sync());
  }

  void _sync() {
    try {
      final p = Get.find<PlayerController>();
      final song = p.currentSong.value;
      songTitle.value = song?.title ?? '';
      songArtist.value = song?.artist ?? '';
      thumbnailUrl.value = song?.artUri?.toString() ?? '';
      isPlaying.value = p.buttonState.value == PlayButtonState.playing;
    } catch (_) {}
  }
}

/// Shows what the host is currently broadcasting (for guest view).
class _SyncSongCard extends StatelessWidget {
  const _SyncSongCard({required this.sync});
  final SyncPayload sync;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final position =
        Duration(milliseconds: sync.positionMs);
    final total = Duration(milliseconds: sync.durationMs);
    final progress =
        total.inMilliseconds > 0
            ? (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: sync.thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: sync.thumbnailUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _FallbackThumb(size: 56),
                      )
                    : _FallbackThumb(size: 56),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sync.songTitle.isNotEmpty
                          ? sync.songTitle
                          : 'ltUnknownSong'.tr,
                      style:
                          Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sync.songArtist.isNotEmpty)
                      Text(
                        sync.songArtist,
                        style:
                            Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                sync.isPlaying
                    ? Icons.play_circle_rounded
                    : Icons.pause_circle_rounded,
                color: cs.primary,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: cs.outline.withOpacity(0.2),
              color: cs.primary,
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(position),
                  style: Theme.of(context).textTheme.labelSmall),
              Text(_fmt(total),
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _FallbackThumb extends StatelessWidget {
  const _FallbackThumb({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.music_note_rounded,
          color: Theme.of(context).colorScheme.primary, size: size * 0.5),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        Theme.of(context).textTheme.titleSmall),
                Text(subtitle,
                    style:
                        Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.steps});
  final List<_Step> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'ltHowItWorks'.tr,
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
          ),
        ),
        ...steps.asMap().entries.map((e) {
          final idx = e.key;
          final step = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  child: Text('${idx + 1}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Icon(step.icon,
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .primary),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(step.text,
                        style:
                            Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Step {
  const _Step({required this.icon, required this.text});
  final IconData icon;
  final String text;
}
