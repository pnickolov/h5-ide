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
            if @modalGroup.length > 1
                @modalGroup[@modalGroup.length-1].tpl.remove()
            @option.onClose?(@tpl)
            @modalGroup.pop()
            if @modalGroup.length < 1
                @wrap.remove()
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
        modalGroup: [@]
        next: (optionConfig)->
            newModal = new Modal optionConfig
            newModal.parentModal = @
            @modalGroup.push(newModal)
            @modalGroup[@modalGroup.length-2]._fadeOut()
            newModal._slideIn()
        back: (optionConfig)->
            length = @modalGroup.length
            @modalGroup[length-2]._fadeIn()
            @modalGroup[length-1]._slideOut()
            window.setTimeout ()->
                @modalGroup[length-1].close()
            ,300
        _fadeOut: ->
            console.log "Fading out"
            @tpl.addClass "fadeOut"
        _fadeIn: ->
            console.log "Fading in"
            @tpl.removeClass 'fadeOut'
        _slideIn: ->
            console.log 'Sliding In'
            @tpl.addClass 'slideIn'
        _slideOut: ->
            console.log 'Sliding Out'
            @tpl.removeClass 'slideIn'
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

