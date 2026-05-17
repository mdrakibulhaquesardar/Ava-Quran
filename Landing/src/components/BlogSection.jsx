import React from 'react';

const BlogSection = () => {
  const articles = [
    {
      title: 'A Moment of Peace with Reels',
      excerpt: 'Watch short, inspiring Islamic clips and reels curated to bring tranquility to your feed...',
      imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB1BmvwHxYSNKRftQDq5Z9V3_VjsyYNIXUsMBjcNhpve4YH41tIz2WCrSRRbu7LQueTtUU2LvUGSZl55kWyn37ywX8on0JTx8qFvuBBVDu5bdnMdqp8D407RoDZqVRPukI8RJ-N1tNzCh6gETi3XRUJldluzABk-KhdkaNDztH29ypNVfiv8DfWW7WRs0ZGD_fUJSoNZeXbohK1JmBJ-AzylKtAzJy-mV7Io12qUxeZ6MOUTys2RNTTBSspwtd2TiJrV1wdXm7WiDpL',
      alt: 'A cinematic, wide-angle photograph of a majestic white marble mosque at dawn, reflected in a still pool of water. The lighting is high-key and ethereal, with soft pink and mint tones in the sky.'
    },
    {
      title: 'Authentic Tafsir Insights',
      excerpt: 'Dive deep into the meanings of the Holy Quran with scholarly commentary and context...',
      imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA-8R1b9ZLHCvAnt4CTGyJAhgjH33S5oloFZA-xbPUZxD_GNzLNt7wBOa6Lc-ZOGrfhZQCnET91NG7fUNZjGhI3qup9ygl7gHtj5NCGK91lKmeyog5jXSkeTltvS3f1LsdTnlFmkcywnFh9J6BMupNv6wGw27QCtGrRKCyQjFWoX2LIrwU6PeouVcUaC6z3n-w7tgjpUdW-rWhbNMv8sSPz4KleY6olHxjD2ASt71rZGJQ1l2TkIsqaIDdKWfqQsl6nLggY1iQlOUC5',
      alt: 'A minimalist architectural detail of the Kaaba in Mecca, showing the golden embroidery on the black Kiswa cloth. The background is a luminous, high-key white, creating a powerful contrast.'
    },
    {
      title: 'Seamless Audio Experience',
      excerpt: 'Listen to world-class reciters with our beautifully designed background audio player...',
      imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDUzLbiOxSN7wxUxk-eU1ahnZwUubhppbpQP-jOCzs7smRkPq2HI1NR-khj2NHgsm2-0RdQjAUxoyIlWUDO95r7quWzPgNBEc_25BdSNfOQOK_SCafvg38LoCq5oOsVylArwvhA8hBtMiF4YkFca2T0qJ-d4V48glEchwXUerGyoF1Lu84AHSpdD5B93UUwLuqHuFmJqkyrh_sxkeRuhwelscvJfd3OoEFCBjGlB-pNBNcZJbCUA5C70B10dw9S9Z6tqfqf36Y3QQWV',
      alt: 'Close-up of a hand holding a beautifully bound Quran with gold lettering against a soft, sunlit mint green background. The image uses a shallow depth of field and soft ambient shadows.'
    }
  ];

  return (
    <section className="mb-stack-lg">
      <h2 className="text-headline-xl font-headline-xl text-primary mb-12">
        Explore Premium App <br />Features Everyday.
      </h2>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {articles.map((article, index) => (
          <article 
            key={index} 
            className="bg-surface-container-lowest rounded-2xl overflow-hidden sacred-shadow group flex flex-col h-full hover:shadow-2xl transition-all duration-300 border border-outline-variant/10 cursor-pointer"
          >
            <div className="relative h-64 overflow-hidden bg-surface-container-high">
              <img 
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" 
                src={article.imgUrl} 
                alt={article.title}
                title={article.alt}
              />
            </div>
            
            <div className="p-8 flex flex-col flex-1">
              <h3 className="text-headline-lg font-headline-lg text-primary mb-4 transition-colors group-hover:text-primary-container">
                {article.title}
              </h3>
              
              <p className="text-body-md text-on-surface-variant line-clamp-3 mb-6">
                {article.excerpt}
              </p>
              
              <div className="mt-auto">
                <a className="inline-flex items-center gap-2 text-primary font-bold text-label-md font-label-md hover:text-primary-container transition-colors" href="#">
                  View Feature
                  <span className="material-symbols-outlined text-sm transition-transform duration-200 group-hover:translate-x-1 group-hover:-translate-y-1">
                    arrow_outward
                  </span>
                </a>
              </div>
            </div>
          </article>
        ))}
      </div>
      
      <div className="mt-12 text-center">
        <a href="https://github.com/mdrakibulhaquesardar/Ava-Quran/releases/download/v1.0.0/avaQuraniaV1.0.0.apk" className="inline-block bg-primary text-on-primary px-10 py-4 rounded-full font-label-md text-label-md scale-95 active:scale-90 hover:shadow-lg transition-all duration-150">
          Explore All Features in App
        </a>
      </div>
    </section>
  );
};

export default BlogSection;
