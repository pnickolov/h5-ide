
define [
    'backbone'
    'constant'
    'Design'
    '../../property/OsPropertyModel'
    '../../property/OsPropertyBundle'

], ( Backbone, constant, Design, OsPropertyModel, OsPropertyBundle )->

  Backbone.View.extend

    initialize: ( options ) ->
        @options = options
        @resModel = Design.instance().component options.uid

    render: () ->

        @

