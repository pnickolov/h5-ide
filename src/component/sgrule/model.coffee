#############################
#  View Mode for component/sgrule
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    SGRulePopupModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    return SGRulePopupModel