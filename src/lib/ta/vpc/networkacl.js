(function() {
  define(['MC'], function(MC) {
    var addAssociationToACL, addAssociationToDefaultACL, addRelatedSubnetToDefaultACL, getDefaultACL, getNewName, removeAssociationFromACL;
    getNewName = function() {
      var maxNum;
      maxNum = 0;
      _.each(MC.canvas_data.component, function(compObj) {
        var aclName, compType, currentNum;
        compType = compObj.type;
        if (compType === 'AWS.VPC.NetworkAcl') {
          aclName = compObj.name;
          if (aclName.slice(0, 10) === 'CustomACL-') {
            currentNum = Number(aclName.slice(10));
            if (currentNum > maxNum) {
              maxNum = currentNum;
            }
          }
        }
        return null;
      });
      maxNum++;
      return 'CustomACL-' + maxNum;
    };
    getDefaultACL = function() {
      var defaultACLComp;
      defaultACLComp = null;
      _.each(MC.canvas_data.component, function(compObj) {
        var aclName, compType;
        compType = compObj.type;
        if (compType === 'AWS.VPC.NetworkAcl') {
          aclName = compObj.name;
          if (aclName === 'DefaultACL') {
            defaultACLComp = compObj;
          }
        }
      });
      return defaultACLComp;
    };
    addAssociationToACL = function(subnetUID, aclUID) {
      var aclComp, addToAssociation;
      aclComp = MC.canvas_data.component[aclUID];
      addToAssociation = true;
      _.each(aclComp.resource.AssociationSet, function(associationObj) {
        var originSubnetUIDRef, subnetUIDRef;
        subnetUIDRef = associationObj.SubnetId;
        originSubnetUIDRef = '@' + subnetUID + '.resource.SubnetId';
        if (subnetUIDRef === originSubnetUIDRef) {
          addToAssociation = false;
          return false;
        }
      });
      if (addToAssociation) {
        MC.canvas_data.component[aclUID].resource.AssociationSet.push({
          SubnetId: '@' + subnetUID + '.resource.SubnetId',
          NetworkAclAssociationId: '',
          NetworkAclId: ''
        });
      }
      return null;
    };
    removeAssociationFromACL = function(subnetUID, aclUID) {
      var aclComp, newAssociationSet;
      aclComp = MC.canvas_data.component[aclUID];
      newAssociationSet = _.filter(aclComp.resource.AssociationSet, function(associationObj) {
        var originSubnetUIDRef, subnetUIDRef;
        subnetUIDRef = associationObj.SubnetId;
        originSubnetUIDRef = '@' + subnetUID + '.resource.SubnetId';
        if (subnetUIDRef === originSubnetUIDRef) {
          return false;
        } else {
          return true;
        }
      });
      MC.canvas_data.component[aclUID].resource.AssociationSet = newAssociationSet;
      return null;
    };
    addAssociationToDefaultACL = function(subnetUID) {
      var defaultACLComp, defaultACLUID;
      defaultACLComp = MC.aws.acl.getDefaultACL();
      defaultACLUID = defaultACLComp.uid;
      return MC.aws.acl.addAssociationToACL(subnetUID, defaultACLUID);
    };
    addRelatedSubnetToDefaultACL = function(aclUID) {
      var aclComp, defaultACLComp, defaultACLUID;
      aclComp = MC.canvas_data.component[aclUID];
      defaultACLComp = MC.aws.acl.getDefaultACL();
      defaultACLUID = defaultACLComp.uid;
      return _.each(aclComp.resource.AssociationSet, function(associationObj) {
        var subnetUID, subnetUIDRef;
        subnetUIDRef = associationObj.SubnetId;
        subnetUID = subnetUIDRef.split('.')[0].slice(1);
        MC.aws.acl.addAssociationToACL(subnetUID, defaultACLUID);
        return null;
      });
    };
    return {
      getNewName: getNewName,
      getDefaultACL: getDefaultACL,
      addAssociationToACL: addAssociationToACL,
      removeAssociationFromACL: removeAssociationFromACL,
      addAssociationToDefaultACL: addAssociationToDefaultACL,
      addRelatedSubnetToDefaultACL: addRelatedSubnetToDefaultACL
    };
  });

}).call(this);
