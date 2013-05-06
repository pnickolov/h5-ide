
###
//router.js
define( [ 'backbone','view' ], function( Backbone, MainView ) {

	var AppRouter = Backbone.Router.extend({

		routes : {

			//load remote module
			'module1' : 'loadModule1',
			'module2' : 'loadModule2',

			//必须要放在最后
			'*actions': 'defaultRouter'

		}

	});

	var init = function() {

		var router = new AppRouter();

		router.on( 'route:defaultRouter', function () {

			var mainView = new MainView();
			mainView.render();

		});

		router.on( 'route:loadModule1', function() {

			//load remote module2.js
			require([ './module/module1/main.js' ], function( module1 ) {
				module1.loadModule();
			});

		});

		router.on( 'route:loadModule2', function() {

			//load remote module2.js
			require([ './module/module2/main.js' ], function( module2 ) {
				module2.loadModule();
			});

		});

		Backbone.history.start();

	};

	return {
		initialize : init
	};

});
###

define [ 'backbone', 'view' ], ( Backbone, MainView ) ->

	AppRouter = Backbone.Router.extend {
		routes :
			#load remote module
			'module1' : 'loadModule1'
			'module2' : 'loadModule2'

			#必须要放在最后
			'*actions': 'defaultRouter'

	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->
			mainView = new MainView()
			mainView.render()

		router.on 'route:loadModule1', () ->
			require [ './module/module1/main.js' ], ( module1 ) ->
				module1.loadModule()

		router.on 'route:loadModule2', () ->
			require [ './module/module2/main.js' ], ( module2 ) ->
				module2.loadModule()

		Backbone.history.start()

	initialize : init

