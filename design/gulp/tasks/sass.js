var gulp = require('gulp')
var config = require('../config')
var $ = require('gulp-load-plugins')()

var sass = function() {
	return gulp.src(config.src + 'scss/style.scss')
		.pipe($.plumber({
			errorHandler: $.notify.onError('<%= error.message %>')
		}))
		.pipe($.sourcemaps.init())
		.pipe($.sass().on('error', function(e) {
			console.log(e)
			this.emit('end')
		}))
		.pipe($.sourcemaps.write('./'))
		.pipe(gulp.dest(config.dest + 'css/'))
};

gulp.task('sass', sass)
