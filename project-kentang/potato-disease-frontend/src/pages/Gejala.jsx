import { Link } from 'react-router-dom';
import ScrollStack, { ScrollStackItem } from '../components/ScrollStack';

const rows = [
  { feature: 'Warna Bercak', early: 'Coklat tua kehitaman dengan tepian kuning', late: 'Hijau kelabu, tampak basah atau berminyak', healthy: 'Hijau segar merata tanpa noda' },
  { feature: 'Bentuk', early: 'Cincin konsentris khas (seperti papan target)', late: 'Tidak beraturan, cepat melebar ke seluruh daun', healthy: 'Permukaan daun halus dan utuh' },
  { feature: 'Lokasi', early: 'Dimulai dari daun tua (bagian bawah tanaman)', late: 'Menyerang daun muda, batang, hingga umbi', healthy: 'Seluruh bagian tanaman tegak & kuat' },
  { feature: 'Penyebab', early: 'Jamur Alternaria solani', late: 'Phytophthora infestans', healthy: 'Nutrisi optimal & drainase baik', italic: true },
  { feature: 'Kecepatan', early: 'Sedang — menyebar perlahan', late: 'Sangat cepat — merusak lahan dalam 1 minggu', healthy: '—' },
  { feature: 'Bahaya', early: '⚠️ Sedang', late: '🔴 Tinggi / Kritis', healthy: '✅ Aman' },
];

const tips = [
  { icon: '💡', title: 'Tips Pencegahan', desc: 'Pastikan rotasi tanaman dilakukan setiap 3 tahun untuk memutus siklus hidup jamur tanah.', bg: 'bg-amber-950/40' },
  { icon: '💧', title: 'Manajemen Air', desc: 'Siram tanaman di bagian pangkal, hindari membasahi daun pada sore hari untuk mencegah kelembaban tinggi.', bg: 'bg-blue-950/40' },
  { icon: '🌡️', title: 'Kondisi Risiko', desc: 'Suhu 10–25°C dengan kelembaban tinggi (>90%) merupakan kondisi ideal penyebaran Late Blight.', bg: 'bg-red-950/40' },
  { icon: '🧪', title: 'Deteksi Dini', desc: 'Periksa tanaman 2–3 kali seminggu terutama saat musim hujan. Deteksi dini dapat menyelamatkan hingga 80% panen.', bg: 'bg-primary/10' },
];

export default function Gejala() {
  return (
    <div className="flex-1">
      {/* Header */}
      <section className="bg-brand-dark px-4 sm:px-6 py-10 sm:py-16">
        <div className="mx-auto max-w-7xl">
          <span className="inline-flex items-center gap-2 rounded-full bg-primary/20 px-3 sm:px-4 py-1.5 text-xs sm:text-sm font-medium text-primary mb-4">
            🩺 Identifikasi Gejala
          </span>
          <h1 className="text-3xl sm:text-4xl font-bold text-white md:text-5xl">Identifikasi Gejala</h1>
          <p className="mt-3 sm:mt-4 text-white/60 text-sm sm:text-lg max-w-2xl">
            Gunakan tabel perbandingan di bawah ini untuk mengidentifikasi kondisi tanaman kentang Anda secara akurat.
          </p>
        </div>
      </section>

      <section className="px-4 sm:px-6 py-8 sm:py-12">
        <div className="mx-auto max-w-7xl">

          {/* Comparison Table */}
          <div className="mb-10 sm:mb-12">
            <div className="bg-[#151b17] rounded-2xl overflow-hidden border border-white/8">
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse" style={{ minWidth: '560px' }}>
                  <thead>
                    <tr className="bg-[#0d1210] border-b border-white/10">
                      <th className="px-3 sm:px-6 py-3 sm:py-5 text-xs font-bold uppercase tracking-wider text-slate-500 w-1/4">Fitur</th>
                      <th className="px-3 sm:px-6 py-3 sm:py-5 w-1/4 text-xs font-bold text-orange-400">⚠️ Early Blight</th>
                      <th className="px-3 sm:px-6 py-3 sm:py-5 w-1/4 text-xs font-bold text-red-400">🔴 Late Blight</th>
                      <th className="px-3 sm:px-6 py-3 sm:py-5 w-1/4 text-xs font-bold text-primary">✅ Sehat</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-white/8">
                    {rows.map(({ feature, early, late, healthy, italic }) => (
                      <tr key={feature} className="hover:bg-primary/5 transition-colors">
                        <td className="px-3 sm:px-6 py-3 sm:py-4 text-xs sm:text-sm font-bold text-slate-200 bg-white/5">{feature}</td>
                        <td className={`px-3 sm:px-6 py-3 sm:py-4 text-xs sm:text-sm text-slate-300 ${italic ? 'italic' : ''}`}>{early}</td>
                        <td className={`px-3 sm:px-6 py-3 sm:py-4 text-xs sm:text-sm text-slate-300 ${italic ? 'italic' : ''}`}>{late}</td>
                        <td className="px-3 sm:px-6 py-3 sm:py-4 text-xs sm:text-sm text-primary font-medium">{healthy}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          {/* Tips dengan ScrollStack */}
          <div className="mb-10 sm:mb-12">
            <h3 className="text-lg sm:text-xl font-bold text-white mb-2 text-center">Tips & Panduan</h3>
            <p className="text-center text-slate-500 text-xs sm:text-sm mb-4">↓ Scroll untuk melihat semua tips</p>

            <div>
              <ScrollStack
                useWindowScroll={true}
                itemDistance={60}
                itemScale={0.04}
                itemStackDistance={20}
                stackPosition="18%"
                baseScale={0.88}
              >
                {tips.map(({ icon, title, desc, bg }) => (
                  <ScrollStackItem key={title} itemClassName={`${bg} max-w-2xl mx-auto border border-white/10`}>
                    <div className="p-4 sm:p-6 flex gap-3 sm:gap-4">
                      <div className="text-3xl sm:text-4xl flex-shrink-0">{icon}</div>
                      <div>
                        <h4 className="font-bold text-white text-base sm:text-lg mb-1 sm:mb-2">{title}</h4>
                        <p className="text-slate-400 leading-relaxed text-xs sm:text-sm">{desc}</p>
                      </div>
                    </div>
                  </ScrollStackItem>
                ))}
              </ScrollStack>
            </div>
          </div>

          {/* CTA */}
          <div className="rounded-2xl bg-primary/10 border border-primary/20 p-6 sm:p-8 md:p-10 flex flex-col md:flex-row items-center justify-between gap-4 sm:gap-6">
            <div>
              <h3 className="text-xl sm:text-2xl font-bold text-white">Butuh diagnosa cepat?</h3>
              <p className="mt-2 text-sm sm:text-base text-slate-400">Gunakan AI kami untuk mendeteksi penyakit hanya dari foto daun.</p>
            </div>
            <Link
              to="/cek"
              className="w-full md:w-auto whitespace-nowrap rounded-xl bg-primary px-6 sm:px-8 py-3 sm:py-4 font-bold text-white hover:bg-primary/90 transition-colors flex items-center justify-center gap-2 text-sm sm:text-base"
            >
              📸 Mulai Deteksi AI
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
