import React from 'react';

const RecitersSection = () => {
  const reciters = [
    {
      name: 'Mishary Rashid Alafasy',
      imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBZgxrZeQveraTOp6PgvZYWnlnAMHbVgcUg5US2OjXJ6ZM8sHvjWFHmickCoP1MiEC6wt0bMR_B7NW48V0XgHNYpLiekUA4rhUaOLi4xLH-GhnrpHbcNWKkMcVIplUS6nipxMaBeroN6qViEYFyW-2sfJWluokMd4DRgp9di8wnZ7yTEhHKcowO8cSyBRWj2Zq17g3fvI0MTyNjyROH5h7PX2da5y_WFztvrOefwpb538kt3_AnNmes0QHdr4Io4kh6AtU0U1Ba4iXV',
      alt: 'Professional studio portrait of a male Quran reciter wearing traditional white attire, looking serene and focused against a soft, luminous mint green background.'
    },
    {
      name: 'Abdul Rahman Al-Sudais',
      imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBHYNr7Q5KfT0MsO69wTvwVHBo6XQ8sP7DWInzDxf97obwIz7hTJbMzprCUcYPZU4ogSsReU8mqmzznIHHIoto8tVoVIHUKFBfnMXlBLJVubRVbCibfBBcsDUW-Hckxc-0MbOTcxb_upInXtInL6yqdFljv1FiDir-hRqdCWbaa1qURoEgvYtupCpqRAIU063SBEVH3F-tQMWFzQa7Wte-fAqoOT4kZ1bcCrjnhAYPwf5xRvYTzIyadXyqPcGklG0CprKY9K_MPlqlK',
      alt: 'Professional portrait of a distinguished Islamic scholar and reciter in traditional robes. The background is a vast, minimalist sunlit courtyard in a soft mint palette.'
    },
    {
      name: 'Abdul-Basit Samad',
      imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCUp82aiIa3my79n2ZbZzz5i1dwDdrIkdYPWh1owxZWmmAilAxKAbSzr14R_aT1knIAPpEnoMNW4zNih4VneD0dNd9bTWLiTFiFFlzZISpeXdG8patxSEVmfvFtgX1-6u6kYWcQV0yvxdr4sDMQk0zkpcqDC_cH1XGdk7-Nwq_ufXucafsEAS5bKNM0Vizv0jnKvMSbm7j1WicVg4ZwVBeNwvjVpgoUA7rLk5IFM7Q_-6FTZiS5mUETW5vh5S10GvpL_eMkJc-of9jA',
      alt: 'Calm portrait of a young reciter with a gentle expression. The visual style is contemporary minimalism with organic accents, featuring a soft mint green and off-white color palette.'
    },
    {
      name: 'Yasser Al-Dosari',
      imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAjKIcfoOPcWKf1QqdLmMq7y3rPpHKLeJ_9wvdpsmu30eyPFkDtK-W_yC9n8WOkWByp2zc3nMTdZlOFFvhIV1ZjlyaKXnV2yz3aiW8mdLNNA7ehpsEthUqTgsun4mxMf7ywhJGy3AKOprfEko7n0AruzcUYbZd-_W_GodgA5c1pEl_kHeEHDG7UZzW9MwU8GKFRBIeQ3v5XseceCEZ4bFHbjNkRoZkCmtaPw_yt-zXIHiIBFs8Ae-33RTpJZZZN38TwSchp0drPB8k2',
      alt: 'Artistic portrait of a senior reciter against a luminous off-white background with subtle teal accents. The mood is tranquil and reflective, designed for a modern global audience.'
    },
    {
      name: 'Abdul Aziz Al-Baleela',
      imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBw01LCA_ZWCdk1h1-Gy1eQu2dK2_HPVzzd49sXvAK1MI-Pu1o6XJllmS28nySySLcOWTvvJDnGlX_yYUza-NglSr0975wsvfYW5JELUigNMNXpxGhOlIgWtbXl5xs2a43JpLJaL2o_WUMDRAESyOSc150EPxOdNtqEUIN6qXmGU_OrDANFdhEBY3MDnMRYhkCH5KULJUAF5_cxvgDh8j-BuZuNr45aKkBZ4VPCRmxhN2HGWDJImTZdcT9sVqyKd8vDRltFBzoY_G6P',
      alt: 'Luminous portrait of a Quran reader in a modern mosque setting. The space is filled with airy whitespace and soft natural lighting. The overall aesthetic is one of sacred stillness.'
    },
    {
      name: 'Abdur Rahman Al Ossi',
      imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCXEQGmjmQUQ8TSIZtaTevHseBgf_m-uLECedz72xmfIcpLuFcEvvg7W5wFgOPHKsOlASKS6PkuAwE17e3GzKXRZGaf3d0gSgckAMPS20Of9mmTXmOlpAjyVmAoBSFE0LuPLlFaHh6TRqz0z45IFzQa2dudpPai6SZ_wi28WkzLpZH-7yGnfw7TvFmoc2XTXgH_vI2CMokU-YTJjF6W3TTDVe6ui_WsEKsH3efgiX4Jo4rUHLnt4ffV0Ke8tPIfCpxLpEUybr9l4GlZ',
      alt: 'Professional headshot of a spiritual guide and reciter. The style is contemporary minimalism, featuring clean lines and a soft, sunlit atmosphere.'
    }
  ];

  return (
    <section className="mb-stack-lg py-12">
      <div className="flex justify-between items-end mb-12">
        <h2 className="text-headline-xl font-headline-xl text-primary">
          Listen to Soothing Audio <br />Recitations & Radio
        </h2>
        <a className="text-primary font-bold hover:underline" href="https://github.com/mdrakibulhaquesardar/Ava-Quran/releases/download/v1.0.0/avaQuraniaV1.0.0.apk">Listen in App</a>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-8">
        {reciters.map((reciter, index) => (
          <div key={index} className="group text-center cursor-pointer">
            <div className="relative aspect-square rounded-[2.5rem] overflow-hidden mb-4 bg-surface-container-high transition-transform duration-300 group-hover:-translate-y-2">
              <img 
                className="w-full h-full object-cover grayscale opacity-80 group-hover:grayscale-0 group-hover:opacity-100 transition-all duration-500" 
                src={reciter.imgUrl} 
                alt={reciter.name}
                title={reciter.alt}
              />
            </div>
            <h4 className="text-body-md font-bold text-primary transition-colors group-hover:text-primary-container">
              {reciter.name}
            </h4>
          </div>
        ))}
      </div>
    </section>
  );
};

export default RecitersSection;
