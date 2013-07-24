#############################
#  View(UI logic) for design/property/sgrule
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.modal' ], ( template, ide_event ) ->

    list_template = Handlebars.compile $( '#property-sgrule-create-list-tmpl' ).html()

    SGRuleView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-sgrule-create-tmpl' ).html()

        #events   :

        render     : ( attributes ) ->
            console.log 'Showing Security Group Rule Create Dialog'

            modal this.template( this.model.attributes ), true
            this.$el = $modal = $("#sg-rule-create-modal").closest "#modal-box"

            # Update sidebar
            this.updateSidebar()

            self = this;
            # Bind Events
            $modal.on( "click", ".sg-rule-create-add",   ()->
                                                            self.addRule() )
                  .on( "click", ".sg-node-wrap input",   ()->
                                                            self.switchNode() )
                  .on( "click", ".sg-rule-create-readd", ()->
                                                            self.readdRule() )
                  .on( "click", ".sg-rule-delete",       ()->
                                                            self.deleteRule() )

            $modal.closest("#closed").on("closed", this.onClose)

        onClose : () ->
          # TODO : When the popup close, if there's no sg rules, tell canvas to remove the line.

        switchNode : () ->
          this.$el.find(".sg-rule-create-add-wrap").toggleClass( "outward", $("#sg-rule-create-tgt-o").is(":checked") )
          null

        addRule : () ->

          # `this` points to the view

          # TODO : Tell model to add rule.

          # TODO : Insert rule to the sidebar

          # Switch to done view.
          this.$el.animate({left:"+=100px"}, 300).toggleClass('done', true);

          # Update sidebar
          this.updateSidebar()

        readdRule : () ->
          this.$el.animate({left:"-=100px"}, 300).toggleClass('done', false);

        deleteRule : () ->
          # `this` points to the view

          # TODO : Tell model to delete rule

          # TODO : Remove dom element.

        updateSidebar : () ->
          this.$el.find( '.sg-rule-create-sidebar' ).html( list_template( this.model.attributes ) )

    }

    view = new SGRuleView()

    return view
