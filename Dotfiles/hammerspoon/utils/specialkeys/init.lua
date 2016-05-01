local cache  = { modules = {} }
local module = { cache = cache }

module.start = function()
  hs.fnutils.each(specialkeys.enabled, function(moduleName)
    table.insert(cache.modules, require('utils.specialkeys.' .. moduleName))
  end)

  cache.eventtap = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.NSSystemDefined
  }, function(event)
    local matchingModule = hs.fnutils.find(cache.modules, function(module)
      return module.shouldProcessEvent(event) == true
    end)

    if not matchingModule then return false end

    return matchingModule.processEvent(event)
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
