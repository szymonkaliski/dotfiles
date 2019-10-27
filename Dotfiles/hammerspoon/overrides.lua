local axuiWindowElement = require('hs._asm.axuielement').windowElement

local module = {}
local log    = hs.logger.new('overrides', 'debug');

-- detects if window can be resized
-- this is not ideal, but works for me
local isResizable = function(win)
  return axuiWindowElement(win):isAttributeSettable('AXSize')
end

module.init = function()
  local gridMargin = (hhtwm and hhtwm.margin) or 12

  -- hs.grid.setGrid('16x10', '1680x1050') -- cell: 105 x 105
  -- hs.grid.setGrid('16x9',  '1920x1080') -- cell: 120 x 120
  -- hs.grid.setGrid('16x9',  '2560x1440') -- cell: 160 x 160
  -- hs.grid.setGrid('9x16',  '1440x2560') -- cell: 160 x 160

  hs.grid.setGrid('18x32') -- default

  hs.grid.setGrid('24x15', '1680x1050') -- cell: 70 x 70
  hs.grid.setGrid('32x18', '1920x1080') -- cell: 60 x 60
  hs.grid.setGrid('32x18', '2560x1440') -- cell: 80 x 80
  hs.grid.setGrid('18x32', '1440x2560') -- cell: 80 x 80

  hs.grid.setGrid('48x20', '3840x1600') -- cell: 60 x 60

  hs.grid.setMargins({ gridMargin, gridMargin })
  hs.grid.getMargins = function() return { gridMargin, gridMargin } end

  hs.grid.center = function(win)
    local cell       = hs.grid.get(win)
    local screen     = win:screen()
    local screenGrid = hs.grid.getGrid(screen)

    cell.x = math.floor(screenGrid.w / 2 - cell.w / 2)
    cell.y = math.floor(screenGrid.h / 2 - cell.h / 2)

    hs.grid.set(win, cell, screen)
  end

  hs.grid.set = function(win, cell, screen)
    local margins  = { w = gridMargin, h = gridMargin }
    local winFrame = win:frame()

    screen = hs.screen.find(screen)
    if not screen then screen = win:screen() end
    cell = hs.geometry.new(cell)

    local screenRect = screen:fullFrame()

    if hhtwm then
      local screenMarginFromTiling = hhtwm.screenMargin.top - hhtwm.margin / 2

      screenRect.y = screenRect.y + screenMarginFromTiling
      screenRect.h = screenRect.h - screenMarginFromTiling
    end

    local screenGrid = hs.grid.getGrid(screen)

    local cellW = screenRect.w / screenGrid.w
    local cellH = screenRect.h / screenGrid.h

    local frame = {
      x = cell.x * cellW + screenRect.x + margins.w,
      y = cell.y * cellH + screenRect.y + margins.h,
      w = cell.w * cellW - (margins.w * 2),
      h = cell.h * cellH - (margins.h * 2)
    }

    local frameMarginX   = 0
    local isWinResizable = isResizable(win)

    if not isWinResizable then
      local widthDiv = math.floor(winFrame.w / cellW)

      -- we always want window to take up divisible-by-two cell number
      if widthDiv % 2 == 1 then widthDiv = widthDiv + 1 end

      local frameWidth = widthDiv * cellW
      frameMarginX     = (frameWidth - winFrame.w) / 2 - margins.w / 2
      frame.w          = winFrame.w
    end

    -- calculate proper margins
    -- this fixes doubled margins betweeen windows

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
        if isWinResizable then
          frame.w = frame.w + margins.w / 2
        end
        frame.x = frame.x - margins.w / 2
      end

      if cell.x + cell.w ~= screenGrid.w then
        if isWinResizable then
          frame.w = frame.w + margins.w / 2
        end
      end
    end

    -- snap to edges
    -- or add margins if exist
    local maxMargin = gridMargin * 2

    if cell.x ~= 0 and frame.x - screenRect.x + frame.w > screenRect.w - maxMargin then
      frame.x = screenRect.x + screenRect.w - margins.w - frame.w
    elseif cell.x ~= 0 then
      frame.x = frame.x + frameMarginX
    end

    if cell.y ~= 0 and (frame.y - screenRect.y + frame.h > screenRect.h - maxMargin) then
      frame.y = screenRect.y + screenRect.h - margins.h - frame.h
    end

    -- don't set frame if nothing has changed!
    -- fixes issues with autogrid and infinite updates
    if not winFrame:equals(frame) then
      win:setFrame(frame)
    end

    return hs.grid
  end

  log.d('inited!')
end

return module
