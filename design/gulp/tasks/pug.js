var gulp = require('gulp');
var config = require('../config');
var $ = require('gulp-load-plugins')();

var pug = function() {
	return gulp.src(config.src + 'pug/**/!(_)*.pug')
		.pipe($.plumber({
			errorHandler: $.notify.onError('<%= error.message %>')
		}))
		.pipe($.pug({
			basedir: config.src + 'pug/',
			pretty: true
		}).on('error', function(e) {
			console.log(e);
			this.emit('end')
		}))
		.pipe(gulp.dest(config.root + 'public/'))
};

gulp.task('pug', pug);
