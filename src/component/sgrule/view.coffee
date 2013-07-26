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
          'closed'                           : 'onClose'
          'click .sg-rule-create-add'        : 'addRule'
          'click .sg-rule-create-node'       : 'switchNode'
          'click .sg-rule-create-readd'      : 'readdRule'
          'OPTION_CHANGE #sg-create-proto'   : 'onProtocolChange'
          'click .sg-rule-create'            : 'onDirChange'
          'OPTION_CHANGE #sg-proto-icmp-sel' : 'onICMPChange'

        render   : () ->
            console.log 'Showing Security Group Rule Create Dialog'

            modal template( this.model.attributes ), true

            # In case there's two modal dialog in the page, although it is ALMOST
            # not possible
            # And `closed` event is send to '#modal-wrap'
            this.setElement $('#sg-rule-create-modal').closest '#modal-wrap'

            # Update sidebar
            this.updateSidebar()

        renderDeleteModule : () ->

            modal list_template( this.model.attributes ), true

        onClose : () ->
          # TODO : When the popup close, if there's no sg rules, tell canvas to remove the line.
          this.trigger 'CLOSE_POPUP'

        switchNode : ( event ) ->

          $node = $( event.currentTarget ).toggleClass "selected", true
          $node.siblings().removeClass "selected"
          $node.find("input").prop 'checked', true

          outward = $("#sg-rule-create-tgt-o").is(":checked")
          $(".sg-rule-create-out").toggle( outward )
          $(".sg-rule-create-in").toggle( !outward)

          this.$el.find('.sg-rule-create-add-wrap').toggleClass( 'outward', $('#sg-rule-create-tgt-o').is(':checked') )
          null

        addRule : ( event ) ->
          # Extract the data from the view
          data = this.extractRuleData()
          console.log data

          this.trigger 'ADD_SG_RULE', data
          # TODO : Tell model to add rule.

          # TODO : Insert rule to the sidebar

          # Switch to done view.

          #this.$el.animate({left:'+=100px'}, 300).toggleClass('done', true)
          this.$el.find('#modal-box').animate({left:'+=100px'}, 300).toggleClass('done', true)



          # Update sidebar
          this.updateSidebar()

        readdRule : () ->
          this.$el.animate({left:'-=100px'}, 300).find("#modal-box").toggleClass('done', false)


        deleteRule : () ->
          # TODO : Tell model to delete rule

          # TODO : Remove dom element.

        onDirChange : () ->
          $(".sg-rule-direction").html( if $("#sg-rule-create-dir-i").is(":checked") then "Source" else "Destination" )

        onProtocolChange : ( event, id ) ->
          $(".sg-proto-input").hide()
          $("#sg-proto-ipt-" + id).show()

        onICMPChange : ( event, id ) ->
          $(".sg-proto-input-sub").hide()
          $("#sg-proto-input-sub-" + id).show()

        updateSidebar : () ->
          this.$el.find( '.sg-rule-create-sidebar' ).html( list_template( this.model.attributes ) )

        extractRuleData : () ->
          outward = if $("#sg-rule-create-tgt-o").find("input").is(":checked") then "out" else "in"

          data =
            sgId      : $("#sg-create-sg-" + outward).find( ".selected" ).attr("data-id")
            isInbound : $("#sg-rule-create-dir-i").is(":checked")
            direction : $("#sg-create-dir-"+ outward).find( ".selected" ).attr("data-id")
            protocol  : $("#sg-create-proto").find( ".selected" ).attr("data-id")

          $protoIptWrap = $("#sg-proto-ipt-"+data.protocol)
          $protoIpt     = $protoIptWrap.find("input")

          if $protoIpt.length
            protocolValue = $protoIpt.val()
          else
            protocolValue = $protoIptWrap.find(".selected").attr("data-id")

          data.protocolValue = protocolValue

          if data.protocol is "icmp"
            if protocolValue == "3" || protocolValue == "5" || protocolValue == "11" || protocolValue == "12"
              data.protocolSubValue = $("#sg-proto-input-sub-" + protocolValue).find(".selected").attr("data-id")

          data
    }

    SGRulePopupView
