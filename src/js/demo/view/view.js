/*
//view.js
define( [ 'backbone', 'jquery', 'handlebars' ], function( Backbone, $, Handlebars ) {

    var MainView = Backbone.View.extend({

        el       : $( '#controlContent' ),
        template : Handlebars.compile( $( "#control-tmpl" ).html() ),

        events   : {
            'click .addModule1' : 'loadModule1',
            'click .addModule2' : 'loadModule2'
        },

        loadModule1 : function() {

            //loading bar
            $( '#itemContent' ).html( 'loading...' );

        },

        loadModule2 : function() {

            //loading bar
            $( '#itemShowContent' ).html( 'loading...' );
            
        },

        render      : function () {
            $( this.el ).html( this.template( this.model ));
            return this;
        }

    });

    return MainView;

});
*/


(function() {
  define(['backbone', 'jquery', 'handlebars'], function(Backbone, $, Handlebars) {
    var MainView;
    MainView = Backbone.View.extend({
      el: $('#controlContent'),
      template: Handlebars.compile($("#control-tmpl").html()),
      events: {
        'click .addModule1': 'loadModule1',
        'click .addModule2': 'loadModule2',
        'click .addDialog': 'addDialog'
      },
      loadModule1: function() {
        return $('#itemContent').html('loading...');
      },
      loadModule2: function() {
        return $('#itemShowContent').html('loading...');
      },
      addDialog: function() {
        return $('#dialogGroup').html('loading...');
      },
      render: function() {
        return $(this.el).html(this.template());
      }
    });
    return MainView;
  });

}).call(this);
