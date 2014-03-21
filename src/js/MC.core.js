/*
#**********************************************************
#* Filename: MC.core.js
#* Creator: Angel
#* Description: The core of the whole system
#* Date: 20131115
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

var MC_HOST = 'https://api.madeiracloud.com/';

var MC = {
	// Global Variable
	API_URL: MC_HOST,
	IMG_URL: './assets/images/',
	WS_URL: MC_HOST + 'ws/',//-> 8300
	SAVEPNG_URL: MC_HOST + 'export/',//->8400

	current_module : {},

	_extractIDRegex : /^\s*?@?{?([-A-Z0-9a-z]+)}?/,

	// Global data
	data: {},

	/**
	 * Generate GUID
	 * @return {string} the guid
	 */
	guid: function ()
	{
		return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c)
		{
			var r = Math.random() * 16 | 0,
				v = c == 'x' ? r : (r&0x3 | 0x8);
			return v.toString(16);
   		}).toUpperCase();
	},

	/**
	 * Determine the string is JSON or not
	 * @param  {string}  string the string will be determined
	 * @return {Boolean} if the string is JSON, return true, otherwise return false
	 */
	isJSON: function (string)
	{
		var rvalidchars = /^[\],:{}\s]*$/,
			rvalidescape = /\\(?:["\\\/bfnrt]|u[\da-fA-F]{4})/g,
			rvalidtokens = /"[^"\\\r\n]*"|true|false|null|-?(?:\d\d*\.|)\d+(?:[eE][\-+]?\d+|)/g,
			rvalidbraces = /(?:^|:|,)(?:\s*\[)+/g;

		return typeof string === 'string' && string.trim() !== '' ?
			rvalidchars.test(string
				.replace(rvalidescape, '@')
				.replace(rvalidtokens, ']')
				.replace(rvalidbraces, '')) :
			false;
	},

	api_queue: {},
	/**
	 * JSON-RPC API request
	 * @param  {object} option the configuration of API request
	 * @return {[type]} [description]
	 *
	 * example:
	 * MC.api({
 		url: '/app/',
	 	method: 'summary',
	 	data: {},
	 	success: function (data)
	 	error: function (status, error)
	 	});
	 */
	api: function (option)
	{
		var api_frame = $('#api-frame'),
			guid = MC.guid(),
			callback = function(event)
			{
				var data = event.originalEvent.data,
					option = MC.api_queue[data.id];

				if (data.call === 'success' && option.success)
				{
					option.success(data.result[1], data.result[0]);
					/*try{
						option.success(data.result[1], data.result[0]);
					}
					catch(error)
					{
						console.info(error);
					}*/
				}
				if (data.call === 'error' && option.error)
				{
					option.error(data.status, -1);
				}
				delete MC.api_queue[data.id];
			},
			postMessage = function (guid)
			{
				var option = MC.api_queue[guid];

				if (api_frame[0] !== undefined)
				{
					api_frame[0].contentWindow.postMessage({
						id: guid,
						url: '' + option.url,
						method: option.method || '',
						params: option.data || {}
					}, '*');
				}
			};

		MC.api_queue[guid] = option;

		if (!api_frame[0])
		{
			$(document.body).append('<iframe id="api-frame" src="' + MC.API_URL + 'api.html" style="display:none;"></iframe>');
			api_frame = $('#api-frame');
			api_frame.load(function ()
			{
				api_frame[0].docLoad = true;
				$.each(MC.api_queue, function (guid, option)
				{
					postMessage(guid);
				});
			});
			$(window).on('message', callback);
		}

		if (api_frame[0].docLoad === true)
		{
			postMessage(guid);
		}
	},

	browserDetect: function ()
	{
		var rbrowser = /(webkit|firefox|opera|msie|ipad|iphone|android)/ig,
			ua = navigator.userAgent.toLowerCase(),
			doc = $(document.body),
			name,
			version;

		rbrowser.exec(ua);

		name = RegExp.$1;

		doc.addClass(name);

		if (name === 'webkit' && /version\/([0-9])\.([0-9\.]*) safari/ig.exec(ua) !== null)
		{
			doc.addClass('safari');

			name = 'safari';

			version = /version\/([0-9])\.([0-9\.]*) safari/ig.exec(ua)[1];
		}

		if (name === 'webkit' && /chrome\/([0-9]{1,2})/ig.exec(ua) !== null)
		{
			doc.addClass('chrome');

			name = 'chrome';

			version = /chrome\/([0-9]{1,2})/ig.exec(ua)[1];
		}

		if (name === 'opera' && /version\/([0-9]{1,2})/ig.exec(ua) !== null)
		{
			doc.addClass('opera');

			name = 'opera';

			version = /version\/([0-9]{1,2})/ig.exec(ua)[1];
		}

		if (name === 'firefox' && /firefox\/([0-9]{1,2})/ig.exec(ua))
		{
			version = /firefox\/([0-9]{1,2})/ig.exec(ua)[1];
		}

		if (name === 'msie' && /msie ([0-9]{1,2})/ig.exec(ua))
		{
			version = /msie ([0-9]{1,2})/ig.exec(ua)[1];
		}

		version = version * 1;

		MC.browser = name;
		MC.browserVersion = version;

		return {
			'browser': name,
			'version': version
		};
	},

	isSupport: function ()
	{
		var data = MC.browserDetect(),
			browser = data.browser,
			version = data.version;

		if (
			(
				browser === 'chrome' && version >= 10
			) ||
			(
				browser === 'safari' && version >= 6
			) ||
			(
				browser === 'msie' && version >= 10
			) ||
			(
				browser === 'firefox' && version >= 4
			) ||
			(
				browser === 'opera' && version >= 10
			) ||
			(
				// For IE 11
				/trident\/7\.0/ig.test( navigator.userAgent.toLowerCase() )
			)
		)
		{
			return true;
		}
		else
		{
			return false;
		}
	},

	capitalize: function (string)
	{
	    return string.charAt(0).toUpperCase() + string.slice(1);
	},

	canvasName : function (string)
	{
		return string.length > 17 ? string.substring(0, 17) + '...' : string;
	},

	asgName : function (string)
	{
		return string.length > 12 ? string.substring(0, 12) + '...' : string;
	},

	truncate: function (string, length)
	{
		return string.length > length ? string.substring(0, length) + '...' : string;
	},

	/*
		For realtime CSS edit
	 */
	realtimeCSS: function (option)
	{
		if (option === false)
		{
			clearInterval(MC.realtimeCSS_timer);

			return true;
		}
		MC.realtimeCSS_timer = setInterval(function ()
		{
			var date = new Date(),
				date_query = date.getTime(),
				item;

			$('link', document.head[0]).map(function (index, item)
			{
				item = $(item);

				if (item.attr('rel') === 'stylesheet')
				{
					item.attr('href', item.attr('href').replace(/\.css(\?d=[0-9]*)?/ig, '.css?d=' + date_query));
				};
			});
		}, 2000);
	},

	refreshCSS: function ()
	{
		var date = new Date(),
			date_query = date.getTime(),
			item;

		$('link', document.head[0]).map(function (index, item)
		{
			item = $(item);

			if (item.attr('rel') === 'stylesheet')
			{
				item.attr('href', item.attr('href').replace(/\.css(\?d=[0-9]*)?/ig, '.css?d=' + date_query));
			};
		});
	},

	extractID: function (uid)
	{
		if (!uid) { return ""; }

		var result = MC._extractIDRegex.exec(uid);

		return result ? result[1] : uid;
	},

	/**
	 * Display and update notification number on title
	 * @param  {number} number the notification number
	 * @return {boolean} true
	 */
	titleNotification: function (number)
	{
		var rnumber = /\([0-9]*\)/ig;

		if (number > 0)
		{
			document.title = (document.title.match(rnumber)) ? document.title.replace(rnumber, '(' + number + ')') : '(' + number + ') ' + document.title;
		}
		else
		{
			document.title = document.title.replace(rnumber, '');
		}

		return true;
	},

	/**
	 * Format a number with grouped thousands
	 * @param  {number} number The target number
	 * @return {string}
	 *
	 * 3123131 -> 3,123,131
	 */
	numberFormat: function (number)
	{
		number = (number + '').replace(/[^0-9+\-Ee.]/g, '');

		var n = !isFinite(+number) ? 0 : +number,
			precision = 0,
			separator = ',',
			decimal = '.',
			string = '',
			fix = function (n, precision)
			{
				var k = Math.pow(10, precision);
				return '' + Math.round(n * k) / k;
			};

		string = (precision ? fix(n, precision) : '' + Math.round(n)).split('.');
		if (string[0].length > 3)
		{
			string[0] = string[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, separator);
		}
		if ((string[1] || '').length < precision)
		{
			string[1] = string[1] || '';
			string[1] += [precision - string[1].length + 1].join('0');
		}

		return string.join(decimal);
	},

	/**
	 * Returns a formatted string according to the given format string with date object
	 * @param  {Date object} date   The date object
	 * @param  {String} format the string of format
	 * @return {String} The formatted date string
	 */
	dateFormat: function (date, format)
	{
		var date_format = {
				"M+" : date.getMonth() + 1,
				"d+" : date.getDate(),
				"h+" : date.getHours(),
				"m+" : date.getMinutes(),
				"s+" : date.getSeconds(),
				"q+" : Math.floor((date.getMonth() + 3) / 3),
				"S" : date.getMilliseconds()
			},
			key;

		if (/(y+)/.test(format))
		{
			format = format.replace(
				RegExp.$1,
				(date.getFullYear() + "").substr(4 - RegExp.$1.length)
			);
		}
		for (key in date_format)
		{
			if (new RegExp("("+ key +")").test(format))
			{
				format = format.replace(
					RegExp.$1,
					RegExp.$1.length === 1 ? date_format[key] : ("00"+ date_format[key]).substr((""+ date_format[key]).length)
				);
			}
		}

		return format;
	},

	/**
	 * Calculate the interval time between now and target date time.
	 * @param  {timespan number} date_time The target date time with second
	 * @return {[string]} The interval time.
	 */
	intervalDate: function (date_time)
	{
		var now = new Date(),
			date_time = date_time * 1000,
			second = (now.getTime() - date_time) / 1000,
			days = Math.floor(second / 86400),
			hours = Math.floor(second / 3600),
			minute = Math.floor(second / 60);

		if (days > 30)
		{
			return MC.dateFormat(new Date(date_time), "dd/MM yyyy");
		}
	 	else
	 	{
			return days > 0 ? days + ' days ago' : hours > 0 ? hours + ' hours ago' : minute > 0 ? minute + ' minutes ago' : 'just now';
	 	}
	},

	/**
	 * Calculate the interval time between two date time.
	 * @param  {Date} first time
	 * @param  {Date} second time
	 * @param  {String} (s)econd | (m)inute | (h)our | (d)ay default is second
	 * @return {number} time difference
	 */
	timestamp : function( t1, t2, type ) {

		if ( $.type( t1 ) === 'date' && $.type( t2 ) === 'date' ) {

			var div_num = 1;

			switch ( type ) {
				case 's':
					div_num = 1000;
					break;
				case 'm':
					div_num = 1000 * 60;
					break;
				case 'h':
					div_num = 1000 * 3600;
					break;
				case 'd':
					div_num = 1000 * 3600 * 24;
					break;
				default:
					div_num = 1000;
					break;
			}
			return parseInt(( t2.getTime() - t1.getTime() ) / parseInt( div_num ));
		}

		else {
			console.error( 'variable is type date', t1, t2, type );
		}
	},

	/**
	 * Generate random number
	 * @param  {number} min min number
	 * @param  {number} max max number
	 * @return {number} The randomized number
	 */
	rand: function (min, max)
	{
		return Math.floor(Math.random() * (max - min + 1) + min);
	},

	base64Encode: function (string)
	{
		return window.btoa(unescape(encodeURIComponent( string )));
	},

	base64Decode: function (string)
	{
		return decodeURIComponent(escape(window.atob( string )));
	},

	log: function (module_name, log_level, content)
	{
		//log_level  info|log|debug|warn|error

		if (MC.current_module !== module_name)
		{
			return;
		}

		console[ log_level ]('[', module_name, ']', content);
	},

	camelCase: function (string)
	{
		return string.replace(/-([a-z])/ig, function (match, letter)
		{
			return (letter + '').toUpperCase();
		});
	},

	getBoolean: function (string)
	{
		if ( string === "true"  || string === "True" )  return true;
		if ( string === "false" || string === "False" ) return false;
		return !!string;
	}
};

/*
* Storage
* Author: Angel & Tim
*
* Save data into local computer via HTML5 localStorage or sessionStorage.
*
* Saving data
* MC.[storage|session].set(name, value)
*
* Getting data
* MC.[storage|session].get(name)
*
* Remove data
* MC.[storage|session].remove(name)
*/

var storage = function( instance ) {
	return {
		set: function (name, value)
		{
			instance[name] = typeof value === 'object' ? JSON.stringify(value) : value;
		},

		get: function (name)
		{
			var data = instance[name];

			if (MC.isJSON(data))
			{
				return JSON.parse(data);
			}

			return data || '';
		},

		remove: function (name)
		{
			instance.removeItem(name);

			return true;
		}
	}
}

MC.storage = storage( localStorage )
MC.session = storage( sessionStorage )

MC.cacheForDev = function( key, data, callback ) {
	/* env:dev*/

	if ( key && data ) {
		MC.session.set( key, data );
		return;
	}

	data = MC.session.get( key );

	if ( data && callback ){
		callback( data );
		return true;
	}

	if ( data ) {
		return data
	}

	/* env:dev:end*/

	return false;


};

/* Define as MC module */
define( "MC", [ "ui/MC.template", "lib/handlebarhelpers", "jquery", "sprintf" ], function ( template ) {

// For event handler
var returnTrue = function () {return true},
	returnFalse = function () {return false};

/**
 * jQuery plugin to convert a given $.ajax response xml object to json.
 *
 * @example var json = $.xml2json(response);
 * modified by Angel
 */
(function ()
{
	jQuery.extend(
	{

		xml2json: function xml2json(xml)
		{
			var result = {},
				attribute,
				content,
				node,
				child,
				i,
				j;

			for (i in xml.childNodes)
			{
				node = xml.childNodes[ i ];

				if (node.nodeType === 1)
				{
					child = node.hasChildNodes() ? xml2json(node) : node.nodevalue;

					child = child == null ? null : child;

					// Special for "item" & "member"
					if (
						(node.nodeName === 'item' || node.nodeName === 'member') &&
						child.value
					)
					{
						if (child.key)
						{
							if ($.type(result) !== 'object')
							{
								result = {};
							}
							if (!$.isEmptyObject(child))
							{
								result[ child.key ] = child.value;
							}
						}
						else
						{
							if ($.type(result) !== 'array')
							{
								result = [];
							}
							if (!$.isEmptyObject(child))
							{
								result.push(child.value);
							}
						}
					}
					else
					{
						if (
							(
								node.nextElementSibling &&
								node.nextElementSibling.nodeName === node.nodeName
							)
							||
							node.nodeName === 'item' ||
							node.nodeName === 'member'
						)
						{
							if ($.type(result[ node.nodeName ]) === 'undefined')
							{
								result[ node.nodeName ] = [];
							}
							if (!$.isEmptyObject(child))
							{
								result[ node.nodeName ].push(child);
							}
						}
						else
						{
							if (node.previousElementSibling && node.previousElementSibling.nodeName === node.nodeName)
							{
								if (!$.isEmptyObject(child))
								{
									result[ node.nodeName ].push(child);
								}
							}
							else
							{
								result[ node.nodeName ] = child;
							}
						}
					}

					// Add attributes if any
					if (node.attributes.length > 0)
					{
						result[ node.nodeName ][ '@attributes' ] = {};
						for (j in node.attributes)
						{
							attribute = node.attributes.item(j);
							result[ node.nodeName ]['@attributes'][attribute.nodeName] = attribute.nodeValue;
						}
					}

					// Add element value
					if (
						node.childElementCount === 0 &&
						node.textContent != null &&
						node.textContent !== ''
					)
					{
						content = node.textContent.trim();

						switch (content.toLowerCase())
						{
							case 'true':
								content = true;
								break;

							case 'false':
								content = false;
								break;
						}

						if (result[ node.nodeName ] instanceof Array)
						{
							result[ node.nodeName ].push(content);
						}
						else
						{
							result[ node.nodeName ] = content;
						}
					}
				}
			}

			return result;
		}
	});
})();

/*!
 * jQuery Cookie Plugin v1.3.1
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2013 Klaus Hartl
 * Released under the MIT license
 */
(function(e){function m(a){return a}function n(a){return decodeURIComponent(a.replace(j," "))}function k(a){0===a.indexOf('"')&&(a=a.slice(1,-1).replace(/\\"/g,'"').replace(/\\\\/g,"\\"));try{return d.json?JSON.parse(a):a}catch(c){}}var j=/\+/g,d=e.cookie=function(a,c,b){if(void 0!==c){b=e.extend({},d.defaults,b);if("number"===typeof b.expires){var g=b.expires,f=b.expires=new Date;f.setDate(f.getDate()+g)}c=d.json?JSON.stringify(c):String(c);return document.cookie=[d.raw?a:encodeURIComponent(a),"=",d.raw?c:encodeURIComponent(c),b.expires?"; expires="+b.expires.toUTCString():"",b.path?"; path="+b.path:"",b.domain?"; domain="+b.domain:"",b.secure?"; secure":""].join("")}c=d.raw?m:n;b=document.cookie.split("; ");for(var g=a?void 0:{},f=0,j=b.length;f<j;f++){var h=b[f].split("="),l=c(h.shift()),h=c(h.join("="));if(a&&a===l){g=k(h);break}a||(g[l]=k(h))}return g};d.defaults={};e.removeCookie=function(a,c){return void 0!==e.cookie(a)?(e.cookie(a,"",e.extend({},c,{expires:-1})),!0):!1}})(jQuery);

/* Global initialization */
$(document).ready(function ()
{
	var language = $.cookie('lang');

	if (language === undefined)
	{
		language = navigator.language ? navigator.language : navigator.browserLanguage;

		language = language.replace(/-[\w]*/ig, '');

		if ( language === 'zh' ) {
			language = 'zh-cn';
		}
		else if ( language === 'en' ) {
			language = 'en-us';
		}
		else {
			language = 'en-us';
		}

		// MC.storage.set( 'language', language );

		// $.cookie('lang', language);
	}

	$(document.body).addClass('locale-' + language);

	if (navigator.platform.toLowerCase().indexOf('mac') >= 0)
	{
		$(document.body).addClass('mac');
	}

	// Detecting browser and add the class name on body, so that we can use specific CSS style
	// or for specific usage.
	MC.browserDetect();
});

	MC.template = template;
	return MC;
});
