module.exports = {
  module: {
    rules: [
      { test: /\.css/, use: ['style-loader', 'css-loader'] },
      { test: /\.scss/, use: [
        'style-loader',
        { loader: 'css-loader', options: { sourceMaps: true } },
        { loader: 'sass-loader', options: { sourceMaps: true } }
      ]},
    ]
  }
}
