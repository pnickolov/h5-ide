

define [ 'backbone', 'jquery', 'handlebars', 'UI.tooltip', 'UI.scrollbar' ], () ->

    LeftPanelView = Backbone.View.extend {

        #element
        el          : $( '#siderbar' )

        #template
        template    : Handlebars.compile $( '#leftpanel-tmpl' ).html()

        #event handler
        events   :
            'click #hide_siderbar_btn'  : 'hide_siderbar'
            'click #show_siderbar_btn'  : 'show_siderbar'
            'click .siderbar_tab_title' : 'siderbar_tab_click'

        #method
        hide_siderbar : () ->

            console.log 'hide_siderbar'

            $('#siderbar_body_main').hide()

            $('#main_body').animate { 'margin-left': 60 }, 300

            $('#siderbar').animate { 'width': 60 }      , 300

            $('#show_siderbar_btn').fadeIn()

        show_siderbar : () ->

            console.log 'show_siderbar'

            $('#main_body').animate { 'margin-left': 279 }, 300

            $('#siderbar').animate { 'width': 279 }, 300, () ->
                $('#siderbar_body_main').show()
                $('#show_siderbar_btn').fadeOut()

        siderbar_tab_click : ( event ) ->

            console.log 'siderbar_tab_click'

            target =  $( event.target )
            list   = target.next()

            if list.css('display') != 'block'
                $('.siderbar_tab ol').slideUp()
                list.slideDown 200
            return

        render      : () ->
            console.log 'render'

            $( this.el ).html this.template()
            this
    }

    return LeftPanelView