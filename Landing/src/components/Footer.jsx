import React from 'react';

const Footer = () => {
  return (
    <footer className="bg-surface-container-low border-t border-outline-variant">
      <div className="flex flex-col md:flex-row justify-between items-center w-full px-margin-page py-stack-md max-w-7xl mx-auto gap-gutter-grid">
        <div className="flex flex-col items-center md:items-start gap-4">
          <div className="flex items-center gap-3">
            <img 
              alt="Ava Qurania Logo" 
              className="h-8 w-8" 
              src="https://lh3.googleusercontent.com/aida-public/AB6AXuDNDF0FB04zjIJlDQkii-18PPzU0R9QHPm_-XtiF00m7C_KUbC-KpNK5cVCVD1JZzNFQbOeBRPN4QI_svLzpTQ0F-g-WI5I0J8tjcoinUp8gcH0WPXE5ooCMebsyUFzk6Ykoq818Ob_M4q98aTHmZyw7YCq6xVq4DGpfUtzOP2CS2qF_JmDHxI0psela8AppMBBSrRgq3Y2DobOqO5-J0eJU1pu6XC5Zl08QBuhRgEt5i_OQGLm61YEZdNnimpLwuU8OciBJN6RJfvJ" 
            />
            <span className="text-headline-lg font-headline-lg font-bold text-primary">Ava Qurania</span>
          </div>
          <p className="text-body-md font-body-md text-on-surface-variant opacity-80 text-center md:text-left">
            © {new Date().getFullYear()} Ava Qurania. Sacred Stillness in Every Verse.
          </p>
        </div>
        
        <div className="flex flex-wrap justify-center gap-8">
          <a className="text-on-surface-variant hover:text-primary transition-all underline font-label-md text-label-md" href="#">Privacy Policy</a>
          <a className="text-on-surface-variant hover:text-primary transition-all underline font-label-md text-label-md" href="#">Terms of Service</a>
          <a className="text-on-surface-variant hover:text-primary transition-all underline font-label-md text-label-md" href="#">Contact Support</a>
          <a className="text-on-surface-variant hover:text-primary transition-all underline font-label-md text-label-md" href="#">Global Community</a>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
