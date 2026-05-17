import React, { useState, useEffect } from 'react';
import { APP_DOWNLOAD_LINK } from '../config';

const HeroSection = () => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(24); // Starting at 24s as per HTML design
  const duration = 48; // Total 48s
  const [isShuffle, setIsShuffle] = useState(false);
  const [isRepeat, setIsRepeat] = useState(false);

  useEffect(() => {
    let interval = null;
    if (isPlaying) {
      interval = setInterval(() => {
        setCurrentTime((prevTime) => {
          if (prevTime >= duration) {
            setIsPlaying(false);
            return 0;
          }
          return prevTime + 1;
        });
      }, 1000);
    } else {
      clearInterval(interval);
    }
    return () => clearInterval(interval);
  }, [isPlaying]);

  // Format seconds to 00:XX style
  const formatTime = (timeInSeconds) => {
    const secs = timeInSeconds % 60;
    return `00:${secs < 10 ? '0' : ''}${secs}`;
  };

  const progressPercentage = (currentTime / duration) * 100;

  return (
    <section className="relative hero-mesh w-full overflow-hidden mb-stack-lg">
      <div className="max-w-7xl mx-auto px-margin-page py-8 md:py-16 flex flex-col md:flex-row items-center gap-12">
        <div className="flex-1 space-y-8">
        <div className="inline-flex items-center gap-2 bg-primary-fixed/30 text-on-primary-fixed-variant px-4 py-2 rounded-full text-label-md font-label-md">
          <span className="w-2 h-2 rounded-full bg-primary animate-pulse"></span>
          Self-purification through the Quran
        </div>
        
        <h1 className="font-headline-xl text-headline-xl text-primary max-w-xl">
          Your Complete Companion for <span className="italic font-normal">Islamic Spirituality.</span>
        </h1>
        
        <p className="text-body-lg font-body-lg text-on-surface-variant max-w-lg">
          Immerse yourself in the Holy Quran, explore authentic Tafsir, listen to soothing recitations, and discover inspiring short-form Islamic Reels—all in one seamless mobile app.
        </p>
        
        <div className="flex flex-wrap gap-4">
          <a href={APP_DOWNLOAD_LINK} className="flex items-center gap-2 bg-primary text-on-primary px-8 py-4 rounded-full font-label-md text-label-md hover:shadow-lg scale-95 hover:scale-100 transition-all duration-150">
            <span className="material-symbols-outlined text-[1.25rem]">download</span>
            Download the App
          </a>
          <button className="border border-outline text-primary px-8 py-4 rounded-full font-label-md text-label-md hover:bg-surface-container scale-95 hover:scale-100 transition-all duration-150">
            Discover peace
          </button>
        </div>
      </div>
      
      <div className="flex-1 w-full max-w-md">
        <div className="glass-player sacred-shadow rounded-3xl p-6 relative select-none">
          <div className="flex items-center justify-between mb-8">
            <div>
              <p className="text-label-md font-label-md text-on-surface-variant opacity-60">Relaxation Radio (Surah)</p>
              <h3 className="text-headline-lg font-headline-lg text-primary">Surah Al-Fatihah</h3>
            </div>
            <button className="material-symbols-outlined text-primary hover:bg-primary/5 p-1 rounded-full transition-colors">more_vert</button>
          </div>
          
          {/* Seeker / Progress bar */}
          <div className="relative h-1 bg-surface-container-highest rounded-full mb-4 cursor-pointer">
            <div 
              className="absolute left-0 top-0 h-full bg-primary rounded-full transition-all duration-300"
              style={{ width: `${progressPercentage}%` }}
            ></div>
            <div 
              className="absolute top-1/2 -translate-y-1/2 w-3 h-3 bg-primary rounded-full ring-4 ring-primary/20 transition-all duration-300"
              style={{ left: `calc(${progressPercentage}% - 6px)` }}
            ></div>
          </div>
          
          <div className="flex justify-between text-label-md font-label-md text-on-surface-variant mb-8">
            <span>{formatTime(currentTime)}</span>
            <span>{formatTime(duration)}</span>
          </div>
          
          <div className="flex items-center justify-around">
            <button 
              onClick={() => setIsShuffle(!isShuffle)}
              className={`material-symbols-outlined p-2 rounded-full transition-all duration-200 ${
                isShuffle ? 'text-primary bg-primary/10 font-bold scale-110' : 'text-primary/60 hover:text-primary'
              }`}
            >
              shuffle
            </button>
            
            <button className="material-symbols-outlined text-primary text-3xl hover:bg-primary/5 p-1 rounded-full transition-colors scale-95 active:scale-90">
              skip_previous
            </button>
            
            <button 
              onClick={() => setIsPlaying(!isPlaying)}
              className="w-16 h-16 rounded-full bg-primary flex items-center justify-center text-on-primary shadow-lg shadow-primary/20 scale-95 hover:scale-100 active:scale-90 transition-all duration-150"
            >
              <span className="material-symbols-outlined text-4xl" style={{ fontVariationSettings: "'FILL' 1" }}>
                {isPlaying ? 'pause' : 'play_arrow'}
              </span>
            </button>
            
            <button className="material-symbols-outlined text-primary text-3xl hover:bg-primary/5 p-1 rounded-full transition-colors scale-95 active:scale-90">
              skip_next
            </button>
            
            <button 
              onClick={() => setIsRepeat(!isRepeat)}
              className={`material-symbols-outlined p-2 rounded-full transition-all duration-200 ${
                isRepeat ? 'text-primary bg-primary/10 font-bold scale-110' : 'text-primary/60 hover:text-primary'
              }`}
            >
              repeat
            </button>
          </div>
        </div>
      </div>
      </div>
    </section>
  );
};

export default HeroSection;
