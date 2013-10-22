(function() {
  define(['constant', 'MC'], function(constant, MC) {
    var isNotCIDRConflict, updateRT_SubnetLines;
    isNotCIDRConflict = function(currentCIDR, otherCIDRAry) {
      var noConflict;
      noConflict = true;
      _.each(otherCIDRAry, function(cidrValue) {
        if (MC.aws.subnet.isSubnetConflict(currentCIDR, cidrValue)) {
          return noConflict = false;
        }
      });
      return noConflict;
    };
    updateRT_SubnetLines = function() {
      var asso, comp, connect, connects, exist_connect, id, mainRt, port, portMap, rt, rts, subnets, target_uid, uid, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
      subnets = {};
      rts = [];
      mainRt = null;
      _ref = MC.canvas_data.component;
      for (uid in _ref) {
        comp = _ref[uid];
        if (comp.type === constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet) {
          subnets[uid] = false;
        } else if (comp.type === constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable) {
          rts.push(comp);
          if (comp.resource.AssociationSet.length && "" + comp.resource.AssociationSet[0].Main === "true") {
            mainRt = uid;
          }
        }
      }
      for (_i = 0, _len = rts.length; _i < _len; _i++) {
        rt = rts[_i];
        _ref1 = rt.resource.AssociationSet;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          asso = _ref1[_j];
          if ("" + asso.Main === "true") {
            continue;
          }
          subnets[MC.extractID(asso.SubnetId)] = rt.uid;
        }
      }
      connects = {};
      _ref2 = MC.canvas_data.layout.connection;
      for (uid in _ref2) {
        connect = _ref2[uid];
        if (connect.type !== "association") {
          continue;
        }
        portMap = {};
        _ref3 = connect.target;
        for (id in _ref3) {
          port = _ref3[id];
          portMap[port] = id;
        }
        if (portMap["subnet-assoc-out"] && portMap["rtb-src"]) {
          connects[portMap["subnet-assoc-out"]] = uid;
        }
      }
      for (uid in subnets) {
        target_uid = subnets[uid];
        if (!target_uid) {
          target_uid = mainRt;
        }
        exist_connect = MC.canvas_data.layout.connection[connects[uid]];
        if (exist_connect) {
          if (exist_connect.target[uid] && exist_connect.target[target_uid]) {
            continue;
          } else {
            MC.canvas.remove(document.getElementById(connects[uid]));
          }
        }
        MC.canvas.connect(uid, "subnet-assoc-out", target_uid, 'rtb-src');
      }
      return null;
    };
    return {
      isNotCIDRConflict: isNotCIDRConflict,
      updateRT_SubnetLines: updateRT_SubnetLines
    };
  });

}).call(this);
