var gulp = require('gulp');
var config = require('../config');
var $ = require('gulp-load-plugins')();
var del = require('del');

var clean = function() {
	return del([
		config.root + 'public/assets/**/*',
		config.root + 'public/**/*.html'
	]);
};

gulp.task('clean', clean);
