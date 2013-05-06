
define [ 'jquery', 'text!./module/leftpanel/template.html' ], ( $, template ) ->
    
    loadModule = () ->

        #load remote html template
        $( template ).appendTo 'head'

        #load remote css  template
        #style = '<style type="text/css">' + style + '</style>'
        #$( style ).appendTo 'head'

        #load remote module1.js
        require [ './module/leftpanel/view' ], ( View ) ->

            #view
            view       = new View()
            #itemView.model = item
            view.render()

    loadModule : loadModule