
define [
    'backbone'
    'constant'
    '../../property/OsPropertyView'
    '../../property/OsPropertyBundle'

], ( Backbone, constant, OsPropertyView )->


    Backbone.View.extend

        initialize: ( options ) ->
            @options = options
            @mode = Design.instance().mode()
            @type = 'globalconfig'

            @model      = @getModel()
            @viewClass  = OsPropertyView.getClass @mode, @type

        getModel: ->
            Backbone.Model.extend {
                initialize: () ->
                    design = Design.instance()
                    @set {
                        name       : design.get("name").replace(/\s+/g, '')
                        id         : design.get("id")
                        usage      : design.get("usage")
                        description: design.get('description')
                        type       : typeMap[ design.type() ]
                    }
            }

        render: () ->
            that = @
            @$el.html new @viewClass( model: @model ).render().el

            @$el.find('select.value').each() ->
                that.bindSelection($(@))

            @

