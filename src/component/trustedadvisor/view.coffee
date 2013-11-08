#############################
#  View(UI logic) for component/trustedadvisor
#############################

define [ 'event',
         'text!./template.html', 'text!./modal_template.html',
         'backbone', 'jquery', 'handlebars'
], ( ide_event, template, modal_template ) ->

    TrustedAdvisorView = Backbone.View.extend {

        el         : '#status-bar-modal'

        events     :
            'click .modal-close'   : 'closedPopup'

        render     : ( type, status ) ->
            console.log 'pop-up:trusted advisor run render', status
            #
            if type is 'stack'
                $('#stack-run-validation-container').html Handlebars.compile( template )( @model.attributes )
                $('.validating').hide()
                @processDetails()
                $('.stack-validation details').show()
                # $( '#modal-wrap' ).find( '#modal-run-stack' ).find( 'summary' ).after Handlebars.compile( template )( @model.attributes )
            else if type is 'statusbar'
                @$el.html modal_template
                @$el.find( '#modal-validation-statusbar' ).html Handlebars.compile( template )( @model.attributes )
                @processStatusBarDetails()
                #
                $('#status-bar-modal').show()

            null

        processStatusBarDetails: ()->
            error = @model.get 'error_list'
            warning = @model.get 'warning_list'
            notice = @model.get 'notice_list'
            tabs = @$el.find '.tab li'

            if error.length

            else if warning.length
                tabs.eq( 1 ).click()

            else if notice.length
                tabs.eq( 2 ).click()
            else
                @$el.find( '.validation-content' ).text 'No error, warning or notice.'

        processDetails: () ->
            error = @model.get 'error_list'
            warning = @model.get 'warning_list'
            notice = @model.get 'notice_list'

            tabs = $ '#stack-run-validation-container .tab li'
            details = $ '#modal-run-stack details'
            nutshell = $ '#modal-run-stack .nutshell'
            summary = details.find 'summary'

            bindSummary = () ->
                summary.click ()->
                    if details.attr( 'open' ) is 'open'
                        nutshell.show()
                    else
                        nutshell.hide()

            processNutshell = ( notShow ) ->
                content = ''
                if error.length
                    content += "#{error.length} error, "
                    _.defer () ->
                        modal.position()

                if warning.length
                    content += "#{warning.length} warning, "
                if notice.length
                    content += "#{notice.length} notice, "

                if not content
                    content = 'No error, warning or notice.'
                else
                    content = content.slice 0, -2

                nutshell.find( 'label' ).text content
                nutshell.click () ->
                    summary.click()

                if not notShow
                    nutshell.show()


            if error.length
                bindSummary()
                processNutshell true

            else if warning.length
                tabs.eq( 1 ).click()
                details.removeAttr 'open'
                processNutshell()
                bindSummary()

            else if notice.length
                tabs.eq( 2 ).click()
                details.removeAttr 'open'
                processNutshell()
                bindSummary()
            else
                details.removeAttr 'open'
                processNutshell()
                bindSummary()
                $( '.validation-content' ).text 'No error, warning or notice.'



        restoreRun: ->
            $( '#btn-confirm' ).removeAttr( 'disabled' )


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
                $( '#status-bar-modal' ).hide()

    }

    return TrustedAdvisorView