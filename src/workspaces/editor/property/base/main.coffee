
####################################
#  Base Class for Property Module
####################################

define [ 'event' ], ( ide_event )->

    activeModule        = null
    activeModuleType    = null
    activeSubModule     = null
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

    propertyTypeMap = {}
    propertyTypeRegExpArr = []
    propertyTypeMap.DEFAULT_TYPE = "default"

    propertySubTypeMap = {}

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

    # handle    : String | Regex
                  ( Defined by library when property is loaded)
        description : User can use this attribute to determine what type of the component ( This will be one of the value in this.handleTypes )

    # handleTypes : String | Array(of string, regex)
                  ( Defined by user )
        description : This attribute is used to determine which Property should be shown. The String can be one of constant.RESTYPE.
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

    # onUnloadSubPanel(id) :
        description : This method is called when sub panel is closed. id is the sub panel's `subPanelID`.



    ++ Class Method ++

    # loadSubPanel( subPanelID, componentUid ) :
        description : calling this method will show the property. It does nothing if the property module is main module, not sub module.

    # activeModule :
        description : Returns the currently showing property.

    # activeSubModule :
        description : Returns the currently showing sub property. Maybe null.



    ++ Static Method ++

    # extend :
         description : User must use this method to inherit from PropertyModule. The usage is the same as Backbone's extend.

    ###


    PropertyModule = ()->
        this.type = PropertyModule.TYPE.Stack
        null

    PropertyModule.TYPE = PropertyModule.prototype.TYPE =
        Stack   : "Stack"
        App     : "App"
        AppEdit : "AppEdit"


    PropertyModule.prototype.loadSubPanel = ( subPanelID, componentUid ) ->
        __loadProperty( propertySubTypeMap[ subPanelID ], subPanelID, componentUid, activeModule.type )

    PropertyModule.extend = ( protoProps, staticProps ) ->
        ### env:dev ###
        if not ( protoProps.hasOwnProperty( "handleTypes" ) or protoProps.hasOwnProperty( "subPanelID" ) )
            console.warn "The property doesn't specify what kind of component it can handle"
            return
        ### env:dev:end ###

        # 1. Create a new property module
        newPropertyClass = Backbone.Model.extend.call PropertyModule, protoProps, staticProps
        newProperty      = new newPropertyClass()

        # 2. Register it

        # 2.1 If the panel is subpanel, register it to propertySubTypeMap
        if newProperty.subPanelID
            propertySubTypeMap[ newProperty.subPanelID ] = newProperty
            return newPropertyClass

        # 2.2 Register main panel to propertyTypeMap
        if protoProps.handleTypes is ""
            handleTypes = [ propertyTypeMap.DEFAULT_TYPE ]
        else if _.isString( protoProps.handleTypes ) or not protoProps.handleTypes.hasOwnProperty "length"
            # This might be string or regexp
            handleTypes = [ protoProps.handleTypes ]
        else
            handleTypes = protoProps.handleTypes


        for type in handleTypes
            ### env:dev ###
            if propertyTypeMap.hasOwnProperty type
                console.warn "Duplicated property panel"
            ### env:dev:end ###

            if not type.hasOwnProperty "length"
                # Assume this is a regexp
                propertyTypeRegExpArr.push {
                    regexp : type
                    prop   : newProperty
                }
                continue

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

    PropertyModule.prototype.activeModule    = () -> activeModule
    PropertyModule.prototype.activeSubModule = () -> activeSubModule
    PropertyModule.activeModule    = PropertyModule.prototype.activeModule
    PropertyModule.activeSubModule = PropertyModule.prototype.activeSubModule
    PropertyModule.loadSubPanel    = PropertyModule.prototype.loadSubPanel

    # Class methods. They're used by design/property/main.
    PropertyModule.load  = ( componentType, componentUid, tab_type, restore ) ->
        property   = __getProperty( componentType, componentUid, tab_type )
        loadResult = __loadProperty( property, componentType, componentUid, tab_type, restore )

        if loadResult isnt true
            if loadResult is false
                # Cannot load the property due to data issue. Display the missing property
                componentType = 'Missing_Resource'
            else
                # The property doesn't handle current tab_type. Display the stack property
                componentType = ""
                console.warn "Cannot open component for type: #{ componentType }, data : #{componentUid }"

            property = __getProperty( componentType, componentUid, tab_type )
            return __loadProperty( property, componentType, componentUid, tab_type, restore )
        true

    __getProperty = ( componentType, componentUid, tab_type ) ->

        if not componentType then componentType = propertyTypeMap.DEFAULT_TYPE

        handle = componentType
        # 1. Find the corresponding property
        property = propertyTypeMap[ componentType ]
        if not property
            # If we cannot find the property
            # then try using `App:XXXXX` and `Stack:XXXXX` to match
            handle = tab_type + ":" + componentType
            property = propertyTypeMap[ handle ]

        if not property and componentType.indexOf ">" > -1
            # This is a line, we try to match the line using regexp
            for r in propertyTypeRegExpArr
                if componentType.match r.regexp
                    handle   = r.regexp
                    property = r.prop
                    break

        if not property
            return

        property.handle = handle
        property

    __loadProperty = ( property, componentType, componentUid, tab_type, restore ) ->
        if not property then return false

        # 1. Set the property type to "App" or "Stack"
        property.type = tab_type
        # 2. Init
        procName = "init#{property.type}"
        if property[ procName ]
            property.uid = componentUid
            result = property[ procName ].call property, componentUid
            if result is false
                # The property cannot init. Default to use Stack property.
                return
        else
            # The property cannot init. Default to use Stack property.
            return
        # 3. Setup ( Only run once )
        procName = "setup#{property.type}"
        if property[ procName ]
            property[ procName ].call property
            property[ procName ] = null
        # 4. Register the property as active property
        if property.subPanelID
            activeSubModule     = property
            activeSubModuleType = componentType
        else
            activeSubModule     = null
            activeSubModuleType = null
            activeModule        = property
            activeModuleType    = componentType
        # 5. Re-init the `model` and `view`
        # Since the model is singleton, need to clear all the attributes.
        property.model.clear( { silent : true } )
        # If the model cannot init. Default to use Missing Property.
        if property.model.init( componentUid ) is false
            return false

        __resetSelectedinGroup restore, property.model
        # Injects the model to the view. So that the view doesn't have hard dependency
        # to the model. Thus they're decoupled.
        property.view.model      = property.model
        property.view._isSub     = !!property.subPanelID
        property.view.__restore  = PropertyModule.__restore
        PropertyModule.__restore = false # Reset this attr here, so that even there's error, it still get reset
        # 6. Tell view to Render
        if property.subPanelID
            property.view._loadAsSub( property.subPanelID )
        else
            property.view._load()
        # 7. After load callback.
        procName = "afterLoad#{property.type}"
        if property[ procName ]
            property[ procName ].call property

        true

    __resetSelectedinGroup = ( restore, model ) ->
        # mid = model.get 'mid'
        # uid = model.get 'uid'

        # if restore and mid
        #     if mid.length is 38
        #         MC.canvas.instanceList.selectById uid, mid
        #     else
        #         MC.canvas.asgList.selectById uid, mid

    PropertyModule.onUnloadSubPanel = () ->
        # Calls `onUnloadSubPanel` callback for current main property module
        if activeModule.onUnloadSubPanel
            activeModule.onUnloadSubPanel( activeSubModule.subPanelID )

        activeSubModule     = null
        activeSubModuleType = null
        null

    PropertyModule.snapshot = () ->
        activeModuleId      : activeModule.uid
        activeModuleType    : activeModuleType
        activeSubModuleId   : if activeSubModule then activeSubModule.uid else null
        activeSubModuleType : activeSubModuleType
        tab_type            : activeModule.type

    PropertyModule.restore  = ( ss, propertyView ) ->
        PropertyModule.load( ss.activeModuleType, ss.activeModuleId, ss.tab_type, true )

        if ss.activeSubModuleType
            PropertyModule.__restore = true
            PropertyModule.loadSubPanel ss.activeSubModuleType, ss.activeSubModuleId, true
            PropertyModule.__restore = false
        null

    # Export PropertyModule
    PropertyModule

