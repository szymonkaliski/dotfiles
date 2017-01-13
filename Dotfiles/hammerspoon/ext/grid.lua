local cache  = {}
local module = { cache = cache }

-- swap window screens using center between monitors as reflection mirror
-- since I use two monitors of the same size this is very useful,
-- but will probably break on different sized displays
-- module.swapScreens = function()
--   local reflectScreenCenter = function(geom, screenGeom)
--     local p = hs.geometry.point(geom.x, geom.y)

--     if geom.x > screenGeom.w then
--       local diff = geom.x - screenGeom.w
--       p.x = screenGeom.w - diff - geom.w
--     else
--       local diff = screenGeom.w - geom.x
--       p.x = screenGeom.w + diff - geom.w
--     end

--     return p
--   end

--   hs.fnutils.each(hs.window.visibleWindows(), function(win)
--     local reflected             = reflectScreenCenter(win:frame(), win:screen():frame())
--     local reflectedFrame        = win:frame()

--     reflectedFrame.x            = reflected.x
--     reflectedFrame.y            = reflected.y

--     local lastAnimDuration      = hs.window.animationDuration
--     hs.window.animationDuration = lastAnimDuration * 4

--     win:setFrame(reflectedFrame)

--     hs.window.animationDuration = lastAnimDuration
--   end)
-- end

-- show hs.grid, but simpler (nicer)
module.toggleGrid = function()
  cache.lines = cache.lines or {}

  if #cache.lines > 0 then
    hs.drawing.disableScreenUpdates()
    hs.fnutils.each(cache.lines, function(line)
      line:hide(0.5)
    end)
    hs.drawing.enableScreenUpdates()

    hs.timer.doAfter(0.5, function()
      hs.fnutils.each(cache.lines, function(line)
        line:delete()
      end)

      cache.lines = {}
    end)
  else
    hs.fnutils.each(hs.screen.allScreens(), function(screen)
      local grid  = hs.grid.getGrid(screen)
      local frame = screen:fullFrame()

      for x = 1, grid.w - 1, 1 do
        local line = hs.drawing.line(
          { x = 1, y = 1       },
          { x = 1, y = frame.h }
        )
        :setTopLeft({
          x = frame.x + x * frame.w / grid.w,
          y = frame.y
        })

        table.insert(cache.lines, line)
      end

      for y = 1, grid.h - 1, 1 do
        local line = hs.drawing.line(
          { x = 1,       y = 1 },
          { x = frame.w, y = 1 }
        )
        :setTopLeft({
          x = frame.x,
          y = frame.y + y * frame.h / grid.h
        })

        table.insert(cache.lines, line)
      end
    end)

    hs.drawing.disableScreenUpdates()
    hs.fnutils.each(cache.lines, function(line)
      local frame = line:frame()

      line
        :setStroke(true)
        :setStrokeColor({ white = 0.0, alpha = 0.7 })
        :setLevel(hs.drawing.windowLevels.overlay)
        :setBehaviorByLabels({ 'canJoinAllSpaces', 'stationary' })
        :show(0.5)
    end)
    hs.drawing.enableScreenUpdates()
  end
end

return module
