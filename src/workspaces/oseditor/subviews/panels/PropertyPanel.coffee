
define [
    'backbone'
    'constant'
    'Design'
    '../../property/OsPropertyView'
    '../../property/OsPropertyBundle'


], ( Backbone, constant, Design, OsPropertyView, OsPropertyBundle )->

  Backbone.View.extend

    initialize: ( options ) ->
        @options = options

        @mode = Design.instance().mode()
        @uid  = options.uid
        @type = options.type

        @model      = Design.instance().component @uid
        @viewClass  = OsPropertyView.getClass @mode, @type


    render: () ->
        @$el.html new @viewClass( model: @model )
        @

