var gulp = require('gulp')
var config = require('../config')
var $ = require('gulp-load-plugins')()
var imageminPngquant = require('imagemin-pngquant')

var minifyImage = function() {
	return gulp.src(config.src + 'images/*.{png,svg}')
		.pipe($.imagemin({
			'plugins': [
				imageminPngquant({
					'quality': '60-80',
					'speed': 1
				})
			],
			'verbose': [
				true
			]
		}))
		.pipe(gulp.dest(config.dest + 'images/'))
}

gulp.task('minify-image', minifyImage)
