#############################
#  View(UI logic) for dialog
#############################

define [ "backbone", "jquerysort" ], () ->

    Backbone.View.extend {

      el : $("#tabbar-wrapper")[0]

      events :
        "click li"              : "onClick"
        "click .icon-close"     : "onClose"

      initialize : ( options )->
        self = this
        @tabsWidth = 0

        @$el.find("#ws-tabs").dragsort {
          horizontal : true
          dragSelectorExclude : ".fixed, .icon-close"
          dragEnd : ()->
            self.updateTabOrder()
            return
        }
        return

      updateTabOrder : ()-> @trigger "orderChanged", @tabOrder()
      tabOrder : ()-> _.map @$el.find("li"), ( li )-> li.id

      setTabIndex : ( id, isFixed, idx )->
        $tgt = @$el.find("##{id}")
        if not $tgt.length then return

        if isFixed
          $group = $("#ws-fixed-tabs")
        else
          $group = $("#ws-tabs")
          idx   -= $("#ws-fixed-tabs").children().length

        $after = $group.children().eq( idx )
        if $after.length
          $tgt.insertBefore( $after )
        else
          $group.append($tgt)
        return


      addTab : ( data, index = -1, fixed = false )->
        # data = {
        #   title    : ""
        #   id       : ""
        #   closable : false
        #   klass    : ""
        # }
        $parent = if fixed then $("#ws-fixed-tabs") else $("#ws-tabs")
        tpl = "<li class='#{data.klass}' id='#{data.id}' title='#{data.title}'><span class='truncate'>#{data.title}</span>"
        if data.closable
          tpl += '<i class="icon-close" title="Close Tab"></i>'

        $tgt = $parent.children().eq( index )
        if $tgt.length
          $tgt = $( tpl + "</li>" ).insertAfter $tgt
        else
          $tgt = $( tpl + "</li>" ).appendTo $parent

        @tabsWidth += $tgt.outerWidth()
        @ensureTabSize()
        $tgt

      removeTab : ( id )->
        $tgt = @$el.find("##{id}")
        @tabsWidth -= $tgt.outerWidth()
        $tgt.remove()
        @ensureTabSize()
        $tgt

      ensureTabSize : ()->
        windowWidth = $(window).width()
        availableSpace = windowWidth - $("#header").outerWidth() - $("#ws-tabs").offset().left

        children = $("#ws-tabs").children()
        if @tabsWidth < availableSpace
          children.css("max-width", "auto")
        else
          availableSpace = Math.floor( availableSpace / children.length )
          children.css("max-width", availableSpace)
        return

      updateTab : ( id, title, klass )->
        $tgt = @$el.find("##{id}")
        if title isnt undefined or title isnt null
          @tabsWidth -= $tgt.outerWidth()
          $tgt.attr("title", title)
          $tgt.children("span").text( title )
          $tgt.attr("title", title)
          @tabsWidth += $tgt.outerWidth()
          @ensureTabSize()

        if klass isnt undefined or klass isnt null
          if $tgt.hasClass("active")
            klass += " active"
          $tgt.attr("class", klass )
        return

      activateTab : ( id )->
        @$el.find(".active").removeClass("active")
        @$el.find("##{id}").addClass("active")
        return

      onClick : ( evt )->
        @trigger "click", evt.currentTarget.id
        return

      onClose : ( evt )->
        @trigger "close", $(evt.currentTarget).closest("li")[0].id
        false

      showLoading : ()-> $("#GlobalLoading").show()
      hideLoading : ()-> $("#GlobalLoading").hide()

    }
