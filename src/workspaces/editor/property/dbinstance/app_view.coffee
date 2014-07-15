
#############################
#  View(UI logic) for design/property/cgw(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

  CGWAppView = PropertyView.extend {

    render : () ->
      console.log @model.toJSON()
      @$el.html template.appView @model?.toJSON()
      @model.get 'name'
  }

  new CGWAppView()
