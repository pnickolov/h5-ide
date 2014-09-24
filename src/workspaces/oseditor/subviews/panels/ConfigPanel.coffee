
define [
    'backbone'
    'constant'
    './PropertyPanel'
    '../../property/OsPropertyView'

], ( Backbone, constant, PropertyPanel, OsPropertyView )->


    PropertyPanel.extend

        initialize: ( options ) ->
            PropertyPanel.prototype.initialize.apply @, arguments

            @type = 'globalconfig'
            @model = @appModel = Design.instance()

            @viewClass  = OsPropertyView.getClass @mode, @type


