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
        require [ './module/tabbar/view' ], ( View ) ->

            #view
            view       = new View()
            view.render()

            #listen dashboard
            ide_event.onLongListen ide_event.OPEN_DASHBOARD, ( target ) ->
                console.log ide_event.OPEN_DASHBOARD + ' tab_name = ' + target
                #tabbar api
                Tabbar.open target
                #show dashboard and hide stack tab
                $( '#tab-content-dashboard' ).addClass 'active'
                $( '#tab-content' ).removeClass        'active'

            #listen stack tab
            ide_event.onLongListen ide_event.OPEN_STACK_TAB, ( target ) ->
                console.log ide_event.OPEN_STACK_TAB + ' tab_name = ' + target
                #tabbar api
                Tabbar.open target.toLowerCase(), target
                #hide dashboard and show stack tab
                $( '#tab-content-dashboard' ).removeClass 'active'
                $( '#tab-content' ).addClass              'active'

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule