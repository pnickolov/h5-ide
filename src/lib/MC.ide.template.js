/*
#**********************************************************
#* Filename: MC.ide.template.js
#* Creator: Kenshin
#* Description: The file to storage HTML templates for IDE
#* Date: 20130624
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

MC.IDEcompile = function( suffix, template_data, compile_obj ) {
    
    var data  = template_data.split( /\<!--{{ (.*) }}--\>/ig )
    data      = _.difference( data, _.keys( compile_obj ))
    data      = _.rest( data )
    data      = _.object( _.values( compile_obj ), data )

    //
    _.each( data, function( value, key ) {
        tmp = '<script type="text/x-handlebars-template" id="' + key + '">' + value + '</script>'
        $( tmp ).appendTo( 'head' )
    });
}