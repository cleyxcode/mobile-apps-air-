import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import ColorBends from '../components/ColorBends';
import CardSwap, { Card } from '../components/CardSwap';
import SplitText from '../components/SplitText';
import RotatingText from '../components/RotatingText';
import CountUp from '../components/CountUp';
import ElectricBorder from '../components/ElectricBorder';

const fadeUp = {
  hidden: { opacity: 0, y: 40 },
  show: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.5, ease: 'easeOut', delay: i * 0.1 },
  }),
};

const features = [
  {
    icon: '✅',
    title: 'Akurasi 97%',
    desc: 'Model AI kami dilatih dengan ribuan dataset penyakit kentang untuk hasil yang presisi.',
    bg: 'bg-primary/10 group-hover:bg-primary group-hover:text-white',
    electricColor: '#4cae7d',
  },
  {
    icon: '⚡',
    title: 'Hasil Instan',
    desc: 'Dapatkan diagnosis penyakit hanya dalam hitungan detik setelah upload foto.',
    bg: 'bg-yellow-400/10 group-hover:bg-yellow-400 group-hover:text-white',
    electricColor: '#f59e0b',
  },
  {
    icon: '🔬',
    title: '3 Kategori Penyakit',
    desc: 'Deteksi Early Blight, Late Blight, atau identifikasi tanaman Sehat dengan akurat.',
    bg: 'bg-blue-400/10 group-hover:bg-blue-500 group-hover:text-white',
    electricColor: '#3b82f6',
  },
];

export default function Beranda() {
  return (
    <div className="flex-1">
      {/* Hero */}
      <section className="relative overflow-hidden bg-brand-dark px-4 sm:px-6 py-14 sm:py-20 md:py-32">
        {/* ColorBends background */}
        <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
          <ColorBends
            colors={['#4cae7d', '#1a4d2e', '#27ae60', '#0d2b1a', '#2ecc71']}
            rotation={0}
            speed={0.18}
            scale={1}
            frequency={1}
            warpStrength={1.2}
            mouseInfluence={0}
            parallax={0}
            noise={0.05}
            transparent={false}
            autoRotate={0}
          />
        </div>
        <div className="absolute inset-0 bg-gradient-to-r from-brand-dark/90 via-brand-dark/55 to-brand-dark/20 pointer-events-none" />
        <div className="relative mx-auto max-w-7xl flex flex-col lg:flex-row items-center justify-between gap-10">
          {/* Kiri: Teks */}
          <motion.div
            className="w-full lg:max-w-xl"
            initial="hidden"
            animate="show"
            variants={{ show: { transition: { staggerChildren: 0.15 } } }}
          >
            {/* Badge */}
            <motion.div variants={fadeUp} className="mb-4">
              <span className="inline-flex items-center gap-2 rounded-full bg-primary/20 px-3 sm:px-4 py-1.5 text-xs sm:text-sm font-medium text-primary">
                <motion.span animate={{ scale: [1, 1.3, 1] }} transition={{ repeat: Infinity, duration: 2 }}>🌱</motion.span>
                Deteksi:
                <RotatingText
                  texts={['Early Blight 🍂', 'Late Blight 🟫', 'Healthy 🌿']}
                  mainClassName="px-2 py-0.5 bg-primary text-white rounded-md font-bold text-xs"
                  splitLevelClassName="overflow-hidden"
                  staggerFrom="last"
                  initial={{ y: '100%' }}
                  animate={{ y: 0 }}
                  exit={{ y: '-120%' }}
                  staggerDuration={0.025}
                  transition={{ type: 'spring', damping: 30, stiffness: 400 }}
                  rotationInterval={2500}
                  splitBy="words"
                />
              </span>
            </motion.div>

            {/* Judul hero */}
            <motion.div variants={fadeUp}>
              <h1 className="text-3xl sm:text-4xl font-bold leading-tight text-white md:text-5xl lg:text-6xl">
                <SplitText
                  text="Deteksi Penyakit"
                  tag="span"
                  className="block"
                  delay={25}
                  duration={0.9}
                  ease="power3.out"
                  splitType="words"
                  from={{ opacity: 0, y: 50 }}
                  to={{ opacity: 1, y: 0 }}
                  threshold={0}
                  rootMargin="0px"
                  textAlign="left"
                />
                <span className="flex items-center gap-2 sm:gap-3 flex-wrap mt-1">
                  <RotatingText
                    texts={['Early Blight', 'Late Blight', 'Tanaman Sehat']}
                    mainClassName="px-2 sm:px-3 py-1 bg-primary/20 text-primary rounded-xl font-black"
                    splitLevelClassName="overflow-hidden pb-1"
                    staggerFrom="last"
                    initial={{ y: '100%' }}
                    animate={{ y: 0 }}
                    exit={{ y: '-120%' }}
                    staggerDuration={0.03}
                    transition={{ type: 'spring', damping: 28, stiffness: 350 }}
                    rotationInterval={3000}
                    splitBy="characters"
                  />
                  <SplitText
                    text="dengan AI"
                    tag="span"
                    className="text-white"
                    delay={20}
                    duration={0.8}
                    ease="power3.out"
                    splitType="words"
                    from={{ opacity: 0, x: -20 }}
                    to={{ opacity: 1, x: 0 }}
                    threshold={0}
                    rootMargin="0px"
                    textAlign="left"
                  />
                </span>
              </h1>
            </motion.div>

            <motion.div variants={fadeUp} className="mt-4 sm:mt-6">
              <p className="text-base sm:text-lg text-white/70 max-w-lg">
                Upload foto daun kentang dan dapatkan diagnosis instan untuk menjaga kualitas panen Anda dengan teknologi Computer Vision terkini.
              </p>
            </motion.div>

            <motion.div variants={fadeUp} className="mt-6 sm:mt-10 flex flex-col sm:flex-row flex-wrap gap-3 sm:gap-4">
              <Link to="/cek" className="flex items-center justify-center gap-2 rounded-xl bg-primary px-6 sm:px-8 py-3 sm:py-4 text-sm sm:text-base font-bold text-white shadow-lg shadow-primary/30 hover:scale-105 transition-transform">
                Mulai Cek Sekarang <span>→</span>
              </Link>
              <Link to="/info" className="flex items-center justify-center gap-2 rounded-xl border border-white/20 bg-white/10 px-6 sm:px-8 py-3 sm:py-4 text-sm sm:text-base font-bold text-white backdrop-blur-sm hover:bg-white/20 transition-colors">
                Pelajari Lebih Lanjut
              </Link>
            </motion.div>

            <motion.div variants={fadeUp} className="mt-8 sm:mt-12 flex flex-wrap gap-6 sm:gap-10">
              {[
                { from: 0, to: 97, suffix: '%', label: 'Akurasi Model', duration: 2 },
                { from: 0, to: 2152, suffix: '', separator: '.', label: 'Dataset Gambar', duration: 2.5 },
                { from: 0, to: 3, suffix: '', label: 'Jenis Deteksi', duration: 1.5 },
              ].map(({ from, to, suffix, separator, label, duration }) => (
                <div key={label}>
                  <p className="text-2xl sm:text-3xl font-bold text-primary flex items-baseline gap-0.5">
                    <CountUp from={from} to={to} duration={duration} separator={separator || ''} direction="up" className="tabular-nums" />
                    {suffix}
                  </p>
                  <p className="text-xs sm:text-sm text-white/60 mt-1">{label}</p>
                </div>
              ))}
            </motion.div>
          </motion.div>

          {/* Kanan: CardSwap — hanya desktop */}
          <div className="hidden lg:block relative w-[500px] h-[420px] flex-shrink-0">
            <CardSwap cardDistance={60} verticalDistance={70} delay={4000} pauseOnHover={true} width={380} height={240} skewAmount={4}>
              <Card className="bg-gradient-to-br from-orange-950/90 to-orange-900/80 backdrop-blur-sm border-orange-500/30 p-6 flex flex-col gap-3">
                <div className="flex items-center gap-3">
                  <span className="text-3xl">🍂</span>
                  <div>
                    <span className="text-xs font-bold uppercase tracking-widest text-orange-400">Terdeteksi</span>
                    <h3 className="text-xl font-black text-white">Early Blight</h3>
                  </div>
                  <span className="ml-auto text-2xl font-black text-orange-400">92%</span>
                </div>
                <div className="space-y-2">
                  {[['Early Blight', 92, 'bg-orange-400'], ['Late Blight', 5, 'bg-red-400'], ['Healthy', 3, 'bg-primary']].map(([name, pct, color]) => (
                    <div key={name}>
                      <div className="flex justify-between text-xs mb-1">
                        <span className="text-white/70">{name}</span>
                        <span className="text-white font-bold">{pct}%</span>
                      </div>
                      <div className="h-1.5 bg-white/10 rounded-full">
                        <div className={`h-full ${color} rounded-full`} style={{ width: `${pct}%` }} />
                      </div>
                    </div>
                  ))}
                </div>
                <p className="text-xs text-orange-300/80 mt-1">Disebabkan jamur <em>Alternaria solani</em></p>
              </Card>
              <Card className="bg-gradient-to-br from-red-950/90 to-red-900/80 backdrop-blur-sm border-red-500/30 p-6 flex flex-col gap-3">
                <div className="flex items-center gap-3">
                  <span className="text-3xl">🟫</span>
                  <div>
                    <span className="text-xs font-bold uppercase tracking-widest text-red-400">Terdeteksi</span>
                    <h3 className="text-xl font-black text-white">Late Blight</h3>
                  </div>
                  <span className="ml-auto text-2xl font-black text-red-400">88%</span>
                </div>
                <div className="space-y-2">
                  {[['Late Blight', 88, 'bg-red-400'], ['Early Blight', 9, 'bg-orange-400'], ['Healthy', 3, 'bg-primary']].map(([name, pct, color]) => (
                    <div key={name}>
                      <div className="flex justify-between text-xs mb-1">
                        <span className="text-white/70">{name}</span>
                        <span className="text-white font-bold">{pct}%</span>
                      </div>
                      <div className="h-1.5 bg-white/10 rounded-full">
                        <div className={`h-full ${color} rounded-full`} style={{ width: `${pct}%` }} />
                      </div>
                    </div>
                  ))}
                </div>
                <p className="text-xs text-red-300/80 mt-1">Disebabkan <em>Phytophthora infestans</em></p>
              </Card>
              <Card className="bg-gradient-to-br from-green-950/90 to-emerald-900/80 backdrop-blur-sm border-primary/30 p-6 flex flex-col gap-3">
                <div className="flex items-center gap-3">
                  <span className="text-3xl">🌿</span>
                  <div>
                    <span className="text-xs font-bold uppercase tracking-widest text-primary">Sehat</span>
                    <h3 className="text-xl font-black text-white">Healthy</h3>
                  </div>
                  <span className="ml-auto text-2xl font-black text-primary">97%</span>
                </div>
                <div className="space-y-2">
                  {[['Healthy', 97, 'bg-primary'], ['Early Blight', 2, 'bg-orange-400'], ['Late Blight', 1, 'bg-red-400']].map(([name, pct, color]) => (
                    <div key={name}>
                      <div className="flex justify-between text-xs mb-1">
                        <span className="text-white/70">{name}</span>
                        <span className="text-white font-bold">{pct}%</span>
                      </div>
                      <div className="h-1.5 bg-white/10 rounded-full">
                        <div className={`h-full ${color} rounded-full`} style={{ width: `${pct}%` }} />
                      </div>
                    </div>
                  ))}
                </div>
                <p className="text-xs text-primary/80 mt-1">Tanaman dalam kondisi optimal ✅</p>
              </Card>
            </CardSwap>
          </div>
        </div>
      </section>

      {/* Feature Cards */}
      <section className="relative -mt-6 sm:-mt-12 px-4 sm:px-6 pb-12 sm:pb-20">
        <div className="mx-auto max-w-7xl">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
            {features.map(({ icon, title, desc, bg, electricColor }, i) => (
              <motion.div
                key={title}
                custom={i}
                variants={fadeUp}
                initial="hidden"
                whileInView="show"
                viewport={{ once: true }}
              >
                <ElectricBorder color={electricColor} speed={0.6} chaos={0.1} borderRadius={16} className="h-full">
                  <div className="group flex flex-col gap-3 sm:gap-4 rounded-xl bg-[#151b17] p-5 sm:p-6 md:p-8 h-full cursor-default hover:-translate-y-1 transition-transform">
                    <div className={`flex h-12 w-12 sm:h-14 sm:w-14 items-center justify-center rounded-xl text-xl sm:text-2xl transition-all duration-300 ${bg}`}>
                      {icon}
                    </div>
                    <div>
                      <h3 className="text-base sm:text-xl font-bold text-white">{title}</h3>
                      <p className="mt-1 sm:mt-2 text-sm text-slate-400">{desc}</p>
                    </div>
                  </div>
                </ElectricBorder>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* How it works */}
      <section className="px-4 sm:px-6 py-12 sm:py-16 bg-[#0a0d0b]">
        <div className="mx-auto max-w-7xl">
          <div className="text-center mb-8 sm:mb-12">
            <SplitText
              text="Cara Kerja"
              tag="h2"
              className="text-2xl sm:text-3xl font-bold text-white md:text-4xl"
              delay={40}
              duration={1}
              ease="power3.out"
              splitType="chars"
              from={{ opacity: 0, y: 30, rotationX: -90 }}
              to={{ opacity: 1, y: 0, rotationX: 0 }}
              threshold={0.3}
              rootMargin="-50px"
              textAlign="center"
            />
            <motion.p
              initial={{ opacity: 0, y: 10 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.4 }}
              className="mt-3 text-slate-500 text-sm sm:text-base"
            >
              3 langkah mudah untuk deteksi penyakit
            </motion.p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 sm:gap-8">
            {[
              { step: '01', icon: '📸', title: 'Upload Foto', desc: 'Ambil atau upload foto daun kentang yang jelas dengan pencahayaan cukup.' },
              { step: '02', icon: '🤖', title: 'Analisis AI', desc: 'Model EfficientNetB3 kami menganalisis gambar secara otomatis dalam hitungan detik.' },
              { step: '03', icon: '📋', title: 'Dapat Hasil', desc: 'Dapatkan diagnosis lengkap beserta tingkat kepercayaan dan rekomendasi penanganan.' },
            ].map(({ step, icon, title, desc }, i) => (
              <motion.div
                key={step}
                custom={i}
                variants={fadeUp}
                initial="hidden"
                whileInView="show"
                viewport={{ once: true }}
                className="flex flex-col items-center text-center gap-3 sm:gap-4"
              >
                <div className="relative">
                  <div className="flex h-16 w-16 sm:h-20 sm:w-20 items-center justify-center rounded-2xl bg-[#151b17] shadow-lg shadow-black/30 text-3xl sm:text-4xl">
                    {icon}
                  </div>
                  <span className="absolute -top-2 -right-2 flex h-6 w-6 sm:h-7 sm:w-7 items-center justify-center rounded-full bg-primary text-xs font-bold text-white">
                    {step}
                  </span>
                </div>
                <h3 className="text-base sm:text-lg font-bold text-white">{title}</h3>
                <p className="text-slate-400 text-xs sm:text-sm leading-relaxed">{desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="px-4 sm:px-6 py-12 sm:py-16">
        <div className="mx-auto max-w-7xl">
          <motion.div initial={{ opacity: 0, y: 30 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }}>
            <ElectricBorder color="#4cae7d" speed={0.5} chaos={0.08} borderRadius={16}>
              <div className="rounded-2xl bg-primary/10 p-6 sm:p-8 md:p-12">
                <div className="flex flex-col items-center justify-between gap-6 sm:gap-8 md:flex-row">
                  <div className="max-w-xl text-center md:text-left">
                    <h2 className="text-2xl sm:text-3xl font-bold text-white flex flex-wrap items-center justify-center md:justify-start gap-2">
                      Siap Deteksi
                      <RotatingText
                        texts={['Early Blight?', 'Late Blight?', 'Penyakit?']}
                        mainClassName="px-3 py-1 bg-primary text-white rounded-lg font-black text-xl sm:text-2xl"
                        splitLevelClassName="overflow-hidden pb-0.5"
                        staggerFrom="last"
                        initial={{ y: '100%' }}
                        animate={{ y: 0 }}
                        exit={{ y: '-120%' }}
                        staggerDuration={0.03}
                        transition={{ type: 'spring', damping: 28, stiffness: 350 }}
                        rotationInterval={2800}
                        splitBy="characters"
                      />
                    </h2>
                    <p className="mt-3 sm:mt-4 text-sm sm:text-base text-slate-400">
                      Bergabunglah dengan ratusan petani yang telah menggunakan PotatoCare AI untuk memantau kesehatan tanaman kentang mereka.
                    </p>
                  </div>
                  <Link
                    to="/cek"
                    className="w-full sm:w-auto whitespace-nowrap rounded-xl bg-primary px-8 py-4 font-bold text-white hover:bg-primary/90 transition-colors shadow-lg shadow-primary/20 text-center"
                  >
                    Mulai Cek Sekarang →
                  </Link>
                </div>
              </div>
            </ElectricBorder>
          </motion.div>
        </div>
      </section>
    </div>
  );
}
