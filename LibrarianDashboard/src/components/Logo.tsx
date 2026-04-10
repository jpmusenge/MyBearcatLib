// src/components/Logo.tsx

interface Props {
    className?: string;
  }
  
  export default function Logo({ className = "w-16 h-16" }: Props) {
    return (
      <svg 
        viewBox="0 0 100 100" 
        fill="none" 
        xmlns="http://www.w3.org/2000/svg"
        className={className}
      >
        <defs>
          <linearGradient id="bg-grad" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#2E5FBF" />
            <stop offset="100%" stopColor="#0F2557" />
          </linearGradient>
          <filter id="shadow" x="-10%" y="-10%" width="120%" height="120%">
            <feDropShadow dx="0" dy="8" stdDeviation="6" floodColor="#0F2557" floodOpacity="0.35"/>
          </filter>
        </defs>
  
        {/* iOS Squircle Background */}
        <rect 
          x="5" y="5" 
          width="90" height="90" 
          rx="22" 
          fill="url(#bg-grad)" 
          filter="url(#shadow)"
        />
  
        {/* Books Group */}
        <g transform="translate(0, 4)">
          {/* Left Book (White) */}
          <rect x="25" y="40" width="13" height="40" rx="3.5" fill="#FFFFFF" />
          
          {/* Middle Book (Rust College Gold) */}
          <rect x="43" y="30" width="13" height="50" rx="3.5" fill="#D4952A" />
          
          {/* Right Book (Leaning, translucent white) */}
          {/* Rotated 16 degrees from its bottom-left corner */}
          <rect 
            x="59" y="37" 
            width="13" height="43" 
            rx="3.5" 
            fill="#FFFFFF" 
            fillOpacity="0.6" 
            transform="rotate(16, 59, 80)"
          />
        </g>
  
        {/* Digital Sync Dot */}
        <circle cx="75" cy="27" r="5.5" fill="#D4952A" />
      </svg>
    );
  }