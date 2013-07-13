#############################
#  View Mode for design/property/instance
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    InstanceModel = Backbone.Model.extend {

        defaults :
            'sg_detail'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getSG : ( uid, parent ) ->

            me = this

            sg_detail = {}

            sg_detail.parent = parent

            sg_detail.component = MC.canvas_data.component[uid]

            _.map MC.canvas_property.sg_list, ( value ) ->

                if value.uid == uid

                    sg_detail.members = value.member.length

                    if MC.canvas_data.component[uid].resource.IpPermissionsEgress

                            sg_detail.rules = MC.canvas_data.component[uid].resource.IpPermissions.length + MC.canvas_data.component[uid].resource.IpPermissionsEgress.length
                        else

                            sg_detail.rules = MC.canvas_data.component[uid].resource.IpPermissions.length

                    sg_detail.member_names = []

                    _.map value.member, ( instance_uid ) ->

                        sg_detail.member_names.push MC.canvas_data.component[instance_uid].name

                null

            me.set 'sg_detail', sg_detail

        addSG : ( parent )->

            me = this

            uid = MC.guid()

            component_data = $.extend(true, {}, MC.canvas.SG_JSON.data)

            if not MC.canvas_data.component[parent].resource.VpcId

                delete component_data.resource.IpPermissionsEgress

            component_data.uid = uid

            sg_name = 'custom-sg'
            # check custom sg name duplicate or not
            component_data.name = sg_name

            component_data.resource.GroupName = sg_name

            tmp = {}
            tmp.uid = uid
            tmp.name = sg_name
            tmp.member = [ parent ]

            MC.canvas_property.sg_list.push tmp

            data = MC.canvas.data.get('component')

            data[uid] = component_data
            
            MC.canvas.data.set('component', data)

            sg_detail = {}

            sg_detail.parent = parent

            sg_detail.component = MC.canvas_data.component[uid]

            sg_detail.members = 1

            sg_detail.rules = 1

            sg_detail.member_names = [ MC.canvas_data.component[parent].name ]

            MC.canvas_data.component[parent].resource.SecurityGroupId.push '@'+uid+'.resource.GroupId'

            me.set 'sg_detail', sg_detail

        setSGName : ( uid, value ) ->

            old_name = MC.canvas_data.component[uid].resource.GroupName

            MC.canvas_data.component[uid].resource.GroupName = value

            MC.canvas_data.component[uid].name = value

            _.map MC.canvas_property.sg_list, ( sg ) ->

                if sg.name == old_name

                    sg.name = value

                null

            null

    }

    model = new InstanceModel()

    return model