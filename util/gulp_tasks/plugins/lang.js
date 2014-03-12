// Author : Tim

module.exports = function( callback, lang_src ) {

    var fs          = require( 'fs' ),
        path        = fs.realpathSync( '.' ),
        source_file = path + '/src/nls/lang-source.coffee',
        zh_file     = path + '/src/nls/zh-cn/lang.js',
        en_file     = path + '/src/nls/en-us/lang.js',
        lang        = lang_src,
        zh_cn       = {},
        en_us       = {};

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
                checkEnInvalid(l.en, key);
            } else {
                for (var k in l) {
                    recursion(l[k], k);
                }
            }
        };

        try {
            recursion(lang);
        } catch (e) {
            console.log("Lang File Error: " + e);
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

    var checkEnInvalid = function(lang, key) {
         for(var i = 0; i < lang.length; i++) {
             if(lang.charCodeAt(i) <= 0x00 || lang.charCodeAt(i) >= 0xff) {
                throw '"' + key + ': ' + lang + '" has Invalid charactor [ ' + lang[i] + ' ]';
             }
         }
    };

    var checkEnHasCNReg = function(lang, key) {
         var re = /.*[\u4e00-\u9fa5]+.*$/;
         if(re.test(lang))
            throw '"' + key + ': ' + lang + '" has Chinese charactor';
    };


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
        var s = JSON.stringify(obj, null, 4);
        return 'define(' + s + ');';
    };

    // do check
    if (!check(lang)) {
        return false;
    }

    // do divorce
    divorce(lang, en_us, zh_cn);

    callback(en_file, format(en_us));
    callback(zh_file, format(zh_cn));
};
