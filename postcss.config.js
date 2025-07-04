console.log("▶️  Loading PostCSS config with plugins:", [
  "postcss-import",
  "tailwindcss",
  "autoprefixer",
]);

module.exports = {
  plugins: [
    require("postcss-import")({
      path: ["./web/assets", "./node_modules"]
    }),
    require("tailwindcss"),
    require("autoprefixer"),
  ],
}
