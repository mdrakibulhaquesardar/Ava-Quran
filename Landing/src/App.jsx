import React from 'react';
import Navbar from './components/Navbar';
import HeroSection from './components/HeroSection';
import SurahSection from './components/SurahSection';
import ReelsSection from './components/ReelsSection';
import RecitersSection from './components/RecitersSection';
import BlogSection from './components/BlogSection';
import Footer from './components/Footer';

function App() {
  return (
    <>
      <Navbar />
      <HeroSection />
      <main className="max-w-7xl mx-auto px-margin-page">
        <SurahSection />
        <ReelsSection />
        <RecitersSection />
        <BlogSection />
      </main>
      <Footer />
    </>
  );
}

export default App;
