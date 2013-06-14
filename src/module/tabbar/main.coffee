####################################
#  Controller for tabbar module
####################################

define [ 'jquery', 'text!/module/tabbar/template.html', 'event', 'UI.tabbar' ], ( $, template, ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="tabbar-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#tab-bar'

        #load remote module1.js
        require [ './module/tabbar/view', './module/tabbar/model' ], ( View, model ) ->

            #view
            view       = new View()

            #listen
            view.on 'SWITCH_DASHBOARD', ( target ) ->
                console.log 'SWITCH_DASHBOARD ' + ' tab_name = ' + target
                #push event
                ide_event.trigger ide_event.SWITCH_DASHBOARD, null

            #listen
            view.on 'SWITCH_STACK_TAB', ( original_tab_id, tab_id ) ->
                console.log 'SWITCH_STACK_TAB'
                console.log 'original_tab_id = ' + original_tab_id
                console.log 'tab_id          = ' + tab_id
                #model
                model.refresh original_tab_id, tab_id
                #push event
                ide_event.trigger ide_event.SWITCH_STACK_TAB, null

            #listen
            view.on 'CLOSE_STACK_TAB', ( tab_id ) ->
                console.log 'CLOSE_STACK_TAB'
                console.log 'tab_id          = ' + tab_id
                #model
                model.delete tab_id

            #listen stack tab
            ide_event.onLongListen ide_event.OPEN_STACK_TAB, ( target ) ->
                console.log ide_event.OPEN_STACK_TAB + ' tab_name = ' + target
                #tabbar api
                Tabbar.open target.toLowerCase(), target

            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule