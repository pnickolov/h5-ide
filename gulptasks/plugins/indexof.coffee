module.exports = (haystack, needle, i) ->

  if not Buffer.isBuffer(needle)
    needle = new Buffer(needle)

  i = i or 0
  l = haystack.length - needle.length + 1
  n = needle.length

  while i<l
    good = true
    j = 0

    while j < n
      if haystack[ i+j ] isnt needle[j]
        good = false
        break
      ++j

    if good then return i
    ++i

  -1
