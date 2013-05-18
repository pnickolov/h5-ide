
###
//view.js
define( [ 'backbone', 'jquery', 'handlebars' ], function( Backbone, $, Handlebars ) {

    var MainView = Backbone.View.extend({

        el       : $( '#controlContent' ),
        template : Handlebars.compile( $( "#control-tmpl" ).html() ),

        events   : {
            'click .addModule1' : 'loadModule1',
            'click .addModule2' : 'loadModule2'
        },

        loadModule1 : function() {

            //loading bar
            $( '#itemContent' ).html( 'loading...' );

        },

        loadModule2 : function() {

            //loading bar
            $( '#itemShowContent' ).html( 'loading...' );
            
        },

        render      : function () {
            $( this.el ).html( this.template( this.model ));
            return this;
        }

    });

    return MainView;

});
###

define [ 'backbone', 'jquery', 'handlebars' ], ( Backbone, $, Handlebars ) ->

    MainView = Backbone.View.extend {

        el       : $( '#controlContent' )

        template : Handlebars.compile $( "#control-tmpl" ).html()

        events   :
            'click .addModule1' : 'loadModule1'
            'click .addModule2' : 'loadModule2'

        loadModule1 : () ->
            #loading bar
            $( '#itemContent' ).html 'loading...'

        loadModule2 : () ->
            #loading bar
            $( '#itemShowContent' ).html 'loading...'

        render      : () ->
             $( this.el ).html this.template()

    }

    return MainView