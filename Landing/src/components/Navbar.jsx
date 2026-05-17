import React, { useState, useEffect } from 'react';

const Navbar = () => {
  const [isDarkMode, setIsDarkMode] = useState(false);

  // Initialize theme based on current HTML class list
  useEffect(() => {
    const isDark = document.documentElement.classList.contains('dark');
    setIsDarkMode(isDark);
  }, []);

  const toggleTheme = () => {
    if (isDarkMode) {
      document.documentElement.classList.remove('dark');
      document.documentElement.classList.add('light');
      setIsDarkMode(false);
    } else {
      document.documentElement.classList.remove('light');
      document.documentElement.classList.add('dark');
      setIsDarkMode(true);
    }
  };

  return (
    <nav className="sticky top-0 z-50 bg-surface/80 backdrop-blur-md border-b border-outline-variant/10">
      <div className="flex justify-between items-center w-full px-margin-page py-6 max-w-7xl mx-auto">
        <div className="flex items-center gap-3 cursor-pointer">
          <img 
            alt="Ava Qurania Logo" 
            className="h-10 w-10" 
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuDNDF0FB04zjIJlDQkii-18PPzU0R9QHPm_-XtiF00m7C_KUbC-KpNK5cVCVD1JZzNFQbOeBRPN4QI_svLzpTQ0F-g-WI5I0J8tjcoinUp8gcH0WPXE5ooCMebsyUFzk6Ykoq818Ob_M4q98aTHmZyw7YCq6xVq4DGpfUtzOP2CS2qF_JmDHxI0psela8AppMBBSrRgq3Y2DobOqO5-J0eJU1pu6XC5Zl08QBuhRgEt5i_OQGLm61YEZdNnimpLwuU8OciBJN6RJfvJ" 
          />
          <span className="text-headline-lg font-headline-lg font-bold text-primary">Ava Qurania</span>
        </div>
        
        <div className="hidden md:flex gap-8 items-center">
          <a className="text-on-surface-variant hover:text-primary transition-colors duration-200 font-label-md text-label-md" href="#">Reciters</a>
          <a className="text-primary font-bold border-b-2 border-primary pb-1 font-label-md text-label-md" href="#">Quran</a>
          <a className="text-on-surface-variant hover:text-primary transition-colors duration-200 font-label-md text-label-md" href="#">Tafsir</a>
          <a className="text-on-surface-variant hover:text-primary transition-colors duration-200 font-label-md text-label-md" href="#">Islamic Reels</a>
        </div>
        
        <div className="flex items-center gap-4">
          <button 
            onClick={toggleTheme}
            className="material-symbols-outlined p-2 text-on-surface-variant hover:bg-surface-container-low rounded-full transition-all duration-200 hover:scale-105 active:scale-95"
            aria-label="Toggle theme"
          >
            {isDarkMode ? 'light_mode' : 'dark_mode'}
          </button>
          <a href="https://github.com/mdrakibulhaquesardar/Ava-Quran/releases/download/v1.0.0/avaQuraniaV1.0.0.apk" className="flex items-center gap-2 bg-primary text-on-primary px-6 py-2 rounded-full font-label-md text-label-md scale-95 active:scale-90 hover:shadow-md hover:bg-primary-container transition-all duration-150">
            <span className="material-symbols-outlined text-[1.1rem]">download</span>
            Get the App
          </a>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
