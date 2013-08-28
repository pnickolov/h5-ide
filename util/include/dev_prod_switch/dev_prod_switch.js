/*
 * grunt-dev-prod-switch
 * https://github.com/sanusart/grunt-dev-prod-switch
 *
 * Copyright (c) 2013 Sasha Khamkov
 * Licensed under the MIT license.
 */

'use strict';

module.exports = function (grunt) {

    // Please see the Grunt documentation for more information regarding task
    // creation: http://gruntjs.com/creating-tasks

    grunt.registerMultiTask('dev_prod_switch', 'Use to switch between previously defined HTML comment blocks in project files to change environment from development to production and back.', function () {

        // Merge task-specific and/or target-specific options with these defaults.
        var options = this.options();
        var blocking_char = ((options.env_char) ? options.env_char : '#');
        var env_prod = (options.env_block_prod) ? options.env_block_prod : 'env:prod';
        var env_dev = (options.env_block_dev) ? options.env_block_dev : 'env:dev';

        var dev_replace1 = '<!-- ' + env_prod + ' --' + blocking_char + '>',
            dev_replace2 = '<!-- ' + env_dev + ' -->',
            dev_replace3 = '/* ' + env_prod + ' *' + blocking_char + '/',
            dev_replace4 = '/\\* ' + env_dev + '\\*/';

        var prod_replace1 = '<!-- ' + env_prod + ' -->',
            prod_replace2 = '<!-- ' + env_dev + ' --' + blocking_char + '>',
            prod_replace3 = '/\\* ' + env_prod + '\\*/',
            prod_replace4 = '/* ' + env_dev + ' *' + blocking_char + '/';

        var prod_reg1 = new RegExp( dev_replace1, 'g' ),
            prod_reg2 = new RegExp( dev_replace2, 'g' ),
            prod_reg3 = new RegExp( dev_replace3, 'g' ),
            prod_reg4 = new RegExp( dev_replace4, 'g' );

        var dev_reg1 = new RegExp( prod_replace1, 'g' ),
            dev_reg2 = new RegExp( prod_replace2, 'g' ),
            dev_reg3 = new RegExp( prod_replace3, 'g' ),
            dev_reg4 = new RegExp( prod_replace4, 'g' );

        // Iterate over all specified files.
        this.files.forEach(function (f) {
            var out = f.src.map(function (src) {
                if (options.environment === 'prod') {
                    var result = grunt.file.read(src, 'utf8')
                        .replace( prod_reg1, prod_replace1 )
                        .replace( prod_reg2, prod_replace2 )
                        .replace( prod_reg3, prod_replace3 )
                        .replace( prod_reg4, prod_replace4 );
                } else if (options.environment === 'dev') {
                    var result = grunt.file.read(src, 'utf8')
                        .replace( dev_reg2, dev_replace2 )
                        .replace( dev_reg1, dev_replace1 )
                        .replace( dev_reg4, dev_replace4 )
                        .replace( dev_reg3, dev_replace3 );
                } else {
                    grunt.log.writeln('Please set "environment" in options object.');
                }
                return result;
            });

            var env = (options.environment === 'prod') ? 'Production' : 'Development';
            grunt.log.writeln('Data in file "' + f.dest + '" switched to "' + env + '".');

            grunt.file.write(f.dest, out);
        });

    });
};
