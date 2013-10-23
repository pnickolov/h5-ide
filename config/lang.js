

module.exports.run = function( grunt, callback ) {

	var fs          = require( 'fs' ),
		path        = fs.realpathSync( '.' ),
		source_file = path + '/src/nls/lang-source.coffee',
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

	var check = function(lang) {
		var recursion = function (l, key) {
			if (hit(l)) {
				checkEnHasCN(l.en, key);
			} else {
				for (var k in l) {
					recursion(l[k], k);
				}
			}
		};

		try {
			recursion(lang);
		} catch (e) {
			grunt.log.error("Lang File Error: " + e);
			return false;
		}
		return true;

	};
	// more fast than checkEnHasCNReg below
	var checkEnHasCN = function(lang, key) {
		 for(var i = 0; i < lang.length; i++) {
			 if(lang.charCodeAt(i) >= 0x4E00 && lang.charCodeAt(i) <= 0x9FA5) {
			 	throw '"' + key + ': ' + lang + '" has Chinese charactor';
	         }
		 }
	};

	var checkEnHasCNReg = function(lang, key) {
		 var re = /.*[\u4e00-\u9fa5]+.*$/;
		 if(re.test(lang))
		 	throw '"' + key + ': ' + lang + '" has Chinese charactor';
	}


	var divorce = function(lang, en_us, zh_cn) {

		if (lang === Object(lang) ) {
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
				} else {
					return false;
				}
			}
		}


	};

	var format = function(obj) {
		var s = JSON.stringify(obj);
		return 'define(' + s + ');';
	};

	// do check
	if (!check(lang))
		return false;

	// do divorce
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

	callback();
};