var gulp = require('gulp')
var config = require('../config')
var $ = require('gulp-load-plugins')()

var watch = function() {
	gulp.watch(config.src + 'jade/**/*.jade', ['jade'])
	gulp.watch(config.src + 'scss/**/*.scss', ['minify-css'])
	gulp.watch(config.src + 'images/*.{png,svg}', ['minify-image'])
};

gulp.task('watch', ['build'], watch)
