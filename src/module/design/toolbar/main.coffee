####################################
#  Controller for design/toolbar module
####################################

define [ 'jquery', 'text!/module/design/toolbar/template.html', 'event' ], ( $, template, event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="toolbar-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#main-toolbar'

        #load remote module1.js
        require [ './module/design/toolbar/view', './module/design/toolbar/model' ], ( View, model ) ->

            #view
            view       = new View()
            view.model = model
            view.render template

            #save
            view.on 'TOOLBAR_SAVE_STACK_CLICK', () ->
                console.log 'design_toolbar_click:save_stack'
                model.save_stack()

            #duplicate
            view.on 'TOOLBAR_DUPLICATE_STACK_CLICK', () ->
                console.log 'design_toolbar_click:duplicate_stack'
                model.duplicate_stack()

            #delete
            view.on 'TOOLBAR_DELETE_STACK_CLICK', () ->
                console.log 'design_toolbar_click:delete_stack'
                model.delete_stack()

            #new
            view.on 'TOOLBAR_NEW_STACK_CLICK', () ->
                console.log 'design_toolbar_click:new_stack'
                model.new_stack()

            #run
            view.on 'TOOLBAR_RUN_STACK_CLICK', () ->
                console.log 'design_toolbar_click:run_stack'
                model.run_stack( 'stack_test_run' )

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule