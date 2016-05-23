var gulp = require('gulp')
var config = require('../config')
var $ = require('gulp-load-plugins')()

var minifyImage = function() {
	return gulp.src(config.src + 'images/*')
		.pipe($.imagemin())
		.pipe(gulp.dest(config.dest + 'images/'))
}

gulp.task('minify-image', minifyImage)