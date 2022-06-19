import { URL } from 'node:url';
import webpack from 'webpack';

const NODE_ENV = 'production';

const name = 'PublicRetroBoardWidget';

export default {
  context: new URL('./public/build', import.meta.url).pathname,
  entry: {},
  mode: NODE_ENV,
  output: {
    filename: '[name].js',
    chunkFilename: '[id].[contenthash].js',
    path: new URL('./public/build/dist', import.meta.url).pathname,
    clean: true,
    publicPath: 'auto',
  },
  resolve: {
    extensions: ['.js'],
  },
  plugins: [
    new webpack.container.ModuleFederationPlugin({
      name,
      filename: '[name].js',
      exposes: { '.': './PublicRetroBoard.js' },
      shared: {},
    }),
  ],
};
