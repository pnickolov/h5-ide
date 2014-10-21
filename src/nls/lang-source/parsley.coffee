# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =

  PARSLEY:

    MUST_BE_A_VALID_FORMAT_OF_NUMBER:
      en: "Must be a valid format of number."
      zh: ""

    THE_PROTOCOL_NUMBER_RANGE_MUST_BE_0_255:
      en: "The protocol number range must be 0-255."
      zh: ""

    MUST_BE_A_VALID_FORMAT_OF_PORT_RANGE:
      en: "Must be a valid format of port range."
      zh: ""

    PORT_RANGE_BETWEEN_0_65535:
      en: "Port range needs to be a number or a range of numbers between 0 and 65535."
      zh: ""

    VALID_RULE_NUMBER_1_TO_32767:
      en: "Valid rule number must be between 1 to 32767."
      zh: ""

    RULE_NUMBER_100_HAS_EXISTED:
      en: "The DefaultACL's Rule Number 100 has existed."
      zh: ""

    RULENUMBER_ALREADY_EXISTS:
      en: "Rule %s already exists."
      zh: ""

    MUST_BE_CIDR_BLOCK:
      en: "Must be a valid form of CIDR block."
      zh: ""

    MAX_VALUE_86400:
      en: "Max value: 86400"
      zh: ""

    DUPLICATED_POLICY_NAME:
      en: "Duplicated policy name in this autoscaling group"
      zh: ""

    ASG_SIZE_MUST_BE_EQUAL_OR_GREATER_THAN_1:
      en: "ASG size must be equal or greater than 1"
      zh: ""

    MINIMUM_SIZE_MUST_BE_LESSTHAN_MAXIMUM_SIZE:
      en: "Minimum Size must be <= Maximum Size."
      zh: ""

    MAXIMUM_SIZE_MUST_BE_MORETHAN_MINIMUM_SIZE:
      en: "Maximum Size must be >= Minimum Size."
      zh: ""

    VALUE_MUST_BE_LESSTHAN_VAR:
      en: "This value should be < %s"
      zh: ""

    VALUE_MUST_BE_GREATERTHAN_VAR:
      en: "This value should be > %s"
      zh: ""

    VALUE_MUST_IN_ALLOW_SCOPE:
      en: "This value should be >= %s and <= %s"
      zh: ""

    DESIRED_CAPACITY_EQUAL_OR_GREATER_1:
      en: "Desired Capacity must be equal or greater than 1"
      zh: ""

    DESIRED_CAPACITY_IN_ALLOW_SCOPE:
      en: "Desired Capacity must be >= Minimal Size and <= Maximum Size"
      zh: ""

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
      zh: ""

    TYPE_NAME_CONFLICT:
      en: "%s name \" %s \" is already in using. Please use another one."
      zh: ""

    RESOURCE_NAME_ELBSG_RESERVED:
      en: "Resource name starting with \"elbsg-\" is reserved."
      zh: ""

    MUST_BE_BETWEEN_1_AND_65534:
      en: "Must be between 1 and 65534"
      zh: ""

    ASN_NUMBER_7224_RESERVED:
      en: "ASN number 7224 is reserved in Virginia"
      zh: ""

    ASN_NUMBER_9059_RESERVED_IN_IRELAND:
      en: "ASN number 9059 is reserved in Ireland"
      zh: ""

    LOAD_BALANCER_PORT_MUST_BE_SOME_PROT:
      en: "Load Balancer Port must be either 25,80,443 or 1024 to 65535 inclusive"
      zh: ""

    INSTANCE_PORT_MUST_BE_BETWEEN_1_AND_65535:
      en: "Instance Port must be between 1 and 65535"
      zh: ""

    THIS_NAME_IS_ALREADY_IN_USING:
      en: "This name is already in using."
      zh: ""

    INVALID_IP_ADDRESS:
      en: "Invalid IP address"
      zh: ""

    VOLUME_SIZE_OF_ROOTDEVICE_MUST_IN_RANGE:
      en: "Volume size of this rootDevice must in the range of %s -1024 GB."
      zh: ""

    IOPS_MUST_BETWEEN_100_4000:
      en: "IOPS must be between 100 and 4000"
      zh: ""

    IOPS_MUST_BE_LESS_THAN_10_TIMES_OF_VOLUME_SIZE:
      en: "IOPS must be less than 10 times of volume size."
      zh: ""

    THIS_VALUE_MUST_BETWEEN_1_99:
      en: "This value must be >= 1 and <= 99"
      zh: ""

    SHOULD_BE_A_VALID_STACK_NAME:
      en: "This value should be a valid Stack name"
      zh: ""

    PLEASE_PROVIDE_A_VALID_AMAZON_SQS_ARN:
      en: "Please provide a valid Amazon SQS ARN"
      zh: ""

    PLEASE_PROVIDE_A_VALID_APPLICATION_ARN:
      en: "Please provide a valid Application ARN"
      zh: ""

    PLEASE_PROVIDE_A_VALID_PHONE_NUMBER:
      en: "Please provide a valid phone number (currently only support US phone number)"
      zh: ""

    PLEASE_PROVIDE_A_VALID_URL:
      en: "Please provide a valid URL"
      zh: ""

    VOLUME_SIZE_MUST_IN_1_1024:
      en: "Volume size must in the range of 1-1024 GB."
      zh: ""

    DEVICENAME_LINUX:
      en: "Device name must be like /dev/hd[a-z], /dev/hd[a-z][1-15],/dev/sd[a-z] or /dev/sd[b-z][1-15]"
      zh: ""

    DEVICENAME_WINDOWS:
      en: "Device name must be like xvd[f-p]."
      zh: ""

    VOLUME_NAME_INUSE:
      en: "Volume name '%s' is already in using. Please use another one."
      zh: ""

    RDS_VALUE_IS_NOT_ALLOWED:
      en: "The value %s is not an allowed value."
      zh: ""

    OPTION_GROUP_NAME_INVALID:
      en: "Option group name invalid"
      zh: ""

    OPTION_GROUP_DESCRIPTION_INVALID:
      en: "Option group description invalid"
      zh: ""

    PROVIDE_VALID_TIME_VALUE:
      en: "Provide a valid time value from 00:00 to 23:59."
      zh: ""

    MAX_LENGTH_IS_8:
      en: "Max length is 8."
      zh: ""

    MAX_LENGTH_IS_64:
      en: "Max length is 64."
      zh: ""

    MAX_LENGTH_IS_63:
      en: "Max length is 63."
      zh: ""

    MUST_BEGIN_WITH_LETTER_OR_UNDERSCORE:
      en: "Must begin with a letter or an underscore"
      zh: ""


    ALLOCATED_STORAGE_CANNOT_BE_REDUCED:
      en: "Allocated storage cannot be reduced."
      zh: ""

    ALLOCATED_STORAGE_MUST_INCREASE_BY_AT_LEAST_10:
      en: "Allocated storage must increase by at least 10%, for a new storage size of at least %s."
      zh: ""

    MUST_BE_AN_INTEGER_FROM_MIN_TO_MAX:
      en: "Must be an integer from %s to %s"
      zh: ""

    SNAPSHOT_STORAGE_NEED_LARGE_THAN_ORIGINAL_VALUE:
      en: "Snapshot storage need large than original value"
      zh: ""

    REQUIRE_AT_LEAST_1000_IOPS:
      en: "Require at least 1000 IOPS"
      zh: ""

    SQLSERVER_IOPS_REQUIRES_A_MULTIPLE_OF_1000:
      en: "SQL Server IOPS requires a multiple of 1000 and a multiple of 10 for Allocated Storage"
      zh: ""

    REQUIRE_IOPS_GB_RATIOS_BETWEEN_3_AND_10:
      en: "Require IOPS / GB ratios between 3 and 10"
      zh: ""

    CANNOT_CONTAIN_CHARACTER_SPLASH:
      en: "Cannot contain character /,\",@"
      zh: ""

    MUST_CONTAIN_FROM_MIN_TO_MAX_CHARACTERS:
      en: "Must contain from %s to %s characters"
      zh: ""

    THIS_VALUE_CANNOT_BE_1434_3389_47001_49152_49156:
      en: "This value can't be 1434, 3389, 47001, 49152-49156"
      zh: ""

    MUST_CONTAIN_FROM_MIN_TO_MAX_ALPHANUMERIC_CHARACTERS_HYPHEN:
      en: "Must contain from %s to %s alphanumeric characters or hyphens and first character must be a letter, cannot end with a hyphen or contain two consecutive hyphens"
      zh: ""

    MUST_CONTAIN_FROM_MIN_TO_MAX_ALPHANUMERIC_CHARACTERS:
      en: "Must be %s to %s alphanumeric characters and first character must be a letter"
      zh: ""







