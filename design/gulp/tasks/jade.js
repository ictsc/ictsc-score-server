var gulp = require('gulp')
var config = require('../config')
var $ = require('gulp-load-plugins')()

var jade = function() {
	return gulp.src(config.src + 'jade/**/!(_)*.jade')
		.pipe($.plumber({
			errorHandler: $.notify.onError('<%= error.message %>'),
		}))
		.pipe($.jade({
			basedir: config.src + 'jade/'
		}).on('error', function(e) {
			console.log(e)
			this.emit('end')
		}))
		.pipe(gulp.dest(config.root + 'public/'))
}

gulp.task('jade', jade)
