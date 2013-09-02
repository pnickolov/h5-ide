(function() {
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
        switch (comp.type) {
          case res_type.AWS_EC2_Instance:
            expandInstance(json_data, uid);
            break;
          case res_type.AWS_VPC_NetworkInterface:
            expandENI(json_data, uid);
            break;
          case res_type.AWS_EBS_Volume:
            expandVolume(json_data, uid);
        }
      }
      return json_data;
    };
    expandInstance = function(json_data, uid) {
      var comp_data, i, ins_comp, ins_num, instance_list, new_comp, server_group_name;
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
        }
      } else {
        console.error('[expandInstance] can not found number of instance');
      }
      json_data.layout.component.node[uid].instanceList = instance_list;
      return null;
    };
    expandENI = function(json_data, uid) {
      var comp_data, eni_list, layout_data;
      comp_data = json_data.component;
      layout_data = json_data.layout;
      eni_list = [];
      return null;
    };
    expandVolume = function(json_data, uid) {
      var comp_data, layout_data, volume_list;
      comp_data = json_data.component;
      layout_data = json_data.layout;
      volume_list = [];
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
      var comp_data, comp_uid, i, ins_comp, ins_num, instance_list, new_comp;
      comp_data = json_data.component;
      ins_comp = comp_data[uid];
      ins_comp.name = ins_comp.serverGroupName;
      instance_list = json_data.layout.component.node[uid].instanceList;
      ins_num = ins_comp.number;
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
