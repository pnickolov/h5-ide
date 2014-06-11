define [
    'UI.modalplus'
    './component/resdiff/resDiffTpl'
    'jsondiffpatch'
    './component/resdiff/a'
    './component/resdiff/b'

], ( modalplus, template, jsondiffpatch, a, b ) ->

    Backbone.View.extend

        className: 'res_diff_tree'

        initialize: () ->
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

        getDelta: ->
            jsondiffpatch.diff a, b


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

            console.log @getDelta()

        render: () ->

            @$el.html template.resDiffTree {}
            @open()
            @