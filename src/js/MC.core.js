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

/* Define as MC module */
define( "MC", [ "ui/MC.template", "q", "lib/IntercomAnalytics", "lib/handlebarhelpers", "jquery", "sprintf" ], function ( template, Q, Analytics ) {

Analytics.update("version", window.version);

window.Q = Q;

var storage = function( instance ) {
	var s = {
		  set: function (name, value) {
			instance[name] = typeof value === 'object' ? JSON.stringify(value) : value;
		}

		, get: function (name) {
			var data = instance[name];

			try {
				data = JSON.parse(data);
			} catch (e) {}
			return data || "";
		}

		, remove: function (name) {
			instance.removeItem(name);

			return true;
		}

		, clear: function() {
			instance.clear();
		}
	};
	return s;
};

var _extractIDRegex = /^\s*?@?{?([-A-Z0-9a-z]+)}?/;

var MC = {
	// Global Variable

	DOMAIN   : window.MC_DOMAIN,
	API_HOST : window.MC_PROTO + "://api." + window.MC_DOMAIN,

	IMG_URL: '/assets/images/',

	// Global data
	data: {},

	Analytics : Analytics,

	getCidrBinStr: function ( ipCidr )
	{
		var cutAry, ipAddr, ipAddrAry, ipAddrBinAry, prefix, suffix;

		cutAry = ipCidr.split('/');
		ipAddr = cutAry[0];
		suffix = Number(cutAry[1]);
		prefix = 32 - suffix;
		ipAddrAry = ipAddr.split('.');
		ipAddrBinAry = ipAddrAry.map(function(value) {
			return MC.leftPadString(parseInt(value).toString(2), 8, "0");
		});

		return ipAddrBinAry.join('');
	},

	getValidCIDR: function ( cidr )
	{
		var newCIDRStr, newIPAry, newIPBinStr, newIPStr,
			prefixIPBinStr, subnetCidrBinStr, subnetCidrSuffix,
			suffixIPBinStr, suffixNum;

		subnetCidrBinStr = MC.getCidrBinStr(cidr);
		subnetCidrSuffix = Number(cidr.split('/')[1]);
		suffixIPBinStr = subnetCidrBinStr.slice(subnetCidrSuffix);
		suffixNum = parseInt(suffixIPBinStr);
		if ((suffixNum === 0) || (suffixIPBinStr === '')) {
			return cidr;
		} else {
			prefixIPBinStr = subnetCidrBinStr.slice(0, subnetCidrSuffix);
			newIPBinStr = prefixIPBinStr + MC.rightPadString('', suffixIPBinStr.length, '0');
			newIPAry = _.map([0, 8, 16, 24], function(value) {
				return parseInt(newIPBinStr.slice(value, value + 8), 2);
			});
			newIPStr = newIPAry.join('.');
			newCIDRStr = newIPStr + '/' + subnetCidrSuffix;
			return newCIDRStr;
		}
	},

	prettyStackTrace : function ( popLevel )
	{
		function StackTrace (){}
		var stack = new Error().stack.split("\n");
		popLevel = (popLevel || 0) + 2;
		var pretty = new StackTrace();
		for ( var i = 0; i < stack.length - popLevel; ++i ) {
			pretty[ "@"+i ] = stack[i+popLevel].replace(/^\s+at\s+/,"");
		}
		return pretty;
	},


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

	genResRef: function(uid, attrName)
	{
		return "@{" + uid + "." + attrName + "}"
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
		return Q($.ajax({
			url: MC.API_HOST + option.url,
			dataType: 'json',
			type: 'POST',
			jsonp: false,
			data: JSON.stringify({
				jsonrpc: '2.0',
				id: MC.guid(),
				method: option.method || '',
				params: option.data || {}
			}),
			success: function(res){
				option.success && option.success(res.result[1], res.result[0]);
			},
			error: function(xhr, status, error){
				option.error && option.error(status, -1);
			}
		}));
	},

	capitalize: function (string)
	{
	    return string.charAt(0).toUpperCase() + string.slice(1);
	},

	truncate: function (string, length)
	{
		return string.length > length ? string.substring(0, length - 3) + '...' : string;
	},

	leftPadString : function (string, length, padding)
	{
		if ( string.length >= length ) { return string; }
		return (new Array(length-string.length+1)).join(padding) + string;
	},
	rightPadString : function (string, length, padding)
	{
		if ( string.length >= length ) { return string; }
		return string + (new Array(length-string.length+1)).join(padding);
	},


	/*
		For realtime CSS edit
	 */
	/* env:dev */
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
	/* env:dev:end */

	extractID: function (uid)
	{
		if (!uid) { return ""; }

		var result = _extractIDRegex.exec(uid);

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

	camelCase: function (string)
	{
		return string.replace(/-([a-z])/ig, function (match, letter)
		{
			return (letter + '').toUpperCase();
		});
	},

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
	storage : storage( localStorage ),
	session : storage( sessionStorage ),

	cacheForDev : function( key, data, callback ) {
		/* env:dev */

		if ( key && data ) {
			// don't cache if resolved_data is null or is_error is true
			if ( !data.is_error && (!data.hasOwnProperty('resolved_data') || data.resolved_data) )
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

		/* env:dev:end */

		return false;


	},

	createCompareFn : function(propertyName)
	{
		/**
		example:
		var data = [{ name: "seacha.com", age: 36 }, { name: "jiang", age: 45 }, { name: "google", age: 32 }, { name: "javascript", age: 19}];
		data.sort(createCompareFn("age"));
		**/
		return function(object1, object2)
		{
			var value1 = object1[propertyName];
			var value2 = object2[propertyName];
			if (value1 < value2)
			{
				return -1;
			}
			else if (value1 > value2)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}

};

window.MC = MC;



	/**
	 * jQuery plugin to convert a given $.ajax response xml object to json.
	 *
	 * @example var json = $.xml2json(response);
	 * modified by Angel
	 */
	jQuery.extend({
		xml2json : function xml2json(xml) {
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

	/*!
	 * jQuery Cookie Plugin v1.3.1
	 * https://github.com/carhartl/jquery-cookie
	 *
	 * Copyright 2013 Klaus Hartl
	 * Released under the MIT license
	 */
	(function(e){function m(a){return a}function n(a){return decodeURIComponent(a.replace(j," "))}function k(a){0===a.indexOf('"')&&(a=a.slice(1,-1).replace(/\\"/g,'"').replace(/\\\\/g,"\\"));try{return d.json?JSON.parse(a):a}catch(c){}}var j=/\+/g,d=e.cookie=function(a,c,b){if(void 0!==c){b=e.extend({},d.defaults,b);if("number"===typeof b.expires){var g=b.expires,f=b.expires=new Date;f.setDate(f.getDate()+g)}c=d.json?JSON.stringify(c):String(c);return document.cookie=[d.raw?a:encodeURIComponent(a),"=",d.raw?c:encodeURIComponent(c),b.expires?"; expires="+b.expires.toUTCString():"",b.path?"; path="+b.path:"",b.domain?"; domain="+b.domain:"",b.secure?"; secure":""].join("")}c=d.raw?m:n;b=document.cookie.split("; ");for(var g=a?void 0:{},f=0,j=b.length;f<j;f++){var h=b[f].split("="),l=c(h.shift()),h=c(h.join("="));if(a&&a===l){g=k(h);break}a||(g[l]=k(h))}return g};d.defaults={};e.removeCookie=function(a,c){return void 0!==e.cookie(a)?(e.cookie(a,"",e.extend({},c,{expires:-1})),!0):!1}})(jQuery);

	/* Global initialization */
	// Detecting browser and add the class name on body, so that we can use specific CSS style
	// or for specific usage.
	(function () {
		var ua  = navigator.userAgent.toLowerCase();

		var ua = navigator.userAgent.toLowerCase();
    var browser = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
            /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
            /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
            /(msie) ([\w.]+)/.exec( ua ) ||
            ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) || [];
    var kclass = browser[1] || "";

    if ( browser[1] == "webkit" ) {
    	var safari = /version\/([\d\.]+).*safari/.exec( ua );
      if (safari) {
      	kclass += " safari";
      	browser[2] = safari[1];
      }
    } else if ( browser[1] == "chrome" ) {
    	kclass += " webkit";
    }
    if (navigator.platform.toLowerCase().indexOf('mac') >= 0) {
			kclass += " mac";
		}

		MC.browser = browser[1];
		MC.browserVersion = parseInt(browser[2], 10);

		$(document.body).addClass(kclass);
	})();

  /* Bugfix for jquery ready() */
  // If jQuery is loaded after `DOMContentLoaded` is dispatched, jQuery will trigger `ready` event
  // after `window.load` event.
  // Since we're pretty sure the DOM is OK when this file is loaded, we just trigger an fake `DOMContentLoaded` event on document.
  if ( window.CustomEvent ) {
    // IE9, IE10 doesn't support CustomEvent
  	document.dispatchEvent( new CustomEvent("DOMContentLoaded") );
  }


	MC.template = template;
	return MC;
});
