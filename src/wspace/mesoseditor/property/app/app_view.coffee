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
      "OPTION_CHANGE .mesos-switch-versions"     : "switchVersion"

    initialize   : (options) ->

    openContainer: ()->
      @container = new Container(model: @model, appData: @data).render()

    switchVersion: (evt)->
      version = $(evt.currentTarget).find(".selection").text()
      @_render version.toString()

    render: ()->
      @_render()

    _render: (version)->
      @appList = _.map @appData, (model)->
        model.toJSON()
      if version
        data =  _.findWhere @appList, {version: version}
      else
        data = _.sortBy(@appList, "version")[0]

      data.versions = _.pluck @appList, 'version'

      path = @model.path()

      data.task = Design.instance().serialize().host + "v2/apps" + path

      @data = data

      #Switch Command/Arguments
      data.isCommand = data.cmd and not data.args?.length || true

      @$el.html Tpl data
      @model.get 'name'



  new view()