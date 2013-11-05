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
                # $( '#modal-wrap' ).find( '#modal-run-stack' ).find( 'summary' ).after Handlebars.compile( template )( @model.attributes )
                @closedPopup() if $.trim( @$el.html() )
            else if type is 'statusbar'
                @$el.html modal_template
                @$el.find( '#modal-run-stack' ).html Handlebars.compile( template )( @model.attributes )
            #
            # @_clickCurrentTab status
            #
            $( '#btn-confirm' ).attr( 'disabled', true ) if MC.ta.state_list.error_list.length isnt 0
            #
            null

        _clickCurrentTab : ( status ) ->
            console.log '_clickCurrentTab, status = ' + status
            return if !status
            _.each $( '.tab' ).find( 'li' ), ( item ) ->
                $(item).trigger 'click' if $( item ).attr( 'data-tab-target' ) is '#item-' + status

        closedPopup : ->
            console.log 'closedPopup'
            @$el.empty()
            this.trigger 'CLOSE_POPUP'

    }

    return TrustedAdvisorView