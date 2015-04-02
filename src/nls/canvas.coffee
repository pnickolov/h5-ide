# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =

  CANVAS:

    WARN_NOTMATCH_VOLUME:
      en: "Volumes and snapshots must be dragged to an instance or image."
      zh: "卷和快照必须拖放到实例或 AMI。"

    ERR_SERVERGROUP_VOLUME:
      en: "Detach existing volume or snapshot of instance server group is not supported yet."
      zh: "目前尚不支持断开实例组上已存在的卷或快照"

    ERR_SERVERGROUP_VOLUME2:
      en: "Attach existing volume from single instance to instance server group is not supported yet."
      zh: "目前尚不支持把单独实例上已存在的卷连接到实例组的操作"

    WARN_NOTMATCH_SUBNET:
      en: "Subnets must be dragged to an availability zone."
      zh: "子网必须拖放到可用区域。"

    WARN_NOTMATCH_INSTANCE_SUBNET:
      en: "Instances must be dragged to a subnet or auto scaling group."
      zh: "实例必须拖放到子网或Auto Scaling组。"

    WARN_NOTMATCH_SGP_VPC:
      en: "Subnet Group must be dragged to a VPC."
      zh: "子网组必须拖放到 VPC 中"

    WARN_NOTMATCH_DBINSTANCE_SGP:
      en: "DB Instance must be dragged to a subnet group."
      zh: "数据库实例必须拖放到子网组中"

    WARN_NOTMATCH_ASG:
      en: "Auto Scaling Group must be dropped in a subnet."
      zh: "Auto Scaling 组必须拖放到子网。"

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
      zh: "除非此子网的CIDR小于/27，否则该子网不能连接负载均衡器"

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
      zh: "确定要删除启动配置 %s？"

    CVS_CFM_ADD_IGW:
      en: "An Internet Gateway is Required"
      zh: "必须要有一个互联网网关"

    CVS_CFM_ADD_IGW_MSG:
      en: "Automatically add an internet gateway for using Elastic IP or public IP"
      zh: "为设置EIP或公网IP，自动添加了一个互联网网关"

    CVS_CFM_DEL_NONEXISTENT_DBINSTANCE:
      en: "Deleting <span class='resource-tag'>%s</span> will remove all read replica related to it. Are you sure to continue?"
      zh: "%s 未创建，删除它会同时删除与之相关的所有只读副本，确定要删除它吗？"

    CVS_CFM_DEL_EXISTENT_DBINSTANCE:
      en: "<span class='resource-tag'>%s</span> is a live resource. Deleting it will remove not-yet-created read replica, but keep existing ones. Are you sure to continue?"
      zh: "%s已存在，删除它会同时删除与之相关的只读副本，但会保留，确定要删除它吗？"

    CVS_CFM_DEL_RELATED_RESTORE_DBINSTANCE:
      en: "You are going to restore DB instance <span class='resource-tag'>%s</span> to a point in time. By deleting it, restored DB instance %s will be deleted too. Are you sure to continue?"
      zh: "您将要还原数据库实例 <span class='resource-tag'>%s</span> 到一个时间点，如果删除此数据库实例即将还原的数据库实例也将被删除。要继续吗？"

    ERR_ZOOMED_DROP_ERROR:
      en: "Please reset the zoom to 100% before adding new resources."
      zh: "在添加新资源前，请重设缩放至100%。"

    CVS_TIP_EXPAND_W:
      en: "Increase Canvas Width"
      zh: "增加画布宽度"

    CVS_TIP_SHRINK_W:
      en: "Decrease Canvas Width"
      zh: "减少画布宽度"

    CVS_TIP_EXPAND_H:
      en: "Increase Canvas Height"
      zh: "增加画布高度"

    CVS_TIP_SHRINK_H:
      en: "Decrease Canvas Height"
      zh: "减少画布宽度"

    CVS_TIP_ASG_DRAGGER:
      en: "Expand the group by drag-and-drop in other availability zone."
      zh: "拖放到其他可用区来扩展该Auto Scaling组。"

    CVS_NO_SUBNET_ASSIGNED_TO_SG:
      en: "No subnet is assigned to this subnet group yet"
      zh: "无子网"

    CVS_POP_ATTACHED_VOLUMES:
      en: "Attached Volumes"
      zh: "已连接的卷"

    CVS_POP_NO_ATTACHED_VOLUME:
      en: "No Attached Volumes"
      zh: "没有被连接的卷"

    CVS_POP_NO_INSTANCES:
      en: "No instances"
      zh: "没有实例"

    CVS_POP_NO_NETWORK_INTERFACE:
      en: "No network interface"
      zh: "没有网络接口"

    CVS_ASG_DROP_LC_1:
      en: "Drop AMI from"
      zh: "从资源面板拖放"

    CVS_ASG_DROP_LC_2:
      en: "resource panel to"
      zh: "AMI来创建"

    CVS_ASG_DROP_LC_3:
      en: "create launch"
      zh: "启动配置"

    CVS_ASG_DROP_LC_4:
      en: "configuration"
      zh: " "

    ATTACH_NETWORK_INTERFACE_TO_INTERFACE:
      en: "Attach Network Interface to Instance"
      zh: "连接网络接口到实例"

    ATTACH_AND_REMOVE_PUBLIC_IP:
      en: "Attach and Remove Public IP"
      zh: "连接并且删除公有IP"

    NETWORK_INTERFACE_ATTACHED_INTERFACE_NO_NEED_FOR_SG_RULE:
      en: "The Network Interface is attached to the instance. No need to connect them by security group rule."
      zh: "此网络接口已连接到实例，不必用安全组连接。"

    LAUNCH_CONFIGURATION_MUST_BE_CREATED_FROM_AMI_IN_RESOURCE_PANEL:
      en: "Launch Configuration must be created from AMI in Resource Panel"
      zh: "启动配置只能从通过资源面板拖拽 AMI 来创建"

    DETACH_ELASTIC_IP_FROM_PRIMARY_IP:
      en: "Detach Elastic IP from primary IP"
      zh: "取消关联弹性 IP"

    ASSOCIATE_ELASTIC_IP_TO_PRIMARY_IP:
      en: "Associate Elastic IP to primary IP"
      zh: "关联弹性 IP"

    MASTER_NODE_CANNOT_BE_DELETED:
      en: "Master node cannot be deleted."
      zh: "Master node 不能删除。"









