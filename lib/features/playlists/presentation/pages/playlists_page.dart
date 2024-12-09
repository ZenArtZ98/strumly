import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
// import '../models/playlist.dart';
// import '../models/song.dart';
import '../widgets/playlist_card.dart';
import 'playlist_page.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({Key? key}) : super(key: key);

  // Открытие диалогового окна для добавления по Email
  void _showImportDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Добавление избранного'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Введите электронную почту Яндекса:'),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  await _importPlaylistsFromEmail(context, email); // Импорт по Email
                }
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Импортировать'),
            ),
          ],
        );
      },
    );
  }

  // Открытие диалогового окна для добавления по URL
  void _showAddPlaylistDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Добавление плейлиста'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Вставьте ссылку на ваш плейлист:'),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  await _importPlaylistFromUrl(context, url); // Импорт по URL
                }
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  // Импорт плейлистов по Email
  Future<void> _importPlaylistsFromEmail(BuildContext context, String email) async {
    try {
      final username = email.split('@').first;
      final url =
          'https://music.yandex.ru/handlers/playlist.jsx?owner=$username&kinds=3';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null || data['playlist'] == null || data['playlist']['tracks'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Плейлисты не найдены для этого пользователя')),
          );
          return;
        }

        final playlistData = data['playlist'];
        final tracks = playlistData['tracks'] as List<dynamic>;

        final songs = tracks.map((track) {
          return Song(
            title: track['title'] ?? 'Без названия',
            artist: track['artists']?[0]['name'] ?? 'Без артиста',
          );
        }).toList();

        final playlist = Playlist(
          title: playlistData['title'] ?? 'Без названия',
          description: playlistData['description'] ?? 'Описание отсутствует',
          songs: songs,
        );

        context.read<PlaylistProvider>().addPlaylists(playlist);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Плейлист успешно импортирован!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка импорта: $e')),
      );
    }
  }

  // Импорт плейлистов по URL
  Future<void> _importPlaylistFromUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      if (segments.length < 4 || segments[0] != 'users' || segments[2] != 'playlists') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Неверный формат ссылки')),
        );
        return;
      }

      final owner = segments[1];
      final kinds = segments[3];

      final apiUrl =
          'https://music.yandex.ru/handlers/playlist.jsx?owner=$owner&kinds=$kinds';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null || data['playlist'] == null || data['playlist']['tracks'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Плейлист не найден')),
          );
          return;
        }

        final playlistData = data['playlist'];
        final tracks = playlistData['tracks'] as List<dynamic>;

        final songs = tracks.map((track) {
          return Song(
            title: track['title'] ?? 'Без названия',
            artist: track['artists']?[0]['name'] ?? 'Без артиста',
          );
        }).toList();

        final playlist = Playlist(
          title: playlistData['title'] ?? 'Без названия',
          description: playlistData['description'] ?? 'Описание отсутствует',
          songs: songs,
        );

        context.read<PlaylistProvider>().addPlaylists(playlist);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Плейлист успешно добавлен!')),
        );
      } else {
        print('Owner: $owner');
        print('Kinds: $kinds');
        print('API URL: $apiUrl');
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки, проверьте публичность плейлиста')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistProvider>().playlists;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои плейлисты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddPlaylistDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              _showImportDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistPage(
                      playlistTitle: playlist.title,
                      playlistDescription: playlist.description,
                      playlistIndex: index,
                    ),
                  ),
                );
              },
              child: PlaylistCard(
                title: playlist.title,
                author: playlist.description,
              ),
            );
          },
        ),
      ),
    );
  }
}
