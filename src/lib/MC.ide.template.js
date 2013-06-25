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
    //
    $( 'head' ).append( '<div id="template_' + suffix + '"></div>' )
    //
    suffix = '#template_' + suffix
    $( suffix ).html( template_data )
    //
    _.each( compile_obj, function( value, key ) {
    	tmp = $( suffix ).find( key ).html()
        //add handlebars script
        tmp = '<script type="text/x-handlebars-template" id="' + value + '">' + tmp + '</script>'
        $( tmp ).appendTo( 'head' )
    });
    //
    $( 'head' ).remove( suffix )
}