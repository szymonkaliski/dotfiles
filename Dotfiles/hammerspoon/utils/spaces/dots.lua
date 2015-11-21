local spaces = require('hs._asm.undocumented.spaces')

local cache = {
  watchers = {},
  dots     = {}
}

local module = {}

module.draw = function()
  local activeSpace = spaces.activeSpace()

  -- FIXME: what if I remove screen, the dots are still being drawn?
  hs.fnutils.each(hs.screen.allScreens(), function(screen)
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
