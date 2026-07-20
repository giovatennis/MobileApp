import 'package:flutter/foundation.dart';

import '../models/album.dart';
import '../models/load_status.dart';
import '../services/deezer_api_service.dart';

/// State for the Search tab: current query, results, and load state.
class SearchProvider extends ChangeNotifier {
  SearchProvider({DeezerApiService? api}) : _api = api ?? DeezerApiService();

  final DeezerApiService _api;

  String query = '';
  List<Album> results = [];
  LoadStatus status = LoadStatus.idle;
  String? error;

  Future<void> search(String rawQuery) async {
    final q = rawQuery.trim();
    query = rawQuery;

    if (q.isEmpty) {
      results = [];
      status = LoadStatus.idle;
      error = null;
      notifyListeners();
      return;
    }

    status = LoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      results = await _api.searchAlbums(q);
      status = LoadStatus.loaded;
    } catch (e) {
      error = e.toString();
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
