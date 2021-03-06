define [
    'UI.modalplus'
    'DiffTree'
    'component/resdiff/resDiffTpl'
    'component/resdiff/prepare'
    'constant'
    'i18n!/nls/lang.js'
    'ApiRequest'
], ( modalplus, DiffTree, template, Prepare, constant, lang, ApiRequest ) ->

    Backbone.View.extend

        className: 'res_diff_tree'

        tagName: 'section'

        initialize: (option) ->

            @oldAppJSON = option.old
            @newAppJSON = option.new
            @callback = option.callback if option.callback

            @prepare = new Prepare oldAppJSON: @oldAppJSON, newAppJSON: @newAppJSON
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

        render: () ->

            that = this

            # popup modal
            okText = lang.PROP.APP_DIFF_CHANGE_CONFIRM
            options =
                template: template.frame()
                title: lang.IDE.TITLE_APP_CHANGES
                disableClose: true
                hideClose: true
                confirm:
                    text: okText
                width: '608px'
                compact: false
                preventClose: true

            @modal = new modalplus options
            @modal.on 'confirm', () ->
                $confirmBtn = that.modal.tpl.find('.modal-confirm')
                if that.callback
                    $confirmBtn.addClass('disabled')
                    $confirmBtn.text('Saving...')
                    promise = that.callback(true)
                    promise.then () ->
                        # $confirmBtn.removeClass('disabled')
                        that.modal.close()
                    , (data) ->
                        $confirmBtn.text(okText)
                        $confirmBtn.removeClass('disabled')
                        if data.error is ApiRequest.Errors.AppConflict
                            notification 'error', lang.IDE.WARNNING_APP_CHANGE_BY_OTHER_USER
                        else
                            notification 'error', data.msg
                else
                    that.modal.close()
            , @
            @modal.on 'cancel', () ->
                if that.callback
                    that.callback(false)
                that.modal.close()
            , @

            #settle frame
            @modal.tpl.find('article').html(@$el)
            @_genResGroup(@$el)

            @modal.resize()

        _genDiffInfo: (oldComps, newComps) ->

            that = this

            that.addedComps = {}
            that.removedComps = {}
            that.modifiedComps = {}

            unionOldComps = {}
            unionNewComps = {}

            ignoreDiffMap = {}

            _.each oldComps, (comp, uid) ->

                if comp and not ignoreDiffMap[comp.type]

                    if newComps[uid]
                        unionOldComps[uid] = oldComps[uid]
                        unionNewComps[uid] = newComps[uid]
                    else
                        that.removedComps[uid] = oldComps[uid]
                    null

            _.each _.keys(newComps), (uid) ->

                if not oldComps[uid]
                    if newComps[uid] and not ignoreDiffMap[newComps[uid].type]
                        that.addedComps[uid] = newComps[uid]
                null

            diffTree = new DiffTree()

            that.modifiedComps = diffTree.compare unionOldComps, unionNewComps
            that.modifiedComps = {} if not that.modifiedComps
            # that.modifiedComps = diffTree.compare {x: [{a: 1, b: [{d: 1}, {e: 2}], c: 3}, {a: 4, b: 5, c: 6}, {a: 7, b: 8, c: 9}]},
            #     {x: [{a: 4, b: 5, c: 6}, {a: 1, b: [{e: 2}, {d: 1}], c: 3}, {a: 7, b: 8, c: 9}]}

        _genResGroup: ($containerDom) ->

            that = this

            groupData = [{
                title: lang.TOOLBAR.POP_DIFF_NEW_RES,
                diffComps: that.addedComps,
                closed: true,
                type: 'added',
                needDiff: false
            }, {
                title: lang.TOOLBAR.POP_DIFF_REMOVED_RES,
                diffComps: that.removedComps,
                closed: true,
                type: 'removed',
                needDiff: false
            }, {
                title: lang.TOOLBAR.POP_DIFF_MODIFY_RES,
                diffComps: that.modifiedComps,
                closed: false,
                type: 'modified'
                needDiff: true
            }]

            for data in groupData

                compCount = _.keys(data.diffComps).length

                if compCount

                    $group = $(template.resDiffGroup({
                        type: data.type
                        title: data.title
                        count: compCount
                    })).appendTo $containerDom

                    @_genResTree($group.find('.content'), data.diffComps, data.closed, data.needDiff)

        _genResTree: ($container, diffComps, closed, needDiff) ->

            that = this

            _genTree = (value, key, path, $parent) ->

                if _.isObject(value)

                    if _.isUndefined(value.__new__) and _.isUndefined(value.__old__)

                        # $diffTree is <ul class="tree">
                        $diffTree = $(template.resDiffTree {}).appendTo($parent)

                        for _key, _value of value

                            __value = if _.isObject(_value) then '' else _value

                            nextPath = path.concat([_key])
                            data = @prepare.node(nextPath, {
                                key: _key,
                                value: __value,
                                originValue: _value
                            })

                            if data.key

                                if data.skip

                                    $treeItem = $parent
                                    $diffTree.remove()

                                else

                                    # $treeItem is <li class="item">
                                    $treeItem = $(template.resDiffTreeItem {
                                        key: data.key,
                                        value: data.value,
                                        closed: closed
                                    }).appendTo($diffTree)

                                    if not _.isObject(_value)
                                        $treeItem.addClass('end')

                                if _.isArray(_value) and _value.length is 0
                                    $treeItem.remove()
                                else
                                    _genTree.call that, _value, _key, nextPath, $treeItem

                    else # end node

                        changeType = value.type

                        data = @prepare.node(path, {
                            key: key,
                            value: value
                        })

                        if data.key

                            type = value1 = type1 = ''

                            if _.isObject(data.value)

                                if data.value.type is 'added'
                                    value = data.value.new
                                    type = 'new'
                                else if data.value.type is 'removed'
                                    value = data.value.old
                                    type = 'old'
                                else if data.value.type is 'changed'
                                    value = data.value.old
                                    value1 = data.value.new
                                    type = 'old'
                                    type1 = 'new'

                            else

                                value = data.value

                            # $parent is <li class="item">
                            $parent.html template.resDiffTreeMeta({
                                key: data.key,
                                value: value,
                                type: type,
                                value1: value1,
                                type1: type1,
                                closed: closed
                            })
                            $parent.addClass('end')
                            $parent.addClass(changeType)

                        else

                            $parent.remove()

            _genTree.call that, diffComps, null, [], $container

        getRelatedInstanceGroupUID: (originComps, comp) ->

            that = this

            resType = comp.type
            if resType is constant.RESTYPE.INSTANCE
                return comp.serverGroupUid
            if resType is constant.RESTYPE.ENI
                instanceRef = comp.resource.Attachment.InstanceId
            if instanceRef
                instanceUID = MC.extractID(instanceRef)
                instanceComp = originComps[instanceUID]
                if instanceComp
                    return instanceComp.serverGroupUid
            if resType is constant.RESTYPE.VOL
                instanceRef = comp.resource.AttachmentSet.InstanceId
            if instanceRef
                instanceUID = MC.extractID(instanceRef)
                instanceComp = originComps[instanceUID]
                if instanceComp
                    return instanceComp.serverGroupUid
            if resType is constant.RESTYPE.EIP
                eniRef = comp.resource.NetworkInterfaceId
            if eniRef
                eniUID = MC.extractID(eniRef)
                eniComp = originComps[eniUID]
                if eniComp
                    return that.getRelatedInstanceGroupUID(originComps, eniComp)

            return ''

        renderAppUpdateView: () ->

            @_genResGroup(@$el)
            return @$el

        getDiffInfo: () ->

            that = this

            oldAppJSON = _.extend {}, that.oldAppJSON
            newAppJSON = _.extend {}, that.newAppJSON

            # if have component change
            hasCompChange = false
            if _.size(that.addedComps) or
                _.size(that.removedComps) or
                _.size(that.modifiedComps)
                    hasCompChange = true

            # if have layout change
            diffTree = new DiffTree()
            layoutModifiedComps = diffTree.compare oldAppJSON.layout, newAppJSON.layout
            hasLayoutChange = false
            if _.size(layoutModifiedComps)
                hasLayoutChange = true

            # if have state change
            hasStateChange = false
            onlyStateChange = true
            _.each that.modifiedComps, (comp, uid) ->
                if comp.state
                    hasStateChange = true
                if _.size(comp) is 1 and comp.state
                    delete that.modifiedComps[uid]
                else
                    onlyStateChange = false
                delete comp.state if (comp and comp.state)
                null
            if onlyStateChange and _.size(that.addedComps) is 0 and _.size(that.removedComps) is 0
                hasCompChange = false

            # if have app change
            delete oldAppJSON.component
            delete oldAppJSON.layout
            delete newAppJSON.component
            delete newAppJSON.layout
            appModifiedComps = diffTree.compare oldAppJSON, newAppJSON
            if _.size(appModifiedComps) > 0
                hasLayoutChange = true

            return {
                compChange: hasCompChange,
                layoutChange: hasLayoutChange,
                stateChange: hasStateChange
            }

        getChangeInfo: () ->

            that = this

            hasResChange = false
            if _.size(that.addedComps) or
                _.size(that.removedComps) or
                _.size(that.modifiedComps)
                    hasResChange = true

            needUpdateLayout = _.some that.addedComps, ( comp ) ->
                that.newAppJSON.layout[ comp.uid ]

            newComps = that.newAppJSON.component
            oldComps = that.oldAppJSON.component

            # if have any change about server group, update layout
            _.each that.modifiedComps, (comp, uid) ->
                originComp = oldComps[uid]
                if originComp and originComp.type in [constant.RESTYPE.ENI, constant.RESTYPE.EIP, constant.RESTYPE.INSTANCE, constant.RESTYPE.VOL]
                    if originComp and originComp.number > 1
                        needUpdateLayout = true
                null

            # if have elb and attached server group change, update layout
            _.each that.modifiedComps, (comp, uid) ->
                if oldComps[uid] and oldComps[uid].type is constant.RESTYPE.ELB
                    if comp and comp.resource and comp.resource.Instances
                        instanceAry = []
                        _.map comp.resource.Instances, (refObj) ->
                            _refObj = refObj.InstanceId
                            if _refObj
                                instanceAry.push(_refObj.__old__) if _refObj.__old__
                                instanceAry.push(_refObj.__new__) if _refObj.__new__
                        _.each instanceAry, (uidRef) ->
                            uid = MC.extractID(uidRef)
                            if oldComps[uid] and oldComps[uid].number > 1
                                needUpdateLayout = true
                            null
                null

            # if have asg AvailabilityZones or VPCZoneIdentifier change, update layout
            _.each that.modifiedComps, (comp, uid) ->
                if newComps[uid] and newComps[uid].type is constant.RESTYPE.ASG
                    if comp and comp.resource and comp.resource.AvailabilityZones
                        needUpdateLayout = true
                    if comp and comp.resource and comp.resource.VPCZoneIdentifier
                        needUpdateLayout = true
                null

            # if have any add/remove about server group, update layout
            _.each that.removedComps, (comp) ->
                if comp.type in [constant.RESTYPE.ENI, constant.RESTYPE.EIP, constant.RESTYPE.INSTANCE, constant.RESTYPE.VOL]
                    serverGroupUid = that.getRelatedInstanceGroupUID(oldComps, comp)
                    originComp = oldComps[serverGroupUid]
                    if originComp and originComp.number > 1
                        needUpdateLayout = true
                null

            return {
                hasResChange: hasResChange,
                needUpdateLayout: needUpdateLayout
            }
