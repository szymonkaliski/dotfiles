local module = {}

module.set = function(addr, value)
  local command = 'homebridge-remote'

  command = command .. ' set '
  command = command .. addr.aid .. ' '
  command = command .. addr.iid .. ' '
  command = command .. value .. ' '

  hs.execute(command, true)
end

return module
