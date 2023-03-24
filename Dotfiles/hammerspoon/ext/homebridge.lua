local module = {}

-- TODO: find paths automatically
-- TODO: grab all paths when HS starts, and expose as global
local NODE_PATH        = os.getenv('HOME') .. '/.nvm/versions/node/v14.15.5/bin/node'
local HOME_REMOTE_PATH = os.getenv('HOME') .. '/.nvm/versions/node/v14.15.5/bin/homebridge-remote'

module.list = function()
  local command = NODE_PATH .. ' ' .. HOME_REMOTE_PATH .. ' list --json'
  local output = hs.execute(command)

  return hs.json.decode(output)
end

module.find = function(name)
  return hs.fnutils.find(module.list(), function(d)
    return d.name == name
  end)
end

module.set = function(addr, value)
  local command = NODE_PATH .. ' ' .. HOME_REMOTE_PATH

  command = command .. ' set '
  command = command .. addr.aid .. ' '
  command = command .. value .. ' '

  os.execute(command)
end

module.get = function(addr)
  local command = NODE_PATH .. ' ' .. HOME_REMOTE_PATH

  command = command .. ' get '
  command = command .. addr.aid .. ' '
  command = command .. ' | grep -v 1'

  local _, _, rc = os.execute(command)

  return rc == 1
end


return module
