define [], ->
    helper = ( options ) ->
        getAttrMap: ( path ) ->
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


            retVal =  {
                oldAttr: oldCompAttr
                newAttr: newCompAttr
            }


    prepareNode = ( path, data ) ->
        _genValue = (oldValue, newValue) ->

            result = ''

            if oldValue
                result = oldValue
                if newValue and oldValue isnt newValue
                    result += (' -> ' + newValue)
            else
                result = newValue

            return result

        _getRef = (value) ->

            if _.isString(value) and value.indexOf('@{') is 0

                refRegex = /@\{.*\}/g
                refMatchAry = value.match(refRegex)
                if refMatchAry and refMatchAry.length
                    refName = value.slice(2, value.length - 1)
                    refUID = refName.split('.')[0]
                    return "#{refUID}.name" if refUID

            return null

        if _.isObject(data.value) # process end node

            # default
            newValue = data.value
            oldRef = _getRef(newValue.__old__)
            newRef = _getRef(newValue.__new__)

            newValue.__old__ = @h.getAttrMap(oldRef).oldAttr if oldRef
            newValue.__new__ = @h.getAttrMap(newRef).newAttr if newRef

            data.value = _genValue(newValue.__old__, newValue.__new__)

        else

            compAttrObj = @h.getAttrMap(path)
            oldAttr = compAttrObj.oldAttr
            newAttr = compAttrObj.newAttr

            valueRef = _getRef(data.value)
            data.value = @h.getAttrMap(valueRef).oldAttr if valueRef

            if path.length is 1

                compUID = path[0]
                oldCompName = (oldAttr.name if oldAttr) or ''
                newCompName = (newAttr.name if newAttr) or ''

                if oldAttr
                    data.key = oldAttr.type
                else
                    data.key = newAttr.type

                data.value = _genValue(oldCompName, newCompName)

        if path.length is 2

            if path[1] in ['type', 'uid', 'name']
                delete data.key
            else if path[1] is 'resource'
                data.skip = true

        return data

    Prepare = ( options ) ->
        _.extend @, options
        @h = helper( options )
        @

    Prepare.prototype.node = prepareNode

    Prepare.prototype.abc = prepareNode

    Prepare.prototype.bcd = () -> console.log 1


    Prepare



