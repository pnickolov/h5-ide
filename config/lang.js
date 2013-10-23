
module.exports.run = function( grunt, callback ) {

	var fs          = require( 'fs' ),
		path        = fs.realpathSync( '.' ),
		source_file = path + '/src/nls/lang-source.js',
		zh_file     = path + '/src/nls/zh-cn/lang.js',
		en_file     = path + '/src/nls/en-us/lang.js',
		lang        = require( source_file ),
		zh_cn       = {},
		en_us       = {};

	delete require.cache[require.resolve(source_file)];

	var hit = function(obj) {
		var hitKey = obj.zh !== undefined && obj.en !== undefined;

		var isString = toString.call(obj.zh) == '[object String]' && toString.call(obj.en) == '[object String]';

		if (hitKey && isString) {
			return true;
		}

		return false;
	};

	var divorce = function(lang, en_us, zh_cn) {

		if (lang === Object(lang) )
			for (var k in lang) {
				en_us[k] = en_us[k] || {};
				zh_cn[k] = zh_cn[k] || {};

				if (lang[k] === Object(lang[k])) {
					if (hit(lang[k])){
						en_us[k] = lang[k].en;
						zh_cn[k]= lang[k].zh;
					} else {
						divorce(lang[k], en_us[k], zh_cn[k]);
					}
				}
			}

	};

	var format = function(obj) {
		var s = JSON.stringify(obj);
		return 'define(' + s + ');';
	};

	divorce(lang, en_us, zh_cn);

	grunt.file.write(en_file, format(en_us));
	grunt.file.write(zh_file, format(zh_cn));

	callback();

};

module.exports.merge = function( grunt, callback ) {
	var fs          = require( 'fs' ),
		path        = fs.realpathSync( '.' ),
		en_us       = require( path + '/src/nls/en-us/lang.js').lang,
		zh_cn       = require( path + '/src/nls/zh-cn/lang.js').lang;

	var checkLang = function(en_us, zh_cn) {
		var creature = {};
		var rec = function(ob, cp, creature) {
			if (ob === Object(ob) )
				for (var k in ob) {
					creature[k] = creature[k] || {};
					if (ob[k] === Object(ob[k])) {
						rec(ob[k], cp[k], creature[k]);
					}
					else if (ob[k] !== undefined) {
						creature[k].en_us = ob[k];
						creature[k].zh_cn = cp[k];
					}
					else{
						console.log(ob);
					}
				}
			else
				return;
		};

		rec(en_us, zh_cn, creature);

		return creature;
	};

	var creature = checkLang(en_us, zh_cn);
	grunt.file.write('lang.js', JSON.stringify(creature));
	grunt.loadNpmTasks('grunt-jsbeautifier');

	callback();
};