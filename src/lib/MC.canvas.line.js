/*
#**********************************************************
#* Filename: MC.canvas.line.js
#* Creator: Ken
#* Description: The core of the whole system
#* Date: 20130827
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

MC.canvas.initLine = function() {
  var lines, main_rt, subnet_ids;
  subnet_ids = [];
  lines = [];
  main_rt = null;
  $.each(MC.canvas_data.component, function(comp_uid, comp) {
    if (comp.type === 'AWS.VPC.RouteTable') {
      if (comp.resource.AssociationSet.length && "" + comp.resource.AssociationSet[0].Main === 'true') {
        main_rt = comp_uid;
      }
      $.each(comp.resource.AssociationSet, function(idx, asso) {
        var subnet_id;
        if (asso.SubnetId) {
          subnet_id = asso.SubnetId.split('.')[0].slice(1);
          subnet_ids.push(subnet_id);
          return lines.push([subnet_id, comp_uid, 'subnet-assoc-out', 'rtb-src']);
        }
      });
      return $.each(comp.resource.RouteSet, function(idx, route) {
        var gateway_port, rtb_port;
        if (route.InstanceId) {
          lines.push([route.InstanceId.split('.')[0].slice(1), comp_uid, 'instance-rtb', 'rtb-tgt']);
        }
        if (route.GatewayId && route.GatewayId !== 'local') {
          gateway_port = null;
          rtb_port = null;
          if (route.GatewayId.indexOf('Internet') >= 0) {
            gateway_port = 'igw-tgt';
            rtb_port = 'rtb-tgt';
          } else {
            gateway_port = 'vgw-tgt';
            rtb_port = 'rtb-tgt';
          }
          lines.push([route.GatewayId.split('.')[0].slice(1), comp_uid, gateway_port, rtb_port]);
        }
        if (route.NetworkInterfaceId) {
          return lines.push([route.NetworkInterfaceId.split('.')[0].slice(1), comp_uid, 'eni-rtb', 'rtb-tgt']);
        }
      });
    }
  });
  $.each(MC.canvas_data.component, function(comp_uid, comp) {
    var expand_asg;
    if (comp.type === 'AWS.VPC.Subnet' && (__indexOf.call(subnet_ids, comp_uid) < 0)) {
      lines.push([comp_uid, main_rt, 'subnet-assoc-out', 'rtb-src']);
    }
    if (comp.type === "AWS.VPC.VPNConnection") {
      lines.push([comp.resource.CustomerGatewayId.split('.')[0].slice(1), comp.resource.VpnGatewayId.split('.')[0].slice(1), 'cgw-vpn', 'vgw-vpn']);
    }
    if (comp.type === "AWS.ELB") {
      $.each(comp.resource.Instances, function(i, instance) {
        return lines.push([comp_uid, instance.InstanceId.split('.')[0].slice(1), 'elb-sg-out', 'instance-sg']);
      });
      $.each(comp.resource.Subnets, function(i, subnet_id) {
        return lines.push([comp_uid, subnet_id.split('.')[0].slice(1), 'elb-assoc', 'subnet-assoc-in']);
      });
    }
    if (comp.type === "AWS.AutoScaling.Group") {
      expand_asg = [];
      $.each(MC.canvas_data.layout.component.node, function(c, node) {
        if (node.type === "AWS.AutoScaling.LaunchConfiguration" && node.groupUId === comp_uid) {
          return expand_asg.push(c);
        }
      });
      $.each(MC.canvas_data.layout.component.group, function(c, g) {
        if (g.type === "AWS.AutoScaling.Group" && g.originalId && g.originalId === comp_uid) {
          return expand_asg.push(c);
        }
      });
      $.each(expand_asg, function(i, asg) {
        return $.each(comp.resource.LoadBalancerNames, function(j, elb) {
          return lines.push([asg, elb.split('.')[0].slice(1), 'launchconfig-sg', 'elb-sg-out']);
        });
      });
    }
    if (comp.type === "AWS.VPC.NetworkInterface" && comp.resource.Attachment.InstanceId && comp.resource.Attachment.DeviceIndex !== '0' && comp.resource.Attachment.DeviceIndex !== 0) {
      return lines.push([comp_uid, comp.resource.Attachment.InstanceId.split('.')[0].slice(1), 'eni-attach', 'instance-attach']);
    }
  });
  return $.each(lines, function(idx, line_data) {
    return MC.canvas.connect($("#" + line_data[0]), line_data[2], $("#" + line_data[1]), line_data[3]);
  });
}

MC.canvas.reDrawSgLine = function() {
  var lines, sg_refs;
  lines = [];
  sg_refs = [];
  $.each(MC.canvas_data.component, function(comp_uid, comp) {
    if (comp.type === "AWS.EC2.SecurityGroup") {
      $.each(comp.resource.IpPermissions, function(i, rule) {
        var from_key, to_key, to_sg_uid;
        if (rule.IpRanges.indexOf('@') >= 0) {
          to_sg_uid = rule.IpRanges.split('.')[0].slice(1);
          if (to_sg_uid !== comp.uid) {
            from_key = comp.uid + '|' + to_sg_uid;
            to_key = to_sg_uid + '|' + comp.uid;
            if ((__indexOf.call(sg_refs, from_key) < 0) && (__indexOf.call(sg_refs, to_key) < 0)) {
              return sg_refs.push(from_key);
            }
          }
        }
      });
      return $.each(comp.resource.IpPermissionsEgress, function(i, rule) {
        var from_key, to_key, to_sg_uid;
        if (rule.IpRanges.indexOf('@') >= 0) {
          to_sg_uid = rule.IpRanges.split('.')[0].slice(1);
          if (to_sg_uid !== comp.uid) {
            from_key = comp.uid + '|' + to_sg_uid;
            to_key = to_sg_uid + '|' + comp.uid;
            if ((__indexOf.call(sg_refs, from_key) < 0) && (__indexOf.call(sg_refs, to_key) < 0)) {
              return sg_refs.push(to_key);
            }
          }
        }
      });
    }
  });
  $.each(sg_refs, function(i, val) {
    var from_sg_group, from_sg_uid, to_sg_group, to_sg_uid, uids;
    uids = val.split('|');
    from_sg_uid = uids[0];
    to_sg_uid = uids[1];
    from_sg_group = [];
    to_sg_group = [];
    $.each(MC.canvas_data.component, function(comp_uid, comp) {
      switch (comp.type) {
        case "AWS.EC2.Instance":
          if (MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.EC2_CLASSIC) {
            return $.each(comp.resource.SecurityGroupId, function(idx, sgs) {
              if (sgs.split('.')[0].slice(1) === from_sg_uid) {
                from_sg_group.push(comp.uid);
              }
              if (sgs.split('.')[0].slice(1) === to_sg_uid) {
                return to_sg_group.push(comp.uid);
              }
            });
          }
          break;
        case "AWS.VPC.NetworkInterface":
          return $.each(comp.resource.GroupSet, function(idx, sgs) {
            if (sgs.GroupId.split('.')[0].slice(1) === from_sg_uid) {
              if (comp.resource.Attachment.DeviceIndex !== "0") {
                from_sg_group.push(comp.uid);
              } else {
                from_sg_group.push(comp.resource.Attachment.InstanceId.split('.')[0].slice(1));
              }
            }
            if (sgs.GroupId.split('.')[0].slice(1) === to_sg_uid) {
              if (comp.resource.Attachment.DeviceIndex !== "0") {
                return to_sg_group.push(comp.uid);
              } else {
                return to_sg_group.push(comp.resource.Attachment.InstanceId.split('.')[0].slice(1));
              }
            }
          });
        case "AWS.ELB":
          if (MC.canvas_data.platform !== MC.canvas.PLATFORM_TYPE.EC2_CLASSIC) {
            return $.each(comp.resource.SecurityGroups, function(idx, sgs) {
              if (sgs.split('.')[0].slice(1) === from_sg_uid) {
                from_sg_group.push(comp.uid);
              }
              if (sgs.split('.')[0].slice(1) === to_sg_uid) {
                return to_sg_group.push(comp.uid);
              }
            });
          }
          break;
        case "AWS.AutoScaling.LaunchConfiguration":
          return $.each(comp.resource.SecurityGroups, function(idx, sgs) {
            var asg_uid;
            if (sgs.split('.')[0].slice(1) === from_sg_uid) {
              from_sg_group.push(comp.uid);
              asg_uid = MC.canvas_data.layout.component.node[comp.uid].groupUId;
              $.each(MC.canvas_data.layout.component.group, function(group_id, group) {
                if (group.type === "AWS.AutoScaling.Group" && group.originalId && group.originalId === asg_uid) {
                  return from_sg_group.push(group_id);
                }
              });
            }
            if (sgs.split('.')[0].slice(1) === to_sg_uid) {
              to_sg_group.push(comp.uid);
              asg_uid = MC.canvas_data.layout.component.node[comp.uid].groupUId;
              return $.each(MC.canvas_data.layout.component.group, function(group_id, group) {
                if (group.type === "AWS.AutoScaling.Group" && group.originalId && group.originalId === asg_uid) {
                  return to_sg_group.push(group_id);
                }
              });
            }
          });
      }
    });
    return $.each(from_sg_group, function(i, from_comp_uid) {
      return $.each(to_sg_group, function(i, to_comp_uid) {
        var existing, from_port, to_port;
        if (from_comp_uid !== to_comp_uid) {
          from_port = null;
          to_port = null;
          if (MC.canvas_data.component[from_comp_uid]) {
            switch (MC.canvas_data.component[from_comp_uid].type) {
              case "AWS.EC2.Instance":
                from_port = 'instance-sg';
                break;
              case "AWS.VPC.NetworkInterface":
                from_port = 'eni-sg';
                break;
              case "AWS.ELB":
                if (MC.canvas_data.component[from_comp_uid].resource.Scheme === 'internet-facing') {
                  return;
                }
                from_port = 'elb-sg-in';
                break;
              case "AWS.AutoScaling.LaunchConfiguration":
                from_port = 'launchconfig-sg';
            }
          } else {
            from_port = 'launchconfig-sg';
          }
          if (MC.canvas_data.component[to_comp_uid]) {
            switch (MC.canvas_data.component[to_comp_uid].type) {
              case "AWS.EC2.Instance":
                to_port = 'instance-sg';
                break;
              case "AWS.VPC.NetworkInterface":
                to_port = 'eni-sg';
                break;
              case "AWS.ELB":
                if (MC.canvas_data.component[to_comp_uid].resource.Scheme === 'internet-facing') {
                  return;
                }
                to_port = 'elb-sg-in';
                break;
              case "AWS.AutoScaling.LaunchConfiguration":
                to_port = 'launchconfig-sg';
            }
          } else {
            to_port = 'launchconfig-sg';
          }
          if ((from_port === to_port && to_port === 'launchconfig-sg')) {
            existing = false;
            $.each(MC.canvas_data.layout.component.group, function(comp_uid, comp) {
              if (comp.type === "AWS.AutoScaling.Group" && comp.originalId && ((comp.originalId === from_comp_uid && comp_uid === to_comp_uid) || (comp.originalId === to_comp_uid && comp_uid === from_comp_uid))) {
                existing = true;
                return false;
              }
            });
            if (!existing) {
              return lines.push([from_comp_uid, to_comp_uid, from_port, to_port]);
            }
          } else if ((from_port === 'instance-sg' && to_port === 'eni-sg') || (from_port === 'eni-sg' && to_port === 'instance-sg')) {
            if (MC.canvas_data.component[from_comp_uid].type === "AWS.EC2.Instance" && MC.canvas_data.component[to_comp_uid].resource.Attachment.InstanceId.split('.')[0].slice(1) !== from_comp_uid) {
              return lines.push([from_comp_uid, to_comp_uid, from_port, to_port]);
            } else if (MC.canvas_data.component[to_comp_uid].type === "AWS.EC2.Instance" && MC.canvas_data.component[from_comp_uid].resource.Attachment.InstanceId.split('.')[0].slice(1) !== to_comp_uid) {
              return lines.push([from_comp_uid, to_comp_uid, from_port, to_port]);
            }
          } else {
            return lines.push([from_comp_uid, to_comp_uid, from_port, to_port]);
          }
        }
      });
    });
  });
  $.each(MC.canvas_data.layout.connection, function(line_id, line) {
    if (line.type === 'sg' && $("#" + line_id)[0] !== void 0) {
      return MC.canvas.remove($("#" + line_id)[0]);
    }
  });
  $.each(lines, function(idx, line_data) {
    return MC.canvas.connect($("#" + line_data[0]), line_data[2], $("#" + line_data[1]), line_data[3]);
  });
  return lines;
};