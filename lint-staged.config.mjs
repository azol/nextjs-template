const config = {
  "*.{js,jsx,ts,tsx,cjs,mjs,cts,mts}": ["eslint --fix", "prettier --write"],
  "*.{json,jsonc,css,md,mdx,yml,yaml}": ["prettier --write"],
};

export default config;
