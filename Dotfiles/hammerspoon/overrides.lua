local module = {}

local log = hs.logger.new('overrides', 'debug');

-- override some hs.grid stuff so it works better with my OCD
module.init = function()
  local gridMargin = 8

  hs.grid.setGrid('16x12').setMargins({ gridMargin, gridMargin })

  hs.grid.set = function(win, cell, screen)
    local margins  = { w = gridMargin, h = gridMargin }
    local min, max = math.min, math.max

    screen = hs.screen.find(screen)
    if not screen then screen = win:screen() end
    cell = hs.geometry.new(cell)

    local screenRect = screen:fullFrame()
    local screenGrid = hs.grid.getGrid(screen)

    local cellW = screenRect.w / screenGrid.w
    local cellH = screenRect.h / screenGrid.h

    local frame = {
      x = (cell.x * cellW) + screenRect.x + margins.w,
      y = (cell.y * cellH) + screenRect.y + margins.h,
      w = cell.w * cellW - (margins.w * 2),
      h = cell.h * cellH - (margins.h * 2)
    }

    if cell.h < screenGrid.h and cell.h % 1 == 0 then
      if cell.y ~= 0 then
        frame.h = frame.h + margins.h / 2
        frame.y = frame.y - margins.h / 2
      end
      if cell.y + cell.h ~= screenGrid.h then
        frame.h = frame.h + margins.h / 2
      end
    end

    if cell.w < screenGrid.w and cell.w % 1 == 0 then
      if cell.x ~= 0 then
        frame.w = frame.w + margins.w / 2
        frame.x = frame.x - margins.w / 2
      end
      if cell.x + cell.w ~= screenGrid.w then
        frame.w = frame.w + margins.w / 2
      end
    end

    win:setFrameInScreenBounds(frame)

    return grid
  end

  log.d('inited!')
end

return module
