
####################################
#  Base Class for Property Module
####################################

define [ 'event', 'backbone' ], ( ide_event, Backbone )->

    activeModule        = null
    activeSubModule     = null
    activeModuleType    = null
    activeSubModuleType = null
    slice               = [].slice

    # Bind an event listener to ide_event,
    # Then dispatch the event to the current active property modul
    ide_event.onLongListen "all", ( eventName ) ->

        # Current property-pane and sub-property-pane are not interested in ideEvents at all
        if ( not activeModule or not activeModule.ideEvents ) and ( not activeSubModule or not activeSubModule.ideEvents )
           return

        # Current property-pane are insterested in current ideEvent, dispatch
        if activeModule and activeModule.ideEvents and activeModule.ideEvents.hasOwnProperty eventName

            args    = slice.call arguments, 1
            handler = activeModule.ideEvents[ eventName ]
            if _.isString handler
                handler = activeModule[ handler ]
            handler.apply activeModule, args

        # Current sub-property-pane are insterested in current ideEvent too, dispatch
        if activeSubModule and activeSubModule.ideEvents and activeSubModule.ideEvents.hasOwnProperty eventName

            if not args
                args = slice.call arguments, 1
            handler = activeSubModule.ideEvents[ eventName ]
            if _.isString handler
                handler = activeSubModule[ handler ]
            handler.apply activeSubModule, args

        null

    # TODO : Set activeSubModule to null, when :
    # 1. Second panel is hidden
    # 2. Tag switch to another one.
    ide_event.onLongListen "HIDE_SECOND_PANEL", ()->
        activeSubModule = null
        null

    propertyTypeMap = {}
    propertyTypeMap.DEFAULT_TYPE = "default"

    # # # # # # # # # # # # # # # # # # # # # # # # #
    ###
    # Above is internal implementation. User doesn't have to care about its detail.
    ###
    # # # # # # # # # # # # # # # # # # # # # # # # #



    ###

    -------------------------------
     PropertyModule is a base class that every property controller ( a.k.a property main )
     should inherit.
    -------------------------------

    ++ Class attributes ++

    # ideEvents : Map
                  ( Defined by user )
        example : this.ideEvents = {
                    ABC : "functionNameOfModule"
                    DEF : () -> null
                  }
        description : This attributes specify what kind of ide_event this property cares. The event will dispatch to the property when the property is active.

    # subPanelID : String
                  ( Defined by user )
        description : If it is not falsy, this Module is meaned to be used as sub panel, or part of another module. For example, sglist / acl / sgrule should set this to something

    # uid        : String
                  ( Defined by library when property is loaded )
        description : This uid is the uid of current component. It is set before `init#{type}` is called.


    # type      : PropertyModule.TYPE.STACK || PropertyModule.TYPE.APP
                  ( Defined by library when property is loaded)
        description : User can use this attribute to determine what mode ( stack or app ) it is right now.

    # handleTypes : String | StringArray
                  ( Defined by user )
        description : This attribute is used to determine which Property should be shown. The String can be one of constant.AWS_RESOURCE_TYPE.
        Examples :
            "AWS.EC2.Instance",
            "App:AWS.EC2.Instance"   ( `App:` means it only open when it's app mode )
            "Stack:AWS.EC2.Instance" ( `Stack:` means it only open when it's design mode )
            "vgw-vpn>cgw-vpn"        ( line between `vgw-vpn` and `cgw-vpn` )
            "subnet-assoc-in>"       ( line between `subnet-assoc-in` and anything )


    # model     : PropertyModel
                  ( Assigned by user when `init#{type}` is called )
        description : This points to current model for the property.

    # view      : PropertyView
                  ( Assigned by user when `init#{type}` is called )
        description : This points to current view for the property.



    ++ Class Protocol ( Should be implemented by user ) ++
    # init#{type} :
         example     : initApp, initStack
         description : These methods are called when the property is loaded. In these method, user has to assign `this.model` and `this.view`. If this method returns false, it means the property is unable to load. And default property panel ( Stack Panel ) will be used.

    # setup#{type} :
         example     : setupApp, setupStack
         description : These methods are called after the first time the property is inited. User should use these methods to do proper setup. These methods are called only once, since the `controller`, the `model` and the `view` are all singleton.

    # afterLoad#{type} :
         example     : afterLoadApp, afterLoadStack
         description : These methods are called when the property finished loading. The view is guaranteed to be loaded.



    ++ Class Method ++

    # load :
        description : calling this method will should the property.

    # activeModule :
        description : Returns the currently showing property.

    # activeSubModule :
        description : Returns the currently showing sub property. Maybe null.



    ++ Static Method ++

    # extend :
         description : User must use this method to inherit from PropertyModule. The usage is the same as Backbone's extend. It's basically the same as triggering `ide_event.OPEN_PROPERTY`

    ###


    PropertyModule = ()->
        this.type = PropertyModule.TYPE.Stack
        null

    PropertyModule.TYPE = PropertyModule.prototype.TYPE =
        Stack : "Stack"
        App   : "App"


    PropertyModule.prototype.load = ( componentUid ) ->
        # TODO :
        null



    PropertyModule.extend = ( protoProps, staticProps ) ->
        ### env:dev ###
        if not protoProps.hasOwnProperty "handleTypes"
            console.warn "The property doesn't specify what kind of component it can handle"
            return
        ### env:dev:end ###

        # 1. Create a new property module
        newPropertyClass = Backbone.Model.extend.call PropertyModule, protoProps, staticProps
        newProperty      = new newPropertyClass()

        # 2. Register it
        if _.isString newProperty.handleTypes
            handleTypes = if protoProps.handleTypes is "" then [ propertyTypeMap.DEFAULT_TYPE ] else [ protoProps.handleTypes ]
        else
            handleTypes = newProperty.handleTypes

        for type in handleTypes
            if propertyTypeMap.hasOwnProperty type
                console.warn "Duplicated property panel"

            if type.indexOf ">"
                # This type specified a line type.
                # If it's like "cgw>", then it means every line that has a "cgw" port can be handled.
                # If it's like "cgw>vpn", then it means only cgw to vpn or vpn to cgw port can be handled
                types = type.split ">"
                if types.length == 2 and types[1].length > 0
                    # Revert the line type to be like "vpn>cgw"
                    propertyTypeMap[ types[1] + ">" + types[0] ] = newProperty

            propertyTypeMap[ type ] = newProperty

        # 3. Return the Property Class
        newPropertyClass

    PropertyModule.prototype.activeModule = () ->
        activeModule

    PropertyModule.prototype.activeSubModule = () ->
        activeSubModule


    # Class methods. They're used by design/property/main.
    PropertyModule.load  = ( componentType, componentUid, tab_type ) ->
        if not componentType
            this._doLoad propertyTypeMap.DEFAULT_TYPE, "", tab_type
        else if not this._doLoad componentType, componentUid, tab_type
            console.warn "Cannot open component for type: #{ componentType }, data : #{componentUid }"
            this._doLoad propertyTypeMap.DEFAULT_TYPE, "", tab_type
        null


    PropertyModule._doLoad = ( componentType, componentUid, tab_type, noRender ) ->

        # 1. Find the corresponding property
        property = propertyTypeMap[ componentType ]
        if not property
            # If we cannot find the property
            # then try using `App:XXXXX` and `Stack:XXXXX` to match
            property = propertyTypeMap[ tab_type + ":" + componentType ]

        if not property
            return false

        # 2. Set the property type to "App" or "Stack"
        property.type = tab_type

        # 3. Init
        procName = "init#{property.type}"
        if property[ procName ]
            property.uid = componentUid
            property[ procName ].call property, componentUid
        else
            # The property cannot init. Default to use Stack property.
            return false

        # 4. Setup ( Only run once )
        procName = "setup#{property.type}"
        if property[ procName ]
            property[ procName ].call property
            property[ procName ] = null

        # 5. Register the property as active property
        if property.subPanelID
            activeSubModule     = property
            activeSubModuleType = componentType
        else
            activeSubModule     = null
            activeSubModuleType = null
            activeModule        = property
            activeModuleType    = componentType

        # 6. Re-init the `model` and `view`
        # Since the model is singleton, need to clear all the attributes.
        property.model.clear( { silent : true } )
        # If the model cannot init. Default to use Stack property.
        if property.model.init( componentUid ) is false
            return false

        # Injects the model to the view. So that the view doesn't have hard dependency
        # to the model. Thus they're decoupled.
        property.view.model     = property.model
        property.view._isSub    = !!property.subPanelID
        property.view._noRender = noRender # If we are restore state of a tab, no need to render the property panel

        # 7. Tell view to Render
        if property.subPanelID
            property.view._loadAsSub( property.subPanelID )
        else
            property.view._load()

        # 8. After load callback.
        procName = "afterLoad#{property.type}"
        if property[ procName ]
            property[ procName ].call property

        true

    PropertyModule.snapshot = ()->
        data =
            activeModuleType    : activeModuleType
            activeSubModuleType : activeSubModuleType
            activeModuleId      : activeModule.uid
            activeSubModuleId   : if activeSubModule then activeSubModule.uid else null
            tab_type            : activeModule.type

        data

    PropertyModule.restore  = ( snapshot )->
        PropertyModule.load snapshot.activeModuleType, snapshot.activeModuleId, snapshot.tab_type, true

        if snapshot.activeSubModuleType
            PropertyModule.load snapshot.activeSubModuleType, snapshot.activeSubModuleId, snapshot.tab_type, true

        null

    # The event object is used to communicate with design/property/view
    # So that we don't have a reference to desing/property/view, avoiding
    # a strong dependency on it.
    PropertyModule.event = _.extend {}, Backbone.Events
    PropertyModule.event.FORCE_SHOW = "forceshow"


    # Export PropertyModule
    PropertyModule

