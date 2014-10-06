var path = require('path');
var fs = require('fs');

module.exports = function(grunt) {
  'use strict';

  var jsRoot = path.join(__dirname, 'app', 'assets', 'javascripts');
  var cssRoot = path.join(__dirname, 'app', 'assets', 'stylesheets');

  grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-sass');

  grunt.initConfig({
    meta: {
      cssRoot: cssRoot
    },

    requirejs: {
      compile: {
        options: {
          baseUrl:  "app/assets/javascripts",
          out: "public/js/compiled/app.js",
          mainConfigFile: 'app/assets/javascripts/main.js',
          optimize: "uglify",
          uglify: {
            toplevel:   true,
            ascii_only: true,
            beautify:   false,
            max_line_length: 1000,
            no_mangle: false
          },

          pragmasOnSave: {
            excludeHbsParser : true,
            excludeHbs: true,
            excludeAfterBuild: true
          },

          removeCombined: false,
          inlineText: true,
          preserveLicenseComments: false,

          name: "main",
          include: [ 'main' ]
        }
      }
    },

    sass: {
      dist: {
        options: {
          style: 'expanded',
          includePaths: [
            cssRoot
          ],
          outputStyle: 'nested'
        },
        files: {
          'public/stylesheets/compiled/app.css': '<%= meta.cssRoot %>/app.scss',
        }
      }
    },

    watch: {
      options: {
        spawn: false,
      },

      css: {
        files: cssRoot + '/**/*',
        tasks: [ 'sass' ]
      }
    }
  });

  grunt.registerTask('development', function() {
    var compiledJsPath = path.join(__dirname, 'public', 'javascripts', 'compiled', 'app.js');
    var rawJsPath = path.join(jsRoot, 'main.js');

    if (fs.existsSync(compiledJsPath)) {
      fs.unlinkSync(compiledJsPath);
    }

    fs.symlinkSync(rawJsPath, compiledJsPath);
  });

  grunt.registerTask('build', [ 'requirejs', 'sass' ]);
  grunt.registerTask('default', [ 'watch' ]);
};
