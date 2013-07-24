#############################
#  View Mode for component/sgrule
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    SGRulePopupModel = Backbone.Model.extend {

        defaults :
            inward   :
                name : "instance"
                sg   : ["DefaultSG", "CustomSG"]
                connection : ["eni", "eni-1"]
 
            outward  :
                name : "eni"
                sg   : ["DefaultSG", "CustomSG"]
                connection : ["eni", "eni-1"]
 
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

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    return SGRulePopupModel
