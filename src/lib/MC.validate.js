/*
#**********************************************************
#* Filename: MC.validate.js
#* Creator: Tim
#* Description: The core of the whole system
#* Date: 20130813
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

var MC = MC || {};

(function( MC ) {

	MC = MC || {};

	var slice = function( arr ) {
		return Array.prototype.slice.apply( arr, Array.prototype.slice.call( arguments, 1 ) );
	};

	var regExp = {
		email: /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i,
		alphanum: /^\w+$/,
		digits: /^\d+$/,
		number: /^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/,
		phone: /^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/,
		// IPv4 only
		ipv4: /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/,
		// CIDR only
		cidr: /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(\d|[1-2]\d|3[0-2]))$/,
		// AWS CIDR
		awsCidr: /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([1][6789]|[2]\d|3[0-2]))$/,
		// IPv4 and CIDR
		ipaddress: /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(\d|[1-2]\d|3[0-2]))?$/
	};

	MC.validate = function() {
		var func = arguments[ 0 ];
		if ( func in MC.validate ) {
			return MC.validate[ func ].apply( MC.validate, slice( arguments, 1 ) );
		} else if ( func in regExp ) {
			return regExp[ func ].test( slice( arguments, 1, 2) );
		}
		else {
			throw "the validate method: [" + func + "] doesn't exist";
		}
	};

	MC.validate.required = function( value ) {
		return !! value;
	};

	MC.validate.equal = function( value1, value2 ) {
		return value1 === value2;
	};

	MC.validate.exist = function( value, set ) {
		if ( Array.prototype.indexOf && Array.prototype.indexOf === set.indexOf ) {
			return set.indexOf( value ) !== -1;
		}

		var i = 0;
		for ( ; i<set.length; i++ ) {
			if ( set[ i ] === value ) {
				break;
			}
		}

		return !( i === set.length );
	};

	MC.validate.range = function( value, range ) {
		return value >= range[ 0 ] && value <= range[ 1 ];
	};

	// helper

	MC.validate.preventDupname = function( target, id, name, type ) {
		target.parsley('custom', function() {
            if ( !MC.aws.aws.checkIsRepeatName( id, name ) ) {
                return type + ' name " ' + name + ' " is already in using. Please use another one.'
            }
		})
	};

})( MC );

