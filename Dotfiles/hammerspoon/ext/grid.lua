local cache  = {}
local module = { cache = cache }

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

      if hhtwm then
        local screenMarinFromTiling = hhtwm.screenMargin.top - hhtwm.margin / 2

        frame.y = frame.y + screenMarinFromTiling
        frame.h = frame.h - screenMarinFromTiling
      end

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
