#############################
#  View(UI logic) for dialog
#############################

define [ 'backbone', 'jquery', 'handlebars' ], ( Backbone, $, Handlebars ) ->

    Dialog = Backbone.View.extend {

        el       : $( '#dialogGroup' )

        template : Handlebars.compile $( '#dialog-tmpl' ).html()

        render   : () ->
            console.log 'render'
            $( this.el ).html this.template()
            this.trigger 'complete', null

        popup    : () ->
            console.log 'popup'
            $( '#myModal' ).modal()

        remove   : () ->
            console.log 'remove'
            $( this.el ).empty()
    }

    return Dialog