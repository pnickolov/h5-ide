

define ['./TestTpl', "backbone"], ( TestTpl)->

  Backbone.View.extend {

    initialize : ( attr )-> @setElement $(TestTpl( attr )).appendTo("#scenes")
 }

