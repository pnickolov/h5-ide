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
            )
            @tpl.find(".modal-body").parent()
            .css(width: @option.width||"520px")
            @tpl.appendTo @wrap
            @modalGroup.push(@)
            @show()
            @bindEvent()
            @
        close: ()->
            if @isMoving
                return false
            console.log @option.onClose
            if @.parentModal
                return false
            if @modalGroup.length > 1
                @.back()
            else if @modalGroup.length == 1
                @getLast().tpl.remove()
                @option.onClose?(@)
                @modalGroup=[]
            if @modalGroup.length < 1
                @wrap.remove()
            null
        show: ()->
            @wrap.removeClass("hide")
            if @modalGroup.length > 1
                @getLast().resize(1)
                @getLast()._slideIn()
                @getLastButOne()._fadeOut()
            else
                @resize()
            console.log @option.onShow
            @option.onShow?(@)
        bindEvent: ()->
            @tpl.find('#button-confirm').click (e)=>
                @option.onConfirm?(@tpl,e)
                console.log @modalGroup
                @modalGroup[0].back()
            @tpl.find('#button-cancel').click (e)=>
                @option.onCancel?(@tpl,e)
                @modalGroup[0].back()
            @tpl.find("i.modal-close").click (e)=>
                @modalGroup[0].back()
            if(!@option.disableClose)
                @wrap.on 'click', (e)=>
                    if(e.target == e.currentTarget)
                        @back()
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

        resize: (slideIn)->
            windowWidth = $(window).width()
            windowHeight = $(window).height()
            width = @tpl.width()
            height= @tpl.height()
            console.info windowHeight, windowWidth, width, height
            top = (windowHeight - height) / 2
            left = (windowWidth - width) / 2
            if slideIn
                left = windowWidth + left
            @tpl.css
                top:  if top > 0 then top else 10
                left: left
        modalGroup: []
        getFirst: ->
            return @modalGroup?[0]
        getLast: ->
            return @modalGroup[@modalGroup.length - 1]
        getLastButOne: ->
            return @modalGroup[@modalGroup.length - 2]
        next: (optionConfig)->
            unless @modalGroup?.length < 1
                newModal = new Modal optionConfig
                lastModal = @.getLastButOne()
                @.getFirst()?.option.onNext?()
                newModal.parentModal = lastModal
                lastModal.childModal = newModal
                lastModal.parentModal?.option.disableClose = true
                @isMoving = true
                window.setTimeout ()=>
                    @isMoving = false
                ,300
            else
                return false
        back: ()->
            if @parentModal or @isMoving
                return false
            if @modalGroup.length == 1
                @close()
                return false
            else
                @getLastButOne()._fadeIn()
                @getLast()._slideOut()
                toRemove = @modalGroup.pop()
                @getLast().childModal = null
                toRemove.option.onClose?()
                @isMoving = true
                window.setTimeout ()=>
                    toRemove.tpl.remove()
                    @isMoving = false;
                ,300
        _fadeOut: ->
            console.log "Fading out"
            @tpl.animate
                left: "-="+ $(window).width()
            ,300
        _fadeIn: ->
            console.log "Fading in"
            @tpl.animate
                left: "+="+ $(window).width()
            ,300
        _slideIn: ->
            console.log 'Sliding In'
            @tpl.animate
                left: "-="+ $(window).width()
            ,300
        _slideOut: ->
            console.log 'Sliding Out'
            @tpl.animate
                left: "+="+ $(window).width()
            ,300
    Modal


#taModal = new Modal
#    title: "TA Modal 1"
#    disableClose: false
#    dragable: true
#    template: "<h1 style='font-size: 100px;line-height:125px;text-align: center'>One</h1>"
#    onClose: ->
#        console.log("Close!")
#window.setTimeout ()->
#    taModal.next
#        title: "TA Modal 2"
#        disableClose: false
#        dragable: true
#        width: "1000px"
#        template: "<h1 style='font-size: 100px;line-height:125px;text-align: center'>Two</h1>"
#        onClose: ->
#            console.log("Close!")
#        onConfirm: ->
#            alert 2
#,1000
#window.setTimeout ()->
#    taModal.next
#        title: "Ta Modal 3"
#        disableClose: true
#        dragable: true
#        template: "<h1 style='font-size: 100px;line-height:125px;text-align: center'>Three</h1>"
#        onCancel: ->
#            alert 3
#,2000
#window.setTimeout ()->
#    taModal.next
#        title: "Ta Modal 4"
#        disableClose: false
#        dragable: true
#        template: "<h1 style='font-size: 100px;line-height:125px;text-align: center'>Four</h1>"
#        onClose: ->
#            console.log("Closed 4")
#,3000
