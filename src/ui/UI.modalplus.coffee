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

            @option = _.extend _.clone(defaultOptions), option
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

            @bindEvent()
            @

        close: ()->
            self = @
            if @pending then return false
            @pending = true
            if @isClosed or @isMoving then return false
            modal = modals[modals.length - 1]
            modal.trigger "close", @
            modal.option.onClose?(@)

            if modals.length > 1
                if modal.option.mode is "panel"
                    modal.tpl.removeClass("bounce")
                else
                    modal.animate "slideOut"
                modals[modals.length - 2].animate "fadeIn"
            else
                modal.wrap.removeClass "show"
                modal.tpl.removeClass("bounce")
            _.delay ->
                modal.tpl.remove()
                modal.trigger "closed", @
                self.pending = false
                if modals.length > 1
                    modals.pop()
                else
                    modal.wrap.remove()
                    modals = []
            , modal.option.delay || 300
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
                modals[modals.length - 1].resize()

            $(document).keyup (e)->
                if e.which is 27 and not @option.disableClose
                    e.preventDefault()
                    self.close()
            modal = modals[modals.length - 1]
            if not @option.disableDrag or @option.mode isnt "normal" and modal
                diffX = 0
                diffY = 0
                draggable = false
                modal.find(".modal-header h3").mousedown (e)->
                    draggable = true
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
            if @option.mode isnt "normal"
                @trigger "resize", @
                return false

            windowWidth = $(window).width()
            windowHeight = $(window).height()
            width = @option.width?.toString()?.toLowerCase().replace('px','') || @tpl.width()
            height = @option.height?.toString()?.toLowerCase().replace('px','') || @tpl.height()
            top = (windowHeight - height) * 0.4
            left = (windowWidth - width) / 2
            if top < 0 then top = 10
            if isSlideIn
                left = windowWidth + left
            @tpl.css {top, left}
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
            if @option.mode is "fullscreen" and animate is "slideIn"
                return false
            if @option.mode is "panel"
                return false
            if @isMoving
                console.warn "It's animating."
                return false
            symbol = "+="
            delayOption = 300
            that = @
            if animate in ["fadeOut", "fadeIn"]
                delayOption = 100
            if animate in ["fadeOut", "slideIn"]
                symbol = "-="
            windowWidth = $(window).width()
            that.isMoving = true
            @tpl.animate
                left: symbol + windowWidth
            , @option.delay || delayOption
            , -> that.isMoving = false
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