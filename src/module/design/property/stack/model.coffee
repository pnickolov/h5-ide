#############################
#  View Mode for design/property/stack
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'constant' ], (Backbone, $, _, MC, constant) ->

    StackModel = Backbone.Model.extend {

        defaults :
            'stack_detail'  : null
            'sg_display'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getStack : ->
            me = this

            stack_detail = $.extend true, {}, MC.canvas_data
            stack_detail.name = MC.canvas_data.name
            stack_detail.region = constant.REGION_LABEL[MC.canvas_data.region]
            stack_detail.type = me.getStackType()
            stack_detail.is_vpc = true if stack_detail.type and stack_detail.type != 'EC2 Classic'
            
            if stack_detail.is_vpc
                stack_detail.acl_list = me.getNetworkACL()

            me.getSecurityGroup()

            stack_detail.cost = me.getStackCost()

            me.set 'stack_detail', stack_detail

        getStackType : ->
            type = MC.canvas_data.platform

            if type == 'ec2-classic'
                return 'EC2 Classic'
            else if type == 'ec2-vpc'
                return 'EC2 VPC'
            else if type == 'default-vpc|custom-vpc'
                return 'Default VPC'
            else if type == 'custom-vpc'
                return 'Custom VPC'

        getSecurityGroup : ->
            me = this

            stack_sg = {}
            stack_sg.detail = []
            stack_sg.rules_detail_ingress = []
            stack_sg.rules_detail_egress = []

            _.map MC.canvas_property.sg_list, ( sg ) ->
                sg_detail = {}

                sg_detail.uid = sg.uid
                sg_detail.parent = sg.uid
                sg_detail.members = sg.member.length
                sg_detail.rules = MC.canvas_data.component[sg.uid].resource.IpPermissions.length + MC.canvas_data.component[sg.uid].resource.IpPermissionsEgress.length
                sg_detail.name = MC.canvas_data.component[sg.uid].resource.GroupName
                sg_detail.desc = MC.canvas_data.component[sg.uid].resource.GroupDescription
                
                stack_sg.rules_detail_ingress = stack_sg.rules_detail_ingress.concat MC.canvas_data.component[sg.uid].resource.IpPermissions
                stack_sg.rules_detail_egress = stack_sg.rules_detail_egress.concat MC.canvas_data.component[sg.uid].resource.IpPermissionsEgress
                
                stack_sg.detail.push sg_detail

            array_unique = ( ori_ary )->

                if ori_ary.length == 0
                    return []

                ary = ori_ary.slice 0
                tmp = []

                $.each ary, (idx, value)->
                    str = JSON.stringify value
                    if str not in tmp
                        tmp.push str
                    null
                                
                return (JSON.parse item for item in tmp)


            stack_sg.rules_detail_ingress = array_unique stack_sg.rules_detail_ingress
            stack_sg.rules_detail_egress = array_unique stack_sg.rules_detail_egress
                          
            me.set 'sg_display', stack_sg

        deleteSecurityGroup : (uid) ->
            me = this

            #delete sg from MC.canvas_property.sg_list
            $.each MC.canvas_property.sg_list, ( key, sg ) ->

                if sg and sg.uid == uid

                    #update instance
                    _.map sg.member, (iid) ->

                        sg_id_ref = "@"+uid+'.resource.GroupId'

                        sg_ids = MC.canvas_data.component[ iid ].resource.SecurityGroupId

                        if sg_ids.length != 1

                            MC.canvas_data.component[ iid ].resource.SecurityGroupId.splice sg_ids.indexOf sg_id_ref, 1

                    MC.canvas_property.sg_list.splice key, 1

                    delete MC.canvas_data.component[uid]

            null

        resetSecurityGroup : (uid) ->
            me = this

            stack_detail = me.get 'stack_detail'

            _.map stack_detail.sg_list, (sg) ->
                if sg.uid == uid

                    flag = stack_detail.sg_list[ stack_detail.sg_list.indexOf sg ].is_shown
                    stack_detail.sg_list[ stack_detail.sg_list.indexOf sg ].is_shown = not flag

                    me.set 'stack_detail', stack_detail

            console.log me.get 'stack_detail'

            null


        getNetworkACL : ->

        getStackCost : ->


    }

    model = new StackModel()

    return model