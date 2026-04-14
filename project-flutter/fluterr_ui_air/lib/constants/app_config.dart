/// Konfigurasi endpoint FastAPI Siram Pintar.
///
/// **Kenapa tampil Offline?**
/// - Aplikasi memanggil `GET {apiBaseUrl}/status`. Jika ini **500** / timeout,
///   beranda menampilkan error — meskipun `GET /` kadang masih 200.
/// - Penyebab umum di backend: koneksi **MySQL** gagal (env `DB_*` salah,
///   Hostinger tidak mengizinkan IP Vercel, firewall, SSL DB, dll.).
///
/// **Ganti URL tanpa edit file (disarankan untuk uji cepat):**
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://domain-anda.com
/// ```
///
/// Atur `defaultValue` di bawah ke URL FastAPI Anda (tanpa `/` di akhir).
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Ganti ke URL API produksi Anda (contoh Hostinger + uvicorn / reverse proxy)
    defaultValue: 'https://ml-api-flax.vercel.app',
  );
}
