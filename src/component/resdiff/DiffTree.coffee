define [], () ->

    DiffTree = () ->

        isArray = (value) ->
            return value and typeof value is 'object' and value.constructor is Array

        typeofReal = (value) ->

            if isArray(value) then 'array' else (if value is null then 'null' else typeof(value))
        
        getType = (value) ->

            if (typeA is 'object' or typeA is 'array') then '' else String(a) + ' '

        _compare = (a, b, key, resultJSON) ->

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

                    hasDiff = _compare(a and a[keys[i]], b and b[keys[i]], keys[i], resultJSON[key])

                    if hasDiff
                        isEqual = false

                haveDiff = not isEqual
                if isEqual
                    delete resultJSON[key]

            else

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
            _compare(json1, json2, 'result', resultJSON)
            return resultJSON.result

        null

    return DiffTree