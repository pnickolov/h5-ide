# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =

  CANVAS:

    WARN_NOTMATCH_VOLUME:
      en: "Volumes and snapshots must be dragged to an instance or image."
      zh: "卷和快照必须拖放到实例或映像。"

    ERR_SERVERGROUP_VOLUME:
      en: "Detach existing volume or snapshot of instance server group is not supported yet."
      zh: "Detach existing volume or snapshot of instance server group is not supported yet."

    ERR_SERVERGROUP_VOLUME2:
      en: "Attach existing volume from single instance to instance server group is not supported yet."
      zh: "Attach existing volume from single instance to instance server group is not supported yet."

    WARN_NOTMATCH_SUBNET:
      en: "Subnets must be dragged to an availability zone."
      zh: "子网必须拖放到可用区域。"

    WARN_NOTMATCH_INSTANCE_SUBNET:
      en: "Instances must be dragged to a subnet or auto scaling group."
      zh: "实例必须拖放到子网或Auto Scaling组。"

    WARN_NOTMATCH_SGP_VPC:
      en: "Subnet Group must be dragged to a vpc."
      zh: ""

    WARN_NOTMATCH_DBINSTANCE_SGP:
      en: "DB Instance must be dragged to a subnet group."
      zh: ""

    WARN_NOTMATCH_ASG:
      en: "Auto Scaling Group must be dropped in a subnet."
      zh: "Auto Scaling组必须拖放到子网。"

    WARN_NOTMATCH_ENI:
      en: "Network interfaces must be dragged to a subnet."
      zh: "网络接口必须拖放到子网。"

    WARN_NOTMATCH_RTB:
      en: "Route tables must be dragged inside a VPC but outside an availability zone."
      zh: "路由表必须拖放到可用区域外的VPC部分。"

    WARN_NOTMATCH_ELB:
      en: "Load balancer must be dropped outside availability zone."
      zh: "负载均衡器必须拖放到可用区域以外。"

    WARN_NOTMATCH_CGW:
      en: "Customer gateways must be dragged outside the VPC."
      zh: "客户网关必须拖放到VPC以外。"

    WARN_NOTMATCH_IGW:
      en: "Internet gateways must be dragged inside a VPC."
      zh: "互联网网关必须拖放到VPC里。"

    WARN_NOTMATCH_VGW:
      en: "Virtual private gateways must be dragged inside a VPC."
      zh: "虚拟私有网关必须拖放到VPC里。"

    WARN_COMPONENT_OVERLAP:
      en: "Nodes cannot overlap each other."
      zh: "节点不能互相重叠。"

    WARN_NO_ENOUGH_SPACE:
      en: "No enough space."
      zh: "没有多余的空间。"

    WARN_NOTMATCH_SERVER:
      en: "Server must be dropped within subnet."
      zh: "Server must be dropped within subnet."

    WARN_NOTMATCH_OSVOL:
      en: "Volume must be dropped on to server."
      zh: "Volume must be dropped on to server."

    WARN_NOTMATCH_ROUTER:
      en: "Router must be dropped outside network."
      zh: "Router must be dropped outside network."

    WARN_NOTMATCH_LB:
      en: "Load balancer must be dropped within subnet."
      zh: "Load balancer must be dropped within subnet."

    WARN_NOTMATCH_POOL:
      en: "Pool must be dropped within subnet."
      zh: "Pool must be dropped within subnet."

    WARN_NOTMATCH_LISTENER:
      en: "Listener must be dropped within subnet."
      zh: "Listener must be dropped within subnet."

    WARN_NOTMATCH_OSSUBNET:
      en: "Subnet must be dropped within network."
      zh: "Subnet must be dropped within network."

    CVS_WARN_EXCEED_ENI_LIMIT:
      en: "%s's type %s supports a maximum of %s network interfaces (including the primary)."
      zh: "%s 的 %s 最多支持%s个网络接口 (包括主要的)。"

    WARN_CANNOT_CONNECT_SUBNET_TO_ELB:
      en: "This subnet cannot be attached with a Load Balancer. Its CIDR mask must be smaller than /27"
      zh: ""

    ERR_CONNECT_ENI_AMI:
      en: "Network interfaces can only be attached to an instance in the same availability zone."
      zh: "网络接口只能连接到同一个可用区域的实例。"

    ERR_MOVE_ATTACHED_ENI:
      en: "Network interfaces must be in the same availability zone as the instance they are attached to."
      zh: "网络接口必须跟它附加的实例在同一个可用区域。"

    ERR_DROP_ASG:
      en: "%s is already in %s."
      zh: "%s已经存在于%s中。"

    ERR_DEL_LC:
      en: "Currently modifying the launch configuration is not supported."
      zh: "目前还不支持修改启动配置。"

    ERR_DEL_MAIN_RT:
      en: "The main route table %s cannot be deleted. Please set another route table as the main and try again."
      zh: "主路由表：%s 不能被删除。 请将其他路由表设为主路由表后再重试。"

    ERR_DEL_LINKED_RT:
      en: "Subnets must be associated to a route table. Please associate the subnets with another route table first."
      zh: "子网必须与路由表关联，请先将这个子网与一个路由表关联起来。"

    ERR_DEL_SBRT_LINE:
      en: "Subnets must be associated with a route table."
      zh: "子网必须与路由表关联。"

    ERR_DEL_ELB_LINE_1:
      en: "Load Balancer must associate with at least 1 subnet for each Availability Zone where it has registered load balanced instances."
      zh: "负载均衡器至少需要连接一个子网。"

    ERR_DEL_ELB_LINE_2:
      en: "Cannot delete or change the current attachment."
      zh: "最少要保留一条已有的负载均衡器和子网的连线。"

    ERR_DEL_LINKED_ELB:
      en: "This subnet cannot be deleted because it is associated to a load balancer."
      zh: "由于这个子网关联着负载均衡器，所以它不能被删除。"

    CVS_CFM_DEL:
      en: "Delete %s"
      zh: "删除 %s"

    CVS_CFM_DEL_IGW:
      en: "Internet-facing load balancer or public IP requires internet gateway to function."
      zh: "面向互联网的负载均衡器和公网IP需要一个互联网网关才能工作。"

    CVS_CFM_DEL_GROUP:
      en: "Deleting %s will also remove all resources inside it. Are you sure you want to delete it?"
      zh: "删除 %s 会同时删除其中的所有资源， 确定要删除它吗？"

    CVS_CFM_DEL_LC:
      en: "Are you sure to delete launch configuration %s?"
      zh: ""

    CVS_CFM_DEL_ASG:
      en: "Launch configuration %s is only used by %s. By deleting %s, %s will also be deleted.<br/>Are you sure to delete asg0?"
      zh: ""

    CVS_CFM_ADD_IGW:
      en: "An Internet Gateway is Required"
      zh: "必须要有一个互联网网关"

    CVS_CFM_ADD_IGW_MSG:
      en: "Automatically add an internet gateway for using Elastic IP or public IP"
      zh: "为设置EIP，自动添加了一个互联网网关"

    CVS_CFM_DEL_NONEXISTENT_DBINSTANCE:
      en: "Deleting <span class='resource-tag'>%s</span> will remove all read replica related to it. Are you sure to continue?"
      zh: "%s 未创建,删除它会同时删除与之相关的所有只读副本，确定要删除它吗？"

    CVS_CFM_DEL_EXISTENT_DBINSTANCE:
      en: "<span class='resource-tag'>%s</span> is a live resource. Deleting it will remove not-yet-created read replica, but keep existing ones. Are you sure to continue?"
      zh: "%s已存在，删除它会同时删除与之相关的只读副本，但会保留，确定要删除它吗？"

    ERR_ZOOMED_DROP_ERROR:
      en: "Please reset the zoom to 100% before adding new resources."
      zh: "在添加新资源前，请重设缩放至100%。"

    CVS_TIP_EXPAND_W:
      en: "Increase Canvas Width"
      zh: "增加画板宽度"

    CVS_TIP_SHRINK_W:
      en: "Decrease Canvas Width"
      zh: "减少画板宽度"

    CVS_TIP_EXPAND_H:
      en: "Increase Canvas Height"
      zh: "增加画板高度"

    CVS_TIP_SHRINK_H:
      en: "Decrease Canvas Height"
      zh: "减少画板宽度"

    CVS_TIP_ASG_DRAGGER:
      en: "Expand the group by drag-and-drop in other availability zone."
      zh: ""

    CVS_NO_SUBNET_ASSIGNED_TO_SG:
      en: "No subnet is assigned to this subnet group yet"
      zh: ""

    CVS_POP_ATTACHED_VOLUMES:
      en: "Attached Volumes"
      zh: ""

    CVS_POP_NO_ATTACHED_VOLUME:
      en: "No Attached Volumes"
      zh: ""

    CVS_POP_NO_INSTANCES:
      en: "No instances"
      zh: ""

    CVS_POP_NO_NETWORK_INTERFACE:
      en: "No network interface"
      zh: ""

    CVS_ASG_DROP_LC_1:
      en: "Drop AMI from"
      zh: ""

    CVS_ASG_DROP_LC_2:
      en: "resource panel to"
      zh: ""

    CVS_ASG_DROP_LC_3:
      en: "create launch"
      zh: ""

    CVS_ASG_DROP_LC_4:
      en: "configuration"
      zh: ""

    ATTACH_NETWORK_INTERFACE_TO_INTERFACE:
      en: "Attach Network Interface to Instance"
      zh: ""

    ATTACH_AND_REMOVE_PUBLIC_IP:
      en: "Attach and Remove Public IP"
      zh: ""

    NETWORK_INTERFACE_ATTACHED_INTERFACE_NO_NEED_FOR_SG_RULE:
      en: "The Network Interface is attached to the instance. No need to connect them by security group rule."
      zh: ""

