var MC = {
	version: '0.1',

	// Global Variable 
	API_URL: 'http://api.madeiracloud.com/',
	IMG_URL: 'http://img.madeiracloud.com/',

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
	 * @return {Boolean}        if the string is JSON, return true, otherwise return false
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
	 * @return {[type]}        [description]
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
					option.error(data.result[1], data.result[0]);
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

	/*
	For realtime CSS edit
	 */
	realtimeCSS: function ()
	{
		setInterval(function ()
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
	 * Format a number with grouped thousands
	 * @param  {number} number The target number
	 * @return {string}
	 *
	 * 3123131 -> 3,123,131
	 */
	number_format: function (number)
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
	}
};

// Storage
// Author: Angel
// 
// Save data into local computer via HTML5 localStorage, up to 10MB storage capacity.
// 
// Saving data
// MC.storage.set(name, value)
// 
// Getting data
// MC.storage.get(name)
// 
// Remove data
// MC.storage.remove(name)
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

// For event handler
var returnTrue = function () {return true},
	returnFalse = function () {return false};

/**
 * jQuery plugin to convert a given $.ajax response xml object to json.
 *
 * @example var json = $.xml2json(response);
 */
(function(){
	jQuery.extend({

		/**
		 * Converts an xml response object from a $.ajax() call to a JSON object.
		 *
		 * @param xml
		 */
		xml2json: function xml2json(xml)
		{
			var result = {};

			for (var i in xml.childNodes)
			{
				var node = xml.childNodes[i];
				if (node.nodeType == 1)
				{
					var child = node.hasChildNodes() ? xml2json(node) : node.nodevalue;
					child = child == null ? {} : child;

					if (result.hasOwnProperty(node.nodeName)) {
						// For repeating elements, cast the node to array
						if(!(result[node.nodeName] instanceof Array)){
							var tmp = result[node.nodeName];
							result[node.nodeName] = [];
							result[node.nodeName].push(tmp);
						}
						result[node.nodeName].push(child);
					}
					else
					{
						result[node.nodeName] = child;
					}

					// Add attributes if any
					if(node.attributes.length > 0) {
						result[node.nodeName]['@attributes'] = {};
						for(var j in node.attributes) {
							var attribute = node.attributes.item(j);
							result[node.nodeName]['@attributes'][attribute.nodeName] = attribute.nodeValue;
						}
					}

					// Add element value
					if(node.childElementCount == 0 && node.textContent != null && node.textContent != "") {
						result[node.nodeName]/*.value */= node.textContent.trim();
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
(function ($) {

	var pluses = /\+/g;

	function raw(s) {
		return s;
	}

	function decoded(s) {
		return decodeURIComponent(s.replace(pluses, ' '));
	}

	function converted(s) {
		if (s.indexOf('"') === 0) {
			// This is a quoted cookie as according to RFC2068, unescape
			s = s.slice(1, -1).replace(/\\"/g, '"').replace(/\\\\/g, '\\');
		}
		try {
			return config.json ? JSON.parse(s) : s;
		} catch(er) {}
	}

	var config = $.cookie = function (key, value, options) {

		// write
		if (value !== undefined) {
			options = $.extend({}, config.defaults, options);

			if (typeof options.expires === 'number') {
				var days = options.expires, t = options.expires = new Date();
				t.setDate(t.getDate() + days);
			}

			value = config.json ? JSON.stringify(value) : String(value);

			return (document.cookie = [
				config.raw ? key : encodeURIComponent(key),
				'=',
				config.raw ? value : encodeURIComponent(value),
				options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
				options.path    ? '; path=' + options.path : '',
				options.domain  ? '; domain=' + options.domain : '',
				options.secure  ? '; secure' : ''
			].join(''));
		}

		// read
		var decode = config.raw ? raw : decoded;
		var cookies = document.cookie.split('; ');
		var result = key ? undefined : {};
		for (var i = 0, l = cookies.length; i < l; i++) {
			var parts = cookies[i].split('=');
			var name = decode(parts.shift());
			var cookie = decode(parts.join('='));

			if (key && key === name) {
				result = converted(cookie);
				break;
			}

			if (!key) {
				result[name] = converted(cookie);
			}
		}

		return result;
	};

	config.defaults = {};

	$.removeCookie = function (key, options) {
		if ($.cookie(key) !== undefined) {
			// Must not alter options, thus extending a fresh object...
			$.cookie(key, '', $.extend({}, options, { expires: -1 }));
			return true;
		}
		return false;
	};
})(jQuery);

if (typeof define === "function")
{
	define( "MC", [], function () { return MC; } );
}