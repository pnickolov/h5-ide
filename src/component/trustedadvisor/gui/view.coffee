#############################
#  View(UI logic) for component/trustedadvisor
#############################

define [ 'event', 'i18n!/nls/lang.js',
         './tpl/template', './tpl/modal_template',
         'backbone', 'jquery', 'handlebars'
], ( ide_event, lang, template, modal_template ) ->

    TrustedAdvisorView = Backbone.View.extend {

        el         : '.status-bar-modal'

        events     :
            'click .modal-close'   : 'closedPopup'

        render     : ( type, status ) ->
            console.log 'pop-up:trusted advisor run render', status

            if type is 'stack'
                $('#stack-run-validation-container').html template( @model.attributes )
                $('.validating').hide()
                @processDetails()
                $('.stack-validation details').show()
            else if type is 'statusbar'
                @$el.html modal_template()
                @$el.find( '#modal-validation-statusbar' ).html template( @model.attributes )
                @processStatusBarDetails()
                #
                $('.status-bar-modal').show()
            else if type is 'openstack'
              $('.validating').hide()
              false
            null

        processStatusBarDetails: ()->
            error = @model.get 'error_list'
            warning = @model.get 'warning_list'
            notice = @model.get 'notice_list'
            $tabs = @$el.find '.tab li'

            if error.length

            else if warning.length
                $tabs.eq( 1 ).click()

            else if notice.length
                $tabs.eq( 2 ).click()
            else
                @$el.find( '.validation-content' ).text lang.IDE.GREAT_JOB_NO_ERROR_WARNING_NOTICE_HERE
                @$el.find( '.validation-content' ).addClass 'empty'

        processDetails: () ->
            error = @model.get 'error_list'
            warning = @model.get 'warning_list'
            notice = @model.get 'notice_list'

            $tabs = $ '.modal-box .tab li'
            $nutshell = $ '.modal-box .nutshell'
            $details = $nutshell.prev 'details'
            $summary = $details.find 'summary'

            processNutshell = ( notShow ) ->
                contentArr = []
                if error.length
                    contentArr.push sprintf lang.IDE.LENGTH_ERROR, error.len
                    _.defer () ->
                        modal.position()

                if warning.length
                    contentArr.push sprintf lang.IDE.LENGTH_WARNING, warning.length
                if notice.length
                    contentArr.push sprintf lang.IDE.LENGTH_NOTICE, notice.length

                if not contentArr.length
                    content = lang.IDE.NO_ERROR_WARNING_OR_NOTICE
                else
                    content = contentArr.join lang.IDE.COMMA

                $nutshell.find( 'label' ).text content
                $nutshell.click () ->
                    $summary.click()


            if error.length
                processNutshell true

            else if warning.length
                $tabs.eq( 1 ).click()
                $details.removeAttr 'open'
                processNutshell()

            else if notice.length
                $tabs.eq( 2 ).click()
                $details.removeAttr 'open'
                processNutshell()
            else
                $details.removeAttr 'open'
                processNutshell()
                $( '.validation-content' ).text 'Great job! No error, warning or notice here.'

        restoreRun: ->
            $( '#btn-confirm, #confirm-update-app' ).removeAttr( 'disabled' )

        _clickCurrentTab : ( status ) ->
            console.log '_clickCurrentTab, status = ' + status
            return if !status
            _.each $( '.tab' ).find( 'li' ), ( item ) ->
                $(item).trigger 'click' if $( item ).attr( 'data-tab-target' ) is '#item-' + status

        closedPopup : ->
            if @$el.html()
                console.log 'closedPopup'
                @$el.empty()
                this.trigger 'CLOSE_POPUP'
                $( '.status-bar-modal' ).hide()

    }

    return TrustedAdvisorView
