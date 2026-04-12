import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';

export default function Footer() {
  return (
    <footer className="border-t border-white/8 bg-[#0a0d0b] px-6 py-12">
      <div className="mx-auto max-w-7xl">
        <div className="flex flex-col items-center justify-between gap-6 md:flex-row">
          <Link to="/" className="flex items-center gap-2">
            <motion.span
              className="text-2xl"
              animate={{ rotate: [0, -10, 10, 0] }}
              transition={{ repeat: Infinity, repeatDelay: 5, duration: 0.6 }}
            >
              🌿
            </motion.span>
            <span className="text-lg font-bold text-white">PotatoCare AI</span>
          </Link>

          <div className="flex flex-wrap justify-center gap-8">
            <Link to="/info" className="text-sm text-slate-500 hover:text-primary transition-colors">Info Penyakit</Link>
            <Link to="/gejala" className="text-sm text-slate-500 hover:text-primary transition-colors">Gejala</Link>
            <Link to="/cek" className="text-sm text-slate-500 hover:text-primary transition-colors">Cek Penyakit</Link>
            <span className="text-sm text-slate-500 hover:text-primary transition-colors cursor-pointer">Bantuan</span>
          </div>

          <p className="text-sm text-slate-600">© 2024 PotatoCare AI. All rights reserved.</p>
        </div>

        <div className="mt-8 pt-6 border-t border-white/8 text-center">
          <p className="text-xs text-slate-600">Model: EfficientNetB3 · Dataset: PlantVillage · Akurasi: ~97%</p>
        </div>
      </div>
    </footer>
  );
}
