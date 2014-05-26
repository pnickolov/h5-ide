#############################
#  View(UI logic) for dialog
#############################

define [ "backbone", "UI.sortable", "jquerysort" ], () ->

    Backbone.View.extend {

      el : $("#tabbar-wrapper")[0]

      events :
        "click li"          : "onClick"
        "click .icon-close" : "onClose"

      initialize : ( options )->
        self = this

        @$el.find("#ws-tabs").dragsort {
          horizontal : true
          dragSelectorExclude : ".fixed"
          dragEnd : ()->
            self.updateTabOrder()
            return
        }
        return

      updateTabOrder : ()-> @trigger "orderChanged", (_.map @$el.find("li"), ( li )-> li.id)

      addTab : ( data, index = -1, fixed = false )->
        # data = {
        #   title    : ""
        #   id       : ""
        #   closable : false
        #   klass    : ""
        # }
        $parent = if fixed then $("#ws-fixed-tabs") else $("#ws-tabs")
        tpl = "<li class='#{data.klass}' id='#{data.id}'><span>#{data.title}</span>"
        if data.closable
          tpl += '<i class="icon-close" title="Close Tab"></i>'

        $tgt = $parent.children().eq( index )
        if $tgt.length
          $( tpl + "</li>" ).insertAfter $tgt
        else
          $( tpl + "</li>" ).appendTo $parent

      removeTab : ( id )-> @$el.find("##{id}").remove()

      updateTab : ( id, title, klass )->
        $tgt = @$el.find("##{id}")
        if title isnt undefined or title isnt null
          $tgt.children("span").text( title )

        if klass isnt undefined or klass isnt null
          $tgt.attr("class", klass )

        return

      activateTab : ( id )->
        @$el.find(".activate").removeClass("activate")
        @$el.find("##{id}").addClass("activate")
        return

      onClick : ( evt )->
        @trigger "click", evt.currentTarget.id
        return

      onClose : ( evt )->
        @trigger "close", $(evt.currentTarget).closest("li")[0].id
        false
    }
