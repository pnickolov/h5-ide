
define [ "Design"], ( Design )->

  # JsonFixer is an util function to normalize JSON before the JSON gets deserilized.

  Design.registerDeserializeVisitor ( data, layout_data, version )->

    if version >= "2014-01-25" then return

    azMap = {}
    azArr = []

    for uid, comp of layout_data

      # Generate Component for AZ
      if comp.type is "AWS.EC2.AvailabilityZone"

        # Some very old stack use "Canvas" as the parent of AZ in classic mode.
        # This line will fix that.
        if comp.groupUId is "Canvas" then delete comp.groupUId

        azArr.push {
          uid  : uid
          type : "AWS.EC2.AvailabilityZone"
          name : comp.name
        }

        azMap[ comp.name ] = MC.genResRef(uid, 'name')

      # Generate Component for expanded Asg
      else if comp.type is "AWS.AutoScaling.Group"
        if comp.originalId
          data[ uid ] = {
            type : "ExpandedAsg"
            uid  : uid
          }

    # Fix AZ reference and Change Boolean value
    checkObj = ( obj )->
      for attr, d of obj
        if _.isString( d )
          if d is "true"
            obj[ attr ] = true
          else if d is "false"
            obj[ attr ] = false

          else if azMap[ d ] # Change azName to id
            obj[ attr ] = azMap[ d]

        else if _.isArray( d )
          for dd, idx in d
            if _.isObject( dd )
              checkObj( dd )
            if _.isString( dd )
              if d is "true"
                d[ idx ] = true
              else if d is "false"
                d[ idx ] = false

              else if azMap[ d ] # Change azName to id
                d[ idx ] = azMap[ d]

        else if _.isObject( d )
          checkObj( d )
      null

    for uid, comp of data
      checkObj( comp )

    for az in azArr
      data[ az.uid ] = az
    null

  null
