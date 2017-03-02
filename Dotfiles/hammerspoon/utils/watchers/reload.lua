local reloadHS = require('ext.system').reloadHS

return hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', function(files)
  local shouldReload = false

  for _, file in pairs(files) do
    if file:sub(-4) == '.lua' then
      shouldReload = true
    end
  end

  if shouldReload then
    reloadHS()
  end
end)
