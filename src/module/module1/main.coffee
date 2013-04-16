
###
//item view
define( [ 'jquery', 'model', 'text!./template.html', 'text!./style.css' ], function( $, item, template, style ) {

    var loadModule = function() {

        //load remote html template
        $( template ).appendTo( "head" );
        //load remote css  template
        style = '<style type="text/css">' + style + '</style>';
        $( style ).appendTo( "head" );

        //load remote module1.js
        require( [ './module/module1/view.js' ], function( ItemView ) {
            var itemView   = new ItemView();
            itemView.model = item;
            itemView.render();
        });

    };

    return {
        loadModule : loadModule
    };

});
###

define [ 'jquery', 'model', 'text!./template.html', 'text!./style.css' ], ( $, item, template, style ) ->
    
    loadModule = () ->

        #load remote html template
        $( template ).appendTo 'head'

        #load remote css  template
        style = '<style type="text/css">' + style + '</style>'
        $( style ).appendTo 'head'

        #load remote module1.js
        require [ './module/module1/view.js' ], ( ItemView ) ->
            itemView       = new ItemView()
            itemView.model = item
            itemView.render()

    loadModule : loadModule