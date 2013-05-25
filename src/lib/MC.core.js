/*
#**********************************************************
#* Filename: MC.core.js
#* Creator: Angel
#* Description: The core of the whole system 
#* Date: 20130525
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var MC = {
	version: '0.1.3',

	// Global Variable 
	API_URL: 'https://api.madeiracloud.com/',
	IMG_URL: 'https://img.madeiracloud.com/',

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
		var api_frame = $('#api_frame'),
			guid = MC.guid(),
			callback = function(event)
			{
				var data = event.originalEvent.data,
					option = MC.api_queue[data.id];

				if (data.call === 'success' && option.success)
				{
					option.success(data.result[1], data.result[0]);
				}
				if (data.call === 'error' && option.error)
				{
					option.error(data.result.message, data.result.code);
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
						url: option.url,
						method: option.method || '',
						params: option.data || {}
					}, '*');
				}
			};

		MC.api_queue[guid] = option;
		
		if (!api_frame[0])
		{
			$(document.body).append('<iframe id="api_frame" src="https://api.madeiracloud.com/api.html" style="display:none;"></iframe>');
			api_frame = $('#api_frame');
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
		var rbrowser = /(webkit|firefox|opera|msie|ipad|iphone|android)/ig;

		rbrowser.exec(navigator.userAgent.toLowerCase());

		$(document.body).addClass(RegExp.$1);
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
	 * Generate random number
	 * @param  {number} min min number
	 * @param  {number} max max number
	 * @return {number} The randomized number
	 */
	rand: function (min, max)
	{
		return Math.floor(Math.random() * (max - min + 1) + min);
	}
};

/*
* Storage
* Author: Angel
* 
* Save data into local computer via HTML5 localStorage, up to 10MB storage capacity.
* 
* Saving data
* MC.storage.set(name, value)
* 
* Getting data
* MC.storage.get(name)
* 
* Remove data
* MC.storage.remove(name)
*/
MC.storage = {
	set: function (name, value)
	{
		localStorage[name] = typeof value === 'object' ? JSON.stringify(value) : value;
	},

	get: function (name)
	{
		var data = localStorage[name];

		if (MC.isJSON(data))
		{
			return JSON.parse(data);
		}

		return data || '';
	},

	remove: function (name)
	{
		localStorage.removeItem(name);

		return true;
	}
};

MC.WebSocket = function (host, options)
{
	return this.WebSocket.prototype.init(host, options);
};

MC.WebSocket.prototype = {
	init: function (host, options)
	{
		var socket = new WebSocket(host),
			data;

		if (socket)
		{
			if (options)
			{
				$.each('open message error close'.split(' '), function (i, name)
				{
					if (options['on' + name] && typeof options['on' + name] === 'function')
					{
						if (name === 'message')
						{
							$(socket).on(name, function (event)
							{
								data = event.originalEvent.data;
								data = MC.isJSON(data) ? JSON.parse(data) : data;

								options.onmessage(data);
							});
						}
						else
						{
							$(socket).on(name, options['on' + name]);
						}
					}
				});
			}

			$.each(MC.WebSocket.prototype, function (name, value)
			{
				if (typeof value === 'function')
				{
					socket[name] = value;
				}
			});
			socket.options = options;

			return socket;
		}
		else
		{
			return false;
		}
	},

	post: function (message)
	{
		if (this.send(message) === false && this.options.onerror)
		{
			this.options.onerror.call(this);
			
			return false;
		}
		return true;
	},

	reconnect: function ()
	{
		this.close();

		return MC.WebSocket.prototype.init(this.URL, this.options);
	}
};

/**
 * jQuery plugin to convert a given $.ajax response xml object to json.
 *
 * @example var json = $.xml2json(response);
 */
(function(){jQuery.extend({xml2json:function f(d){var b={},e;for(e in d.childNodes){var a=d.childNodes[e];if(1==a.nodeType){var c=a.hasChildNodes()?f(a):a.nodevalue,c=null==c?{}:c;if(b.hasOwnProperty(a.nodeName)){if(!(b[a.nodeName]instanceof Array)){var g=b[a.nodeName];b[a.nodeName]=[];b[a.nodeName].push(g)}b[a.nodeName].push(c)}else b[a.nodeName]=c;if(0<a.attributes.length){b[a.nodeName]["@attributes"]={};for(var h in a.attributes)c=a.attributes.item(h),b[a.nodeName]["@attributes"][c.nodeName]=c.nodeValue}0==a.childElementCount&&(null!=a.textContent&&""!=a.textContent)&&(b[a.nodeName]=a.textContent.trim())}}return b}})})();

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
	// Detecting browser and add the class name on body, so that we can use specific CSS style
	// or for specific usage.
	MC.browserDetect();
});

/* Define as MC module */
if (typeof define === "function")
{
	define( "MC", [], function () { return MC; } );
}