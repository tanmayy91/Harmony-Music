import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/models/album.dart';
import '../navigator.dart';
import 'image_widget.dart';

class ContentListItem extends StatelessWidget {
  const ContentListItem(
      {super.key, required this.content, this.isLibraryItem = false});

  ///content will be of Type class Album or Playlist
  final dynamic content;
  final bool isLibraryItem;

  @override
  Widget build(BuildContext context) {
    final isAlbum = content is Album;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (isAlbum) {
          Get.toNamed(ScreenNavigationSetup.albumScreen,
              id: ScreenNavigationSetup.id, arguments:(content, content.browseId));
          return;
        }
        Get.toNamed(ScreenNavigationSetup.playlistScreen,
            id: ScreenNavigationSetup.id,
            arguments: [content, content.playlistId]);
      },
      child: Container(
        width: 148,
        height: 210,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isAlbum
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ImageWidget(
                      size: 140,
                      album: content,
                    ),
                  )
                : content.isCloudPlaylist ||
                        !(content.playlistId == 'LIBRP' ||
                            content.playlistId == 'LIBFAV' ||
                            content.playlistId == 'SongsCache' ||
                            content.playlistId == 'SongDownloads')
                    ? SizedBox.square(
                        dimension: 140,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: ImageWidget(
                                size: 140,
                                playlist: content,
                              ),
                            ),
                            if (content.isPipedPlaylist)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.85),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "P",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )),
                                  ),
                                ),
                              ),
                            if (!content.isCloudPlaylist)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.85),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "L",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )),
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                    : Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.circular(14)),
                        child: Center(
                            child: Icon(
                          content.playlistId == 'LIBRP'
                              ? Icons.history_rounded
                              : content.playlistId == 'LIBFAV'
                                  ? Icons.favorite_rounded
                                  : content.playlistId == 'SongsCache'
                                      ? Icons.flight_rounded
                                      : Icons.download_rounded,
                          color: Colors.white,
                          size: 36,
                        ))),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAlbum
                        ? isLibraryItem
                            ? ""
                            : "${content.artists[0]['name'] ?? ""} | ${content.year ?? ""}"
                        : isLibraryItem
                            ? ""
                            : content.description ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
