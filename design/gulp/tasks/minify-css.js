var gulp = require('gulp');
var config = require('../config');
var $ = require('gulp-load-plugins')();

var minifyCss = function() {
	return gulp.src(config.dest + 'css/style.css')
		.pipe($.sourcemaps.init())
		.pipe($.cleanCss())
		.pipe($.rename({
			extname: '.min.css'
		}))
		.pipe($.sourcemaps.write('./'))
		.pipe(gulp.dest(config.dest + 'css/'))
};

gulp.task('minify-css', ['sass'], minifyCss);
