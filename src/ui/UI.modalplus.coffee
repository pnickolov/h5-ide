#
# *********************************************************
# Filename: UI.modalplus
# Creator: Cyril Hou
# Description: UI.modalplus
# Date: 2014-05-23
# **********************************************************
# (c) Copyright 2014 MadeiraCloud  All Rights Reserved
# **********************************************************
#
# Usage:
#   modal = new UI.modalplus option
#   subModal = modal.next option
#
#   option:
#      title: Modal.header title                                        [required]
#      template: Modal.body content                                     [required]
#      width: set the width of modal                                    [default: 520px]
#      maxHeight: set the Modal body "max-height" css attribute.        [default: 400px]
#      delay: animate delay time.                                       [default: 300ms]
#      disableClose: if can be closed when it's a single modal.         [default: false]
#      disableFooter: if this Modal has footer.                         [default: false]
#      disableDrag: if the modal is dragAble                               [default: false]
#      hideClose: if the close button on the right corner is hidden.    [default: false]
#      cancel: cancel button of Modal                                   [default: "Cancel"/ {text: 'Cancel', hide: false} Both String and Object are accepted]
#      confirm: confirm button of Modal footer.                         [default: {text: :"Submit", color: "blue", disabled: false, hide: false}] (color-support: "blue, red, silver")
#      onClose: function to exec then the modal close.                  [Function]
#      onConfirm: function to exec then the confirm button is clicked   [Function]
#      onCancel: function to exec when the cancel button is clicked     [Function]
#      onShow: function to exec then the modal is shown.                [Function]
#      mode: change to another mode.                                    [Default: "normal", optional: "panel", "normal"]
#      compact: if modal-body has padding.                              [Default: false]
#   Event:
#       on "show","next", "next", "close", "confirm", "cancel", "shown", "closed"
#   Method:
#       next( option )  ====> return new subModal
#       back()          ====> remove Last modal, back to the last but one modal.
#       getLast()       ====> return the last modal in modalGroup
#       getFirst()      ====> return the first modal in modalGroup
#       getLastButOne() ====> return the last but one modal in modalGroup
#       isOpen()        ====> return if the modal is Opened(exist)
#       isCurrent()     ====> return if the modal is current modal.
#       toggleConfirm   ====> toggle if the confirm button is disabled.
#   Property:
#       tpl             ====> the jQuery Dom element of the modal
#       modalGroup      ====> the modalGroup
#
#   Example:
#       modal = new UI.modalplus
#           title: "Modal Title"
#           template:   "<h1>Here Goes Modal Body</h1>"
#           width: "600px"
#
modalGroup = []
define ['backbone'], (Backbone)->
    class Modal
        constructor: (@option)->
            _.extend @, Backbone.Events
            isFirst = false
            if $('#modal-wrap').size() > 0
                isFirst = false
                @wrap = $("#modal-wrap")
            else
                isFirst = true
                @wrap = $("<div id='modal-wrap'>").appendTo $('body')
            if isFirst then modalGroup = []
            @tpl = $(MC.template.modalTemplate
                title       : @option.title || ""
                hideClose   : @option.hideClose
                template    : if typeof @option.template is "object" then "" else @option.template
                confirm:
                    text    : @option.confirm?.text || "Submit"
                    color   : @option.confirm?.color || "blue"
                    disabled: @option.confirm?.disabled
                    hide    : @option.confirm?.hide
                cancel      : if _.isString @option.cancel then {text: @option.cancel|| "Cancel"} else if _.isObject @option.cancel then @option.cancel else {text: "Cancel"}
                hasFooter   : !@option.disableFooter
                hasScroll   : !!@option.maxHeight || @option.hasScroll
                compact     : @option.compact
                mode        : @option.mode || "normal"
            )
            body = @tpl.find(".modal-body")
            if typeof @option.template is "object"
                body.html(@option.template)
            if @option.maxHeight then body.css("max-height":@option.maxHeight)
            if @option.width then body.parent().css( width : @option.width )
            @tpl.appendTo @wrap
            modalGroup.push(@)
            if modalGroup.length == 1 or @option.mode is "panel"
                @tpl.addClass('bounce')
                window.setTimeout =>
                    @tpl.removeClass('bounce')
                ,1
                @trigger "show", @
                @trigger 'shown', @
            @show()
            @bindEvent()
            @
        close: ()->
            if @isMoving
                return false
            if @.parentModal
                return false
            if modalGroup.length > 1
                @.back()
            else if modalGroup.length <= 1
                modalGroup = []
                @trigger 'close',@
                @option.onClose?(@)
                @tpl.addClass('bounce')
                window.setTimeout =>
                    @tpl.remove()
                    @wrap.remove()
                    @trigger 'closed', @ # Last Modal doesn't support Animation. when trigger close, it's closed.
                ,@option.delay||300
                @wrap.fadeOut(@option.delay || 300)

            null
        show: ()->
            @wrap.removeClass("hide")
            if modalGroup.length > 1
                @getLast().resize(1)
                @getLast()._slideIn()
                @getLastButOne()._fadeOut()
            else
                @resize()
            @option.onShow?(@)
            @
        bindEvent: ()->
            @tpl.find('.modal-confirm').click (e)=>
                @option.onConfirm?(@tpl,e)
                @.trigger 'confirm', @
            @tpl.find('.btn.modal-close').click (e)=>
                @option.onCancel?(@tpl,e)
                @.trigger 'cancel', @
                if not @option.preventClose then modalGroup[0]?.back()
            @tpl.find("i.modal-close").click (e)->
                modalGroup[0]?.back()
            if(!@option.disableClose)
                @getFirst().wrap.off 'click'
                @getFirst().wrap.on 'click', (e)=>
                    if(e.target == e.currentTarget)
                        @getFirst()?.back()
            $(window).resize =>
                @?.getLast()?.resize()
            $(document).keyup (e)=>
                if (e.which == 27 and not @option.disableClose)
                    if @?.getFirst()?
                        e.preventDefault()
                        @?.getFirst()?.back()
            if not (@option.disableDrag or (@option.mode is 'panel'))
                diffX = 0
                diffY = 0
                dragable = false
                @tpl.find(".modal-header h3").mousedown (e)=>
                    dragable = true
                    originalLayout = @getLast().tpl.offset()
                    diffX = originalLayout.left - e.clientX
                    diffY = originalLayout.top - e.clientY
                    null
                $(document).mousemove (e)=>
                    if(dragable and @getLast())
                        @getLast().tpl.css
                            top: e.clientY + diffY
                            left: e.clientX + diffX
                        if window.getSelection
                            if window.getSelection().empty
                                window.getSelection().empty()
                            else if window.getSelection().removeAllRanges
                                window.getSelection().removeAllRanges()
                            else if (document.selection)
                                document.selection.empty()
                $(document).mouseup (e)=>
                    if dragable
                        top = e.clientY + diffY
                        left = e.clientX + diffX
                        maxHeight = $(window).height() - @.getLast().tpl.height()
                        maxRight = $(window).width() - @.getLast().tpl.width()
                        if  top < 0
                            top = 0
                        if left < 0
                            left = 0
                        if top > maxHeight
                            top = maxHeight
                        if left > maxRight
                            left = maxRight
                        @getLast().tpl.css
                            top: top
                            left: left
                    dragable =false
                    diffX = 0
                    diffY = 0
                    null
        resize: (slideIn)->
            if @option.mode is 'panel'
              @trigger 'resize', @
              return false
            windowWidth = $(window).width()
            windowHeight = $(window).height()
            width = @option.width?.toLowerCase().replace('px','') || @tpl.width()
            height= @option.height?.toLowerCase().replace('px','') || @tpl.height()
            top = (windowHeight - height) * 0.4
            left = (windowWidth - width) / 2
            if slideIn
                left = windowWidth + left
            @tpl.css
                top:  if top > 0 then top else 10
                left: left
            @.trigger 'resize', {top: top, left: left}
        getFirst: ->
            return modalGroup?[0]
        getLast: ->
            return modalGroup[modalGroup.length - 1]
        getLastButOne: ->
            if @.parentModal
                return @.parentModal.getLastButOne()
            else
                return modalGroup[modalGroup.length - 2]
        isOpen: ()->
            return !@isClosed
        isCurrent: ()->
            return @ == @getLast()
        next: (optionConfig)->
            if modalGroup?.length >= 1
                newModal = new Modal optionConfig
                @trigger "next", @
                lastModal = @.getLastButOne()
                @.getFirst()?.option.onNext?()
                newModal.parentModal = lastModal
                lastModal.childModal = newModal
                lastModal.parentModal?.option.disableClose = true
                @isMoving = true
                window.setTimeout ()=>
                    @isMoving = false
                    newModal.trigger 'shown', newModal
                    null
                ,@option.delay || 300
                newModal
            else
                return false
        back: ()->
            if @parentModal or @isMoving
                return false
            if modalGroup.length == 1
                modalGroup.pop()
                @close()
                @isClosed = true
                return false
            else
                @getLast().trigger "close", @getLast()
                @getLastButOne()._fadeIn()
                @getLast()._slideOut()
                toRemove = modalGroup.pop()
                if toRemove.option.mode is 'panel'
                    toRemove.tpl.addClass('bounce')
                toRemove.isClosed = true
                @getLast().childModal = null
                toRemove.option.onClose?()
                @isMoving = true
                window.setTimeout ()=>
                    @isMoving = false
                    toRemove.tpl.remove()
                    toRemove.trigger 'closed', toRemove
                ,@option.delay || 300
        toggleConfirm: (disabled)->
            @.tpl.find(".modal-confirm").attr('disabled', !!disabled)
            @
        setContent: (content)->
            if @option.hasScroll or @option.maxHeight
              selector = ".scroll-content"
            else
              selector = ".modal-body"
            @tpl.find(selector).html(content)
            @resize()
            @
        setWidth: (width)->
          body = @.tpl.find('.modal-body')
          body.parent().css( width: width )
          @
        compact: ()->
          @tpl.find('.modal-body').css(padding: 0)
          @
        _fadeOut: ->
            if @option.mode is 'panel' then return false
            @tpl.animate
                left: "-="+ $(window).width()
            ,@option.delay || 100
        _fadeIn: ->
            if @option.mode is 'panel' then return false
            @tpl.animate
                left: "+="+ $(window).width()
            ,@option.delay || 100
        _slideIn: ->
            if @option.mode is 'panel' then return false
            @tpl.animate
                left: "-="+ $(window).width()
            ,@option.delay || 300
        _slideOut: ->
            if @option.mode is 'panel' then return false
            @tpl.animate
                left: "+="+ $(window).width()
            ,@option.delay || 300
        find: (selector)->
          @tpl.find(selector)
        $   :(selector)->
          @tpl.find(selector)
        setTitle: (title)->
          @tpl.find(".modal-header h3").text(title)
          @
    Modal
