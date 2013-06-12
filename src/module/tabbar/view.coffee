#############################
#  View(UI logic) for tabbar
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    TabBarView = Backbone.View.extend {

        el       : $( '#tab-bar' )

        template : Handlebars.compile $( '#tabbar-tmpl' ).html()

        events   :
            'OPEN_TAB' : 'openTab'

        render   : () ->
            console.log 'tabbar render'
            $( this.el ).html this.template()

        openTab : ( event, original_tab_id, tab_id ) ->
            console.log 'openTab'
            #
            if tab_id is 'dashboard' then this.trigger 'SWITCH_DASHBOARD', 'dashboard' else this.trigger 'SWITCH_STACK_TAB', original_tab_id, tab_id
            null
    }

    return TabBarView