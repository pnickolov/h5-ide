define ['UI.modalplus', './component/resdiff/resDiffTpl'], (modalplus, template) ->

    Backbone.View.extend

        className: 'res_diff_tree'

        initialize: () ->
            @render()

        _open: () ->

            options =

                template: @el
                title: 'Resource diff'
                disableFooter: true
                disableClose: true
                width: '608px'
                height: '681px'
                compact: true

            @modal = new modalplus options

        render: () ->

            @$el.html template.resDiffTree {}
            @_open()
            @