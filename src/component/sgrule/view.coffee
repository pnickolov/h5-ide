#############################
#  View(UI logic) for component/sgrule
#############################

define [
         'text!/component/sgrule/template.html',
         'text!/component/sgrule/list_template.html',
         'event', 'backbone', 'jquery', 'handlebars', 'UI.modal' ], ( template, list_template, ide_event ) ->

    template      = Handlebars.compile template
    list_template = Handlebars.compile list_template

    SGRulePopupView = Backbone.View.extend {

        events    :
          'closed'                      : 'onClose'
          'click .sg-rule-create-add'   : 'addRule'
          'click .sg-node-wrap input'   : 'switchNode'
          'click .sg-rule-create-readd' : 'readdRule'

        render   : () ->
            console.log 'Showing Security Group Rule Create Dialog'

            modal template( this.model.attributes ), true

            this.setElement '#modal-wrap'

            # Update sidebar
            this.updateSidebar()

            #return this

            ###
            #this.$el = $modal = $("#sg-rule-create-modal").closest "#modal-box"
            self = this
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
            ###

        onClose : () ->
          # TODO : When the popup close, if there's no sg rules, tell canvas to remove the line.
          this.trigger 'CLOSE_POPUP'

        switchNode : () ->
          this.$el.find(".sg-rule-create-add-wrap").toggleClass( "outward", $("#sg-rule-create-tgt-o").is(":checked") )
          null

        addRule : () ->

          # `this` points to the view

          # TODO : Tell model to add rule.

          # TODO : Insert rule to the sidebar

          # Switch to done view.
          #this.$el.animate({left:"+=100px"}, 300).toggleClass('done', true)
          this.$el.find('#modal-box').animate({left:"+=100px"}, 300).toggleClass('done', true)

          # Update sidebar
          this.updateSidebar()

        readdRule : () ->
          this.$el.animate({left:"-=100px"}, 300).toggleClass('done', false)

        deleteRule : () ->
          # `this` points to the view

          # TODO : Tell model to delete rule

          # TODO : Remove dom element.

        updateSidebar : () ->
          this.$el.find( '.sg-rule-create-sidebar' ).html( list_template( this.model.attributes ) )

    }

    SGRulePopupView
