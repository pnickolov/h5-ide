define [
    'UI.modalplus'
    './component/resdiff/resDiffTpl'
    './component/resdiff/a'
    './component/resdiff/b'
], ( modalplus, template, a, b ) ->

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
            console.log(a, b);
            options =

                template: @el
                title: 'App Changes'
                disableClose: true
                disableCancel: true
                confirm:
                    text: 'OK, got it'

                width: '608px'
                compact: true

            @modal = new modalplus options
            @modal.on 'confirm', () ->
                @modal.close()
            @modal

        render: () ->

            @$el.html template.resDiffTree {}
            @_open()
            @