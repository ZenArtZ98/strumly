import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strumly/features/songs/presentation/pages/song_details_page.dart';
import '../providers/playlist_provider.dart';
import 'package:strumly/features/common/widgets/drawer_menu.dart';


class PlaylistPage extends StatelessWidget {
  final String playlistTitle;
  final String playlistDescription;
  final int playlistIndex;

  const PlaylistPage({
    Key? key,
    required this.playlistTitle,
    required this.playlistDescription,
    required this.playlistIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playlist = context.watch<PlaylistProvider>().playlists[playlistIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(playlistTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DrawerMenu(), // Подключаем меню
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок плейлиста и описание
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.image, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    playlistTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    playlistDescription,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Список песен в сетке
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: playlist.songs.length,
                itemBuilder: (context, index) {
                  final song = playlist.songs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongDetailsPage(
                            songTitle: song.title,
                            artist: song.artist,
                            views: 1000000, // Примерное количество просмотров
                            difficulty: 4.5, // Примерная сложность
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blueAccent,
                              child: Icon(Icons.music_note, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              song.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
