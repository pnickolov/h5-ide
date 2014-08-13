define [ 'constant' ], ( constant ) ->

    helper = ( options ) ->

        getNodeMap: ( path ) ->

            path = path.split('.') if _.isString(path)

            oldComp = options.oldAppJSON.component
            newComp = options.newAppJSON.component

            oldCompAttr = _.extend(oldComp, {})
            newCompAttr = _.extend(newComp, {})

            _.each path, (attr) ->

                if oldCompAttr

                    if _.isUndefined(oldCompAttr[attr])
                        oldCompAttr = undefined
                    else
                        oldCompAttr = oldCompAttr[attr]

                if newCompAttr

                    if _.isUndefined(newCompAttr[attr])
                        newCompAttr = undefined
                    else
                        newCompAttr = newCompAttr[attr]

                null

            oldAttr: oldCompAttr
            newAttr: newCompAttr

        genValue: (type, oldValue, newValue) ->

            result = ''

            oldValue = String(oldValue)
            newValue = String(newValue)

            if type is 'changed'
                oldValue = 'none' if not oldValue
                newValue = 'none' if not newValue

            if oldValue
                result = oldValue
                if newValue and oldValue isnt newValue
                    result += (' -> ' + newValue)
            else
                result = newValue

            return result

        getNodeData: ( path ) ->
            @getNewest @getNodeMap path

        getNewest: ( attrMap ) ->
            attrMap.newAttr or attrMap.oldAttr

        pluralToSingular: ( str ) -> # Remove 's'
            str.slice 0, -1

        setToElement: ( str ) -> # Remove 'Set'
            str.slice 0, -3

        replaceArrayIndex: ( path, data ) ->

            componentMap = @getNodeMap path[0]
            component = @getNewest componentMap

            type = component.type
            parentKey = path[ path.length - 2 ]
            childNode = data.originValue

            pluralKeys = [ 'Dimensions'
                'AlarmActions'
                'Instances'
                'Attachments'
                'AvailabilityZones'
                'LoadBalancerNames'
                'TerminationPolicies'
                'ListenerDescriptions'
                'SecurityGroups'
                'Subnets'
                'Routes'
                ]

            # Replace keyword
            switch parentKey
                when 'BlockDeviceMapping'
                    deviceObj = childNode.DeviceName
                    data.key = 'Device'
                    if deviceObj
                        if _.isObject deviceObj
                            data.key = @genValue deviceObj.type, deviceObj.__old__, deviceObj.__new__
                        else
                            data.key = deviceObj

                when 'GroupSet'
                    data.key = 'SecurityGroup'

                when 'IpPermissions', 'IpPermissionsEgress', 'EntrySet'
                    data.key = 'Rule'

                when 'AssociationSet', 'AttachmentSet', 'PrivateIpAddressSet'
                    data.key = @setToElement parentKey

                when 'NotificationType'
                    data.key = 'Type'

                when 'VPCZoneIdentifier'
                    data.key = 'Subnet'

                when 'RouteSet'
                    data.key = 'Route'

                when 'SubnetIds'
                    data.key = 'Subnet'

                when 'Options'
                    data.key = 'Option'

            # Convert need convert pluralKey
            if parentKey in pluralKeys
                data.key = @pluralToSingular parentKey

            # Replace first level node
            if path.length is 1
                data.key = constant.RESNAME[ data.key ] or data.key

            data

    prepareNode = ( path, data ) ->

        _getRef = (value, needName) ->

            if _.isString(value) and value.indexOf('@{') is 0

                refRegex = /@\{.*\}/g
                refMatchAry = value.match(refRegex)
                if refMatchAry and refMatchAry.length
                    refName = value.slice(2, value.length - 1)
                    refUID = refName.split('.')[0]
                    if needName
                        return "#{refUID}.name" if refUID
                    else
                        return refName

            return null

        if _.isObject(data.value) # process end node

            # default
            newValue = data.value

            # show id when key name is a res id ref
            needName = true
            if data.key
                if data.key.substr(data.key.lastIndexOf('Id')) is 'Id'
                    needName = false

            oldRef = _getRef(newValue.__old__, needName)
            newRef = _getRef(newValue.__new__, needName)

            newValue.__old__ = @h.getNodeMap(oldRef).oldAttr if oldRef
            newValue.__new__ = @h.getNodeMap(newRef).newAttr if newRef

            # data.value = @h.genValue(newValue.type, newValue.__old__, newValue.__new__)
            data = @h.replaceArrayIndex path, data

            data.value = {
                type: newValue.type,
                old: newValue.__old__,
                new: newValue.__new__
            }

        else

            compAttrObj = @h.getNodeMap(path)
            oldAttr = compAttrObj.oldAttr
            newAttr = compAttrObj.newAttr

            valueRef = _getRef(data.value)

            if valueRef

                attrObj = @h.getNodeMap(valueRef)
                oldValue = attrObj.oldAttr
                newValue = attrObj.newAttr
                data.value = oldValue or newValue

            if path.length is 1

                compUID = path[0]
                oldCompName = (oldAttr.name if oldAttr) or ''
                newCompName = (newAttr.name if newAttr) or ''

                if oldAttr
                    data.key = oldAttr.type
                else
                    data.key = newAttr.type

                data.value = @h.genValue(null, oldCompName, newCompName)

            data = @h.replaceArrayIndex path, data

        if path.length is 2

            data.skip = true if path[1] is 'resource'
            delete data.key if path[1] is 'state'

        return data

    Prepare = ( options ) ->
        _.extend @, options
        @h = helper( options )
        @

    Prepare.prototype.node = prepareNode

    Prepare
