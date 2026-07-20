import 'package:flutter/foundation.dart';

import '../models/album.dart';
import '../models/genre.dart';
import '../models/load_status.dart';
import '../models/niche_genre.dart';
import '../services/deezer_api_service.dart';
import '../services/genre_description_service.dart';
import '../services/niche_genre_service.dart';

/// State for the Discover tab: Deezer's broad top-level genres (with
/// descriptions and chart albums), plus a curated set of niche/deep-cut
/// genres that Deezer's own genre list doesn't cover.
class DiscoverProvider extends ChangeNotifier {
  DiscoverProvider({
    DeezerApiService? api,
    GenreDescriptionService? descriptionService,
    NicheGenreService? nicheGenreService,
  })  : _api = api ?? DeezerApiService(),
        _descriptionService = descriptionService ?? GenreDescriptionService(),
        _nicheGenreService = nicheGenreService ?? NicheGenreService();

  final DeezerApiService _api;
  final GenreDescriptionService _descriptionService;
  final NicheGenreService _nicheGenreService;
  Map<String, String> _descriptions = {};

  /// Broad Deezer genres hidden from the Popular Genres section, by user
  /// preference. Matched as a case-insensitive substring against whatever
  /// name Deezer's API actually returns, since exact naming (e.g. "Latin"
  /// vs "Latin music") can vary and this way covers either.
  static const List<String> _excludedGenreKeywords = [
    'christian',
    'mexican',
    'african',
    'asian',
    'brazilian',
    'indian',
    'latin',
    'kids',
    'cumbia',
  ];

  bool _isExcludedGenre(String name) {
    final lower = name.toLowerCase();
    return _excludedGenreKeywords.any(lower.contains);
  }

  // ---- Broad (Deezer-provided) genres ----

  List<Genre> genres = [];
  LoadStatus genresStatus = LoadStatus.idle;
  String? genresError;

  Genre? selectedGenre;
  List<Album> chartAlbums = [];
  LoadStatus chartStatus = LoadStatus.idle;
  String? chartError;

  Future<void> loadGenres() async {
    genresStatus = LoadStatus.loading;
    genresError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.getGenres(),
        _descriptionService.loadDescriptions(),
      ]);
      genres = (results[0] as List<Genre>).where((g) => !_isExcludedGenre(g.name)).toList();
      _descriptions = results[1] as Map<String, String>;
      genresStatus = LoadStatus.loaded;
    } catch (e) {
      genresError = e.toString();
      genresStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  String descriptionFor(Genre genre) => _descriptionService.describe(_descriptions, genre.name);

  Future<void> selectGenre(Genre genre) async {
    selectedGenre = genre;
    chartAlbums = [];
    chartStatus = LoadStatus.loading;
    chartError = null;
    notifyListeners();
    try {
      chartAlbums = await _api.getGenreChartAlbums(genre.id);
      chartStatus = LoadStatus.loaded;
    } catch (e) {
      chartError = e.toString();
      chartStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  // ---- Niche / curated genres ----

  List<NicheGenre> nicheGenres = [];
  LoadStatus nicheGenresStatus = LoadStatus.idle;
  String? nicheGenresError;

  NicheGenre? selectedNicheGenre;
  List<Album> nicheAlbums = [];
  LoadStatus nicheAlbumsStatus = LoadStatus.idle;
  String? nicheAlbumsError;

  Future<void> loadNicheGenres() async {
    nicheGenresStatus = LoadStatus.loading;
    nicheGenresError = null;
    notifyListeners();
    try {
      nicheGenres = await _nicheGenreService.loadNicheGenres();
      nicheGenresStatus = LoadStatus.loaded;
    } catch (e) {
      nicheGenresError = e.toString();
      nicheGenresStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> selectNicheGenre(NicheGenre genre) async {
    selectedNicheGenre = genre;
    nicheAlbums = [];
    nicheAlbumsStatus = LoadStatus.loading;
    nicheAlbumsError = null;
    notifyListeners();
    try {
      final resolved = await Future.wait(
        genre.seeds.map((seed) => _api.resolveSeedAlbum(seed.artist, seed.album)),
      );
      nicheAlbums = resolved.whereType<Album>().toList();
      nicheAlbumsStatus = LoadStatus.loaded;
    } catch (e) {
      nicheAlbumsError = e.toString();
      nicheAlbumsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Broad + niche genre names combined, deduplicated and sorted — used to
  /// populate the genre-tagging dropdown on the Album Detail screen so a
  /// niche genre discovered here can still be selected there.
  List<String> get allGenreNames {
    final set = <String>{
      ...genres.map((g) => g.name),
      ...nicheGenres.map((n) => n.name),
    };
    final list = set.toList();
    list.sort();
    return list;
  }
}
