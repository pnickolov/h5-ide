#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore', 'aws_model', 'constant' ], (Backbone, $, _, aws_model, constant) ->

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            temp : null
            #'resourse_list'         : null


        initialize : ->
            me = this
            
            console.error '1'

            aws_model.on 'AWS_RESOURCE_RETURN', ( result ) ->
                console.error '123'
                console.log result

            null
            
        #temp
        temp : ->
            me = this
            null


        describeAWSResourcesService : ( region )->

            me = this

            resources = [
                constant.AWS_RESOURCE.INSTANCE
                constant.AWS_RESOURCE.EIP
                constant.AWS_RESOURCE.VOLUME
                constant.AWS_RESOURCE.VPC
                constant.AWS_RESOURCE.VPN
                constant.AWS_RESOURCE.ELB
            ]

            aws_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  resources

    }

    model = new RegionModel()

    return model