var gulp = require('gulp');
var config = require('../config');
var $ = require('gulp-load-plugins')();
var del = require('del');

var clean = function() {
	return del([
		config.dest + '**/*',
		config.dest + '../**/*.html',
	]);
};

gulp.task('clean', clean);
