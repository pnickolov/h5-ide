define [
    'UI.modalplus'
    './resDiffTpl'
    './DiffTree'
    './prepare'
], ( modalplus, template, DiffTree, Prepare ) ->

    Backbone.View.extend

        className: 'res_diff_tree'

        tagName: 'section'

        initialize: (option) ->

            @oldAppJSON = option.old
            @newAppJSON = option.new

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
            # popup modal
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

            #settle frame
            @$el.html template.frame()

            @_genResGroup(@oldAppJSON.component, @newAppJSON.component)

            @modal.resize()

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
            that.modifiedComps = {} if not that.modifiedComps
            # that.modifiedComps = diffTree.compare {x: [{a: 1, b: [{d: 1}, {e: 2}], c: 3}, {a: 4, b: 5, c: 6}, {a: 7, b: 8, c: 9}]},
            #     {x: [{a: 4, b: 5, c: 6}, {a: 1, b: [{e: 2}, {d: 1}], c: 3}, {a: 7, b: 8, c: 9}]}

        _genResGroup: () ->

            that = this

            groupData = [{
                title: 'New',
                diffComps: that.addedComps,
                closed: true,
                type: 'added'
            }, {
                title: 'Removed',
                diffComps: that.removedComps,
                closed: true,
                type: 'removed'
            }, {
                title: 'Modified',
                diffComps: that.modifiedComps,
                closed: false,
                type: 'modified'
            }]

            for data in groupData

                compCount = _.keys(data.diffComps).length

                if compCount

                    $group = $(template.resDiffGroup({
                        type: data.type
                        title: data.title
                        count: compCount
                    })).appendTo @$( 'article' )

                    @_genResTree($group.find('.content'), data.diffComps, data.closed)

        _genResTree: ($container, diffComps, closed) ->

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
