(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['jquery', 'MC', 'constant'], function($, MC, constant) {
    var compactInstance, compactServerGroup, expandENI, expandInstance, expandServerGroup, expandVolume;
    expandServerGroup = function(canvas_data) {
      var comp, comp_data, json_data, layout_data, res_type, uid;
      json_data = $.extend(true, {}, canvas_data);
      comp_data = json_data.component;
      layout_data = json_data.layout;
      res_type = constant.AWS_RESOURCE_TYPE;
      for (uid in comp_data) {
        comp = comp_data[uid];
        if (comp.type === res_type.AWS_EC2_Instance) {
          expandInstance(json_data, uid);
        }
      }
      if (canvas_data.platform !== MC.canvas.PLATFORM_TYPE.EC2_CLASSIC) {
        for (uid in comp_data) {
          comp = comp_data[uid];
          if (comp.type === res_type.AWS_VPC_NetworkInterface) {
            expandENI(json_data, uid);
          }
        }
      }
      for (uid in comp_data) {
        comp = comp_data[uid];
        if (comp.type === res_type.AWS_EBS_Volume) {
          expandVolume(json_data, uid);
        }
      }
      return json_data;
    };
    expandInstance = function(json_data, uid) {
      var comp, comp_data, comp_uid, elb, elbs, i, ins_comp, ins_num, instance_list, instance_reference, new_comp, server_group_name, _i, _len, _ref;
      comp_data = json_data.component;
      ins_comp = comp_data[uid];
      ins_num = ins_comp.number;
      server_group_name = ins_comp.serverGroupName;
      ins_comp.name = server_group_name + '-0';
      instance_list = json_data.layout.component.node[uid].instanceList;
      if (instance_list.length !== ins_num && instance_list > 0) {
        console.error('[expandInstance]instance number not match');
      }
      if (instance_list.length !== ins_num) {
        instance_list = [uid];
        i = 1;
        while (i < ins_num) {
          instance_list[i] = '';
          i++;
        }
      }
      instance_reference = "@" + ins_comp + ".resource.InstanceId";
      elbs = [];
      _ref = MC.canvas_data.component;
      for (comp_uid in _ref) {
        comp = _ref[comp_uid];
        if (comp.type === constant.AWS_RESOURCE_TYPE.AWS_ELB) {
          if (__indexOf.call(comp.resource.Instances, instance_reference) >= 0) {
            elbs.push(comp_uid);
          }
        }
      }
      if (ins_num) {
        i = 1;
        while (i < ins_num) {
          new_comp = $.extend(true, {}, ins_comp);
          if (!instance_list[i]) {
            instance_list[i] = MC.guid();
          }
          new_comp.uid = instance_list[i];
          new_comp.name = server_group_name + '-' + i;
          new_comp.index = i;
          comp_data[new_comp.uid] = new_comp;
          i++;
          if (elbs.length > 0) {
            for (_i = 0, _len = elbs.length; _i < _len; _i++) {
              elb = elbs[_i];
              json_data.component[elb].resource.Instances.push("@" + new_comp.uid + ".resource.InstanceId");
            }
          }
        }
      } else {
        console.error('[expandInstance] can not found number of instance');
      }
      json_data.layout.component.node[uid].instanceList = instance_list;
      return null;
    };
    expandENI = function(json_data, uid) {
      var az, comp_data, eni_comp_number, eni_list, eni_name, eni_number, i, instance_list, instance_uid, layout_data, new_eni_uid, server_group_name, _ref;
      comp_data = json_data.component;
      layout_data = json_data.layout;
      instance_uid = json_data.component[uid].resource.Attachment.InstanceId;
      instance_uid = instance_uid ? instance_uid.split('.')[0].slice(1) : null;
      if (!instance_uid) {
        console.error("Eni(" + uid + ") do not attach to any instance");
      }
      server_group_name = json_data.component[instance_uid].serverGroupName;
      eni_name = json_data.component[uid].name;
      instance_list = json_data.layout.component.node[instance_uid].instanceList;
      eni_number = json_data.component[instance_uid].number;
      if ((_ref = comp_data[uid].resource.Attachment.DeviceIndex) === 0 || _ref === '0') {
        eni_list = json_data.component[instance_uid].eniList = [uid];
      } else {
        eni_list = json_data.layout.component.node[uid].eniList;
      }
      eni_comp_number = eni_list.length;
      if (eni_comp_number > eni_number) {
        i = eni_number;
        while (i > eni_comp_number) {
          eni_list.splice(i - 1, 1);
          i--;
        }
      } else if (eni_number > eni_comp_number) {
        i = 0;
        while (i < eni_number - 1) {
          new_eni_uid = MC.guid();
          eni_list.push(new_eni_uid);
          i++;
        }
      }
      $.each(eni_list, function(idx, eni_uid) {
        var attach_instance, origin_eni, _ref1, _ref2;
        if (!json_data.component[eni_uid]) {
          origin_eni = $.extend(true, {}, json_data.component[uid]);
          origin_eni.uid = eni_uid;
          origin_eni.index = idx;
          origin_eni.number = eni_number;
          origin_eni.serverGroupENIName = eni_name;
          origin_eni.name = (_ref1 = "" + server_group_name + "-" + idx, __indexOf.call(eni_name, _ref1) < 0) ? "" + server_group_name + "-" + idx + "-" + eni_name : eni_name;
          attach_instance = "@" + instance_list[idx] + ".resource.InstanceId";
          origin_eni.resource.Attachment.InstanceId = attach_instance;
          return comp_data[eni_uid] = origin_eni;
        } else {
          json_data.component[eni_uid].name = (_ref2 = "" + server_group_name + "-" + idx, __indexOf.call(json_data.component[eni_uid].name, _ref2) < 0) ? "" + server_group_name + "-" + idx + "-" + eni_name : json_data.component[eni_uid].name;
          return json_data.component[eni_uid].number = eni_number;
        }
      });
      if (MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.DEFAULT_VPC) {
        az = layout_data.groupUId;
        MC.aws.subnet.updateAllENIIPList(az);
      } else {
        MC.aws.subnet.updateAllENIIPList(comp_data[uid].resource.SubnetId.split('.')[0].slice(1));
      }
      return null;
    };
    expandVolume = function(json_data, uid) {
      var comp_data, i, instance_list, instance_uid, layout_data, new_vol_uid, server_group_name, vol_comp_number, vol_list, vol_number;
      comp_data = json_data.component;
      layout_data = json_data.layout;
      instance_uid = json_data.component[uid].resource.AttachmentSet.InstanceId;
      instance_uid = instance_uid ? instance_uid.split('.')[0].slice(1) : null;
      if (!instance_uid) {
        console.error("Volume(" + uid + ") do not attach to any instance");
      }
      server_group_name = json_data.component[instance_uid].serverGroupName;
      instance_list = json_data.layout.component.node[instance_uid].instanceList;
      vol_number = json_data.component[instance_uid].number;
      vol_list = json_data.layout.component.node[instance_uid].volumeList[uid];
      if (!vol_list) {
        vol_list = json_data.layout.component.node[instance_uid].volumeList[uid] = [uid];
      }
      vol_comp_number = vol_list.length;
      if (vol_comp_number > vol_number) {
        i = vol_number;
        while (i > vol_comp_number) {
          vol_list.splice(i - 1, 1);
          i--;
        }
      } else if (vol_number > vol_comp_number) {
        i = 0;
        while (i < vol_number - 1) {
          new_vol_uid = MC.guid();
          vol_list.push(new_vol_uid);
          i++;
        }
      }
      $.each(vol_list, function(idx, vol_uid) {
        var attach_instance, origin_eni, _ref, _ref1;
        if (!json_data.component[vol_uid]) {
          origin_eni = $.extend(true, {}, json_data.component[uid]);
          origin_eni.uid = vol_uid;
          origin_eni.index = idx;
          origin_eni.number = vol_number;
          origin_eni.name = (_ref = "" + server_group_name + "-" + idx, __indexOf.call(origin_eni.name, _ref) < 0) ? "" + server_group_name + "-" + idx + "-" + origin_eni.serverGroupName : origin_eni.name;
          attach_instance = "@" + instance_list[idx] + ".resource.InstanceId";
          origin_eni.resource.AttachmentSet.InstanceId = attach_instance;
          return comp_data[vol_uid] = origin_eni;
        } else {
          json_data.component[vol_uid].name = (_ref1 = "" + server_group_name + "-" + idx, __indexOf.call(json_data.component[vol_uid].name, _ref1) < 0) ? "" + server_group_name + "-" + idx + "-" + json_data.component[vol_uid].serverGroupName : json_data.component[vol_uid].name;
          return json_data.component[vol_uid].number = vol_number;
        }
      });
      return null;
    };
    compactServerGroup = function(canvas_data) {
      var comp, comp_data, json_data, layout_data, res_type, uid;
      json_data = $.extend(true, {}, canvas_data);
      comp_data = json_data.component;
      layout_data = json_data.layout;
      res_type = constant.AWS_RESOURCE_TYPE;
      for (uid in comp_data) {
        comp = comp_data[uid];
        switch (comp.type) {
          case res_type.AWS_EC2_Instance:
            if (comp.number > 1 && comp.index === 0) {
              compactInstance(json_data, uid);
            }
        }
      }
      return json_data;
    };
    compactInstance = function(json_data, uid) {
      var comp, comp_data, comp_uid, eni_list, i, ins_comp, ins_num, instance_id, instance_list, instance_ref_list, new_comp, vol_data, vol_list, vol_uid, _i, _len, _ref, _ref1, _ref2;
      comp_data = json_data.component;
      ins_comp = comp_data[uid];
      ins_comp.name = ins_comp.serverGroupName;
      instance_list = json_data.layout.component.node[uid].instanceList;
      eni_list = json_data.layout.component.node[uid].eniList;
      vol_list = json_data.layout.component.node[uid].volumeList;
      ins_num = ins_comp.number;
      if (instance_list.length !== ins_num && instance_list > 0) {
        console.error('[expandInstance]instance number not match');
      }
      instance_ref_list = [];
      for (_i = 0, _len = instance_list.length; _i < _len; _i++) {
        instance_id = instance_list[_i];
        if (instance_id !== uid) {
          instance_ref_list.push("@" + instance_id + ".resource.InstanceId");
        }
      }
      for (comp_uid in comp_data) {
        comp = comp_data[comp_uid];
        if (comp.type === constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface && ((_ref = comp.resource.Attachment.DeviceIndex) === 0 || _ref === '0') && (_ref1 = comp.resource.Attachment.InstanceId, __indexOf.call(instance_ref_list, _ref1) >= 0)) {
          delete comp_data[comp_uid];
        }
      }
      for (vol_uid in vol_list) {
        vol_data = vol_list[vol_uid];
        if (comp.type === constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume && (_ref2 = comp.resource.AttachmentSet.InstanceId, __indexOf.call(instance_ref_list, _ref2) >= 0)) {
          delete comp_data[comp_uid];
        }
      }
      if (instance_list.length !== ins_num) {
        instance_list = [uid];
        i = 1;
        while (i < ins_num) {
          instance_list[i] = '';
          i++;
        }
      }
      if (ins_num) {
        i = 1;
        while (i < ins_num) {
          new_comp = $.extend(true, {}, ins_comp);
          if (!instance_list[i]) {
            instance_list[i] = MC.guid();
          } else {
            comp_uid = instance_list[i];
            if (comp_data[comp_uid]) {
              delete comp_data[comp_uid];
            }
          }
          i++;
        }
      } else {
        console.error('[compactInstance] can not found number of instance');
      }
      return null;
    };
    return {
      expandServerGroup: expandServerGroup,
      compactServerGroup: compactServerGroup
    };
  });

}).call(this);
