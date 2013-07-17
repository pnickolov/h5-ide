#############################
#  View Mode for canvas
#############################

define [ 'backbone', 'jquery', 'underscore' ], () ->

	CanvasModel = Backbone.Model.extend {

		defaults : {

		}


		initialize : ->
			#listen
			null

		#change node from one parent to another parent
		changeNodeParent : (src_node, tgt_parent) ->
			#to-do

			null

		#change group from one parent to another parent
		changeGroupParent : (src_group, tgt_parent) ->
			#to-do

			null


	}

	model = new CanvasModel()

	return model