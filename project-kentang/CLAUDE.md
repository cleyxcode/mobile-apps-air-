# Potato Disease Detection — Full Stack Project

## Project Overview
Aplikasi web full-stack untuk mendeteksi penyakit daun kentang menggunakan AI (EfficientNetB3).
User upload foto daun kentang → Frontend kirim ke Backend → Backend jalankan model AI → Tampilkan hasil prediksi.

---

## Struktur Project
```
PROJECT-KENTANG/
├── potato-disease-ap-node/        ← Backend (Node.js + Express)
│   ├── model/
│   │   ├── config.json            ← Arsitektur model Keras
│   │   ├── metadata.json          ← Metadata Keras
│   │   └── model.weights.h5       ← Bobot hasil training
│   ├── uploads/                   ← Temporary folder gambar upload
│   ├── index.js                   ← Entry point API server
│   ├── .env                       ← Environment variables
│   ├── package.json
│   └── node_modules/
│
└── potato-disease-frontend/       ← Frontend (React + Vite)
    ├── src/
    │   ├── App.jsx                ← Root component
    │   ├── main.jsx               ← Entry point React
    │   └── assets/
    ├── public/
    ├── .gitignore
    ├── package.json
    └── node_modules/
```

---

## Tech Stack

### Backend (`potato-disease-ap-node`)
| Package | Versi | Fungsi |
|---|---|---|
| Node.js | v24 | Runtime |
| Express | latest | Web framework |
| @tensorflow/tfjs-node | 4.22.0 | Load & jalankan model AI |
| Multer | latest | Handle upload gambar |
| CORS | latest | Izinkan request dari frontend |
| dotenv | latest | Environment variables |

### Frontend (`potato-disease-frontend`)
| Package | Versi | Fungsi |
|---|---|---|
| React | latest | UI framework |
| Vite | latest | Build tool |
| Axios | latest | HTTP request ke backend |

---

## Backend API

### Base URL
```
http://localhost:3000
```

### Endpoints

#### `GET /`
Health check server.
```json
{
  "status": "✅ Server berjalan!",
  "message": "Potato Disease Detection API"
}
```

#### `POST /predict`
Upload gambar daun kentang, dapatkan hasil prediksi penyakit.

**Request:** `multipart/form-data`
- Field: `image` (file jpg/png)

**Response:**
```json
{
  "class": "Early Blight",
  "confidence": "95.23%",
  "all_predictions": {
    "Early Blight": "95.23%",
    "Late Blight": "3.12%",
    "Healthy": "1.65%"
  }
}
```

---

## Model AI

- **Arsitektur:** EfficientNetB3 (fine-tuned dengan transfer learning)
- **Input:** Gambar 300x300 pixel, RGB, dinormalisasi 0-1
- **Output:** 3 kelas
  - `Early Blight` (index 0) → Penyakit bercak daun awal, jamur *Alternaria solani*
  - `Late Blight` (index 1) → Penyakit busuk daun, jamur *Phytophthora*
  - `Healthy` (index 2) → Tanaman sehat
- **Akurasi:** ~97% validation accuracy
- **Dataset:** PlantVillage (2.152 gambar)
- **Format:** Keras `.keras` (folder berisi config.json + model.weights.h5)

---

## Cara Menjalankan

### 1. Jalankan Backend
```bash
cd potato-disease-ap-node
node index.js
# Server berjalan di http://localhost:3000
```

### 2. Jalankan Frontend
```bash
cd potato-disease-frontend
npm run dev
# App berjalan di http://localhost:5173
```

---

## Koneksi Frontend → Backend

### CORS (sudah dikonfigurasi di backend)
```javascript
// index.js
app.use(cors()); // Mengizinkan request dari http://localhost:5173
```

### Cara Frontend Kirim Gambar ke Backend (Axios)
```javascript
import axios from 'axios';

const predictDisease = async (imageFile) => {
  const formData = new FormData();
  formData.append('image', imageFile);

  const response = await axios.post('http://localhost:3000/predict', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });

  return response.data;
  // { class, confidence, all_predictions }
};
```

---

## Environment Variables

### Backend `.env`
```
PORT=3000
```

### Frontend `.env`
```
VITE_API_URL=http://localhost:3000
```

Cara pakai di React:
```javascript
const API_URL = import.meta.env.VITE_API_URL;
```

---

## Alur Kerja Aplikasi

```
User buka browser (localhost:5173)
    ↓
Upload foto daun kentang
    ↓
React kirim POST ke localhost:3000/predict
    ↓
Express terima gambar → Multer simpan sementara
    ↓
TensorFlow load gambar → resize 300x300 → normalize
    ↓
Model EfficientNetB3 prediksi
    ↓
Return JSON { class, confidence, all_predictions }
    ↓
React tampilkan hasil ke user
```

---

## Yang Perlu Dibangun

### Backend (`potato-disease-ap-node/index.js`)
- [x] Load model TensorFlow
- [x] Endpoint POST /predict
- [x] Handle upload gambar dengan Multer
- [x] Preprocessing gambar (resize 300x300, normalize)
- [ ] Validasi tipe file (hanya jpg/png)
- [ ] Validasi ukuran file (max 5MB)
- [ ] Error handling lebih baik
- [ ] Logging dengan Morgan

### Frontend (`potato-disease-frontend/src/`)
- [ ] `App.jsx` — Layout utama
- [ ] Komponen upload gambar (drag & drop atau klik)
- [ ] Preview gambar sebelum dikirim
- [ ] Loading state saat prediksi berjalan
- [ ] Tampilan hasil prediksi (nama penyakit + confidence)
- [ ] Bar chart persentase semua kelas
- [ ] Handling error (gambar gagal, server mati, dll)

---

## Catatan Penting
- Jangan jalankan `npm audit fix --force` pada backend karena akan downgrade `@tensorflow/tfjs-node`
- Model harus ada di `potato-disease-ap-node/model/` sebelum backend dijalankan
- Backend harus jalan di port 3000 sebelum frontend bisa prediksi
- File gambar di folder `uploads/` otomatis dihapus setelah prediksi selesai