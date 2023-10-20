module.exports = {
  content: ['./src/routes/**/*.{svelte,js,ts}'],
  plugins: [require("@tailwindcss/typography"), require('daisyui')],
  daisyui: {
    themes: ["light", "dark", {
      emerald: {
        ...require("daisyui/src/theming/themes")["[data-theme=emerald]"],
        "primary": "#C2E5D6",
        "base-200": "#FADCB5",
      }
    }],
  },
  theme: {
    extend: {
      animation: {
        'spin-reverse': 'spinreverse 1s linear infinite',
      },
      keyframes: {
        spinreverse: {
          'from': { transform: 'rotate(360deg)'},
          'to': { transform: 'rotate(0deg)' }
        }
      }
    }
  }
};
