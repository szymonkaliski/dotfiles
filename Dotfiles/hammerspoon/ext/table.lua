local module = {}

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

return module
