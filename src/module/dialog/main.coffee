####################################
#  Controller for dialog module
####################################

define [ 'jquery', 'text!./template.html', 'bootstrap-modal' ], ( $, template, bootstrap_modal ) ->

    view = null

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="dialog-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo 'head'

        #load remote module1.js
        require [ './module/dialog/view' ], ( View ) ->

            #view
            view       = new View()

            view.on 'complete', () ->
                console.log 'complete'
                view.popup()

            view.render()

    unLoadModule = () ->
        view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule