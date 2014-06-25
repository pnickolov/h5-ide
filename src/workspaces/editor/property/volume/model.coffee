#############################
#  View Mode for design/property/volume
#############################

define [ '../base/model', 'constant', 'Design', "CloudResources" ], ( PropertyModel, constant, Design, CloudResources ) ->

    VolumeModel = PropertyModel.extend {

        init : ( uid ) ->

            component = Design.instance().component( uid )

            res = component.attributes
            if !res.owner
                console.error "[volume property] can not found owner of volume!"
                return false

            supportEncrypted = component.isSupportEncrypted()
            
            displayEncrypted = true
            if not supportEncrypted
                displayEncrypted = false

            if res.snapshotId
                supportEncrypted = false

            isEncrypted = false
            isEncrypted = (res.encrypted in ['true', true]) if supportEncrypted

            volume_detail =
                isWin       : res.name[0] != '/'
                isStandard  : res.volumeType is 'standard'
                isIo1       : res.volumeType is 'io1'
                isGd2       : res.volumeType is 'gp2'
                iops        : res.iops
                volume_size : res.volumeSize
                snapshot_id : res.snapshotId
                name        : res.name
                displayEncrypted : displayEncrypted
                support_encrypted : supportEncrypted
                encrypted : isEncrypted

            if volume_detail.isWin
                volume_detail.editName = volume_detail.name.slice(-1)
            else
                volume_detail.editName = volume_detail.name.slice(5)


            # Snapshot
            if volume_detail.snapshot_id
                snapshot = CloudResources( constant.RESTYPE.SNAP, Design.instance().region() ).get( volume_detail.snapshot_id )
                if snapshot
                    volume_detail.snapshot_size = snapshot.get('volumeSize')
                    volume_detail.snapshot_desc = snapshot.get('description')

            if volume_detail.volume_size < 10
                volume_detail.iopsDisabled = true

            @set 'volume_detail', volume_detail
            @set 'uid', uid
            null

        setDeviceName : ( name ) ->

            uid        = @get "uid"

            volume = Design.instance().component( uid )

            if not volume

                realuid     = uid.split '_'
                device_name = realuid[ 2 ]
                lcUid     = realuid[ 0 ]

                lc = Design.instance().component( lcUid )

                volumeModel = Design.modelClassForType constant.RESTYPE.VOL
                allVolume = volumeModel and volumeModel.allObjects() or []

                for v in allVolume
                    if v.get( 'owner' ) is lc
                        if v.get( 'name' ) is device_name

                            newDeviceName = volume.genFullName name
                            newId = "#{realuid}_volume_#{name}"

                            v.set 'name', newDeviceName

                            MC.canvas.update uid, 'text', "volume_name", newDeviceName
                            MC.canvas.update realuid, 'id', "volume_#{device_name}", newId
                            @attributes.volume_detail.name     = newDeviceName
                            @attributes.volume_detail.editName = name

                            @set 'uid', newId

                            break

            else

                newDeviceName = volume.genFullName name

                volume.set 'name', newDeviceName

                MC.canvas.update uid, 'text', "volume_name", newDeviceName

                @attributes.volume_detail.name = newDeviceName

            null

        setVolumeSize : ( value ) ->
            uid        = @get "uid"

            volume = Design.instance().component( uid )

            if not volume

                realuid     = uid.split('_')
                device_name = realuid[2]
                lcUid       = realuid[0]

                lc = Design.instance().component( lcUid )

                volumeModel = Design.modelClassForType constant.RESTYPE.VOL
                allVolume = volumeModel and volumeModel.allObjects() or []

                for v in allVolume
                    if v.get( 'owner' ) is lc
                        if v.get( 'name' ) is device_name
                            v.set 'volumeSize', value
                            break


            else
                volume.set 'volumeSize', value

            null

        setVolumeType: ( type, iops ) ->
            volume = Design.instance().component( @get "uid" )

            volume.set 'volumeType': type, 'iops': iops

            null

        setEncrypted : ( value ) ->

            uid = @get "uid"
            volume = Design.instance().component( uid )

            if not volume

                realuid     = uid.split('_')
                device_name = realuid[2]
                lcUid       = realuid[0]

                lc = Design.instance().component( lcUid )

                volumeModel = Design.modelClassForType constant.RESTYPE.VOL
                allVolume = volumeModel and volumeModel.allObjects() or []

                for v in allVolume
                    if v.get( 'owner' ) is lc
                        if v.get( 'name' ) is device_name
                            v.set 'encrypted', value
                            break


            else
                volume.set 'encrypted', value

            null

        genFullName: ( name ) ->
            if comp.name[0] != '/'
                        if comp.name == "xvd" + name
                            return true
                    else if comp.name.indexOf( name ) isnt -1
                        return true


        isDuplicate : ( name ) ->

            uid = @get "uid"

            volume = Design.instance().component( uid )

            volumeModel = Design.modelClassForType constant.RESTYPE.VOL
            allVolume = volumeModel and volumeModel.allObjects() or []

            if not volume
                realuid     = uid.split('_')
                device_name = realuid[2]
                lcUid       = realuid[0]

                lc = Design.instance().component( lcUid )

                for v in allVolume
                    if v.get( 'owner' ) is lc
                        volume = v
                        break

            _.some allVolume, ( v ) ->
                fullName = v.genFullName name
                if v isnt volume and v.get( 'name' ) is fullName
                    true

    }

    new VolumeModel()
