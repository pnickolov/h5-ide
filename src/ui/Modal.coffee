define [], ()->
    Modal = class Modal
        constructor: (@option)->
            console.log option
            @wrap = if $('#modal-wrap').size() > 0 then $("#modal-wrap") else $("<div id='modal-wrap'>").appendTo $('body')
            @tpl = $(MC.template.modalTemplate
                title: @option.title || ""
                closeAble : !@option.disableClose
                template: @option.template||""
                confirm: @option.confirm || "Submit"
                cancel: @option.cancel|| "Cancel"
                hasFooter: !@option.disableFooter
            ).find(".modal-box>div")
            .css(width: @option.width||"520px")
            .end()
            .appendTo @wrap
            @show()
            @bindEvent()
            @
        close: ()->
            console.log @option.onClose
            if (!@subModal or (@subModal and @subModal.closed)) and @close
                @tpl.remove()
            else
                return false
            if @wrap.find(".modal-box").size() < 1
                @wrap.remove()
            @option.onClose?(@tpl)
            @closed = true
            null
        show: ()->
            @wrap.removeClass("hide")
            @resize()
            console.log @option.onShow
            @option.onShow?(@tpl)
        bindEvent: ()->
            @tpl.find('#btn-confirm').click (e)=>
                @option.onConfirm?(@tpl,e)
                @close()
            @tpl.find('#btn-cancel').click (e)=>
                @option.onCancel?(@tpl,e)
                @close()
            @tpl.find("i.modal-close").click (e)=>
                @close()
            if(!@option.disableClose)
                @wrap.on 'click', (e)=>
                    if(e.target == e.currentTarget)
                        @close()
            if(@option.dragable)
                diffX = 0
                diffY = 0
                dragable = false
                @tpl.find(".modal-header h3").mousedown (e)=>
                    dragable = true
                    originalLayout = @tpl.offset()
                    diffX = originalLayout.left - e.clientX
                    diffY = originalLayout.top - e.clientY

                $(document).mousemove (e)=>
                    if(dragable)
                        @tpl.css
                            top: e.clientY + diffY
                            left: e.clientX + diffX
                        if window.getSelection
                            if window.getSelection().empty
                                window.getSelection().empty()
                            else if window.getSelection().removeAllRanges
                                window.getSelection().removeAllRanges()
                            else if (document.selection)
                                document.selection.empty();
                $(document).mouseup (e)->
                    dragable =false
                    diffX = 0
                    diffY = 0

        resize: ()->
            windowWidth = $(window).width()
            windowHeight = $(window).height()
            width = @tpl.width()
            height= @tpl.height()
            console.info windowHeight, windowWidth, width, height
            top = (windowHeight - height) / 2
            left = (windowWidth - width) / 2
            @tpl.css
                top:  if top > 0 then top else 10
                left: left
        new: (optionConfig)->
            @.moveLeft()
            @subModal = new Modal optionConfig
            console.log @subModal
            @wrap.on 'click',(e)=>
                e.preventDefault()
                alert "E"
                return false;
                if(e.target == e.currentTarget)
                    @close()
        moveLeft: ->
            console.log("Moving left")
    Modal


#new Modal
#    title: "Title Example"
#    disableClose: false
#    dragable: true
#    template: "<h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1>"
#    onClose: ()->
#        alert "Modal Closed!"
#    onShow: ()->
#        alert "Modal Shown!"
#    onConfirm: ()->
#        alert "Modal Confirm!"
#    onCancel: ()->
#        alert "Modal Canceled!"

