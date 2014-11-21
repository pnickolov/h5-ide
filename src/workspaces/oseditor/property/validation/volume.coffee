define [
  'constant'
  './ValidationBase'
  'i18n!/nls/lang.js'
], ( constant, ValidationBase, lang ) ->

  ValidationBase.extend {

    mountPoint: (value) ->
      if (value.indexOf "/dev/sd" >= 0) and (value.length is 8 ) and (value.split("").pop() in ["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"])
        return null
      else
        return sprintf lang.PARSLEY.THIS_VALUE_SHOULD_BE_A_VALID_XXX, "mount point"

    size: (value)->
      if value and new RegExp(ValidationBase.limit.positive).test value
        return null
      else
        return sprintf lang.PARSLEY.THIS_VALUE_SHOULD_BE_A_VALID_XXX, "number"
  }, {
    handleTypes: [ constant.RESTYPE.OSVOL ]
  }
