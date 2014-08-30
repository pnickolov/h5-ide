#############################
#  View(UI logic) for component/amis
#############################

define ['../template/TplAmiBrowser', 'i18n!/nls/lang.js', 'UI.modalplus', "ApiRequest", 'CloudResources', 'backbone', 'jqpagination'], ( TplAmiBrowser, lang, Modal, ApiRequest, CloudResources ) ->

    Backbone.View.extend {
        events   :
            'click .ami-option-group .ami-option-wrap .btn' : 'clickOptionBtn'
            'keypress #community-ami-input'                 : "search"
            'click    #btn-search-ami'                      : "search"
            'click    .toggle-fav'                          : "toggleFav"

        initialize : ( attr ) ->

            $.extend this, attr

            modal = new Modal
              title: lang.ide.AMI_LBL_COMMUNITY_AMIS
              width: "855px"
              template: TplAmiBrowser.dialog()
              disableFooter: true
              compact: true

            self = @
            modal.on "close", ()-> if self.onClose then self.onClose(); return

            @setElement modal.tpl
            @doSearch()
            return

        clickOptionBtn : (event) ->
            if $(event.target).hasClass('active')
                active_btns = $(event.target).parent().find('.active')
                if active_btns.length is 1 and active_btns[0] == event.target   # click the only one active button not reply
                    return
                else
                    $(event.target).removeClass('active')
            else
                $(event.target).addClass('active')

            null

        toggleFav: (event)->
          amiElem = $(event.target)
          that = this
          favAmis = CloudResources "FavoriteAmi", @region
          promise = null
          id = amiElem.closest("tr").attr("data-id")
          if amiElem.hasClass('fav')
            promise = favAmis.unfav id
          else
            data    = $.extend { id : id }, @communityAmiData[id]
            promise = favAmis.fav( data )

          promise.then -> amiElem.toggleClass('fav')

        doSearch : (pageNum, perPage)->
          pageNum = pageNum || 1
          @renderAmiLoading()
          name = $("#community-ami-input").val()
          platform = $('#selectbox-ami-platform').find('.selected').data('id')
          isPublic = 'true'
          architecture = '32-bit'
          rootDeviceType = "EBS"
          if $('#filter-ami-type').find('.active').length is 1
            visibility      = radiobuttons.data($('#filter-ami-type'))
            isPublic = if visibility is 'Private' then 'false' else 'true'
          else if $('#filter-ami-type').find('.active').length is 2
            isPublic = null

          if $('#filter-ami-32bit-64bit').find('.active').length is 1
            architecture = radiobuttons.data($('#filter-ami-32bit-64bit'))
          else if $('#filter-ami-32bit-64bit').find('.active').length is 2
            architecture = null

          if $('#filter-ami-EBS-Instance').find('.active').length is 1
            rootDeviceType = radiobuttons.data($('#filter-ami-EBS-Instance'))
          else if $('#filter-ami-EBS-Instance').find('.active').length is 2
            rootDeviceType = null

          perPageNum = parseInt(perPage||50, 10)
          returnPage = parseInt(pageNum, 10)

          self = @
          ApiRequest("aws_public",
            region_name: @region
            filters:
              ami: {name, platform, isPublic, architecture, rootDeviceType, perPageNum, returnPage}
          ).then (result)->
            result = self.addFavStar(result)
            self.communityAmiData = result.ami?.result || {}
            self.communityAmiRender(result)
          , (result)->
            notification 'error', lang.ide.RES_MSG_WARN_GET_COMMUNITY_AMI_FAILED
            self.communityAmiRender({ami:[]})

        searchPrev: ->
          page = parseInt( $("#community_ami_page_current").attr("page"), 10)
          @doSearch(page+1)

        searchNext: ->
          page = parseInt( $("#community_ami_page_current").attr("page"), 10)
          @doSearch(page-1)

        search: (event)->
          if event.keyCode and event.keyCode isnt 13 then return
          @doSearch()

        addFavStar: (result)->
          favAmis = CloudResources("FavoriteAmi",@region).getModels() || []
          dumpObj = _.clone result.ami.result
          favIds = _.pluck (_.pluck favAmis, "attributes"), "id"
          _.each dumpObj, (e,k)->
            if k in favIds
              e.faved = true
          result.ami.result = dumpObj
          result

        communityAmiRender: (data)->
          @communityShowContent()
          totalNum = 0
          if not data.ami then return

          data = data.ami

          $("#community_ami_table").html TplAmiBrowser.amiItem( data.result )
          @communityPagerRender data.curPageNum, data.totalPageNum, data.totalNum

        communityPagerRender: ( current_page, max_page, total ) ->
          resourceView = @
          pageSize = if total > 50 then 50 else total

          itemBegin = ( current_page - 1 ) * 50 + 1
          itemEnd = itemBegin + pageSize - 1
          itemEnd = total if itemEnd > total

          $( '.page-tip' ).text sprintf lang.ide.AMI_LBL_PAGEINFO, itemBegin, itemEnd, total

          pagination = $ '.pagination'

          if max_page is 0
            pagination.hide()
          else
            pagination.show()

          if pagination.data 'jqPagination'
            pagination.jqPagination 'destroy'
            # init page num
            pagination.find( 'input' ).data('current-page', current_page)

          pagination.jqPagination({
            current_page: current_page,
            max_page: max_page,
            page_string: "{current_page} / {max_page}"
            paged: ((current_page, max_page) ->
              (page) ->
                if page isnt current_page and max_page >= page > 0
                  resourceView.doSearch page
            )(current_page, max_page)

          })

        communityShowContent: () ->
          $( ".show-loading" ).hide()
          $( "#ami-table-wrap .scroll-content" ).show()
          $( "#btn-search-ami" ).text( lang.ide.AMI_LBL_SEARCH ).removeAttr( "disabled" )
          $( "#community-ami-page>div" ).show()

        renderAmiLoading: () ->
          $( "#ami-table-wrap .scroll-content" ).hide()
          $( ".show-loading" ).show()
          $( "#btn-search-ami" ).text( lang.ide.AMI_LBL_SEARCHING ).attr( "disabled", "" )
          $( "#community-ami-page>div" ).hide()
    }
