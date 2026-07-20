/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        elyade: {
          50: '#fdf2f8',
          100: '#fce7f3',
          200: '#fbcfe8',
          300: '#f9a8d4',
          400: '#f472b6',
          500: '#ec1878',
          600: '#ca0088',
          700: '#a8006f',
          800: '#8a005a',
          900: '#650044',
          950: '#42002c',
        },
        ink: {
          50: '#f6f7f9',
          100: '#eceef1',
          200: '#d5d9df',
          300: '#b0b8c2',
          400: '#8590a0',
          500: '#677082',
          600: '#525a6b',
          700: '#43495a',
          800: '#3a3f4d',
          900: '#32373c',
          950: '#25292f',
        },
      },
      fontFamily: {
        sans: ['Inter', 'Segoe UI', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        card: '0 1px 3px 0 rgb(0 0 0 / 0.06), 0 1px 2px -1px rgb(0 0 0 / 0.06)',
        elevated: '0 10px 30px -12px rgb(101 0 68 / 0.18)',
      },
    },
  },
  plugins: [],
};
