import { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import GooeyNav from './GooeyNav';

const navLinks = [
  { to: '/', label: 'Beranda' },
  { to: '/cek', label: 'Cek Penyakit' },
  { to: '/info', label: 'Info Penyakit' },
  { to: '/gejala', label: 'Gejala' },
];

export default function Navbar() {
  const { pathname } = useLocation();
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);

  const initialActiveIndex = navLinks.findIndex((l) => l.to === pathname);
  const activeIndex = initialActiveIndex === -1 ? 0 : initialActiveIndex;

  const gooeyItems = navLinks.map((link) => ({
    label: link.label,
    href: link.to,
    onClick: () => navigate(link.to),
  }));

  return (
    <header className="sticky top-0 z-50 w-full border-b border-white/8 bg-[#0c100e]/90 backdrop-blur-md">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-3">
        {/* Logo */}
        <Link to="/" className="flex items-center gap-2 flex-shrink-0">
          <motion.span
            className="text-3xl"
            animate={{ rotate: [0, -10, 10, 0] }}
            transition={{ repeat: Infinity, repeatDelay: 4, duration: 0.6 }}
          >
            🌿
          </motion.span>
          <span className="text-xl font-bold tracking-tight text-white">PotatoCare AI</span>
        </Link>

        {/* Desktop Nav — GooeyNav */}
        <div className="hidden lg:block">
          <GooeyNav
            key={activeIndex}
            items={gooeyItems}
            initialActiveIndex={activeIndex}
            particleCount={15}
            particleDistances={[90, 10]}
            particleR={100}
            animationTime={600}
            timeVariance={300}
            colors={[1, 2, 3, 1, 2, 3, 1, 4]}
          />
        </div>

        {/* Right buttons */}
        <div className="flex items-center gap-3 flex-shrink-0">
          <Link
            to="/cek"
            className="hidden lg:flex items-center gap-2 rounded-xl bg-primary px-5 py-2.5 text-sm font-bold text-white shadow-lg shadow-primary/20 hover:bg-primary/90 transition-all"
          >
            <span>🔍</span> Cek Sekarang
          </Link>
          {/* Mobile menu toggle */}
          <button
            className="flex lg:hidden h-10 w-10 items-center justify-center rounded-xl bg-white/10 text-white"
            onClick={() => setMenuOpen(!menuOpen)}
          >
            {menuOpen ? '✕' : '☰'}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {menuOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="lg:hidden overflow-hidden bg-[#111815] border-t border-white/8"
          >
            <nav className="flex flex-col px-6 py-4 gap-4">
              {navLinks.map(({ to, label }) => (
                <Link
                  key={to}
                  to={to}
                  onClick={() => setMenuOpen(false)}
                  className={`text-sm font-medium py-2 ${
                    pathname === to ? 'text-primary font-semibold' : 'text-slate-400'
                  }`}
                >
                  {label}
                </Link>
              ))}
            </nav>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  );
}
