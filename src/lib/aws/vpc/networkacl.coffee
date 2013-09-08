define [ 'MC' ], ( MC ) ->

	#private
	getNewName = () ->
		maxNum = 0
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is 'AWS.VPC.NetworkAcl'
				aclName = compObj.name
				if aclName.slice(0, 10) is 'CustomACL-'
					currentNum = Number(aclName.slice(10))
					if currentNum > maxNum
						maxNum = currentNum
			null
		maxNum++
		return 'CustomACL-' + maxNum

	getDefaultACL = () ->

		defaultACLComp = null
		
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is 'AWS.VPC.NetworkAcl'
				aclName = compObj.name
				if aclName is 'DefaultACL'
					defaultACLComp = compObj
					return

		return defaultACLComp

	addAssociationToACL = (subnetUID, aclUID) ->

		aclComp = MC.canvas_data.component[aclUID]

		addToAssociation = true
		_.each aclComp.resource.AssociationSet, (associationObj) ->
			subnetUIDRef = associationObj.SubnetId
			originSubnetUIDRef = '@' + subnetUID + '.resource.SubnetId'
			if subnetUIDRef is originSubnetUIDRef
				addToAssociation = false
				return false

		if addToAssociation
			MC.canvas_data.component[aclUID].resource.AssociationSet.push({
				SubnetId: '@' + subnetUID + '.resource.SubnetId',
				NetworkAclAssociationId: '',
				NetworkAclId: ''
			})

		null

	removeAssociationFromACL = (subnetUID, aclUID) ->

		aclComp = MC.canvas_data.component[aclUID]

		newAssociationSet = _.filter aclComp.resource.AssociationSet, (associationObj) ->
			subnetUIDRef = associationObj.SubnetId
			originSubnetUIDRef = '@' + subnetUID + '.resource.SubnetId'
			if subnetUIDRef is originSubnetUIDRef
				return false
			else
				return true

		MC.canvas_data.component[aclUID].resource.AssociationSet = newAssociationSet

		null

	#public
	getNewName	: getNewName
	getDefaultACL : getDefaultACL
	addAssociationToACL : addAssociationToACL
	removeAssociationFromACL : removeAssociationFromACL