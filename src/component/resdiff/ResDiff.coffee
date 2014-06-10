define ['UI.modalplus', './component/resdiff/resDiffTpl'], (modalplus, template) ->

    Backbone.View.extend

        className: 'res_diff_tree'

        initialize: () ->
            @render()

        events:
            'click .item .type': '__toggleTab'

        __toggleTab: ( e ) ->
            $target = $( e.currentTarget ).closest '.item'

            if $target.hasClass 'end'
                return
            $target.toggleClass 'closed'

        _open: () ->

            options =

                template: @el
                title: 'App Changes'
                disableClose: true
                disableCancel: true
                confirm:
                    text: 'OK, got it'

                width: '608px'
                height: '681px'
                compact: true

            @modal = new modalplus options
            @modal.on 'confirm', () ->
                @modal.close()
            @modal

        render: () ->

            @$el.html template.resDiffTree {}
            @_open()
            @