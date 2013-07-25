(function() {
  define(['MC'], function(MC) {
    var addInstanceAndAZToELB, init, removeInstanceFromELB, setAllELBSchemeAsInternal;
    init = function(uid) {
      var allComp, haveVPC, igwCompAry;
      allComp = MC.canvas_data.component;
      haveVPC = allComp[uid].resource.VpcId;
      if (!haveVPC) {
        MC.canvas_data.component[uid].resource.Scheme = '';
      }
      igwCompAry = _.filter(allComp, function(obj) {
        return obj.type === 'AWS.VPC.InternetGateway';
      });
      if (igwCompAry.length !== 0) {
        MC.canvas_data.component[uid].resource.Scheme = 'internet-facing';
      }
      return null;
    };
    addInstanceAndAZToELB = function(elbUID, instanceUID) {
      var addAZToElb, addInstanceToElb, currentInstanceAZ, elbAZAry, elbAZAryLength, elbComp, elbInstanceAry, elbInstanceAryLength, instanceComp, instanceRef;
      elbComp = MC.canvas_data.component[elbUID];
      instanceComp = MC.canvas_data.component[instanceUID];
      currentInstanceAZ = instanceComp.resource.Placement.AvailabilityZone;
      instanceUID = instanceComp.uid;
      instanceRef = '@' + instanceUID + '.resource.InstanceId';
      elbInstanceAry = elbComp.resource.Instances;
      elbInstanceAryLength = elbInstanceAry.length;
      elbAZAry = elbComp.resource.AvailabilityZones;
      elbAZAryLength = elbAZAry.length;
      addInstanceToElb = true;
      _.each(elbInstanceAry, function(elem, index) {
        if (elem.InstanceId === instanceRef) {
          addInstanceToElb = false;
          return null;
        }
      });
      if (addInstanceToElb) {
        MC.canvas_data.component[elbUID].resource.Instances.push({
          InstanceId: instanceRef
        });
      }
      addAZToElb = true;
      _.each(elbAZAry, function(elem, index) {
        if (elem === currentInstanceAZ) {
          addAZToElb = false;
          return null;
        }
      });
      if (addAZToElb) {
        MC.canvas_data.component[elbUID].resource.AvailabilityZones.push(currentInstanceAZ);
      }
      return null;
    };
    removeInstanceFromELB = function(elbUID, instanceUID) {
      var elbComp, elbInstanceAry, elbInstanceAryLength, instanceAry, instanceComp, instanceRef, newInstanceAry;
      elbComp = MC.canvas_data.component[elbUID];
      instanceComp = MC.canvas_data.component[instanceUID];
      instanceUID = instanceComp.uid;
      instanceRef = '@' + instanceUID + '.resource.InstanceId';
      elbInstanceAry = elbComp.resource.Instances;
      elbInstanceAryLength = elbInstanceAry.length;
      instanceAry = MC.canvas_data.component[elbUID].resource.Instances;
      newInstanceAry = _.filter(instanceAry, function(value) {
        if (value.InstanceId === instanceRef) {
          return false;
        } else {
          return true;
        }
      });
      MC.canvas_data.component[elbUID].resource.Instances = newInstanceAry;
      return null;
    };
    setAllELBSchemeAsInternal = function() {
      _.each(MC.canvas_data.component, function(value, key) {
        if (value.type === 'AWS.ELB') {
          MC.canvas_data.component[key].resource.Scheme = 'internal';
          MC.canvas.update(key, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNAL_CANVAS);
        }
        return null;
      });
      return null;
    };
    return {
      init: init,
      addInstanceAndAZToELB: addInstanceAndAZToELB,
      removeInstanceFromELB: removeInstanceFromELB,
      setAllELBSchemeAsInternal: setAllELBSchemeAsInternal
    };
  });

}).call(this);
