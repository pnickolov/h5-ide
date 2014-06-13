define [
    'UI.modalplus'
    './component/resdiff/resDiffTpl'
    './component/resdiff/DiffTree'
], ( modalplus, template, DiffTree ) ->

    Backbone.View.extend

        className: 'res_diff_tree'

        initialize: (option) ->

            @oldAppJSON = option.old
            @newAppJSON = option.new
            @_genDiffInfo(@oldAppJSON.component, @newAppJSON.component)

        events:

            'click .item .type': '_toggleTab'
            'click .head': '_toggleItem'

        _toggleItem: ( e ) ->

            $target = $( e.currentTarget ).closest '.group'
            $target.toggleClass 'closed'

        _toggleTab: ( e ) ->

            $target = $( e.currentTarget ).closest '.item'
            if $target.hasClass 'end'
                return
            $target.toggleClass 'closed'

        popup: () ->

            options =
        
                template: @el
                title: 'App Changes'
                hideClose: true
                disableClose: true
                disableCancel: true
                cancel:
                    hide: true
                confirm:
                    text: 'OK, got it'

                width: '608px'
                compact: true

            @modal = new modalplus options
            @modal.on 'confirm', () ->
                @modal.close()
            , @

            @_genResGroup(@oldAppJSON.component, @newAppJSON.component)

        _genDiffInfo: (oldComps, newComps) ->

            that = this

            that.addedComps = {}
            that.removedComps = {}
            that.modifiedComps = {}

            unionOldComps = {}
            unionNewComps = {}

            _.each oldComps, (comp, uid) ->
                if newComps[uid]
                    unionOldComps[uid] = oldComps[uid]
                    unionNewComps[uid] = newComps[uid]
                else
                    that.removedComps[uid] = oldComps[uid]
                null

            _.each _.keys(newComps), (uid) ->
                if not oldComps[uid]
                    that.addedComps[uid] = newComps[uid]
                null

            diffTree = new DiffTree()
            that.modifiedComps = diffTree.compare unionOldComps, unionNewComps

        _genResGroup: () ->

            that = this

            groupData = [{
                title: 'Added Resource',
                diffComps: that.addedComps
            }, {
                title: 'Removed Resource',
                diffComps: that.removedComps
            }, {
                title: 'Modified Resource',
                diffComps: that.modifiedComps
            }]

            for data in groupData

                $group = $(template.resDiffGroup({
                    title: data.title
                })).appendTo(@$el)

                @_genResTree($group.find('.content'), data.diffComps)

        _genResTree: ($container, diffComps) ->

            that = this

            _genTree = (value, key, path, $parent) ->

                if _.isObject(value)

                    if _.isUndefined(value.__new__) and _.isUndefined(value.__old__)

                        # $diffTree is <ul class="tree">
                        $diffTree = $(template.resDiffTree {}).appendTo($parent)

                        for _key, _value of value

                            __value = if _.isObject(_value) then '' else _value

                            nextPath = path.concat([_key])
                            data = that._processRes(nextPath, {
                                key: _key,
                                value: __value
                            })

                            if data.key

                                if data.skip

                                    $treeItem = $parent
                                    $diffTree.remove()

                                else

                                    # $treeItem is <li class="item">
                                    $treeItem = $(template.resDiffTreeItem {
                                        key: data.key,
                                        value: data.value
                                    }).appendTo($diffTree)

                                    if not _.isObject(_value)
                                        $treeItem.addClass('end')

                                if _.isArray(_value) and _value.length is 0
                                    $treeItem.remove()
                                else
                                    _genTree(_value, _key, nextPath, $treeItem)

                    else # end node
                        
                        changeType = value.type
                        
                        data = that._processRes(path, {
                            key: key,
                            value: value
                        })

                        if data.key

                            # $parent is <li class="item">
                            $parent.html template.resDiffTreeMeta({
                                key: data.key,
                                value: data.value
                            })
                            $parent.addClass('end')
                            $parent.addClass(changeType)

                        else

                            $parent.remove()

            _genTree(diffComps, null, [], $container)

        _getCompAttr: (path) ->

            path = path.split('.') if _.isString(path)

            oldComp = @oldAppJSON.component
            newComp = @newAppJSON.component

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

            return {
                oldAttr: oldCompAttr,
                newAttr: newCompAttr
            }

        _processRes: (path, data) ->

            that = this

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
                
                newValue.__old__ = that._getCompAttr(oldRef).oldAttr if oldRef
                newValue.__new__ = that._getCompAttr(newRef).newAttr if newRef

                data.value = _genValue(newValue.__old__, newValue.__new__)

            else

                compAttrObj = that._getCompAttr(path)
                oldAttr = compAttrObj.oldAttr
                newAttr = compAttrObj.newAttr

                valueRef = _getRef(data.value)
                data.value = that._getCompAttr(valueRef).oldAttr if valueRef

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

        getChangeInfo: () ->

            that = this
            
            hasResChange = false
            if _.keys(that.addedComps).length or
                _.keys(that.removedComps).length or
                _.keys(that.modifiedComps).length
                    hasResChange = true

            return {
                hasResChange: hasResChange,
                needUpdateLayout: true
            }