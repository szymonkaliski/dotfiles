local module = {}

module.flatten = function(xs)
  local result = {}

  hs.fnutils.each(xs, function(xs)
    hs.fnutils.each(xs, function(x)
      table.insert(result, x)
    end)
  end)

  return result
end

module.keys = function(T)
  local keys = {}

  for k, _ in pairs(T) do
    table.insert(keys, k)
  end

  return keys
end

module.uniq = function(T)
  local hash    = {}
  local results = {}

  hs.fnutils.each(T, function(value)
    if not hash[value] then
      table.insert(results, value)
      hash[value] = true
    end
  end)

  return results
end

module.equal = function(a, b)
  if #a ~= #b then
    return false
  end

  for i, _ in ipairs(a) do
    if b[i] ~= a[i] then
      return false
    end
  end

  return true
end

return module
