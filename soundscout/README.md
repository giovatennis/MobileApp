# SoundScout

A mobile app for discovering music by genre and building your own personal, rated music library.

## Concept

SoundScout lets you browse music by genre, read a short write-up of what defines that genre, and check out the albums currently charting in it. When you find something worth remembering, you rate it (1–5 stars), optionally write a short review, tag it with the genre you discovered it under, and save it to your library. Your library is fully yours — filterable, sortable, editable — and a Stats screen visualizes your own rating habits (average rating per genre, rating distribution, and how your listening/logging activity trends over time).

There is no backend and no account system. All catalog data (genres, charts, search, album/tracklist detail) comes from the free, public [Deezer API](https://developers.deezer.com/) — no API key required. Everything you personally do in the app (ratings, reviews, saved albums) is stored **locally on your device** in a SQLite database.

## Platform

Flutter (Dart), targeting Android and iOS from a single codebase.

## Main Features

- **Discover — Popular Genres** — browse Deezer's broad top-level genres as a grid, tap into one to see a written description plus its current chart albums
- **Discover — Niche & Deep Cuts** — a hand-curated set of ~18 niche genres that Deezer's own genre list doesn't expose. Each has a written description and a handful of well-known seed albums that are resolved live against Deezer's search endpoint for real cover art and IDs
- **Search** — direct search by artist or album name
- **Album Detail** — cover art, tracklist, release info, star rating input, optional review text, genre tagging, save/update/remove from library
- **My Library** — everything you've saved, filterable by genre and sortable by date added, rating, or title; swipe to delete
- **Stats** (advanced feature) — charts (via `fl_chart`) showing your average rating per genre, your rating distribution, and albums logged over time, plus a summary card
- Loading, empty, and error states are handled throughout (e.g. no internet, no search results, empty library, no genre description available)

## Architecture

```
lib/
  models/        Genre, NicheGenre, AlbumSeed, Album, Track, LibraryEntry, LoadStatus
  services/      DeezerApiService (network + niche-seed resolution),
                  DatabaseService (SQLite), GenreDescriptionService,
                  NicheGenreService (local JSON assets)
  providers/     DiscoverProvider, SearchProvider, LibraryProvider
                  (ChangeNotifier + the `provider` package)
  screens/       discover/ (broad + niche), search/, album/, library/, stats/
  widgets/       AlbumCard, GenreChip, NicheGenreChip, StarRating,
                  Loading/Empty/ErrorState
assets/
  genre_descriptions.json   curated write-ups for Deezer's broad genres
                             (Deezer has no genre description field)
  niche_genres.json         curated niche genres + seed albums (Deezer has
                             no way to browse genres this specific at all)
```

State management uses the `provider` package. Each provider owns one concern: `DiscoverProvider` (broad genres + genre charts, plus niche genres + their resolved seed albums), `SearchProvider` (search query/results), and `LibraryProvider` (all local CRUD + the derived data the Stats screen charts).

## Setup Instructions

This project was authored as source files without running the Flutter CLI, so it doesn't yet include the generated native platform folders (`android/`, `ios/`, etc.). To get those, run `flutter create` **inside this folder** — it's designed to add a Flutter project to an existing folder:

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) if you haven't already, and confirm your setup with `flutter doctor`.
2. From inside the `soundscout/` folder, run:
   ```
   flutter create .
   ```
   This generates `android/`, `ios/`, and the other platform folders around the existing source.
3. **Android only** — open `android/app/src/main/AndroidManifest.xml` and make sure it includes internet permission, since Flutter's default *main* manifest (unlike the debug one) doesn't add it automatically:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```
   Add that line as a direct child of `<manifest>`, above the `<application>` tag. Without it, network requests to Deezer will fail on real/release builds.
4. Install dependencies:
   ```
   flutter pub get
   ```
5. Run the app on a connected device or emulator:
   ```
   flutter run
   ```

## App Name and Icon

The app is named **SoundScout** and uses a purple vinyl icon (`assets/icon/icon.svg`). 

## How to Run

- Make sure a device or emulator is running (`flutter devices` to check), then `flutter run` from the project root.
- No API keys, accounts, or environment variables are needed — the app talks directly to Deezer's public read-only API.
- On first launch, Discover fetches the genre list and Library loads (empty at first) — both need network access once for genres/charts; your saved ratings work fully offline afterward since they're local.

## Notes / Known Limitations

- Genre names returned by Deezer's `/genre` endpoint can vary slightly; any genre without a matching entry in `assets/genre_descriptions.json` falls back to a generic description rather than breaking.
- The rating scale is a simple 1–5 integer star rating (no half-stars), by design, to keep the interaction simple and reliable.
- A handful of niche-genre seed albums (particularly rarer picks like some Shibuya-kei or vaporwave titles) may occasionally not resolve on Deezer's catalog — the app handles this  by simply omitting that album rather than erroring.


## Video Demo

Youtube link: https://www.youtube.com/watch?v=WUZe0rWcZ_4
