local spaces = require('hs._asm.undocumented.spaces')

local cache = {
  watchers = {},
  dots     = {}
}

local module = {}

local tableKeys = function(T)
  local keys = {}

  for k, _ in pairs(T) do
    table.insert(keys, k)
  end

  return keys
end

local tableUniq = function(T)
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

module.draw = function()
  local activeSpace = spaces.activeSpace()
  local cacheUUIDs  = tableKeys(cache.dots)
  local screenUUIDs = {}

  hs.fnutils.each(hs.screen.allScreens(), function(screen)
    screenUUIDs[screen:spacesUUID()] = screen
  end)

  local allUUIDs = tableUniq(hs.fnutils.concat(cacheUUIDs, tableKeys(screenUUIDs)))

  hs.fnutils.each(allUUIDs, function(screenUUID)
    local screen = screenUUIDs[screenUUID]

    -- if this screen doesn't exist anymore, then delete all dots
    -- TODO: check if this works
    if not screen then
      hs.fnutils.each(cache.dots[screenUUID], function(dot) dot:delete() end)
      return
    end

    local screenFrame  = screen:fullFrame()
    local screenUUID   = screen:spacesUUID()
    local screenSpaces = spaces.layout()[screenUUID]

    if not cache.dots[screenUUID] then cache.dots[screenUUID] = {} end

    for i = 1, math.max(#screenSpaces, #cache.dots[screenUUID]) do
      local dot

      if not cache.dots[screenUUID][i] then
        dot = hs.drawing.circle({ x = 0, y = 0, w = dots.size, h = dots.size })

        dot
          :setStroke(false)
          :setBehaviorByLabels({ 'canJoinAllSpaces', 'stationary' })
          :setLevel(hs.drawing.windowLevels.desktopIcon)
      else
        dot = cache.dots[screenUUID][i]
      end

      local x     = screenFrame.w / 2 - (#screenSpaces / 2) * dots.distance + i * dots.distance - dots.size * 3 / 2
      local y     = screenFrame.h - dots.distance
      local alpha = screenSpaces[i] == activeSpace and dots.selectedAlpha or dots.alpha

      dot
        :setTopLeft({ x = x, y = y })
        :setFillColor({ red = 1.0, green = 1.0, blue = 1.0, alpha = alpha })

      if i <= #screenSpaces then
        dot:show()
      else
        dot:hide()
      end

      cache.dots[screenUUID][i] = dot
    end
  end)
end

module.start = function()
  -- we need to redraw dots on screen and space events
  cache.watchers.spaces = hs.spaces.watcher.new(dots.draw):start()
  cache.watchers.screen = hs.screen.watcher.new(dots.draw):start()

  dots.draw()
end

module.stop = function()
  hs.fnutils.each(cache.watchers, function(watcher) watcher:stop() end)

  cache.dots = {}
end

return module
