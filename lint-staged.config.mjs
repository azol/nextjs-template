import path from "node:path";

const buildEslintCommand = (filenames) =>
  `eslint --fix ${filenames
    .map((f) => `"${path.relative(process.cwd(), f)}"`)
    .join(" ")}`;

const config = {
  "*.{js,jsx,ts,tsx,mjs}": [buildEslintCommand, "prettier --write"],
  "*.json": ["prettier --write"],
  "*.css": ["prettier --write"],
  "*.md": ["prettier --write"],
};

export default config;
