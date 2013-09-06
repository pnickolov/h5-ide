#############################
#  View(UI logic) for component/sgrule
#############################

define [ 'text!./template.html',
         'text!./list_template.html',
         'text!./delete_rule_dialog.html',
         'i18n!../../nls/lang.js',
         'event'
], ( template, list_template, delete_template, lang, ide_event ) ->

    template      = Handlebars.compile template
    list_template = Handlebars.compile list_template
    delete_template = Handlebars.compile delete_template

    SGRulePopupView = Backbone.View.extend {

        events    :
          'closed'                           : 'onClose'
          'click .sg-rule-create-add'        : 'addRule'
          'click .sg-rule-create-readd'      : 'readdRule'
          'OPTION_CHANGE #sg-create-proto'   : 'onProtocolChange'
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
            this.trigger 'UPDATE_SLIDE_BAR'
            #this.updateSidebar()

        renderDeleteModule : () ->
            modal delete_template( this.model.attributes ), true
            this.setElement $("#confirm-delete-sg-line").closest '.modal-footer'

        onClose : () ->
          # TODO : When the popup close, if there's no sg rules, tell canvas to remove the line.
          this.trigger 'CLOSE_POPUP'

        addRule : ( event ) ->
          # Extract the data from the view
          data = this.extractRuleData()

          # Generate Ouput Info
          if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC or MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.DEFAULT_VPC
            rule_count = 1
          else
            rule_count = 2

          if data.direction == "both"
            rule_count *= 2

          out_target = $("#sg-create-sg-out").find(".selected").text()
          in_target  = $("#sg-create-sg-in").find(".selected").text()
          action     = $("#sg-create-direction").find(".selected").text()

          $("#sg-rule-self-ref").hide()

          if rule_count == 1
            info = sprintf lang.ide.PROP_MSG_SG_CREATE, out_target, out_target, action, in_target

          else if data.inSg is data.outSg
            info = sprintf lang.ide.PROP_MSG_SG_CREATE_SELF, rule_count, out_target, out_target
            $("#sg-rule-self-ref").show()

          else
            info = sprintf lang.ide.PROP_MSG_SG_CREATE_MULTI, rule_count, out_target, in_target, out_target, action, in_target

          $("#sg-rule-create-msg").text info



          # Switch to done view.
          this.$el.find('#modal-box').toggleClass('done', true)

          this.trigger 'ADD_RULE', data
          this.trigger 'UPDATE_LINE_ID'

          # Update sidebar
          this.trigger 'UPDATE_SLIDE_BAR'
          #this.updateSidebar()

        readdRule : () ->
          this.$el.find('#modal-box').toggleClass('done', false)

        deleteRule : ( event ) ->
          console.log "delete"

          this.trigger 'DELETE_RULE', $(event.currentTarget).closest('.sg-create-rule-item').attr("data-uid")

          this.trigger 'UPDATE_SLIDE_BAR'
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
          data = $.extend true, {}, this.model.attributes

          data.ruleCount = _.reduce data.sg_group, ( count, item )->
            item.rules.length + count
          , 0

          this.$el.find( '.sg-rule-create-sidebar' ).html( list_template( data ) )
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
          outward = if $("#sg-rule-create-tgt-o").is(":checked") then "out" else "in"

          data =
            outSg     : $("#sg-create-sg-out").find(".selected").attr("data-id")
            direction : $("#sg-create-direction").find(".selected").attr("data-id")
            inSg      : $("#sg-create-sg-in").find(".selected").attr("data-id")
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
