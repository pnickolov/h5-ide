define [], () ->

    DiffTree = () ->

        isArray = (value) ->
            return value and typeof value is 'object' and value.constructor is Array

        typeofReal = (value) ->

            if isArray(value) then 'array' else (if value is null then 'null' else typeof(value))
        
        getType = (value) ->

            if (typeA is 'object' or typeA is 'array') then '' else String(a) + ' '

        _diffAry = (a, b) ->

            for v, i in ([0...a.length])
                for v, j in ([0...b.length])
                    if not _compare(a[i], b[j], '', [])
                        tmp = b[i]
                        b[i] = b[j]
                        b[j] = tmp

            # baseAry = a
            # otherAry = b
            # resultAry = []
            # resultAry.length = b.length

            # switchAry = false
            # if a.length > b.length
            #     baseAry = b.concat([])
            #     otherAry = a.concat([])
            #     resultAry.length = a.length
            #     switchAry = true

            # for v, i in baseAry
            #     for v, j in otherAry
            #         if not _compare(baseAry[i], otherAry[j], '', [])
            #             resultAry[i] = otherAry[j]
            #             otherAry.splice(j, 1)
            #             break

            # for v, k in resultAry
            #     if resultAry[k] is undefined
            #         resultAry[k] = otherAry.splice(0, 1)[0]

            # a = baseAry
            # b = resultAry

            # if switchAry

            #     a = resultAry
            #     b = baseAry

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

                # process array diff
                if typeA is 'array' and typeB is 'array'

                    diffAryResult = {}
                    
                    if a.length < b.length
                        _diffAry(a, b)
                    else
                        _diffAry(b, a)

                keys = []
                for v of a
                    keys.push(v)
                for v of b
                    keys.push(v)
                keys.sort()

                isEqual = true

                if typeA is 'array' and typeB is 'array'
                    console.log(keys)

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