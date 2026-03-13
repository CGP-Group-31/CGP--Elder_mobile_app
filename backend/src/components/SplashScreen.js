import React, { useState, useEffect } from 'react';

export default function SplashScreen({ onFinish }) {
  const [phase, setPhase] = useState(0);

  useEffect(() => {
    const t1 = setTimeout(() => setPhase(1), 300);
    const t2 = setTimeout(() => setPhase(2), 1200);
    const t3 = setTimeout(() => setPhase(3), 2200);
    const t4 = setTimeout(() => onFinish(), 3400);
    return () => { clearTimeout(t1); clearTimeout(t2); clearTimeout(t3); clearTimeout(t4); };
  }, [onFinish]);

  return (
    <div className="splash-screen">
      {/* Animated background elements */}
      <div className="splash-bg">
        <div className="splash-circle splash-circle-1"></div>
        <div className="splash-circle splash-circle-2"></div>
        <div className="splash-circle splash-circle-3"></div>
        <div className="splash-pulse-ring"></div>
      </div>

      <div className={`splash-content ${phase >= 1 ? 'visible' : ''}`}>
        {/* Logo */}
        <div className={`splash-logo ${phase >= 1 ? 'animate-in' : ''}`}>
          <div className="splash-logo-icon">
            <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
              <path d="M24 4C13 4 4 13 4 24s9 20 20 20 20-9 20-20S35 4 24 4z" fill="rgba(255,255,255,0.15)"/>
              <path d="M32 20h-6v-6a2 2 0 10-4 0v6h-6a2 2 0 100 4h6v6a2 2 0 104 0v-6h6a2 2 0 100-4z" fill="white"/>
              <path d="M17 34c-1.5-2-2.5-4.5-2.5-7.5 0-1 .1-2 .4-3" stroke="rgba(255,255,255,0.5)" strokeWidth="1.5" strokeLinecap="round"/>
              <path d="M31 34c1.5-2 2.5-4.5 2.5-7.5 0-1-.1-2-.4-3" stroke="rgba(255,255,255,0.5)" strokeWidth="1.5" strokeLinecap="round"/>
            </svg>
          </div>
          <div className="splash-logo-heartbeat">
            <svg viewBox="0 0 200 40" className="heartbeat-svg">
              <polyline
                className="heartbeat-line"
                fill="none"
                stroke="rgba(255,255,255,0.6)"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                points="0,20 30,20 40,20 50,8 60,32 70,12 80,28 90,20 120,20 130,20 140,8 150,32 160,12 170,28 180,20 200,20"
              />
            </svg>
          </div>
        </div>

        {/* Title */}
        <div className={`splash-title ${phase >= 1 ? 'animate-in' : ''}`}>
          <h1>ElderCare</h1>
          <div className="splash-divider"></div>
          <h2>Doctor Portal</h2>
        </div>

        {/* Tagline */}
        <p className={`splash-tagline ${phase >= 2 ? 'animate-in' : ''}`}>
          Compassionate Care, Smart Technology
        </p>

        {/* Loading bar */}
        <div className={`splash-loader ${phase >= 2 ? 'animate-in' : ''}`}>
          <div className="splash-loader-track">
            <div className={`splash-loader-bar ${phase >= 2 ? 'loading' : ''}`}></div>
          </div>
          <span className="splash-loader-text">
            {phase < 3 ? 'Initializing...' : 'Ready'}
          </span>
        </div>
      </div>

      {/* Fade out overlay */}
      <div className={`splash-fadeout ${phase >= 3 ? 'active' : ''}`}></div>
    </div>
  );
}
