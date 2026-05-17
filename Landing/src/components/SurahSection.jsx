import React, { useState } from 'react';
import { APP_DOWNLOAD_LINK } from '../config';

const SurahSection = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [activeTab, setActiveTab] = useState('Surah');
  
  const initialSurahs = [
    { num: '01.', title: 'Al-Fatihah', eng: 'The Opener', arabic: 'الفاتحة', verses: '7 Verses' },
    { num: '02.', title: 'Al-Baqarah', eng: 'The Cow', arabic: 'البقرة', verses: '286 Verses' },
    { num: '03.', title: 'Al-Imran', eng: 'The Family of Imran', arabic: 'آل عمران', verses: '200 Verses' },
    { num: '04.', title: "An-Nisa'", eng: 'The Women', arabic: 'النساء', verses: '176 Verses' },
    { num: '05.', title: "Al-Ma'idah", eng: 'The Table Spread', arabic: 'المائدة', verses: '120 Verses' },
    { num: '06.', title: "Al-An'am", eng: 'The Cattle', arabic: 'الأنعام', verses: '165 Verses' },
  ];

  const [selectedSurah, setSelectedSurah] = useState('Al-Baqarah'); // Al-Baqarah is highlighted by default in the design spec

  const filteredSurahs = initialSurahs.filter(surah => 
    surah.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    surah.eng.toLowerCase().includes(searchTerm.toLowerCase()) ||
    surah.arabic.includes(searchTerm)
  );

  return (
    <section className="mb-stack-lg">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-12">
        <h2 className="text-headline-xl font-headline-xl text-primary">
          Explore the Holy Quran <br />& Authentic Tafsir
        </h2>
        <div className="relative w-full max-w-sm">
          <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input 
            className="w-full bg-[#F0F2F1] border-none rounded-full py-4 pl-12 pr-6 focus:ring-2 focus:ring-primary/20 transition-all outline-none" 
            placeholder="Search Surahs or Tafsir..." 
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          {searchTerm && (
            <button 
              onClick={() => setSearchTerm('')} 
              className="absolute right-4 top-1/2 -translate-y-1/2 material-symbols-outlined text-on-surface-variant hover:text-primary transition-colors text-lg"
            >
              close
            </button>
          )}
        </div>
      </div>

      <div className="flex gap-4 mb-8 overflow-x-auto pb-4">
        {['Surah', 'Juz', 'Revelation Order'].map((tab) => (
          <button 
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`px-8 py-3 rounded-full font-label-md text-label-md transition-all duration-200 whitespace-nowrap ${
              activeTab === tab 
                ? 'bg-primary text-on-primary shadow-md' 
                : 'bg-secondary-container text-primary hover:bg-primary/10'
            }`}
          >
            {tab}
          </button>
        ))}
      </div>

      {filteredSurahs.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-gutter-grid">
          {filteredSurahs.map((surah) => {
            const isActive = selectedSurah === surah.title;
            return (
              <div 
                key={surah.num} 
                onClick={() => setSelectedSurah(surah.title)}
                className={`group rounded-xl p-6 transition-all duration-300 cursor-pointer ${
                  isActive 
                    ? 'bg-primary text-on-primary shadow-lg shadow-primary/20 scale-[1.02]' 
                    : 'bg-surface-container-lowest border border-outline-variant/30 hover:shadow-xl hover:border-primary/20 hover:scale-[1.01]'
                }`}
              >
                <div className="flex justify-between items-center">
                  <div className="flex items-center gap-4">
                    <span className={`text-label-md font-label-md w-8 ${isActive ? 'opacity-80' : 'text-on-surface-variant'}`}>
                      {surah.num}
                    </span>
                    <div>
                      <h4 className={`text-body-lg font-body-lg font-bold ${isActive ? '' : 'text-primary'}`}>{surah.title}</h4>
                      <p className={`text-label-md font-label-md ${isActive ? 'opacity-80' : 'text-on-surface-variant'}`}>{surah.eng}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className={`text-body-lg font-bold ${isActive ? '' : 'text-primary'}`}>{surah.arabic}</p>
                    <p className={`text-label-md font-label-md ${isActive ? 'opacity-80' : 'text-on-surface-variant'}`}>{surah.verses}</p>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="text-center py-12 bg-surface-container-lowest rounded-xl border border-outline-variant/30 text-on-surface-variant">
          <span className="material-symbols-outlined text-4xl mb-2 text-primary opacity-60">search_off</span>
          <p className="font-bold">No surahs found matching "{searchTerm}"</p>
          <p className="text-sm opacity-80 mt-1">Try checking your spelling or searching for a different surah.</p>
        </div>
      )}
      
      <div className="mt-8 text-center">
        <a className="inline-flex items-center gap-2 text-primary font-bold group hover:underline" href={APP_DOWNLOAD_LINK}>
          Open in App
          <span className="material-symbols-outlined group-hover:translate-x-1 transition-transform">arrow_forward</span>
        </a>
      </div>
    </section>
  );
};

export default SurahSection;
