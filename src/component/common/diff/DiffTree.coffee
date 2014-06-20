define [], () ->

    DiffTree = (option) ->

        option = {} if not option
        # option.filterMap = {} if not option.filterMap

        option.filterMap = {
            'resource.PrivateIpAddressSet.n.AutoAssign': true,
            'resource.AssociatePublicIpAddress': true,
            'resource.KeyName': true,
            'resource.AssociationSet.n.RouteTableAssociationId'
            'resource.AssociationSet.n.NetworkAclAssociationId'
            'resource.BlockDeviceMapping'
            'resource.VolumeSize'
        }

        isArray = (value) ->
            
            return value and typeof value is 'object' and value.constructor is Array

        typeofReal = (value) ->

            if isArray(value) then 'array' else (if value is null then 'null' else typeof(value))
        
        getType = (value) ->

            if (typeA is 'object' or typeA is 'array') then '' else String(a) + ' '

        _diffAry = (a, b) ->

            for v, i in ([0...a.length])
                for v, j in ([0...b.length])
                    if not _compare.call(this, a[i], b[j], '', null, [])
                        tmp = b[i]
                        b[i] = b[j]
                        b[j] = tmp

        _compare = (a, b, key, path, resultJSON) ->

            if path
                
                path = path.concat([key]) if key
                if path.length > 2
                    attrPathAry = path.slice(2)

                    attrPathAry = _.map attrPathAry, (path) ->
                        num = Number(path)
                        return 'n' if num >= 0
                        return path

                    attrPath = attrPathAry.join('.')
                    if option.filterMap[attrPath]
                        return

            if not a and not b
                return

            haveDiff = false

            typeA = typeofReal(a)
            typeB = typeofReal(b)

            aString = if (typeA is 'object' or typeA is 'array') then '' else String(a) + ''
            bString = if (typeB is 'object' or typeB is 'array') then '' else String(b) + ''

            aString = '' if not aString
            bString = '' if not bString

            changeType = value1 = value2 = ''
            
            if a is undefined
                changeType = 'added'
                value2 = bString

            else if b is undefined
                changeType = 'removed'
                value1 = aString

            else if (typeA isnt typeB or (typeA isnt 'object' and typeA isnt 'array' and a isnt b))
                changeType = 'changed'
                value1 = aString
                value2 = bString

            else
                value1 = aString

            resultJSON[key] = {}

            if typeA is 'object' or typeA is 'array' or typeB is 'object' or typeB is 'array'

                # process array diff
                if typeA is 'array' and typeB is 'array'

                    diffAryResult = {}
                    
                    if a.length < b.length
                        _diffAry.call(this, a, b)
                    else
                        _diffAry.call(this, b, a)

                keys = []
                for v of a
                    keys.push(v)
                for v of b
                    keys.push(v)
                keys.sort()

                isEqual = true

                for v, i in keys

                    if (keys[i] is keys[i - 1])
                        continue;

                    hasDiff = _compare.call(this, a and a[keys[i]], b and b[keys[i]], keys[i], path, resultJSON[key])

                    if hasDiff
                        isEqual = false

                haveDiff = not isEqual
                if isEqual
                    delete resultJSON[key]

            else

                path.length = 0 if path

                # ignore number type diff

                if typeofReal(a) is 'number'
                    a = String(a)
                
                if typeofReal(b) is 'number'
                    b = String(b)

                if a isnt b
                    haveDiff = true
                    resultJSON[key] = {
                        type: changeType
                        __old__: a,
                        __new__: b
                    }
                else
                    delete resultJSON[key]

            return haveDiff

        this.compare = (json1, json2) ->

            resultJSON = {}
            _compare.call(this, json1, json2, 'result', [], resultJSON)
            return resultJSON.result

        null

    return DiffTree