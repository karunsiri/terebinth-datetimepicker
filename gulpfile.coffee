# Dependencies
gulp          = require 'gulp'
gutil         = require 'gulp-util'
concat        = require 'gulp-concat'
rename        = require 'gulp-rename'
coffee        = require 'gulp-coffee'
uglify        = require 'gulp-uglify'
watch         = require 'gulp-watch'
templateCache = require 'gulp-angular-templatecache'
del           = require 'del'

paths = {
  coffee: ['./src/coffee/**/*.coffee'],
  templates: ['./src/templates/**/*.html']
}

gulp.task 'coffee', ->
  gulp.src paths.coffee
    .pipe coffee()
      .on 'error', gutil.log
    .pipe concat 'terebinth-datetimepicker.js'
    .pipe gulp.dest './src/build/'

  return

gulp.task 'templatecache', ->
  gulp.src paths.templates
    .pipe templateCache(module: 'terebinth.datetimepicker', transformUrl: (url) -> "/#{url}")
    .pipe rename 'terebinth-datetimepicker-template.js'
    .pipe gulp.dest './src/build/'

gulp.task 'concat', ['compile'], ->
  gulp.src ['./src/build/terebinth-datetimepicker.js', './src/build/terebinth-datetimepicker-template.js']
    .pipe concat 'terebinth-datetimepicker.js'
    .pipe gulp.dest './dist'
    .pipe uglify()
    .pipe rename 'terebinth-datetimepicker.min.js'
    .pipe gulp.dest './dist'

gulp.task 'compile', ['coffee', 'templatecache']

gulp.task 'build', ['concat'], ->
  del ['./src/build/**/*', './src/build']

gulp.task 'watch', ->
  watch paths.coffee, -> gulp.start 'build'
  watch paths.templates, -> gulp.start 'build'

gulp.task 'default', ['watch', 'build']