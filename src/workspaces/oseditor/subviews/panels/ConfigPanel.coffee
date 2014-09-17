
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
            @model      = Design.instance()
            @viewClass  = OsPropertyView.getClass @mode, @type


