

define [ 'backbone', 'jquery', 'handlebars', 'UI.tooltip' ], () ->

    LeftPanelView = Backbone.View.extend {

        #element
        el       : $( '#siderbar' )

        #template
        template : Handlebars.compile $( '#leftpanel-tmpl' ).html()

        #event handler
        events   :
            'click #hide_siderbar_btn'  : 'hideSiderbarEventHandler'
            'click #show_siderbar_btn'  : 'showSiderbarEventHandler'
            'click .siderbar_tab_title' : 'siderbarTabEventHandler'

        #method
        hideSiderbarEventHandler : () ->

            console.log 'hideSiderbarEventHandler'

            $('#siderbar_body_main').hide()

            $('#main_body').animate { 'margin-left': 60 }, 300

            $('#siderbar').animate { 'width': 60 }       , 300

            $('#show_siderbar_btn').fadeIn()

        showSiderbarEventHandler : () ->

            console.log 'showSiderbarEventHandler'

            $('#main_body').animate { 'margin-left': 279 }, 300

            $('#siderbar').animate { 'width': 279 }       , 300, () ->
                $('#siderbar_body_main').show()
                $('#show_siderbar_btn').fadeOut()

        siderbarTabEventHandler : ( event ) ->

            console.log 'siderbarTabEventHandler'

            target =  $( event.target )
            list   = target.next()

            if list.css( 'display' ) isnt 'block'
                $('.siderbar_tab ol').slideUp()
                list.slideDown 200
            return

        render : () ->
            console.log '-- lefet panel render --'

            $( this.el ).html this.template()
    }

    return LeftPanelView