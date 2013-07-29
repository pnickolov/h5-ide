#############################
#  View Mode for design/property/sgrule
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    SGRuleModel = Backbone.Model.extend {

        defaults :
            sg_group : [
                    {
                        name  : "DefaultSG"
                        rules : [ {
                            egress     : true
                            protocol   : "TCP"
                            connection : "eni"
                            port       : "1234"
                        } ]
                    }
                ]
            line_id : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        setLineId : ( line_id ) ->

            this.set 'line_id', line_id

    }

    model = new SGRuleModel()

    return model
