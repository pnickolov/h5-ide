#############################
#  View Mode for design/property/volume
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    VolumeModel = PropertyModel.extend {

        ###
        defaults :
            'uid' : null
            'volume_detail' : null
        ###

        init : ( uid ) ->

            components = MC.canvas_data.component

            if not components[ uid ]
                #lc
                realuid     = uid.split('_')
                device_name = realuid[2]
                realuid     = realuid[0]

                for block in components[realuid].resource.BlockDeviceMapping

                    if block.DeviceName.indexOf(device_name) is -1
                        continue

                    volume_detail =
                        isWin       : block.DeviceName[0] != '/'
                        isLC        : true
                        isStandard  : block.Ebs.VolumeType is 'standard'
                        iops        : block.Ebs.Iops
                        volume_size : block.Ebs.VolumeSize
                        snapshot_id : block.Ebs.SnapshotId
                        name        : block.DeviceName

                    if volume_detail.isWin
                        volume_detail.editName = volume_detail.name.slice(-1)

                    else
                        volume_detail.editName = volume_detail.name.slice(5)

                    break

            else
                #instance
                res = components[ uid ].resource

                volume_detail =
                    isLC        : false
                    isWin       : res.AttachmentSet.Device[0] != '/'
                    isStandard  : res.VolumeType is 'standard'
                    iops        : res.Iops
                    volume_size : res.Size
                    snapshot_id : res.SnapshotId
                    name        : res.AttachmentSet.Device


                if volume_detail.isWin
                    volume_detail.editName = volume_detail.name.slice(-1)

                else
                    volume_detail.editName = volume_detail.name.slice(5)


            # Snapshot
            if volume_detail.snapshot_id
                snapshot_list = MC.data.config[MC.canvas.data.get('region')].snapshot_list
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

        getVolume : ( components ) ->

            uid        = @get "uid"

            if not components[ uid ]
                #lc
                realuid     = uid.split('_')
                device_name = realuid[2]
                realuid     = realuid[0]

                for block in components[realuid].resource.BlockDeviceMapping

                    if block.DeviceName.indexOf( device_name ) is -1
                        continue

                    volume = block

                    break

            else
                #instance
                volume = components[ uid ]

            volume



        setDeviceName : ( name ) ->

            components = MC.canvas_data.component
            uid        = @get "uid"

            volume = @getVolume( components )
            if !volume
                console.error "[setDeviceName]not found volume of uid: " + uid
                return null

            if not components[ uid ]
                #lc
                block = volume

                if block.DeviceName[0] != '/'
                    block.DeviceName = 'xvd' + name
                    newId = "#{realuid}_volume_xvd#{name}"

                else
                    block.DeviceName = '/dev/' + name
                    newId = "#{realuid}_volume_#{name}"

                MC.canvas.update uid, 'text', "volume_name", block.DeviceName
                MC.canvas.update realuid, 'id', "volume_#{device_name}", newId
                @attributes.volume_detail.name     = block.DeviceName
                @attributes.volume_detail.editName = name

                @set 'uid', newId

            else
                #instance

                volume_comp = volume

                if volume_comp.resource.AttachmentSet.Device[0] != '/'
                    device_name = 'xvd' + name

                else
                    device_name = '/dev/' + name

                #serverGroupName
                volume_comp.name = device_name
                volume_comp.serverGroupName = device_name

                MC.canvas.update uid, 'text', "volume_name", device_name

                volume_comp.resource.AttachmentSet.Device = device_name
                @attributes.volume_detail.name = device_name

            null

        setVolumeSize : ( value ) ->

            components = MC.canvas_data.component
            uid        = @get "uid"

            volume = @getVolume( components )
            if !volume
                console.error "[setVolumeSize]not found volume of uid: " + uid
                return null

            if not components[ uid ]
                #lc
                block = volume
                block.Ebs.VolumeSize = value

            else
                #instance
                volume.resource.Size = value

            null

        setVolumeTypeStandard : () ->

            components = MC.canvas_data.component
            uid        = @get "uid"

            volume = @getVolume( components )
            if !volume
                console.error "[setVolumeTypeStandard]not found volume of uid: " + uid
                return null

            if not components[ uid ]
                #lc
                block = volume
                block.Ebs.VolumeType = 'standard'
                delete block.Ebs.Iops

            else
                #instace
                volume.resource.VolumeType = 'standard'
                delete volume.resource.Iops

            null


        setVolumeTypeIops : ( value ) ->

            components = MC.canvas_data.component
            uid        = @get "uid"

            volume = @getVolume( components )
            if !volume
                console.error "[setVolumeTypeIops]not found volume of uid: " + uid
                return null

            if not components[ uid ]
                #lc
                block = volume
                block.Ebs.VolumeType = 'io1'
                block.Ebs.Iops       = value

            else
                #instace
                volume.resource.VolumeType = 'io1'
                volume.resource.Iops       = value

            null


        setVolumeIops : ( value )->

            components = MC.canvas_data.component
            uid        = @get "uid"

            volume = @getVolume( components )
            if !volume
                console.error "[setVolumeIops]not found volume of uid: " + uid
                return null

            if not components[ uid ]
                #lc
                block = volume
                block.Ebs.VolumeType = "io1"
                block.Ebs.Iops       = value

            else
                #instace
                volume.resource.VolumeType = "io1"
                volume.resource.Iops       = value

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
