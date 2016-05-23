var gulp = require('gulp');
var runSequence = require('run-sequence');

var build = function(done) {
	runSequence(
		['sass', 'minify-image'],
		'minify-css',
		done
	);
};

gulp.task('build', build);
