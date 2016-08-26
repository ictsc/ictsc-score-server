

const webpack = require('webpack');
const helpers = require('./helpers');


const CopyWebpackPlugin = require('copy-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ForkCheckerPlugin = require('awesome-typescript-loader').ForkCheckerPlugin;
const HtmlElementsPlugin = require('./html-elements-plugin');
const ExtractTextPlugin = require("extract-text-webpack-plugin");

const METADATA = {
  title: 'ICTSC6 Score Server',
  baseUrl: '/',
  isDevServer: helpers.isWebpackDevServer()
};

module.exports = {

  metadata: METADATA,

  // http://webpack.github.io/docs/configuration.html#entry
  entry: {

    'polyfills': './src/polyfills.browser.ts',
    'vendor':    './src/vendor.browser.ts',
    'main':      './src/main.browser.ts'

  },

  // http://webpack.github.io/docs/configuration.html#resolve
  resolve: {

    // http://webpack.github.io/docs/configuration.html#resolve-extensions
    extensions: ['', '.ts', '.js', '.json'],
    root: helpers.root('src'),
    modulesDirectories: ['node_modules'],

  },

  // http://webpack.github.io/docs/configuration.html#module
  module: {

    // http://webpack.github.io/docs/configuration.html#module-preloaders-module-postloaders
    preLoaders: [

      //https://github.com/wbuchwalter/tslint-loader
      // { test: /\.ts$/, loader: 'tslint-loader', exclude: [ helpers.root('node_modules') ] },

      // https://github.com/webpack/source-map-loader
      {
        test: /\.js$/,
        loader: 'source-map-loader',
        exclude: [
          // these packages have problems with their sourcemaps
          helpers.root('node_modules/rxjs'),
          helpers.root('node_modules/@angular'),
          helpers.root('node_modules/@ngrx'),
          helpers.root('node_modules/@angular2-material'),
        ]
      }

    ],

    // http://webpack.github.io/docs/configuration.html#module-loaders
    loaders: [

      // https://github.com/s-panferov/awesome-typescript-loader
      {
        test: /\.ts$/,
        loaders: ['awesome-typescript-loader', 'angular2-template-loader'],
        exclude: [/\.(spec|e2e)\.ts$/]
      },

      // https://github.com/webpack/json-loader
      {
        test: /\.json$/,
        loader: 'json-loader'
      },

      {
        test: /\.css$/,
        // loaders: ExtractTextPlugin.extract(['to-string-loader', 'css-loader', 'source-map-loader'])
        loader: ExtractTextPlugin.extract('css-loader?sourceMap')
      },

      //https://github.com/webpack/raw-loader

      {
        test: /\.html$/,
        loader: 'raw-loader',
        exclude: [helpers.root('src/index.html')]
      },

      {
        test: /\.jade$/,
        loader: 'raw!jade-html'
      },
      {
        test: /\.scss$/,
        loader: 'to-string!css!sass'
      },
      {
        test: /\.(ttf|otf|eot|svg|woff(2)?)(\?.*)?$/,
        loader: 'file-loader?name=fonts/[name].[ext]'
      }
    ]

  },

  //http://webpack.github.io/docs/configuration.html#plugins

  plugins: [

    //https://github.com/s-panferov/awesome-typescript-loader#forkchecker-boolean-defaultfalse

    new ForkCheckerPlugin(),

    //https://webpack.github.io/docs/list-of-plugins.html#occurrenceorderplugin
    // https://github.com/webpack/docs/wiki/optimization#minimize

    new webpack.optimize.OccurenceOrderPlugin(true),

    // https://webpack.github.io/docs/list-of-plugins.html#commonschunkplugin
    // https://github.com/webpack/docs/wiki/optimization#multi-page-app

    new webpack.optimize.CommonsChunkPlugin({
      name: ['polyfills', 'vendor'].reverse()
    }),
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.jQuery": "jquery",
      "Tether": "tether"
    }),


    // https://www.npmjs.com/package/copy-webpack-plugin

    new CopyWebpackPlugin([{
      from: 'src/assets',
      to: 'assets'
    }]),

    // https://github.com/ampedandwired/html-webpack-plugin

    new HtmlWebpackPlugin({
      template: 'src/index.html',
      chunksSortMode: 'dependency'
    }),


    new HtmlElementsPlugin({
      headTags: require('./head-config.common')
    }),

    new ExtractTextPlugin("[name].css")

  ],

  // https://webpack.github.io/docs/configuration.html#node

  node: {
    global: 'window',
    crypto: 'empty',
    module: false,
    clearImmediate: false,
    setImmediate: false,
    fs: "empty"
  }

};
