import React from 'react';

const ReelsSection = () => {
  const reels = [
    {
      title: 'Finding Peace in Sujood',
      views: '1.2M',
      duration: '0:45',
      imgUrl: 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?auto=format&fit=crop&q=80&w=400&h=700',
    },
    {
      title: 'Beautiful Quran Recitation',
      views: '850K',
      duration: '0:59',
      imgUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&q=80&w=400&h=700',
    },
    {
      title: 'Morning Adhkar Routine',
      views: '430K',
      duration: '0:30',
      imgUrl: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&q=80&w=400&h=700',
    },
    {
      title: 'Story of Prophet Musa (AS)',
      views: '2.1M',
      duration: '1:00',
      imgUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&q=80&w=400&h=700',
    },
    {
      title: 'Dua for Anxiety',
      views: '3.4M',
      duration: '0:40',
      imgUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=400&h=700',
    }
  ];

  return (
    <section className="mb-stack-lg py-12">
      <div className="flex justify-between items-end mb-8">
        <div>
          <div className="inline-flex items-center gap-2 bg-primary-fixed/30 text-on-primary-fixed-variant px-4 py-2 rounded-full text-label-md font-label-md mb-4">
            <span className="material-symbols-outlined text-sm">play_circle</span>
            Infinite Islamic Reels
          </div>
          <h2 className="text-headline-xl font-headline-xl text-primary">
            Watch & Discover <br />Inspiring Moments.
          </h2>
        </div>
        <a className="text-primary font-bold hover:underline hidden md:block" href="https://github.com/mdrakibulhaquesardar/Ava-Quran/releases/download/v1.0.0/avaQuraniaV1.0.0.apk">Open Reels in App</a>
      </div>

      <div className="flex gap-4 overflow-x-auto pb-8 snap-x snap-mandatory" style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}>
        {reels.map((reel, index) => (
          <div 
            key={index} 
            className="group relative flex-none w-[260px] h-[460px] rounded-[2.5rem] overflow-hidden snap-center cursor-pointer shadow-lg hover:shadow-2xl transition-all duration-300 border border-outline-variant/20"
          >
            <img 
              src={reel.imgUrl} 
              alt={reel.title} 
              className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
            />
            {/* Gradient Overlay */}
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>
            
            {/* Play Button Center */}
            <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              <div className="w-16 h-16 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center border border-white/40">
                <span className="material-symbols-outlined text-white text-4xl" style={{ fontVariationSettings: "'FILL' 1" }}>play_arrow</span>
              </div>
            </div>

            {/* Bottom Content */}
            <div className="absolute bottom-0 left-0 w-full p-6 text-white">
              <h4 className="text-body-lg font-bold line-clamp-2 mb-2 leading-tight shadow-black drop-shadow-md">
                {reel.title}
              </h4>
              <div className="flex items-center gap-4 text-label-md opacity-90">
                <span className="flex items-center gap-1">
                  <span className="material-symbols-outlined text-[1rem]">visibility</span>
                  {reel.views}
                </span>
                <span className="flex items-center gap-1">
                  <span className="material-symbols-outlined text-[1rem]">schedule</span>
                  {reel.duration}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
      
      <div className="md:hidden mt-4 text-center">
        <a href="https://github.com/mdrakibulhaquesardar/Ava-Quran/releases/download/v1.0.0/avaQuraniaV1.0.0.apk" className="inline-block bg-primary text-on-primary px-8 py-3 rounded-full font-label-md text-label-md w-full">
          Open Reels in App
        </a>
      </div>
    </section>
  );
};

export default ReelsSection;
