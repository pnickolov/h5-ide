define [], ()->
    Modal = class Modal
        constructor: (@option)->
            console.log option
            modalTitle = @option.title || "Modal Title"
            closeAble = @option.closeAble
            @tpl = $(MC.template.modalTemplate(
                title: @option.title || ""
                closeAble : !@option.disableClose
                template: @option.template||""
                confirm: @option.confirm || "Submit"
                cancel: @option.cancel|| "Cancel"
                hasFooter: !@option.disableFooter
            )).find("#modal-box>div")
            .css(
                width: @option.width||"520px"
            )
            .end()
            .appendTo $("body")
            @show()
            @bindEvent()
        close: ()->
            console.log @option.onClose
            @tpl.remove()
            @option.onClose?()
        show: ()->
            @tpl.removeClass("hide")
            @resize()
            console.log @option.onShow
            @option.onShow?()
        bindEvent: ()->
            @tpl.find('#btn-confirm').click (e)=>
                @option.onConfirm(e)
                @close()
            @tpl.find('#btn-cancel').click (e)=>
                @option.onCancel(e)
                @close()
            @tpl.find("i.modal-close").click (e)=>
                @close()
            if(!@option.disableClose)
                @tpl.click (e)=>
                    if(e.target == e.currentTarget)
                        @close()
            diffX = 0
            diffY = 0
            dragable = false
            @tpl.find(".modal-header h3").mousedown (e)=>
                dragable = true
                originalLayout = @tpl.find('#modal-box').offset()
                diffX = originalLayout.top - e.clientX
                diffY = originalLayout.left - e.clientY
            @tpl.find('.modal-header h3').mousemove (e)=>
                if(dragable)
                    @tpl.find("#modal-box").css
                        top: e.clientY + diffY
                        left: e.clientX + diffX

            $(document).mouseup (e)->
                dragable =false
                diffX = 0
                diffY = 0

        resize: ()->
            windowWidth = $(window).width()
            windowHeight = $(window).height()
            width = @tpl.find("#modal-box").width()
            height= @tpl.find("#modal-box").height()
            console.info windowHeight, windowWidth, width, height
            top = (windowHeight - height) / 2
            left = (windowWidth - width) / 2
            @tpl.find('#modal-box').css
                top:  if top > 0 then top else 10
                left: left
    Modal


new Modal
    title: "Title Example"
    disableClose: true
    template: "<h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1>"
    onClose: ()->
        alert "Modal Closed!"
    onShow: ()->
        alert "Modal Shown!"
    onConfirm: ()->
        alert "Modal Confirm!"
    onCancel: ()->
        alert "Modal Canceled!"
