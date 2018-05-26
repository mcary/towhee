const MiniCssExtractPlugin = require('mini-css-extract-plugin');

// Set this env var by prefixing the command with:
//   NODE_ENV=production
const style_loader = process.env.NODE_ENV !== 'production' ?
  'style-loader' :
  MiniCssExtractPlugin.loader;

module.exports = {
  devServer: {
    contentBase: './dist',
    watchContentBase: true
  },
  plugins: [
    new MiniCssExtractPlugin()
  ],
  module: {
    rules: [
      { test: /\.css/, use: [style_loader, 'css-loader'] },
      { test: /\.scss/, use: [
        style_loader,
        { loader: 'css-loader', options: { sourceMaps: true } },
        { loader: 'sass-loader', options: { sourceMaps: true } }
      ]},
    ]
  }
}
