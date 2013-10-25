#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    StaticSubModel = PropertyModel.extend {

        init : ( uid ) ->

            # If this uid is ami uid
            ami = MC.data.dict_ami[ uid ]
            if ami
                @set ami
                @set "instance_type", MC.aws.ami.getInstanceType( ami ).join(", ")
                @set "ami", true
                return

            # If this uid is snapshot uid
            snapshot_list = MC.data.config[MC.canvas.data.get('region')].snapshot_list
            if snapshot_list and snapshot_list.item
                for item in snapshot_list.item
                    if item.snapshotId is uid
                        @set item
                        return

            false
    }

    new StaticSubModel()
