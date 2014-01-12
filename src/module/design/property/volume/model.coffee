#############################
#  View Mode for design/property/volume
#############################

define [ '../base/model', 'constant', 'Design' ], ( PropertyModel, constant, Design ) ->

    VolumeModel = PropertyModel.extend {

        ###
        defaults :
            'uid' : null
            'volume_detail' : null
        ###

        init : ( uid ) ->

            component = Design.instance().component( uid )

            if !component
                console.error "[volume property] no volume component found!"
                return null

            res = component.attributes
            if !res.owner
                console.error "[volume property] can not found owner of volume!"
                return null

            # if not component
            # #volume of LC(old)
            #     realuid     = uid.split('_')
            #     device_name = realuid[2]
            #     realuid     = realuid[0]

            #     for block in components[realuid].resource.BlockDeviceMapping

            #         if block.DeviceName.indexOf(device_name) is -1
            #             continue

            #         volume_detail =
            #             isWin       : block.DeviceName[0] != '/'
            #             isLC        : true
            #             volume_size : block.Ebs.VolumeSize
            #             snapshot_id : block.Ebs.SnapshotId
            #             name        : block.DeviceName

            #         if volume_detail.isWin
            #             volume_detail.editName = volume_detail.name.slice(-1)

            #         else
            #             volume_detail.editName = volume_detail.name.slice(5)

            #         break

            if res.owner.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
            #volume of lc
                volume_detail =
                    isWin       : res.name[0] != '/'
                    isLC        : true
                    volume_size : res.volumeSize
                    snapshot_id : res.snapshotId
                    name        : res.name

                if volume_detail.isWin
                    volume_detail.editName = volume_detail.name.slice(-1)
                else
                    volume_detail.editName = volume_detail.name.slice(5)


            else if res.owner.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
            #volume of instance

                volume_detail =
                    isLC        : false
                    isWin       : res.name[0] != '/'
                    isStandard  : res.volumeType is 'standard'
                    iops        : res.iops
                    volume_size : res.volumeSize
                    snapshot_id : res.snapshotId
                    name        : res.name

                if volume_detail.isWin
                    volume_detail.editName = volume_detail.name.slice(-1)
                else
                    volume_detail.editName = volume_detail.name.slice(5)


            # Snapshot
            if volume_detail.snapshot_id
                snapshot_list = MC.data.config[Design.instance().region()].snapshot_list
                if snapshot_list and snapshot_list.item
                    for item in snapshot_list.item
                        if item.snapshotId is volume_detail.snapshot_id
                            volume_detail.snapshot_size = item.volumeSize
                            volume_detail.snapshot_desc = item.description
                            break

            if volume_detail.volume_size < 10
                volume_detail.iopsDisabled = true

            @set 'volume_detail', volume_detail
            @set 'uid', uid
            null

        setDeviceName : ( name ) ->

            components = Design.instance().component
            uid        = @get "uid"

            if not components( uid )

                realuid     = uid.split '_'
                device_name = realuid[ 2 ]
                lcUid     = realuid[ 0 ]

                lc = components( lcUid )

                volumeModel = Design.modelClassForType constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
                allVolume = volumeModel and volumeModel.allObjects() or []

                for v in allVolume
                    if v.get( 'owner' ) is lc
                        if v.get( 'name' ) is device_name

                            if v.get( 'name' )[0] not '/'
                                newDeviceName = 'xvd' + name
                                newId = "#{realuid}_volume_xvd#{name}"

                            else
                                newDeviceName = '/dev/' + name
                                newId = "#{realuid}_volume_#{name}"

                            v.set 'name', newDeviceName

                            MC.canvas.update uid, 'text', "volume_name", newDeviceName
                            MC.canvas.update realuid, 'id', "volume_#{device_name}", newId
                            @attributes.volume_detail.name     = newDeviceName
                            @attributes.volume_detail.editName = name

                            @set 'uid', newId

                            break

            else

                volume_comp = components[ uid ]

                if volume_comp.get( 'name' )[ 0 ] not '/'
                    newDeviceName = 'xvd' + name

                else
                    newDeviceName = '/dev/' + name

                volume_comp.set 'name', newDeviceName

                MC.canvas.update uid, 'text', "volume_name", newDeviceName

                @attributes.volume_detail.name = newDeviceName

            null

        setVolumeSize : ( value ) ->

            components = MC.canvas_data.component
            uid        = @get "uid"

            if not components[ uid ]

                realuid     = uid.split('_')
                device_name = realuid[2]
                realuid     = realuid[0]

                for block in components[realuid].resource.BlockDeviceMapping

                    if block.DeviceName.indexOf(device_name) >= 0

                        if block.DeviceName[0] != '/'
                            block.Ebs.VolumeSize = value
                        else
                            block.Ebs.VolumeSize = value

                        break

            else
                components[ uid ].resource.Size = value

            null

        setVolumeTypeStandard : () ->

            uid = @get "uid"
            comp_res = MC.canvas_data.component[uid].resource

            comp_res.VolumeType = 'standard'
            comp_res.Iops = ''

            null

        setVolumeTypeIops : ( value ) ->

            uid = @get "uid"
            comp_res = MC.canvas_data.component[uid].resource

            comp_res.VolumeType = 'io1'
            comp_res.Iops = value

            null

        setVolumeIops : ( value )->

            uid = @get "uid"
            MC.canvas_data.component[uid].resource.Iops = value

            null

        isDuplicate : ( name ) ->

            uid = @get "uid"
            component = MC.canvas_data.component[ uid ]

            if component
                instanceId = component.resource.AttachmentSet.InstanceId
                for comp_uid, comp of MC.canvas_data.component
                    if comp_uid is uid
                        continue

                    if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
                        continue

                    if comp.resource.AttachmentSet.InstanceId isnt instanceId
                        continue

                    if comp.name[0] != '/'
                        if comp.name == "xvd" + name
                            return true
                    else if comp.name.indexOf( name ) isnt -1
                        return true

            else
                realuid     = uid.split('_')
                device_name = realuid[2]
                realuid     = realuid[0]

                # First, test if the newly created name is not changed
                # Because parsely might fires event even if the name is not changed.
                if @attributes.volume_detail.editName is name
                    return false

                for block in MC.canvas_data.component[realuid].resource.BlockDeviceMapping

                    if block.DeviceName[0] != '/'
                        if block.DeviceName == "xvd" + name
                            return true
                    else if block.DeviceName.indexOf( name ) isnt -1
                        return true

            return false
    }

    new VolumeModel()
