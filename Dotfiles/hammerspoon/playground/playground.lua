local module = {}

local splitLines = function(str)
  local t = {}

  local helper = function(line)
    table.insert(t, line)
    return ""
  end

  helper(str:gsub("(.-)\r?\n", helper))

  return t
end

module.chooseDirFromZ = function()
  local dirs = splitLines(hs.execute('z -l', true))

  local choices = hs.fnutils.map(dirs, function(match)
    local dir = match:gsub('^(.-)/', '/')

    return {
      ['text'] = dir,
      ['uuid'] = dir
    }
  end)

  local chooser = hs.chooser.new(function(result)
    print(hs.inspect(result))
  end)

  print(chooser)

  chooser:choices(choices):show()
end

return module
