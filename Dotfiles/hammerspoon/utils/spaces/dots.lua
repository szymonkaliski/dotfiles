local animateAlpha = require('ext.drawing').animateAlpha
local keys         = require('ext.table').keys
local spaces       = require('hs._asm.undocumented.spaces')
local uniq         = require('ext.table').uniq

local cache = {
  watchers = {},
  dots     = {}
}

local module = {}

module.draw = function()
  hs.drawing.disableScreenUpdates()

  local activeSpaces = spaces.query(spaces.masks.currentSpaces, true)
  local cacheUUIDs   = keys(cache.dots)
  local screenUUIDs  = {}

  hs.fnutils.each(hs.screen.allScreens(), function(screen)
    screenUUIDs[screen:spacesUUID()] = screen
  end)

  local allUUIDs = uniq(hs.fnutils.concat(cacheUUIDs, keys(screenUUIDs)))

  hs.fnutils.each(allUUIDs, function(screenUUID)
    local screen = screenUUIDs[screenUUID]

    -- if this screen doesn't exist anymore, or there's only one space
    -- then delete all dots, and don't display anything
    if not screen or #spaces.layout()[screenUUID] <= 1 then
      -- delete all cached dots
      if cache.dots[screenUUID] then
        hs.fnutils.each(cache.dots[screenUUID], function(container)
          if container.animation then container.animation:stop() end
          if container.dot then container.dot:delete() end
        end)

        cache.dots[screenUUID] = nil
      end

      return
    end

    local screenFrame  = screen:fullFrame()
    local screenUUID   = screen:spacesUUID()
    local screenSpaces = spaces.layout()[screenUUID]

    if not cache.dots[screenUUID] then cache.dots[screenUUID] = {} end

    for i = 1, math.max(#screenSpaces, #cache.dots[screenUUID]) do
      local container = cache.dots[screenUUID][i] or {}

      local dot       = container.dot
      local animation = container.animation

      if not dot then
        dot = hs.drawing.circle({ x = 0, y = 0, w = dots.size, h = dots.size })
          :setStroke(false)
          :setBehaviorByLabels({ 'moveToActiveSpace', 'stationary' })
          :setLevel(hs.drawing.windowLevels.desktop)
          :setFillColor({ red = 1.0, green = 1.0, blue = 1.0, alpha = 1.0 })
      end

      if animation then
        animation:stop()
      end

      if i <= #screenSpaces then
        local x     = screenFrame.w / 2 - (#screenSpaces / 2) * dots.distance + i * dots.distance - dots.size * 3 / 2
        local y     = screenFrame.h - dots.distance
        local alpha = hs.fnutils.contains(activeSpaces, screenSpaces[i]) and dots.selectedAlpha or dots.alpha

        dot
          :setTopLeft({ x = x + screenFrame.x, y = y + screenFrame.y })
          :setAlpha(0)
          :show()

        animation = animateAlpha(dot, alpha, { speed = 0.15 })
      else
        -- somehow :hide() creates problems when switching screens ("ghost dots")
        -- deleting invisible dots fixes it
        dot:delete()
        dot = nil
      end

      cache.dots[screenUUID][i] = {
        dot       = dot,
        animation = animation
      }
    end
  end)

  hs.drawing.enableScreenUpdates()
end

module.start = function()
  -- we need to redraw dots on screen and space events
  cache.watchers.spaces = hs.spaces.watcher.new(dots.draw):start()
  cache.watchers.screen = hs.screen.watcher.new(dots.draw):start()

  dots.draw()
end

module.stop = function()
  hs.fnutils.each(cache.watchers, function(watcher) watcher:stop() end)

  hs.fnutils.each(cache.dots, function(screen)
    hs.fnutils.each(screen, function(dot) dot:delete() end)
  end)

  cache.dots = {}
end

return module
