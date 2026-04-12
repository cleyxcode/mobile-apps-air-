import { Link } from 'react-router-dom';
import ScrollStack, { ScrollStackItem } from '../components/ScrollStack';

const diseases = [
  {
    name: 'Early Blight',
    subtitle: 'Bercak Kering',
    badge: 'Warning',
    badgeCls: 'bg-orange-900/50 text-orange-400',
    emoji: '🍂',
    gejala: 'Muncul bercak coklat gelap melingkar (seperti target) pada daun tua yang sudah matang.',
    penyebab: 'Alternaria solani',
    penyebabColor: 'text-orange-400',
    accentColor: '#f97316',
    bg: 'bg-gradient-to-br from-orange-950/60 to-[#1a1f1d]',
    penanganan: [
      'Gunakan fungisida berbasis tembaga atau mankozeb.',
      'Buang dan musnahkan daun yang terinfeksi.',
      'Rotasi tanaman setiap musim tanam.',
    ],
    stat: { val: 1000, label: 'Gambar Dataset' },
  },
  {
    name: 'Late Blight',
    subtitle: 'Hawar Daun',
    badge: 'Critical',
    badgeCls: 'bg-red-900/50 text-red-400',
    emoji: '🟫',
    gejala: 'Bercak basah abu-abu kehijauan pada ujung daun yang cepat meluas dan membusuk saat lembap.',
    penyebab: 'Phytophthora infestans',
    penyebabColor: 'text-red-400',
    accentColor: '#ef4444',
    bg: 'bg-gradient-to-br from-red-950/60 to-[#1a1f1d]',
    penanganan: [
      'Segera aplikasikan fungisida sistemik (metalaksil).',
      'Hindari penyiraman berlebih dan jaga drainase.',
      'Musnahkan tanaman terinfeksi untuk mencegah penyebaran.',
    ],
    stat: { val: 1000, label: 'Gambar Dataset' },
  },
  {
    name: 'Healthy',
    subtitle: 'Tanaman Sehat',
    badge: 'Sehat',
    badgeCls: 'bg-primary/20 text-primary',
    emoji: '🌿',
    gejala: 'Daun berwarna hijau segar merata, tekstur kokoh, tanpa adanya bercak atau perubahan warna abnormal.',
    penyebab: null,
    penyebabColor: '',
    accentColor: '#4cae7d',
    bg: 'bg-gradient-to-br from-green-950/60 to-[#1a1f1d]',
    penanganan: [
      'Pertahankan nutrisi tanah yang optimal.',
      'Lakukan penyiraman teratur di pangkal tanaman.',
      'Periksa rutin untuk deteksi dini.',
    ],
    stat: { val: 152, label: 'Gambar Dataset' },
  },
];

export default function InfoPenyakit() {
  return (
    <div className="flex-1">
      {/* Header */}
      <section className="bg-brand-dark px-4 sm:px-6 py-10 sm:py-16">
        <div className="mx-auto max-w-7xl">
          <span className="inline-flex items-center gap-2 rounded-full bg-primary/20 px-3 sm:px-4 py-1.5 text-xs sm:text-sm font-medium text-primary mb-4">
            🔬 Informasi Penyakit
          </span>

          <h1 className="text-3xl sm:text-4xl font-bold text-white md:text-5xl">Info Penyakit Kentang</h1>

          <p className="mt-3 sm:mt-4 text-white/60 text-sm sm:text-lg max-w-2xl">
            Pelajari berbagai jenis kondisi pada tanaman kentang Anda. Identifikasi gejala sejak dini untuk mencegah penyebaran penyakit.
          </p>

          {/* Stats */}
          <div className="mt-6 sm:mt-8 flex gap-6 sm:gap-10 flex-wrap">
            {[
              { value: '3', label: 'Kelas Penyakit' },
              { value: '2.152', label: 'Total Dataset' },
              { value: '97%', label: 'Akurasi AI' },
            ].map(({ value, label }) => (
              <div key={label}>
                <p className="text-xl sm:text-2xl font-bold text-primary">{value}</p>
                <p className="text-xs text-white/50 mt-0.5">{label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ScrollStack Cards */}
      <section className="px-3 sm:px-4 md:px-6 py-8 sm:py-10 max-w-3xl mx-auto">
        <p className="text-center text-slate-500 text-xs sm:text-sm mb-4">↓ Scroll untuk menjelajahi tiap penyakit</p>

        <div>
          <ScrollStack
            useWindowScroll={true}
            itemDistance={80}
            itemScale={0.04}
            itemStackDistance={24}
            stackPosition="15%"
            baseScale={0.88}
          >
            {diseases.map(({ name, subtitle, badge, badgeCls, emoji, gejala, penyebab, penyebabColor, accentColor, bg, penanganan, stat }) => (
              <ScrollStackItem key={name} itemClassName={`${bg} border border-white/10`}>
                <div className="p-4 sm:p-6">
                  <div className="flex items-start justify-between mb-4 gap-2">
                    <div className="flex items-center gap-2 sm:gap-3 min-w-0">
                      <span className="text-4xl sm:text-5xl flex-shrink-0">{emoji}</span>
                      <div className="min-w-0">
                        <span className={`text-xs font-bold uppercase tracking-widest px-2 py-0.5 rounded-full ${badgeCls}`}>{badge}</span>
                        <h3 className="text-xl sm:text-2xl font-black text-white mt-1 leading-tight">{name}</h3>
                        <p className="text-xs sm:text-sm text-slate-400">{subtitle}</p>
                      </div>
                    </div>
                    <div className="text-right flex-shrink-0">
                      <p className="text-xl sm:text-2xl font-bold tabular-nums" style={{ color: accentColor }}>
                        {stat.val.toLocaleString('id-ID')}
                      </p>
                      <p className="text-xs text-slate-500">{stat.label}</p>
                    </div>
                  </div>

                  <div className="space-y-3">
                    <div>
                      <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-1">Gejala</p>
                      <p className="text-xs sm:text-sm leading-relaxed text-slate-300">{gejala}</p>
                    </div>
                    <div className="pt-3 border-t border-white/10">
                      <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-1">{penyebab ? 'Penyebab' : 'Status'}</p>
                      {penyebab ? (
                        <p className={`text-xs sm:text-sm italic font-semibold ${penyebabColor}`}>{penyebab}</p>
                      ) : (
                        <p className="text-xs sm:text-sm font-semibold text-primary">✅ Kondisi Optimal</p>
                      )}
                    </div>
                    <div className="pt-3 border-t border-white/10">
                      <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Penanganan</p>
                      <ul className="space-y-1">
                        {penanganan.map((tip, j) => (
                          <li key={j} className="flex items-start gap-2 text-xs sm:text-sm text-slate-300">
                            <span style={{ color: accentColor }} className="mt-0.5 flex-shrink-0">•</span>
                            {tip}
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </div>
              </ScrollStackItem>
            ))}
          </ScrollStack>
        </div>
      </section>

      {/* CTA */}
      <section className="px-4 sm:px-6 pb-10 sm:pb-16">
        <div className="mx-auto max-w-7xl">
          <div className="rounded-2xl bg-primary/10 border border-primary/20 p-6 sm:p-8 md:p-10 flex flex-col md:flex-row items-center justify-between gap-4 sm:gap-6">
            <div>
              <h3 className="text-xl sm:text-2xl font-bold text-white">Punya foto tanaman kentang?</h3>
              <p className="mt-2 text-sm sm:text-base text-slate-400">Gunakan AI kami untuk deteksi otomatis penyakit secara akurat.</p>
            </div>
            <Link
              to="/cek"
              className="w-full md:w-auto whitespace-nowrap rounded-xl bg-primary px-6 sm:px-8 py-3 sm:py-4 font-bold text-white hover:bg-primary/90 transition-colors flex items-center justify-center gap-2 text-sm sm:text-base"
            >
              🔍 Mulai Scan Sekarang
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
