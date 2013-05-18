
###
//item view
define( [ 'backbone', 'jquery', 'handlebars' ], function( Backbone, $, Handlebars ) {

    var ItemView = Backbone.View.extend({

        el       : $('#itemContent'),
        template : Handlebars.compile( $("#item-modify-tmpl").html() ),

        events   : {
            'change .itemTitle' : 'changeTitle',
            'change .itemPrice' : 'changePrice'
        },

        changeTitle : function () {
            console.log('title before change:' + this.model.get('title'));
            this.model.set( 'title', $(this.el).find('.itemTitle').first().val() );
            console.log('title after change:' + this.model.get('title'));
        },

        changePrice : function() {
            console.log('price before change:' + this.model.get('price'));
            this.model.set( 'price', $(this.el).find('.itemPrice').first().val() );
            console.log('price after change:' + this.model.get('price'));
        },

        render      : function () {
            console.log('render');
            $( this.el ).html( this.template( this.model ));
            return this;
        }

    });

    return ItemView;

});
###

define [ 'backbone', 'jquery', 'handlebars' ], ( Backbone, $, Handlebars ) ->

    ItemView = Backbone.View.extend {

        el       : $( '#itemContent' )
        template : Handlebars.compile $( '#item-modify-tmpl' ).html()

        events   :
            'change .itemTitle' : 'changeTitle'
            'change .itemPrice' : 'changePrice'

        changeTitle : () ->
            #console.log 'title before change:' + this.model.get( 'title' )
            #this.model.set 'title', $(this.el).find( '.itemTitle' ).first().val()
            #console.log 'title after change:'  + this.model.get( 'title' )

            this.trigger 'titleChange', $( this.el ).find( '.itemTitle' ).first().val()

        changePrice : () ->
            #console.log 'price before change:' + this.model.get( 'price' )
            #this.model.set 'price', $(this.el).find( '.itemPrice' ).first().val()
            #console.log 'price after change:'  + this.model.get( 'price' )

            this.trigger 'priceChange', $( this.el ).find( '.itemPrice' ).first().val()

        render      : () ->
            console.log 'render'
            $( this.el ).html this.template( this.model )
    }

    return ItemView