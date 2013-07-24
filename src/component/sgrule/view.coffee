#############################
#  View(UI logic) for component/sgrule
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.modal'
], ( ide_event ) ->

    SGRulePopupView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.sgrule-popup'

        events   :
            'click .sgrule-click' : 'sgRuleClickEvent'
            'closed'              : 'closedSGRulePopup'

        render     : ( template ) ->
            console.log 'pop-up:sgrule render'
            modal template, true

        sgRuleClickEvent : ->
            console.log 'sgRuleClickEvent'

        closedSGRulePopup : ->
            console.log 'closedSGRulePopup'
            this.trigger 'CLOSE_POPUP'

    }

    return SGRulePopupView