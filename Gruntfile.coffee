# Gruntfile courtesy of trek (https://github.com/trek/)
# ember-todos-with-build-tools-tests-and-other-modern-conveniences
module.exports = (grunt) ->

  grunt.loadNpmTasks "grunt-bower-task"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-qunit"
  grunt.loadNpmTasks "grunt-neuter"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-ember-templates"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-karma"
  grunt.loadNpmTasks "grunt-banner"
  grunt.loadNpmTasks "grunt-text-replace"
  grunt.loadNpmTasks "grunt-release-it"

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    banner: '/*!\n* <%=pkg.name %> v<%=pkg.version%>\n' +
            '* Copyright 2013-<%=grunt.template.today("yyyy")%> Addepar Inc.\n' +
            '* See LICENSE.\n*/',

    clean:
      target: ['build', 'dist' , 'gh_pages']

    karma:
      continuous:  # continuous integration mode
        configFile: 'karma.conf.js'
        singleRun: true
      unit:
        configFile: 'karma.conf.js'
        singleRun: false
        exclude: ['build/src/ember_widgets.js', 'build/tests/functional/*.js', 'build/tests/integration/*.js'],
      functional:
        configFile: 'karma.conf.js'
        singleRun: false
        exclude: ['build/src/ember_widgets.js', 'build/tests/unit/*.js', 'build/tests/integration/*.js'],
      integration:
        configFile: 'karma.conf.js'
        singleRun: false
        exclude: ['build/src/ember_widgets.js', 'build/tests/unit/*.js', 'build/tests/functional/*.js'],
      default:
        configFile: 'karma.conf.js'
        singleRun: false

    uglify:
      "dist/js/ember-widgets.min.js": "dist/js/ember-widgets.js"

    # https://github.com/yatskevich/grunt-bower-task
    bower:
      install:
        options:
          targetDir: 'vendor'
          layout: 'byComponent'
          verbose: true
          copy: false

    coffee:
      srcs:
        options:
          bare: true
        expand: true
        cwd: "src/"
        src: [ "**/*.coffee" ]
        dest: "build/src/"
        ext: ".js"
      app:
        options:
          bare: true
        expand: true
        cwd: "app/"
        src: [ "**/*.coffee" ]
        dest: "build/app/"
        ext: ".js"
      tests:
        options:
          bare: true
          sourceMap: false
        expand: true
        cwd: "tests/"
        src: ["**/*.coffee" ]
        dest: "build/tests/"
        ext: ".js"

    emberTemplates:
      options:
        templateName: (sourceFile) ->
          sourceFile.replace(/src\/templates\//, '')
                    .replace(/app\/templates\//, '')
      srcs:
        files:
          'build/src/templates.js': ["src/templates/**/*.hbs"]
      app:
        files:
          'build/app/templates.js': ["app/templates/**/*.hbs"]

    neuter:
      options:
        includeSourceURL: yes
      srcs:
        files:
          "dist/js/ember-widgets.js": "build/src/ember_widgets.js"
      app:
        files:
          "gh_pages/app.js": "build/app/app.js"

    less:
      srcs:
        options:
          yuicompress: no
        files:
          "dist/css/ember-widgets.css": "src/css/ember-widgets.less"
      app:
        options:
          yuicompress: no
        files:
          "gh_pages/css/app.css": "app/assets/css/app.less"

    usebanner:
      js:
        options:
          banner: '<%=banner%>'
        files:
          src: ['dist/js/*']
      css:
        options:
          banner: '<%=banner%>'
        files:
          src: ['dist/css/*']

    replace:
      global_version:
        src: ['VERSION']
        overwrite: true
        replacements: [{
          from: /.*\..*\..*/
          to: '<%=pkg.version%>'
        }]
      srcs:
        src: ['src/ember_widgets.coffee']
        overwrite: true
        replacements: [{
          from: /Ember.Widgets.VERSION = '.*\..*\..*'/
          to: "Ember.Widgets.VERSION = '<%=pkg.version%>'"
        }]
      app:
        src: ['app/templates/ember_widgets/overview.hbs']
        overwrite: true,
        replacements: [{
          from: /The current version is .*\..*\..*./
          to: "The current version is <%=pkg.version%>."
        }]
      sourceMap:
        src: ['dist/js/ember-widgets.min.js', 'dist/js/ember-widgets.js'],
        overwrite: true,
        replacements: [{
          from: '//@ sourceURL',
          to: '//# sourceMappingURL'
        }]

    # Copy build/app/assets/css into gh_pages/asset and other assets from app
    copy:
      app:
        files: [
          {src: ['dist/css/ember-widgets.css'], dest: 'gh_pages/css/ember-widgets.css'},
          {src: ['app/index.html'], dest: 'gh_pages/index.html'},
          {expand: true, cwd: 'dependencies/', src: ['**/*.js'], dest: 'gh_pages/lib'},
          {expand: true, cwd: 'dependencies/', src: ['**/*.css'], dest: 'gh_pages/lib'},
          {expand: true, cwd: 'vendor/', src: ['**/*.js'], dest: 'gh_pages/lib'},
          {expand: true, cwd: 'vendor/', src: ['**/*.css'], dest: 'gh_pages/lib'},
          {expand: true, cwd: 'vendor/font-awesome/fonts/', src: ['**'], dest: 'gh_pages/lib/font-awesome/fonts'},
          {expand: true, cwd: 'app/assets/font/', src: ['**'], dest: 'gh_pages/fonts'},
          {expand: true, cwd: 'app/assets/img/', src: ['**'],  dest: 'gh_pages/img'},
          {expand: true, cwd: 'src/img/', src: ['**'], dest: 'gh_pages/img'}
        ]
      srcs:
        files: [
          {expand: true, cwd: 'src/img/', src: ['**'], dest: 'dist/img'}
        ]

    ###
      Watch files for changes.

      Changes in dependencies/ember.js or src javascript
      will trigger the neuter task.

      Changes to any templates will trigger the emberTemplates
      task (which writes a new compiled file into dependencies/)
      and then neuter all the files again.
    ###
    watch:
      grunt:
        files: [ "Gruntfile.coffee" ]
        tasks: [ "default" ]
      src:
        files: [ "src/**/*.coffee"]
        tasks: [ "coffee:srcs", "neuter:srcs", "uglify", "usebanner:js" ]
      test:
        files: [ "tests/**/*.coffee"]
        tasks: [ "coffee:tests" ]
      src_handlebars:
        files: [ "src/**/*.hbs" ]
        tasks: [ "emberTemplates:srcs", "neuter:srcs", "uglify", "usebanner:js" ]
      app:
        files: [ "app/**/*.coffee", "dependencies/**/*.js", "vendor/**/*.js" ]
        tasks: [ "coffee:app", "neuter:app" ]
      app_handlebars:
        files: [ "app/**/*.hbs"]
        tasks: [ "emberTemplates:app", "neuter:app" ]
      less:
        files: [ "src/**/*.less", "src/**/*.css",
                 "dependencies/**/*.less", "dependencies/**/*.css",
                 "vendor/**/*.less", "vendor/**/*.css",
                 "app/assets/**/*.less", "app/assets/**/*.css" ]
        tasks: [ "less", "copy", "usebanner:css" ]
      copy:
        files: [ "app/index.html" ]
        tasks: [ "copy" ]
      bower:
        files: [ 'bower.json']
        tasks: [ 'bower']

    ###
      Runs all .html files found in the test/ directory through PhantomJS.
      Prints the report in your terminal.
    ###
    qunit:
      all: [ "build/tests/**/*.html" ]

    ###
      Reads the projects .jshintrc file and applies coding
      standards. Doesn't lint the dependencies or test
      support files.
    ###
    jshint:
      all: ['Gruntfile.js', 'src/**/*.js', 'test/**/*.js', '!dependencies/*.*', '!vendor/*.*', '!test/support/*.*']
      options:
        jshintrc: ".jshintrc"

    ###
      Find all the <whatever>_test.js files in the test folder.
      These will get loaded via script tags when the task is run.
      This gets run as part of the larger 'test' task registered
      below.
    ###
    build_test_runner_file:
      all: [ "build/tests/**/*_test.js" ]

    "release-it":
      options:
        "pkgFiles": ["package.json", "bower.json"]
        "commitMessage": "Release %s"
        "tagName": "v%s"
        "tagAnnotation": "Release %s"
        "increment": "patch"
        "buildCommand": "grunt dist"
        "distRepo": "-b gh-pages git@github.com:Addepar/ember-widgets"
        "distStageDir": ".stage"
        "distBase": "gh_pages"
        "distFiles": ["**/*"]
        "publish": false

  ###
    A task to build the test runner html file that get place in
    /test so it will be picked up by the qunit task. Will
    place a single <script> tag into the body for every file passed to
    its coniguration above in the grunt.initConfig above.
  ###
  grunt.registerMultiTask "build_test_runner_file", "Creates a test runner file.", ->
    tmpl = grunt.file.read("tests/support/runner.html.tmpl")
    renderingContext = data:
      files: @filesSrc.map (fileSrc) -> fileSrc.replace "build/tests/", ""
    grunt.file.write "build/tests/runner.html", grunt.template.process(tmpl, renderingContext)

  grunt.registerTask "build_srcs", [ "coffee:srcs", "emberTemplates:srcs", "neuter:srcs" ]
  grunt.registerTask "build_app", [ "replace:app", "coffee:app", "emberTemplates:app", "neuter:app", "copy:app", "less:app" ]
  grunt.registerTask "build_tests", [ "coffee:tests" ]

  # build dist files: same as default but no bower or watch
  grunt.registerTask "dist", [ "clean", "bower", "replace:srcs", "build_srcs", "less:srcs", "copy:srcs", "uglify", "replace:sourceMap", "usebanner" ]

  grunt.registerTask "default", [ "dist", "build_app", "build_tests", "watch" ]

