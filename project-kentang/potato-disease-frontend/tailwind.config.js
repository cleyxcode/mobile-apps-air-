/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#4cae7d',
        'background-light': '#f6f7f7',
        'background-dark': '#151d19',
        'brand-dark': '#1a4d2e',
      },
      fontFamily: {
        display: ['Space Grotesk', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
