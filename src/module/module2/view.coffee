
###
//item show view
define( [ 'backbone', 'jquery', 'handlebars' ], function( Backbone, $, Handlebars ) {

    var ItemShowView = Backbone.View.extend({

        el       : $('#itemShowContent'),
        template : Handlebars.compile( $("#item-show-tmpl").html() ),

        render   : function () {
            $( this.el ).html( this.template( this.model ));
            return this;
        }

    });

    return ItemShowView;

});
###

#item show view
define [ 'backbone', 'jquery', 'handlebars' ], ( Backbone, $, Handlebars ) ->

    ItemShowView = Backbone.View.extend {

        el       : $( '#itemShowContent' )

        template : Handlebars.compile $( '#item-show-tmpl' ).html()

        render   : () ->
            $( this.el ).html this.template( this.model )
            
    }

    return ItemShowView