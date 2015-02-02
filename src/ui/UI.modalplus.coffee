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
#      mode: change to another mode.                                    [Default: "normal", optional: "panel", "normal", "fullscreen"]
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

modals = []
defaultOptions = {
    title: ""
    mode: "normal" # ["normal", "panel", "fullscreen"]
    template: ""
    width: 520
    maxHeight: null
    delay: 300
    compact: false
    disableClose: false
    disableFooter: false
    disableDrag: false
    hideClose: false
    hasScroll: false
    hasHeader: true
    hasFooter: true
    cancel: {
        text: ""
        hide: false
    }
    confirm: {
        text: ""
        color: "blue" # ["blue", "red", "silver"]
        disabled: false
        hide: false
    }
    onClose: null
    onConfirm: null
    onShow: null
}

define ['backbone', 'i18n!/nls/lang.js'], (Backbone, lang)->
    class Modal extends Backbone.View
        events:
            "click .modal-confirm": "confirm"
            "click .btn.modal-close": "cancel"
            "click i.modal-close": "close"

        constructor: (option)->
            @nextOptions = []
            @nextCloses = []
            if typeof option.cancel is "string"
                option.cancel = {text: option.cancel}
            if typeof option.confirm is "string"
                option.confirm = {text: option.confirm}
            if option.mode is "fullscreen"
                option.disableClose = true
                option.disableFooter = true
            option.hasFooter = !option.disableFooter

            @wrap = $("#modal-wrap")
            if @wrap.size() is 0
                @wrap = $("<div id='modal-wrap'></div>").appendTo $("body")

            @option = $.extend true, {}, defaultOptions, option
            @option.cancel.text ||= lang.IDE.POP_LBL_CANCEL
            @option.confirm.text ||= lang.IDE.LBL_SUBMIT
            @render()

        render: ()->
            self = @
            if typeof @option.template is "object"
                @option.$template = @option.template
                @option.template = ""
            @tpl = $(MC.template.modalTemplate @option)
            @tpl.find(".modal-body").html @option.$template
            @setElement @tpl
            if modals.length and modals[modals.length - 1].isMoving
                console.warn "Sorry, But we are moving..."
                modals[modals.length - 1].nextOptions.push @option
                return @
            @tpl.appendTo @wrap
            @resize()
            modals.push @
            if modals.length > 1
                modals[modals.length - 1].resize(1)
                modals[modals.length - 1].animate "slideIn"
                modals[modals.length - 2].animate "fadeOut"
                modals[modals.length - 1].tpl.addClass("bounce")
            else
                @tpl.addClass "animate"
                @trigger "show", @
                @option.onShow?(@)
                _.defer ->
                    self.wrap.addClass "show"
                    self.tpl.addClass("bounce")
                _.delay ->
                    self.trigger "shown", @
                , 300
            _.delay ->
                self.nextOptions.forEach (option)->
                    new Modal(option)
            , (@option.delay||300)+10
            @bindEvent()
            @

        close: (number)->
            modal = modals[modals.length - 1]
            if modal?.pending
                modal.nextCloses.push @
                return false
            if not number or typeof number isnt "number"
                number = 1
            if @isClosed then return false
            nextModal = modals[modals.length - (1+number)]
            modal.pending = true
            modal.trigger "close", @
            modal.option.onClose?(@)

            if modals.length > 1
                if modal.option.mode is "panel"
                    modal.tpl.removeClass("bounce")
                else
                    modal.animate "slideOut"
                nextModal.animate "fadeIn"
            else
                modal.wrap.removeClass "show"
                modal.tpl.removeClass("bounce")
            _.delay ->
                modal.tpl.remove()
                modal.trigger "closed", @
                modal.pending = false
                if modals.length > 1
                    modals.length = modals.length - number
                else
                    modal.wrap.remove()
                    modals = []
            , modal.option.delay||300
            _.delay ->
                modal.nextCloses.forEach (modalToClose)->
                  modalToClose.close()
            , (modal.option.delay||300)+10
            modal.isClosed = true
            @


        confirm: (evt)->
            if $(evt.currentTarget).is(":disabled")
                return false
            @trigger "confirm", @
            @option.onConfirm?()
            @

        cancel: ()->
            @trigger "cancel", @
            @close()
            @option.onCancel?(@)
            @

        bindEvent: ()->
            #@tpl.draggable({ handle: ".modal-header h3" })
            self = @
            disableClose = false
            _.each modals, (modal)->
                if modal.option.disableClose
                    disableClose = true
            if not disableClose
                @wrap.off "click"
                @wrap.on "click", (e)->
                    if e.target is e.currentTarget
                        self.close()
            $(window).resize =>
                unless self.isClosed
                  if self is modals[modals.length-1]
                    self.resize()
                  else
                    self.resize(-1)

            $(document).keyup (e)->
                if e.which is 27 and not self.option.disableClose
                    e.preventDefault()
                    self.close()
            modal = modals[modals.length - 1]
            if not @option.disableDrag or @option.mode isnt "normal" and modal
                diffX = 0
                diffY = 0
                draggable = false
                modal.find(".modal-header h3").mousedown (e)->
                    draggable = true
                    if e.which
                        if e.which is 3 then draggable = false
                    else if e.button and e.button is 2 then draggable = false
                    console.log draggable
                    if draggable
                        originalLayout = modal.tpl.offset()
                        diffX = originalLayout.left - e.clientX
                        diffY = originalLayout.top - e.clientY
                $(document).mousemove (e)->
                    if draggable
                        modal.tpl.css
                            left: e.clientX + diffX
                            top: e.clientY + diffY
                        if window.getSelection
                            window.getSelection().empty?()
                            window.getSelection().removeAllRanges?()
                            document.selection?.empty?()

                $(document).mouseup (e)->
                    if draggable
                        left = e.clientX + diffX
                        top = e.clientY + diffY
                        maxHeight = $(window).height() - modal.tpl.height()
                        maxRight = $(window).width() - modal.tpl.width()
                        if top < 0 then top = 0
                        if left < 0 then left = 0
                        if top > maxHeight then top = maxHeight
                        if left > maxRight then left = maxRight
                        modal.tpl.animate {top, left}, 100
                    draggable = false
                    diffX = diffX = 0

        resize: (isSlideIn)->
            self = @
            if not isSlideIn
                @tpl.show()
            if @option.mode is "panel" and not isSlideIn
                @trigger "resize", @
                return false
            if @option.mode is "fullscreen" and not isSlideIn
                @tpl.removeAttr("style")
                return false
            windowWidth = $(window).width()
            windowHeight = $(window).height()
            width = @tpl.width()
            height = @tpl.height()
            top = (windowHeight - height) * 0.4
            left = (windowWidth - width) / 2
            if isSlideIn
                @tpl.removeClass("animate")
            if top < 0 then top = 10
            if isSlideIn is 1
                left = windowWidth + left
            if isSlideIn is -1
                left = -windowWidth + left
            self.tpl.css {top, left}
            if isSlideIn
                self.tpl.hide()
            @trigger "resize", {top, left}
            @

        isOpen: ()->
            !@isClosed

        next: (option)->
            newModal = new Modal(option)
            @trigger "next", newModal
            newModal
            @
        toggleConfirm: (disabled)->
            @tpl.find(".modal-confirm").attr("disabled", !!disabled)
            @
        toggleFooter: ( visible ) ->
            @tpl.find(".modal-footer").toggle !!visible
            @

        setContent: (content)->
            if @option.maxHeight or @option.hasScroll
                selector = ".scroll-content"
            else
                selector = ".modal-body"
            @tpl.find(selector).html content
            @resize()
            @
        compact: ()->
            @tpl.find(".modal-body").css(padding: 0)
            @
        animate: (animate)->
            @tpl.show()
            that = @
            if @option.mode is "fullscreen" and animate is "slideIn"
                return false
            if @option.mode is "panel"
                return false
            if @isMoving
                console.warn "It's animating."
                return false
            windowWidth = $(window).width()
            offset = @tpl.offset()
            left = offset.left + windowWidth
            delayOption = 300
            if animate in ["fadeOut", "fadeIn"]
                delayOption = 100
                left = +offset.left + windowWidth
            if animate in ["fadeOut", "slideIn"]
                left = +offset.left - windowWidth
            that.isMoving = true
            @tpl.animate {left}, delayOption , -> that.isMoving = false
            @
        find: (selector)->
            @tpl.find(selector)
        $   :(selector)->
            @tpl.find(selector)
        setTitle: (title)->
            @tpl.find(".modal-header h3").text(title)
            @
        abnormal: ()->
            @option.mode in ["panel", "fullscreen"]
    Modal