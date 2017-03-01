// https://github.com/shelljs/shelljs
require('./check-versions')()
require('shelljs/global')

switch (process.argv[2]) {
  case "production":
  case undefined:
     env.NODE_ENV = "production";
    break;
  case "cloud-test":
    env.NODE_ENV = "cloud-test";
    break;
  default:
    console.warn("Invalid stage. production / cloud-test");
    exit(2);
    break;
}

var path = require('path')
var config = require('../config')
var ora = require('ora')
var webpack = require('webpack')
var webpackConfig = require('./webpack.prod.conf')

console.log(
  '  Tip:\n' +
  '  Built files are meant to be served over an HTTP server.\n' +
  '  Opening index.html over file:// won\'t work.\n'
)

var spinner = ora(`building for ${env.NODE_ENV}...`)
spinner.start()

var assetsPath = path.join(config.build.assetsRoot, config.build.assetsSubDirectory)
rm('-rf', assetsPath)
mkdir('-p', assetsPath)
cp('-R', 'static/*', assetsPath)

webpack(webpackConfig, function (err, stats) {
  spinner.stop()
  if (err) throw err
  process.stdout.write(stats.toString({
    colors: true,
    modules: false,
    children: false,
    chunks: false,
    chunkModules: false
  }) + '\n')
})
