var path = require('path');
var fs = require('fs');

module.exports = function(grunt) {
  'use strict';

  var jsRoot = path.join(__dirname, 'app', 'assets', 'javascripts');
  var cssRoot = path.join(__dirname, 'app', 'assets', 'stylesheets');
  var compiledJsPath = path.join(__dirname, 'public', 'javascripts', 'compiled', 'app.js');

  grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-sass');
  grunt.loadNpmTasks('grunt-concurrent');

  grunt.initConfig({
    meta: {
      cssRoot: cssRoot
    },

    requirejs: {
      compile: {
        options: {
          baseUrl:  "app/assets/javascripts",
          out: compiledJsPath,
          mainConfigFile: 'app/assets/javascripts/main.js',
          optimize: "uglify2",

          uglify2: {
            warnings: true,
            mangle:   true,

            output: {
              beautify: false
            },

            compress: {
              sequences:  true,
              dead_code:  true,
              loops:      true,
              unused:     true,
              if_return:  true,
              join_vars:  true
            }
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
          include: [ 'main', 'boot', 'helpers/underscore' ]
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
        spawn: false
      },

      css: {
        files: cssRoot + '/**/*',
        tasks: [ 'sass' ]
      },

      compiled_css: {
        options: {
          livereload: {
            port: 9135
          }
        },

        files: [ 'public/stylesheets/compiled/app.css' ],
        tasks: []
      }
    },

    concurrent: {
      options: {
        logConcurrentOutput: true,
      },

      watch: [
        'watch:css',
        'watch:compiled_css',
      ],
    },
  });

  grunt.registerTask('development', function() {
    var rawJsPath = path.join(jsRoot, 'main.js');

    if (fs.existsSync(compiledJsPath)) {
      fs.unlinkSync(compiledJsPath);
    }

    fs.symlinkSync(rawJsPath, compiledJsPath);
  });

  grunt.registerTask('build', [ 'requirejs', 'sass' ]);
  grunt.registerTask('default', [ 'concurrent' ]);
};
