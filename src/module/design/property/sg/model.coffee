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

            console.log uid

            sg_detail = {}

            sg_detail.parent = parent
            
            sg_detail.component = MC.canvas_data.component[uid]

            _.map MC.canvas_property.sg_list, ( value ) ->

                if value.uid == uid

                    sg_detail.members = value.member.length

                    if MC.canvas_data.component[uid].resource.IpPermissionsEgress

                            sg_detail.rules = MC.canvas_data.component[sg_uid].resource.IpPermissions.length + MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress.length
                        else

                            sg_detail.rules = MC.canvas_data.component[sg_uid].resource.IpPermissions.length

                    sg_detail.member_names = []

                    _.map value.member, ( instance_uid ) ->

                        sg_detail.member_names.push MC.canvas_data.component[instance_uid].name

                null

            me.set 'sg_detail', sg_detail

    }

    model = new InstanceModel()

    return model