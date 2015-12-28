local module = {}
local cache  = { modules = {} }

-- overrides prev/play/next
-- currently controls online spotify in Chrome if running,
-- defaults back to propagating event to os
module.start = function()
  hs.fnutils.each(specialkeys.enabled, function(moduleName)
    table.insert(cache.modules, require('utils.specialkeys.' .. moduleName))
  end)

  cache.eventtap = hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined }, function(event)
    local systemKey = event:systemKey()

    -- exit as soon as possible if we don't care about the event
    if not next(systemKey) then return false end

    local matchingModule = hs.fnutils.find(cache.modules, function(module)
      return module.shouldProcessEvent(systemKey) == true
    end)

    if not matchingModule then return false end

    return matchingModule.processEvent(systemKey)
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
