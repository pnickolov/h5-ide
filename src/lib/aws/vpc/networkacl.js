(function() {
  define(['MC'], function(MC) {
    var getNewACLName;
    getNewACLName = function() {
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
    return {
      getNewACLName: getNewACLName
    };
  });

}).call(this);
