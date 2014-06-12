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

            _genTree = (value, key, $parent) ->

                if _.isObject(value)

                    if _.isUndefined(value.new) and _.isUndefined(value.old)

                        # $diffTree is <ul class="tree">
                        $diffTree = $(template.resDiffTree {}).appendTo($parent)

                        for _key, _value of value

                            if _.isArray(value)
                                _key = 'item ' + _key

                            __value = if _.isObject(_value) then '' else _value

                            # $treeItem is <li class="item">
                            $treeItem = $(template.resDiffTreeItem {
                                key: _key,
                                value: __value
                            }).appendTo($diffTree)

                            if not _.isObject(_value)
                                $treeItem.addClass('end')

                            _genTree(_value, _key, $treeItem)
                    else
                        
                        # $parent is <li class="item">
                        $parent.html template.resDiffTreeMeta({
                            key: key,
                            value: "#{value.old} -> #{value.new}"
                        })
                        $parent.addClass('end')

            _genTree(diffComps, null, $container)

        getChangeInfo: () ->

            hasResChange = false
            if _.keys(that.addedComps).length or
                _.keys(that.removedComps).length or
                _.keys(that.modifiedComps).length
                    hasResChange = true

            return {
                hasResChange: hasResChange,
                needUpdateLayout: true
            }