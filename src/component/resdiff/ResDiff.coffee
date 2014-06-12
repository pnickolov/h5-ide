define [
    'UI.modalplus'
    './component/resdiff/resDiffTpl'
    'jsondiffpatch'
    'jsona'
    'jsonb'
    './component/resdiff/DiffTree'
], ( modalplus, template, jsondiffpatch, a, b, DiffTree ) ->

    Backbone.View.extend

        className: 'res_diff_tree'

        initialize: () ->

            @diffTree = new DiffTree (para, data) ->
                if _.isArray(para.parentA) or _.isArray(para.parentB)
                    data.key = 'item ' + (Number(data.key) + 1)
                return data
            @render()

        events:
            'click .item .type': 'toggleTab'
            'click .head': 'toggleItem'

        toggleItem: ( e ) ->

            $target = $( e.currentTarget ).closest '.group'
            $target.toggleClass 'closed'

        toggleTab: ( e ) ->

            $target = $( e.currentTarget ).closest '.item'
            if $target.hasClass 'end'
                return
            $target.toggleClass 'closed'

        open: () ->

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

            @genResGroup(a.component, b.component)

        render: () ->

            @open()
            @

        genResGroup: (oldComps, newComps) ->

            addedComps = {}
            removedComps = {}
            modifiedComps = {}

            unionOldComps = {}
            unionNewComps = {}

            _.each oldComps, (comp, uid) ->
                if newComps[uid]
                    unionOldComps[uid] = oldComps[uid]
                    unionNewComps[uid] = newComps[uid]
                else
                    removedComps[uid] = oldComps[uid]
                null

            _.each _.keys(newComps), (uid) ->
                if not oldComps[uid]
                    addedComps[uid] = newComps[uid]
                null

            modifiedComps = @diffTree.compare unionOldComps, unionNewComps

            groupData = [{
                title: 'Added Resource',
                diffComps: addedComps
            }, {
                title: 'Removed Resource',
                diffComps: removedComps
            }, {
                title: 'Modified Resource',
                diffComps: modifiedComps
            }]

            for data in groupData

                $group = $(template.resDiffGroup({
                    title: data.title
                })).appendTo(@$el)

                @genResTree($group.find('.content'), data.diffComps)

        genResTree: ($container, diffComps) ->

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