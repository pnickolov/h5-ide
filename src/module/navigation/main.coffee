####################################
#  Controller for navigation module
####################################

define [ 'jquery',
         'text!/module/navigation/template.html',
         'text!/module/navigation/template_data.html',
         '/module/navigation/model.js',
         'event'
], ( $, template, template_data, model, ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script : template
        #template = '<script type="text/x-handlebars-template" id="navigation-tmpl">' + template + '</script>'
        #$( template ).appendTo 'head'

        #
        $( 'head' ).append '<div id="template_data"></div>'
        $( '#template_data' ).html template_data

        app_list_tmpl    = $( '#template_data' ).find( '.app_list' ).html()
        stack_list_tmpl  = $( '#template_data' ).find( '.stack_list' ).html()
        region_empty_list_tmpl = $( '#template_data' ).find( '.region_empty_list' ).html()
        region_list_tmpl = $( '#template_data' ).find( '.region_list' ).html()

        $( 'head' ).remove '#template_data'

        #add handlebars script : app_list
        app_list_tmpl = '<script type="text/x-handlebars-template" id="nav-app-list-tmpl">' + app_list_tmpl + '</script>'
        $( app_list_tmpl ).appendTo 'head'

        #add handlebars script : stack_list
        stack_list_tmpl = '<script type="text/x-handlebars-template" id="nav-stack-list-tmpl">' + stack_list_tmpl + '</script>'
        $( stack_list_tmpl ).appendTo 'head'

        #add handlebars script : region_empty_list_tmpl
        region_empty_list_tmpl = '<script type="text/x-handlebars-template" id="nav-region-empty-list-tmpl">' + region_empty_list_tmpl + '</script>'
        $( region_empty_list_tmpl ).appendTo 'head'

        #add handlebars script : region_list_tmpl
        region_list_tmpl = '<script type="text/x-handlebars-template" id="nav-region-list-tmpl">' + region_list_tmpl + '</script>'
        $( region_list_tmpl ).appendTo 'head'

        #load remote /module/navigation/view.js
        require [ './module/navigation/view', 'UI.tooltip', 'UI.accordion', 'hoverIntent' ], ( View ) ->

            #view
            view       = new View()
            view.model = model
            #refresh view
            view.render( template )

            #listen vo set change event
            model.on 'change:app_list', () ->
                console.log 'change:app_list'
                #push event
                ide_event.trigger ide_event.RESULT_APP_LIST, model.get 'app_list'
                #refresh view
                view.appListRender()
                #call
                model.stackListService()

            model.on 'change:stack_list', () ->
                console.log 'change:stack_list'
                #push event
                ide_event.trigger ide_event.RESULT_STACK_LIST, model.get 'stack_list'
                #refresh view
                view.stackListRender()
                #call
                model.regionEmptyList()

            model.on 'change:region_empty_list', () ->
                console.log 'change:region_empty_list'
                #push event
                ide_event.trigger ide_event.RESULT_EMPTY_REGION_LIST, null
                #refresh view
                view.regionEmtpyListRender()
                #call
                model.describeRegionsService()

            model.on 'change:region_list', () ->
                console.log 'change:region_list'
                #refresh view
                view.regionListRender()

            #model
            model.appListService()

            ide_event.onLongListen ide_event.UPDATE_APP_LIST, () ->
                console.log 'UPDATE_APP_LIST'
                #call
                model.appListService()

            ide_event.onLongListen ide_event.UPDATE_STACK_LIST, () ->
                console.log 'UPDATE_STACK_LIST'
                #call
                model.stackListService()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule