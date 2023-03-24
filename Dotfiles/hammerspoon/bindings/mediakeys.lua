local cache  = {}
local module = { cache = cache }

-- control only iTunes/Music, by default media keys now pause/play youtube and
-- other things as well, which I don't like

module.start = function()
  cache.eventtap = hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined }, function(event)
    local data       = event:systemKey()
    local key        = data['key']
    local isKeyUp    = data['down'] == false
    local isMediaKey = key == 'PLAY' or key == 'NEXT' or key == 'PREVIOUS'

    if not isMediaKey then
      return false, nil
    end

    local isRunning    = hs.application.find('Music') or hs.application.find('iTunes')
    local shouldDelete = false

    if isRunning then
      if key == 'PLAY' then
        if isKeyUp then
          hs.itunes.playpause()
        end
        shouldDelete = true
      end

      if key == 'NEXT' then
        if isKeyUp then
          hs.itunes.next()
        end
        shouldDelete = true
      end

      if key == 'PREVIOUS' then
        if isKeyUp then
          hs.itunes.previous()
        end
        shouldDelete = true
      end
    end

    return shouldDelete, nil
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
