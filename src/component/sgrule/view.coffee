#############################
#  View(UI logic) for component/sgrule
#############################

define [ 'text!./template.html',
         'text!./list_template.html',
         'text!./delete_rule_dialog.html',
         'event'
], ( template, list_template, delete_template, ide_event ) ->

    template      = Handlebars.compile template
    list_template = Handlebars.compile list_template
    delete_template = Handlebars.compile delete_template

    SGRulePopupView = Backbone.View.extend {

        events    :
          'closed'                           : 'onClose'
          'click .sg-rule-create-add'        : 'addRule'
          'click .sg-rule-create-node'       : 'switchNode'
          'click .sg-rule-create-readd'      : 'readdRule'
          'OPTION_CHANGE #sg-create-proto'   : 'onProtocolChange'
          'click .sg-rule-create'            : 'onDirChange'
          'click .sg-rule-delete'            : 'deleteRule'
          'OPTION_CHANGE #sg-proto-icmp-sel' : 'onICMPChange'
          'click #confirm-delete-sg-line'    : 'deleteSGLine'

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
            modal delete_template( this.model.attributes ), true
            this.setElement $("#confirm-delete-sg-line").closest '.modal-footer'

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
          null

        addRule : ( event ) ->
          # Extract the data from the view
          data = this.extractRuleData()

          this.trigger 'ADD_RULE', data

          # Switch to done view.
          this.$el.find('#modal-box').toggleClass('done', true)

          # Update sidebar
          this.updateSidebar()

        readdRule : () ->
          this.$el.find('#modal-box').toggleClass('done', false)

        deleteRule : ( event ) ->
          console.log "delete"

          this.trigger 'DELETE_RULE', $(event.currentTarget).closest('.sg-create-rule-item').attr("data-uid")

          this.updateSidebar()
          false

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
          rule_count = $(".sg-create-rule-item").length

          $sidebar = $(".sg-rule-create-sidebar")
          $modal   = this.$el.find('#modal-box')

          isShown = $sidebar.hasClass "shown"

          if rule_count is 0
            if isShown
              $sidebar.removeClass( "shown" ).animate({ left : "0" })
              $modal.animate({left:'-=100px'}, 300)
          else
            if not isShown
              $sidebar.addClass( "shown" ).animate({ left : "-200px" })
              $modal.animate({left:'+=100px'}, 300)

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

        deleteSGLine : () ->
          this.trigger 'DELETE_SG_LINE'
          modal.close()
          null

    }

    SGRulePopupView
