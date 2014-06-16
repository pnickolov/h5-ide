#############################
#  View(UI logic) for component/amis
#############################

define [ 'event', './template'
         'i18n!nls/lang.js', 'UI.modalplus'
         'backbone', 'jquery', 'handlebars',
         'UI.modal', 'jqpagination'
], ( ide_event, template, lang, Modal, Backbone, $, Handlebars ) ->

    AMIsView = Backbone.View.extend {

        events   :
            'closed'                                            : 'closedAMIsPopup'
            'click .ami-option-group .ami-option-wrap .btn'     : 'clickOptionBtn'

        render     : () ->
            console.log 'pop-up:amis run render'
            @modal = new Modal
              title: lang.ide.AMI_LBL_COMMUNITY_AMIS
              width: "855px"
              template: template()
              disableFooter: true
              compact: true
        showLoading: ->
            this.$( '.scroll-content' ).hide()
            this.$( '.show-loading' ).show()

        showContent: ->
            this.$( '.show-loading' ).hide()
            this.$( '.scroll-content' ).show()

        closedAMIsPopup : ->
            console.log 'closedAMIsPopup'
            this.trigger 'CLOSE_POPUP'

        clickOptionBtn : (event) ->
            console.log 'click option button'

            if $(event.target).hasClass('active')
                active_btns = $(event.target).parent().find('.active')
                if active_btns.length is 1 and active_btns[0] == event.target   # click the only one active button not reply
                    return
                else
                    $(event.target).removeClass('active')
            else
                $(event.target).addClass('active')

            null

    }

    return AMIsView
