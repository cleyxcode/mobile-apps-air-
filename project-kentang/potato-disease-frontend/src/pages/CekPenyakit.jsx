import { useState, useRef, useCallback } from 'react';
import axios from 'axios';
import { motion, AnimatePresence } from 'framer-motion';
import Lottie from 'lottie-react';
import { toast } from 'react-toastify';
import SplitText from '../components/SplitText';
import RotatingText from '../components/RotatingText';
import ElectricBorder from '../components/ElectricBorder';

import loadingAnim from '../animations/loading.json';
import successAnim from '../animations/success.json';
import errorAnim from '../animations/error.json';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

const CLASS_INFO = {
  'Early Blight': {
    emoji: '🍂',
    badge: 'Warning',
    badgeColor: 'bg-orange-900/50 text-orange-400',
    desc: 'Penyakit bercak daun awal, disebabkan jamur Alternaria solani.',
    color: '#f97316',
    barColor: 'bg-orange-400',
    recommendations: [
      'Gunakan fungisida yang mengandung tembaga untuk mengendalikan penyebaran.',
      'Pastikan rotasi tanaman yang baik dan bersihkan sisa-sisa tanaman yang terinfeksi.',
      'Tingkatkan sirkulasi udara di sekitar tanaman.',
    ],
  },
  'Late Blight': {
    emoji: '🟫',
    badge: 'Critical',
    badgeColor: 'bg-red-900/50 text-red-400',
    desc: 'Penyakit busuk daun, disebabkan Phytophthora infestans. Sangat berbahaya!',
    color: '#ef4444',
    barColor: 'bg-red-500',
    recommendations: [
      'Segera aplikasikan fungisida sistemik (metalaksil) sebelum penyebaran meluas.',
      'Hindari penyiraman berlebih dan pastikan drainase berfungsi baik.',
      'Musnahkan tanaman terinfeksi untuk mencegah penyebaran ke area lain.',
    ],
  },
  Healthy: {
    emoji: '🌿',
    badge: 'Sehat',
    badgeColor: 'bg-primary/20 text-primary',
    desc: 'Tanaman terlihat sehat, tidak ada tanda penyakit.',
    color: '#4cae7d',
    barColor: 'bg-primary',
    recommendations: [
      'Pertahankan kondisi optimal dengan nutrisi tanah yang seimbang.',
      'Lakukan pemeriksaan rutin untuk deteksi dini potensi penyakit.',
      'Jaga jarak tanam yang cukup untuk sirkulasi udara optimal.',
    ],
  },
};

const fadeUp = {
  hidden: { opacity: 0, y: 30 },
  show: { opacity: 1, y: 0, transition: { duration: 0.4, ease: 'easeOut' } },
  exit: { opacity: 0, y: -20, transition: { duration: 0.25 } },
};

export default function CekPenyakit() {
  const [image, setImage] = useState(null);
  const [preview, setPreview] = useState(null);
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [showError, setShowError] = useState(false);
  const [dragging, setDragging] = useState(false);
  const inputRef = useRef();

  const handleFile = (file) => {
    if (!file) return;
    if (!['image/jpeg', 'image/png'].includes(file.type)) {
      toast.error('❌ Hanya file JPG/PNG yang diizinkan!');
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      toast.error('❌ Ukuran file maksimal 5MB!');
      return;
    }
    setResult(null);
    setShowError(false);
    setImage(file);
    setPreview(URL.createObjectURL(file));
    toast.success('✅ Gambar berhasil dipilih!');
  };

  const onInputChange = (e) => handleFile(e.target.files[0]);

  const onDrop = useCallback((e) => {
    e.preventDefault();
    setDragging(false);
    handleFile(e.dataTransfer.files[0]);
  }, []);

  const handlePredict = async () => {
    if (!image) return;
    setLoading(true);
    setResult(null);
    setShowError(false);
    const formData = new FormData();
    formData.append('image', image);
    try {
      const res = await axios.post(`${API_URL}/predict`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
        timeout: 30000,
      });
      setResult(res.data);
      toast.success(`🎯 Prediksi selesai: ${res.data.class}`);
    } catch (err) {
      setShowError(true);
      if (err.code === 'ECONNABORTED') toast.error('⏱️ Timeout! Pastikan backend berjalan.');
      else if (err.response) toast.error(`❌ ${err.response.data?.detail || 'Gagal mendapat hasil.'}`);
      else toast.error('🔌 Tidak bisa terhubung ke server.');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setImage(null);
    setPreview(null);
    setResult(null);
    setShowError(false);
    if (inputRef.current) inputRef.current.value = '';
  };

  const classInfo = result ? CLASS_INFO[result.class] : null;

  return (
    <div className="flex-1">
      {/* Header */}
      <section className="bg-brand-dark px-4 sm:px-6 py-10 sm:py-14">
        <div className="mx-auto max-w-7xl">
          <motion.div initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }}>
            <span className="inline-flex items-center gap-2 rounded-full bg-primary/20 px-3 sm:px-4 py-1.5 text-xs sm:text-sm font-medium text-primary mb-4">
              🔍 Deteksi ·{' '}
              <RotatingText
                texts={['Early Blight', 'Late Blight', 'Healthy']}
                mainClassName="font-bold text-white"
                splitLevelClassName="overflow-hidden"
                staggerFrom="last"
                initial={{ y: '100%' }}
                animate={{ y: 0 }}
                exit={{ y: '-120%' }}
                staggerDuration={0.025}
                transition={{ type: 'spring', damping: 30, stiffness: 400 }}
                rotationInterval={2000}
                splitBy="words"
              />
            </span>

            <SplitText
              text="Cek Penyakit Tanaman"
              tag="h1"
              className="text-3xl sm:text-4xl font-bold text-white md:text-5xl"
              delay={30}
              duration={0.9}
              ease="power3.out"
              splitType="words"
              from={{ opacity: 0, y: 40 }}
              to={{ opacity: 1, y: 0 }}
              threshold={0}
              rootMargin="0px"
              textAlign="left"
            />

            <motion.p
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5 }}
              className="mt-3 sm:mt-4 text-white/60 text-sm sm:text-lg max-w-2xl"
            >
              Unggah foto daun kentang Anda. AI kami akan menganalisis gejala dan memberikan diagnosis penyakit secara instan.
            </motion.p>
          </motion.div>
        </div>
      </section>

      <section className="px-4 sm:px-6 py-8 sm:py-12">
        <div className="mx-auto max-w-7xl">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 sm:gap-10 items-start">

            {/* Left: Upload */}
            <div className="flex flex-col gap-4 sm:gap-6">
              {/* Drop Zone */}
              <motion.div variants={fadeUp} initial="hidden" animate="show">
                <motion.div
                  className={`relative bg-[#151b17] rounded-2xl border-2 border-dashed transition-all flex flex-col items-center justify-center min-h-[260px] sm:min-h-[320px] md:min-h-[360px] overflow-hidden cursor-pointer
                    ${dragging ? 'border-primary bg-primary/10 scale-[1.01]' : 'border-white/15 hover:border-primary/50'}
                    ${preview ? 'border-solid' : ''}
                  `}
                  onDrop={onDrop}
                  onDragOver={(e) => { e.preventDefault(); setDragging(true); }}
                  onDragLeave={() => setDragging(false)}
                  onClick={() => !preview && inputRef.current.click()}
                >
                  <AnimatePresence mode="wait">
                    {preview ? (
                      <motion.div
                        key="preview"
                        className="w-full h-full"
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.9 }}
                      >
                        <img
                          src={preview}
                          alt="Preview"
                          className="w-full h-full object-cover rounded-xl"
                          style={{ maxHeight: 360 }}
                        />
                        <motion.button
                          className="absolute top-3 right-3 w-8 h-8 bg-red-500 text-white rounded-full text-sm font-bold flex items-center justify-center shadow-lg"
                          onClick={(e) => { e.stopPropagation(); handleReset(); }}
                          whileHover={{ scale: 1.15 }}
                          whileTap={{ scale: 0.9 }}
                        >
                          ✕
                        </motion.button>
                      </motion.div>
                    ) : (
                      <motion.div
                        key="hint"
                        className="flex flex-col items-center gap-3 sm:gap-4 p-6 sm:p-10 text-center"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                      >
                        <div className="bg-primary/10 p-4 sm:p-6 rounded-full">
                          <motion.span
                            className="text-4xl sm:text-5xl block"
                            animate={{ y: [0, -8, 0] }}
                            transition={{ repeat: Infinity, duration: 2.5, ease: 'easeInOut' }}
                          >
                            📁
                          </motion.span>
                        </div>
                        <div>
                          <p className="text-sm sm:text-lg font-bold text-white">Klik atau drag foto daun kentang</p>
                          <p className="text-xs sm:text-sm text-slate-500 mt-1">
                            Pastikan foto terlihat jelas dengan pencahayaan cukup
                          </p>
                          <p className="text-xs text-slate-600 mt-1">JPG / PNG · Maks 5MB</p>
                        </div>
                        <button className="mt-1 sm:mt-2 px-5 sm:px-6 py-2 sm:py-2.5 bg-primary/10 text-primary font-bold rounded-xl hover:bg-primary/20 transition-colors text-sm">
                          Pilih File
                        </button>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>

                <input
                  ref={inputRef}
                  type="file"
                  accept="image/jpeg,image/png"
                  onChange={onInputChange}
                  className="hidden"
                />
              </motion.div>

              {/* Action Buttons */}
              <div className="flex gap-3">
                <AnimatePresence>
                  {preview && !loading && (
                    <motion.button
                      className="flex-1 py-3 rounded-xl border-2 border-white/15 font-bold text-slate-300 hover:border-white/30 transition-colors text-sm sm:text-base"
                      onClick={handleReset}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -20 }}
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                    >
                      🔄 Ganti Gambar
                    </motion.button>
                  )}
                </AnimatePresence>
                <motion.button
                  className={`flex-1 py-3 rounded-xl font-bold text-white transition-all flex items-center justify-center gap-2 shadow-lg text-sm sm:text-base
                    ${!image || loading ? 'bg-white/10 cursor-not-allowed shadow-none text-slate-500' : 'bg-primary shadow-primary/20 hover:bg-primary/90'}
                  `}
                  onClick={handlePredict}
                  disabled={!image || loading}
                  whileHover={!loading && image ? { scale: 1.02 } : {}}
                  whileTap={!loading && image ? { scale: 0.98 } : {}}
                >
                  {loading ? (
                    <>
                      <motion.span animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1, ease: 'linear' }}>⏳</motion.span>
                      Menganalisis...
                    </>
                  ) : (
                    <><span>🔬</span> Analisis Sekarang</>
                  )}
                </motion.button>
              </div>

              {/* Tips Card */}
              <ElectricBorder color="#4cae7d" speed={0.5} chaos={0.08} borderRadius={12}>
                <div className="bg-primary/10 rounded-xl p-4 sm:p-5 flex gap-3">
                  <span className="text-xl sm:text-2xl">💡</span>
                  <div>
                    <p className="font-bold text-sm text-white">Tips Fotografi</p>
                    <p className="text-xs text-slate-400 mt-1 leading-relaxed">
                      Ambil foto dari jarak 15–20 cm dengan latar belakang netral. Hindari bayangan yang menutupi daun untuk akurasi AI yang lebih baik.
                    </p>
                  </div>
                </div>
              </ElectricBorder>
            </div>

            {/* Right: Result Panel */}
            <div>
              <AnimatePresence mode="wait">
                {/* Loading */}
                {loading && (
                  <motion.div
                    key="loading"
                    variants={fadeUp}
                    initial="hidden"
                    animate="show"
                    exit="exit"
                    className="bg-[#151b17] rounded-2xl border border-white/10 p-6 sm:p-10 flex flex-col items-center gap-4"
                  >
                    <Lottie animationData={loadingAnim} loop style={{ width: 120, height: 120 }} />
                    <p className="text-base sm:text-lg font-bold text-white">Menganalisis gambar...</p>
                    <p className="text-xs sm:text-sm text-slate-400 text-center">
                      Model EfficientNetB3 sedang memproses foto Anda
                    </p>
                    <div className="flex gap-2 mt-2">
                      {[0, 1, 2].map((i) => (
                        <motion.div
                          key={i}
                          className="w-2 h-2 rounded-full bg-primary"
                          animate={{ opacity: [0.3, 1, 0.3], scale: [0.8, 1.2, 0.8] }}
                          transition={{ repeat: Infinity, duration: 1.2, delay: i * 0.2 }}
                        />
                      ))}
                    </div>
                  </motion.div>
                )}

                {/* Error */}
                {showError && !loading && (
                  <motion.div
                    key="error"
                    variants={fadeUp}
                    initial="hidden"
                    animate="show"
                    exit="exit"
                    className="bg-red-950/30 rounded-2xl border border-red-500/20 p-6 sm:p-10 flex flex-col items-center gap-4"
                  >
                    <Lottie animationData={errorAnim} loop={false} style={{ width: 100, height: 100 }} />
                    <p className="text-lg sm:text-xl font-bold text-red-400">Gagal Menganalisis</p>
                    <p className="text-xs sm:text-sm text-red-400/70 text-center">
                      Periksa koneksi dan pastikan backend berjalan di port 8000.
                    </p>
                  </motion.div>
                )}

                {/* Result */}
                {result && !loading && (
                  <motion.div
                    key="result"
                    variants={fadeUp}
                    initial="hidden"
                    animate="show"
                    exit="exit"
                    className="bg-[#151b17] rounded-2xl border border-white/10 overflow-hidden"
                  >
                    <div className="p-4 sm:p-6 border-b border-white/10 flex items-center justify-between">
                      <h2 className="text-lg sm:text-xl font-bold text-white">Hasil Analisis</h2>
                      <span className={`px-2 sm:px-3 py-1 ${classInfo?.badgeColor} text-xs font-bold rounded-full uppercase tracking-wider`}>
                        {classInfo?.badge}
                      </span>
                    </div>

                    <div className="p-4 sm:p-6">
                      <div className="flex flex-col items-center p-4 sm:p-6 rounded-xl bg-white/5 mb-4 sm:mb-6 gap-2">
                        <Lottie animationData={successAnim} loop={false} style={{ width: 60, height: 60 }} />
                        <p className="text-xs sm:text-sm text-slate-400 font-medium">Diagnosis Utama</p>
                        <motion.h3
                          className="text-2xl sm:text-3xl font-black"
                          style={{ color: classInfo?.color }}
                          initial={{ scale: 0.5 }}
                          animate={{ scale: 1 }}
                          transition={{ type: 'spring', stiffness: 200 }}
                        >
                          {result.class}
                        </motion.h3>
                        <div className="flex items-baseline gap-2">
                          <span className="text-3xl sm:text-4xl font-bold text-white">{result.confidence}</span>
                          <span className="text-slate-500 text-xs sm:text-sm font-medium">Confidence</span>
                        </div>
                        <p className="text-xs sm:text-sm text-slate-400 text-center mt-1">{classInfo?.desc}</p>
                      </div>

                      {/* Bars */}
                      <div className="space-y-3 sm:space-y-4 mb-4 sm:mb-6">
                        <h4 className="font-bold text-white text-sm sm:text-base">Distribusi Prediksi</h4>
                        {Object.entries(result.all_predictions).map(([name, pct]) => {
                          const info = CLASS_INFO[name];
                          const val = parseFloat(pct);
                          return (
                            <div key={name}>
                              <div className="flex justify-between mb-1.5">
                                <span className="text-xs sm:text-sm font-medium text-slate-300">
                                  {info?.emoji} {name}
                                </span>
                                <span className="text-xs sm:text-sm font-bold" style={{ color: info?.color }}>{pct}</span>
                              </div>
                              <div className="h-2 sm:h-3 bg-white/10 rounded-full overflow-hidden">
                                <motion.div
                                  className={`h-full rounded-full ${info?.barColor}`}
                                  initial={{ width: 0 }}
                                  animate={{ width: `${val}%` }}
                                  transition={{ duration: 0.8, ease: 'easeOut' }}
                                />
                              </div>
                            </div>
                          );
                        })}
                      </div>

                      {/* Recommendations */}
                      <div className="pt-4 sm:pt-5 border-t border-white/10">
                        <h4 className="font-bold text-white mb-2 sm:mb-3 flex items-center gap-2 text-sm sm:text-base">
                          <span>📋</span> Rekomendasi Tindakan
                        </h4>
                        <ul className="space-y-2">
                          {classInfo?.recommendations.map((tip, i) => (
                            <motion.li
                              key={i}
                              className="flex items-start gap-2 sm:gap-2.5 text-xs sm:text-sm text-slate-300"
                              initial={{ opacity: 0, x: -10 }}
                              animate={{ opacity: 1, x: 0 }}
                              transition={{ delay: 0.3 + i * 0.1 }}
                            >
                              <span className="w-1.5 h-1.5 rounded-full bg-primary mt-1.5 flex-shrink-0" />
                              {tip}
                            </motion.li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  </motion.div>
                )}

                {/* Empty state */}
                {!result && !loading && !showError && (
                  <motion.div
                    key="empty"
                    variants={fadeUp}
                    initial="hidden"
                    animate="show"
                    className="bg-[#151b17] rounded-2xl border-2 border-dashed border-white/10 p-8 sm:p-10 flex flex-col items-center gap-4 text-center"
                  >
                    <span className="text-5xl sm:text-6xl">🔬</span>
                    <p className="text-base sm:text-lg font-bold text-white">Hasil Analisis</p>
                    <p className="text-xs sm:text-sm text-slate-500 max-w-xs">
                      Upload foto daun kentang dan klik "Analisis Sekarang" untuk melihat hasil diagnosis AI.
                    </p>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
