import 'package:flutter/material.dart';

class Song {
  final String title;
  final String artist;

  Song({required this.title, required this.artist});
}

class Playlist {
  final String title;
  final String description;
  final List<Song> songs;

  Playlist({
    required this.title,
    required this.description,
    this.songs = const [],
  });
}

class PlaylistProvider with ChangeNotifier {
  final List<Playlist> _playlists = [
    Playlist(
      title: 'Облако в штанах',
      description: 'План Ломоносова',
      songs: [
        Song(
          title: 'Back in The Day',
          artist: 'Megadeth',
        ), // Добавляем песню в первый плейлист
      ],
    ),
    Playlist(
      title: 'The Fat of The Land',
      description: 'The Prodigy',
    ),
  ];

  List<Playlist> get playlists => _playlists;

  void addPlaylist(String title, String description) {
    _playlists.add(Playlist(title: title, description: description));
    notifyListeners();
  }

  void addSongToPlaylist(int playlistIndex, Song song) {
    _playlists[playlistIndex].songs.add(song);
    notifyListeners();
  }

  void addPlaylists(Playlist playlist) {
    _playlists.add(playlist);
    notifyListeners();
  }
}
