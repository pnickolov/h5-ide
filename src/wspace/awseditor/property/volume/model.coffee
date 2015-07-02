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

            if component.get('owner').type is constant.RESTYPE.LC
                displayEncrypted = false

            isEncrypted = false
            isEncrypted = (res.encrypted in ['true', true]) if supportEncrypted

            volume_detail =
                isWin       : res.name[0] != '/'
                isStandard  : res.volumeType is 'standard'
                isIo1       : res.volumeType is 'io1'
                isGp2       : res.volumeType is 'gp2'
                iops        : res.iops
                volume_size : res.volumeSize
                snapshot_id : res.snapshotId
                name        : res.name
                displayEncrypted : displayEncrypted
                support_encrypted : supportEncrypted
                encrypted   : isEncrypted
                owner       : res.owner
                tags        : component.tags()

            # Snapshot
            if volume_detail.snapshot_id
                snapshot = CloudResources( Design.instance().credentialId(), constant.RESTYPE.SNAP, Design.instance().region() ).get( volume_detail.snapshot_id )
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
            volume.set 'name', name
            @attributes.volume_detail.name = name

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

                # realuid     = uid.split('_')
                # device_name = realuid[2]
                # lcUid       = realuid[0]

                # lc = Design.instance().component( lcUid )

                # volumeModel = Design.modelClassForType constant.RESTYPE.VOL
                # allVolume = volumeModel and volumeModel.allObjects() or []

                # for v in allVolume
                #     if v.get( 'owner' ) is lc
                #         if v.get( 'name' ) is device_name
                #             v.set 'encrypted', value
                #             break

            else

                volume.set 'encrypted', value

            null

        isDuplicate : ( name ) ->
            uid = @get "uid"
            that = @
            volume = Design.instance().component( uid )
            owner = volume.get( 'owner' )

            volumeList = owner.get( 'volumeList' )
            duplicateOtherVolume = _.some volumeList, ( v ) ->
                if v isnt volume
                    if that.isDeviceNameEqual( that.getDeviceNameMap(v.get('name')), that.getDeviceNameMap(name) )
                        true

            return true if duplicateOtherVolume

            amiInfo = owner.getAmi()
            nameMap = @getDeviceNameMap name
            duplicateRootDevice = _.some amiInfo.blockDeviceMapping, ( obj, rootDeviceName ) ->
                rootDeviceNameMap = that.getDeviceNameMap rootDeviceName
                that.isDeviceNameEqual nameMap, rootDeviceNameMap

            duplicateRootDevice

        isDeviceNameEqual: ( nameMap1, nameMap2 ) ->
            if not nameMap1 or not nameMap2 then return false

            # completely same
            if nameMap1.origin is nameMap2.origin then return true

            # you must use trailing digits on all device names that share the same base letters (such as /dev/sdc1, /dev/sdc2, /dev/sdc3)
            if nameMap1.numberSuffix and not nameMap2.numberSuffix or not nameMap1.numberSuffix and nameMap2.numberSuffix
                return nameMap1.prefix + nameMap1.middle is nameMap2.prefix + nameMap2.middle

            false

        getDeviceNameMap: ( name ) ->
            regResult = /(sd|hd|xvd)([a-z]+)([0-9]*)/i.exec name
            unless regResult then return null

            {
                origin: regResult[ 0 ]
                prefix: regResult[ 1 ]
                middle: regResult[ 2 ]
                numberSuffix: regResult[ 3 ]
            }

    }

    new VolumeModel()
