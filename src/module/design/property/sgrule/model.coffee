#############################
#  View Mode for design/property/sgrule
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    SGRuleModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new SGRuleModel()

    return model