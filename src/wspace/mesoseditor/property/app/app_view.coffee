define ['../base/view'
        './container'
        './template/app'
        'i18n!/nls/lang.js'
        'constant'
        'UI.modalplus'
], (PropertyView, Container, Tpl, lang, constant) ->
  view = PropertyView.extend

    events:
      'click .open-container'                    : 'openContainer'

    initialize   : (options) ->

    openContainer: ()->
      @container = new Container(model: @model, appData: @appData).render()

    render: (version)->
      if version
        data = @jsonData.find({version}).toJSON()
      else
        data = @jsonData.toJSON()[0]

      data.versions = _.pluck @jsonData.toJSON(), "version"

      @appData = data

      #Switch Command/Arguments
      data.isCommand = data.cmd and not data.args?.length || true

      @$el.html Tpl data
      @model.get 'name'



  new view()