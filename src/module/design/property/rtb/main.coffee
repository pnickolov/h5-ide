####################################
#  Controller for design/property/rtb module
####################################

define [ 'jquery',
         'text!/module/design/property/rtb/template.html',
         'text!/module/design/property/rtb/app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-rtb-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-rtb-app-tmpl">' + app_template + '</script>'
    #load remote html template
    $( 'head' ).append( template ).append( app_template )

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP'
            loadAppModule uid
            return

        #
        require [ './module/design/property/rtb/view',
                  './module/design/property/rtb/model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model
            #render

            if tab_type is 'OPEN_APP'

                model.getAppRoute uid

            else

                model.getRoute( uid )

            view.render()

            view.on 'SET_ROUTE', ( uid, data, routes ) ->

                model.setRoutes uid, data, routes

            view.on 'SET_NAME', ( uid, name ) ->

                model.setName uid, name

            view.on 'SET_MAIN_RT', ( uid ) ->

                model.setMainRT uid

                model.getRoute( uid )

                view.render()

            view.on 'SET_PROPAGATION', ( uid, value ) ->

                model.setPropagation uid, value

            ide_event.on ide_event.CANVAS_DELETE_OBJECT, () ->

                model.getRoute( uid )

                view.render()

            ide_event.on ide_event.CANVAS_CREATE_LINE, () ->

                model.getRoute( uid )

                view.render()


    loadAppModule = ( uid ) ->
        require [ './module/design/property/rtb/app_view',
                  './module/design/property/rtb/app_model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.init uid
            view.render()


    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        ide_event.offListen ide_event.CANVAS_DELETE_OBJECT
        ide_event.offListen ide_event.CANVAS_CREATE_LINE
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
