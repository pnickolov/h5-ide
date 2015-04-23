# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =

  PARSLEY:
    THIS_VALUE_IS_REQUIRED:
      en: "This value is required."
      zh: "此字段必填。"

    MUST_BE_A_VALID_FORMAT_OF_NUMBER:
      en: "Must be a valid format of number."
      zh: "请输入合法的数字。"

    THE_PROTOCOL_NUMBER_RANGE_MUST_BE_0_255:
      en: "The protocol number range must be 0-255."
      zh: "协议号必须在0-255范围之内。"

    MUST_BE_A_VALID_FORMAT_OF_PORT_RANGE:
      en: "Must be a valid format of port range."
      zh: "请输入合法的端口号。"

    PORT_RANGE_BETWEEN_0_65535:
      en: "Port range needs to be a number or a range of numbers between 0 and 65535."
      zh: "端口范围必须是一个在0-65535范围内的数字或者范围。"

    VALID_RULE_NUMBER_1_TO_32767:
      en: "Valid rule number must be between 1 to 32767."
      zh: "请输入1-32767之间的数字"

    RULE_NUMBER_100_HAS_EXISTED:
      en: "The DefaultACL's Rule Number 100 has existed."
      zh: "默认 ACL 规则号100已经存在。"

    RULENUMBER_ALREADY_EXISTS:
      en: "Rule %s already exists."
      zh: "规则 %s 已存在。"

    MUST_BE_CIDR_BLOCK:
      en: "Must be a valid form of CIDR block."
      zh: "请输入合法的CIDR。"

    MAX_VALUE_86400:
      en: "Max value: 86400"
      zh: "请输入不超过86400的数字。"

    DUPLICATED_POLICY_NAME:
      en: "Duplicated policy name in this auto scaling group"
      zh: "在 Auto Scaling 组中已存在该策略名。"

    ASG_SIZE_MUST_BE_EQUAL_OR_GREATER_THAN_1:
      en: "ASG size must be equal or greater than 1."
      zh: "最小数量必须大于等于1。"

    MINIMUM_SIZE_MUST_BE_LESSTHAN_MAXIMUM_SIZE:
      en: "Minimum Size must be <= Maximum Size."
      zh: "最小数量必须小于等于最大数量。"

    MAXIMUM_SIZE_MUST_BE_MORETHAN_MINIMUM_SIZE:
      en: "Maximum Size must be >= Minimum Size."
      zh: "最大数量必须大于等于最小数量。"

    VALUE_MUST_BE_LESSTHAN_VAR:
      en: "This value should be < %s"
      zh: "该值应当小于 %s"

    VALUE_MUST_BE_GREATERTHAN_VAR:
      en: "This value should be > %s"
      zh: "该值应当大于 %s"

    VALUE_MUST_IN_ALLOW_SCOPE:
      en: "This value should be >= %s and <= %s"
      zh: "该值应当大于等于 %s 且小于等于 %s"

    DESIRED_CAPACITY_EQUAL_OR_GREATER_1:
      en: "Desired Capacity must be equal or greater than 1"
      zh: "期望数量必须大于等于1"

    DESIRED_CAPACITY_IN_ALLOW_SCOPE:
      en: "Desired Capacity must be >= Minimal Size and <= Maximum Size"
      zh: "期望数量必须大于等于最小数量且小于等于最大数量"

    THIS_VALUE_SHOULD_BE_A_VALID_XXX:
      en: "This value should be a valid %s."
      zh: ""

    THIS_VALUE_SHOULD_BE_BETWEEN_XXX_AND_XXX:
      en: "This value should be between %s and %s."
      zh: ""

    THIS_VALUE_SHOULD_BE_GREATER_THAN_OR_EQUAL_TO_XXX:
      en: "This value should be greater than or equal to %s."
      zh: ""

    THIS_VALUE_SHOULD_BE_LOWER_THAN_OR_EQUAL_TO_XXX:
      en: "This value should be lower than or equal to %s."
      zh: ""

    THIS_VALUE_SHOULD_BE_GREATER_THAN_XXX:
      en: "This value should be greater than %s."
      zh: ""

    THIS_VALUE_SHOULD_BE_LOWER_THAN_XXX:
      en: "This value should be lower than %s."
      zh: ""

    THIS_VALUE_SHOULD_BE_A_VALID_TYPE_NAME:
      en: "This value should be a valid %s name."
      zh: "请输入合法的名称"

    TYPE_NAME_CONFLICT:
      en: "%s name \" %s \" is already in using. Please use another one."
      zh: "%s 的名称 “%s”已被使用，请使用其他名称。"

    RESOURCE_NAME_ELBSG_RESERVED:
      en: "Resource name starting with \"elbsg-\" is reserved."
      zh: "以“elbsg-”开头的资源名称是被保留的，不能使用。"

    MUST_BE_BETWEEN_1_AND_65534:
      en: "Must be between 1 and 65534"
      zh: "请输入1-65534之间的数字"

    ASN_NUMBER_7224_RESERVED:
      en: "ASN number 7224 is reserved in Virginia"
      zh: "ASN 号码 7224 在 Virginia 地区是被保留的"

    ASN_NUMBER_9059_RESERVED_IN_IRELAND:
      en: "ASN number 9059 is reserved in Ireland"
      zh: "ASN 号码 9059 在 Ireland 地区是被保留的"

    LOAD_BALANCER_PORT_MUST_BE_SOME_PROT:
      en: "Load Balancer Port must be either 25,80,443 or 1024 to 65535 inclusive"
      zh: "负载均衡器端口必须是 25，80，443，或者1024-65535"

    INSTANCE_PORT_MUST_BE_BETWEEN_1_AND_65535:
      en: "Instance Port must be between 1 and 65535"
      zh: "实例端口必须在1-65535范围内"

    THIS_NAME_IS_ALREADY_IN_USING:
      en: "This name is already in using."
      zh: "该名称已被使用"

    INVALID_IP_ADDRESS:
      en: "Invalid IP address"
      zh: "无效的 IP 地址"

    VOLUME_SIZE_OF_ROOTDEVICE_MUST_IN_RANGE:
      en: "Volume size of this rootDevice must in the range of %s -16384 GB."
      zh: "该根设备的卷容量必须在 %s-16384 GB 范围内。"

    IOPS_MUST_BETWEEN_100_4000:
      en: "IOPS must be between 100 and 20000"
      zh: "IOPS 必须在 100-20000 范围内"

    IOPS_MUST_BE_LESS_THAN_10_TIMES_OF_VOLUME_SIZE:
      en: "IOPS must be less than 10 times of volume size."
      zh: "IOPS 必须小于卷大小的 10 倍"

    THIS_VALUE_MUST_BETWEEN_1_99:
      en: "This value must be >= 1 and <= 99"
      zh: "该值必须大于等于1且小与等于99"

    THIS_VALUE_MUST_BETWEEN_XXX_XXX:
      en: "This value should be between %s and %s."
      zh: ""

    SHOULD_BE_A_VALID_STACK_NAME:
      en: "This value should be a valid Stack name"
      zh: "请输入合法的 Stack 名称"

    PLEASE_PROVIDE_A_VALID_AMAZON_SQS_ARN:
      en: "Please provide a valid Amazon SQS ARN"
      zh: "请输入合法的亚马逊 SQS ARN"

    PLEASE_PROVIDE_A_VALID_APPLICATION_ARN:
      en: "Please provide a valid Application ARN"
      zh: "请输入合法的应用 ARN"

    PLEASE_PROVIDE_A_VALID_PHONE_NUMBER:
      en: "Please provide a valid phone number (currently only support US phone number)"
      zh: "请输入合法的手机号码（当前仅支持美国手机号）"

    PLEASE_PROVIDE_A_VALID_URL:
      en: "Please provide a valid URL"
      zh: "请输入合法的URL"

    VOLUME_SIZE_MUST_IN_1_1024:
      en: "Volume size must in the range of 1-16384 GB."
      zh: "卷大小必须在 1-16384 GB 范围内。"

    DEVICENAME_PARAVIRTUAL:
      en: "Device name must be like /dev/hd[a-z], /dev/hd[a-z][1-15],/dev/sd[a-z] or /dev/sd[a-z][1-15]"
      zh: "设备名必须符合以下格式：/dev/hd[a-z]，/dev/hd[a-z][1-15]，/dev/sd[a-z]，/dev/sd[a-z][1-15]"

    DEVICENAME_HVM:
      en: "Device name must be like xvd[a-z], /dev/xvd[a-z], /dev/sd[a-z]."
      zh: "设备名必须符合xvd[a-z]，/dev/xvd[a-z]，/dev/sd[a-z]的格式"

    VOLUME_NAME_INUSE:
      en: "Volume name '%s' is already in using. Please use another one."
      zh: "卷名称 “%s” 已被使用，请使用其他的名称。"

    RDS_VALUE_IS_NOT_ALLOWED:
      en: "The value %s is not an allowed value."
      zh: "此处不允许使用 %s 这个值。"

    OPTION_GROUP_NAME_INVALID:
      en: "Option group name invalid"
      zh: "非法的选项组名称"

    OPTION_GROUP_DESCRIPTION_INVALID:
      en: "Option group description invalid"
      zh: "非法的选项组描述"

    PROVIDE_VALID_TIME_VALUE:
      en: "Provide a valid time value from 00:00 to 23:59."
      zh: "请输入合法的时间，格式为 00:00-23:59"

    MAX_LENGTH_IS_8:
      en: "Max length is 8."
      zh: "最大长度不能超过8位。"

    MAX_LENGTH_IS_64:
      en: "Max length is 64."
      zh: "最大长度不能超过64位。"

    MAX_LENGTH_IS_63:
      en: "Max length is 63."
      zh: "最大长度不能超过63位。"

    MUST_BEGIN_WITH_LETTER_OR_UNDERSCORE:
      en: "Must begin with a letter or an underscore"
      zh: "请以字母或下划线开头"


    ALLOCATED_STORAGE_CANNOT_BE_REDUCED:
      en: "Allocated storage cannot be reduced."
      zh: "分配的存储不能被减少。"

    ALLOCATED_STORAGE_MUST_INCREASE_BY_AT_LEAST_10:
      en: "Allocated storage must increase by at least 10%, for a new storage size of at least %s."
      zh: "分配的存储最少要增加 10%，对于新的存储最少要增加 %s。"

    MUST_BE_AN_INTEGER_FROM_MIN_TO_MAX:
      en: "Must be an integer from %s to %s"
      zh: "请输入从 %s 到 %s 之间的整数"

    SNAPSHOT_STORAGE_NEED_LARGE_THAN_ORIGINAL_VALUE:
      en: "Snapshot storage need large than original value"
      zh: "快照存储必须大于等于原始值。"

    REQUIRE_AT_LEAST_1000_IOPS:
      en: "Require at least 1000 IOPS"
      zh: "IOPS 不能小于1000"

    SQLSERVER_IOPS_REQUIRES_A_MULTIPLE_OF_1000:
      en: "SQL Server IOPS requires a multiple of 1000 and a multiple of 10 for Allocated Storage"
      zh: "SQL Server IOPS 必须是1000的倍数，并且必须等于分配存储的10倍"

    REQUIRE_IOPS_GB_RATIOS_BETWEEN_3_AND_10:
      en: "Require IOPS / GB ratios between 3 and 10"
      zh: "IOPS 必须在分配存储的3到10倍之间"

    CANNOT_CONTAIN_CHARACTER_SPLASH:
      en: "Cannot contain character /,\",@"
      zh: "不能使用 /,\",@ 等字符"

    MUST_CONTAIN_FROM_MIN_TO_MAX_CHARACTERS:
      en: "Must contain from %s to %s characters"
      zh: "密码长度必须大于等于%s且小于等于%s"

    THIS_VALUE_CANNOT_BE_1434_3389_47001_49152_49156:
      en: "This value can't be 1434, 3389, 47001, 49152-49156"
      zh: "该值不能为1434, 3389, 47001或者在49152-49156的范围内"

    MUST_CONTAIN_FROM_MIN_TO_MAX_ALPHANUMERIC_CHARACTERS_HYPHEN:
      en: "Must contain from %s to %s alphanumeric characters or hyphens and first character must be a letter, cannot end with a hyphen or contain two consecutive hyphens"
      zh: "请输入长度为 %s 到 %s 的数字、字母或连字符，且必须以字母开头，不能以连字符结束，且不能输入连续的连字符"

    MUST_CONTAIN_FROM_MIN_TO_MAX_ALPHANUMERIC_CHARACTERS:
      en: "Must be %s to %s alphanumeric characters and first character must be a letter"
      zh: "请输入长度为 %s 到 %s 的数字、字母，且必须以字母开头"







