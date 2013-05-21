
###
//item view
define( [ 'jquery', 'model', 'text!./template.html' ], function( $, item, template ) {

    var loadModule = function() {

        //load remote html template
        $( template ).appendTo( "head" );

        //load remote module1.js
        require( [ './module/module2/view.js' ], function( ItemShowView ) {
            
            var itemShowView   = new ItemShowView();
            itemShowView.model = item;
            itemShowView.render();

            item.on( 'change', function() {
                console.log( 'change' );
                itemShowView.render();
            });

        });

    };

    return {
        loadModule : loadModule
    };

});
###

define [ 'jquery', 'model', 'text!./template.html' ], ( $, item, template ) ->

    #private
    loadModule = () ->

        #load remote html template
        $( template ).appendTo 'head'

        #load remote module1.js
        require [ './module/module2/view.js' ], ( ItemShowView ) ->
            
            itemShowView   = new ItemShowView()
            itemShowView.model = item
            itemShowView.render()

            item.on 'change', () ->
                console.log 'change'
                itemShowView.render()

    #public
    loadModule : loadModule
