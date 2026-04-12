import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

import Navbar from './components/Navbar';
import Footer from './components/Footer';
import Beranda from './pages/Beranda';
import InfoPenyakit from './pages/InfoPenyakit';
import CekPenyakit from './pages/CekPenyakit';
import Gejala from './pages/Gejala';

export default function App() {
  return (
    <BrowserRouter>
      <div className="flex min-h-screen flex-col bg-[#0c100e] font-display">
        <ToastContainer position="top-right" autoClose={3000} theme="dark" />
        <Navbar />
        <Routes>
          <Route path="/" element={<Beranda />} />
          <Route path="/cek" element={<CekPenyakit />} />
          <Route path="/info" element={<InfoPenyakit />} />
          <Route path="/gejala" element={<Gejala />} />
        </Routes>
        <Footer />
      </div>
    </BrowserRouter>
  );
}
