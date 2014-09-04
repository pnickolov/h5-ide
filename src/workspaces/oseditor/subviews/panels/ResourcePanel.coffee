
define [
    'backbone'
    'constant'
    './template/TplResourcePanel'

], ( Backbone, constant, ResourcePanelTpl )->

  Backbone.View.extend

    initialize: ( options ) ->

    render: () ->
        @$el.html ResourcePanelTpl {}
        @

