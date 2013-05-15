

define [ 'backbone', 'jquery', 'handlebars', 'UI.scrollbar' ], () ->

    CanvasView = Backbone.View.extend {

        #element
        el          : $( '#main_body' )

        #template
        template    : Handlebars.compile $( '#canvas-tmpl' ).html()

        render      : () ->
            console.log '-- canvas render --'
            $( this.el ).html this.template()
    }

    return CanvasView