// ═══════════════════════════════════════════════════════════════════════════
// PATCH — tempel ke sketch Siram Pintar Anda
//
// Masalah: pompa hanya mengikuti pump_action dari POST /sensor saat mode AUTO.
// Backend jadwal / app mengatur pump_status lewat DB tanpa pump_action → relay
// tidak ikut.
//
// Perbaikan:
// 1) Setelah POST /sensor sukses: jika tidak ada pump_action, ikuti pump_status.
// 2) (Sangat disarankan) Poll GET /status agar tidak tunggu 5 menit (API_INTERVAL).
// ═══════════════════════════════════════════════════════════════════════════

// ── Tambah di atas loop() / dengan variabel global timing lain ─────────────
unsigned long lastStatusPoll = 0;
const unsigned long STATUS_POLL_INTERVAL = 20000UL; // 20 detik

// ── Tambah fungsi ini (mis. setelah sendControlToAPI) ─────────────────────
void pollStatusFromServer() {
  if (WiFi.status() != WL_CONNECTED) return;
  if (ESP.getFreeHeap() < 25000) return;

  WiFiClientSecure* client = new WiFiClientSecure();
  client->setInsecure();
  client->setTimeout(12);

  HTTPClient http;
  http.setTimeout(12000);
  http.begin(*client, String(API_BASE_URL) + "/status");
  int code = http.GET();
  if (code == 200) {
    String response = http.getString();
    JsonDocument doc;
    if (!deserializeJson(doc, response)) {
      bool serverPump = doc["pump_status"] | false;
      String serverMode = doc["mode"] | "auto";

      // Saat ESP di AUTO, selalu ikuti server (auto / schedule / manual dari app).
      if (mode == AUTO) {
        setPump(serverPump);
        (void)serverMode; // bisa dipakai untuk OLED nanti
      }
    }
  }
  http.end();
  delete client;
}

/*
  Di dalam sendToAPI(), ganti blok:

        if (mode == AUTO) {
          String action = res["pump_action"].as<String>();
          if (action == "on")  setPump(true);
          if (action == "off") setPump(false);
        }

  menjadi:

        if (mode == AUTO) {
          String action = res["pump_action"].as<String>();
          if (action == "on") {
            setPump(true);
          } else if (action == "off") {
            setPump(false);
          } else {
            // Jadwal / kontrol app mengubah DB tanpa pump_action (mis. mode schedule).
            bool ps = res["pump_status"] | false;
            setPump(ps);
          }
        }

  (pump_status selalu ada di JSON respons POST /sensor versi FastAPI Anda.)
*/

/*
  Di loop(), tambahkan misalnya setelah blok kirim API:

  if (now - lastStatusPoll >= STATUS_POLL_INTERVAL) {
    lastStatusPoll = now;
    if (wifiConnected) pollStatusFromServer();
  }

  Ini membuat pompa mengikuti server dalam hitungan detik, bukan menunggu
  API_INTERVAL 5 menit.
*/
