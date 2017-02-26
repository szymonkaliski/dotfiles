local axuiWindowElement = require('hs._asm.axuielement').windowElement

local module = {}

local log = hs.logger.new('overrides', 'debug');

-- override some hs.grid stuff so it works better with my OCD
module.init = function()
  -- detects if window can be resized
  -- this is not ideal, but works for me
  hs.window.isResizable = function(self)
    local title = self:title()
    local app   = self:application():name()

    local hasFullscreenButton = axuiWindowElement(self):attributeValue('AXFullScreenButton') ~= nil

    return hasFullscreenButton
      or title == 'Hammerspoon Console'
      or title == 'Mini Player'
      or title == 'Song Info'
      or title == 'Quick Look'
      or app   == 'Tweetbot'
      or app   == 'Max'
      or app   == 'Finder'
  end

  local gridMargin = 10

  -- hs.grid.setGrid('32x18', '2560x1440') -- cell: 80 x 80
  -- hs.grid.setGrid('21x13', '1680x1050') -- cell: 80 x ~81

  hs.grid.setGrid('16x9', '2560x1440') -- cell: 160 x 160
  hs.grid.setGrid('10x6', '1680x1050') -- cell: 168 x 175

  hs.grid.setMargins({ gridMargin, gridMargin })

  hs.grid.set = function(win, cell, screen)
    local min, max, floor = math.min, math.max, math.floor

    local margins  = { w = gridMargin, h = gridMargin }
    local winFrame = win:frame()

    screen = hs.screen.find(screen)
    if not screen then screen = win:screen() end
    cell = hs.geometry.new(cell)

    local screenRect = screen:fullFrame()
    local screenGrid = hs.grid.getGrid(screen)

    local cellW = screenRect.w / screenGrid.w
    local cellH = screenRect.h / screenGrid.h

    local frame = {
      x = cell.x * cellW + screenRect.x + margins.w,
      y = cell.y * cellH + screenRect.y + margins.h,
      w = cell.w * cellW - (margins.w * 2),
      h = cell.h * cellH - (margins.h * 2)
    }

    local frameMarginX = 0
    -- local frameMarginY = 0

    -- multiple fixes for non-resizable windows
    -- basically center them in grid
    -- and "snap" when near edges
    if not win:isResizable() then
      local widthDiv   = floor(winFrame.w / cellW + 0.0)
      local frameWidth = widthDiv * cellW

      frameMarginX     = (frameWidth - winFrame.w) / 2 - margins.w / 2
      frame.w          = winFrame.w

      -- local heightDiv   = floor(winFrame.h / cellH + 0.5)
      -- local frameHeight = heightDiv * cellH
      -- frameMarginY      = (frameHeight - winFrame.h) / 2
      -- frame.h           = winFrame.h
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
        if win:isResizable() then
          frame.w = frame.w + margins.w / 2
        end
        frame.x = frame.x - margins.w / 2
      end

      if cell.x + cell.w ~= screenGrid.w then
        if win:isResizable() then
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
    -- elseif cell.y ~= 0 then
    --   frame.y = frame.y + frameMarginY
    end

    -- print(
    --   win:title(),
    --   win:application():name(),
    --   win:isResizable(),
    --   hs.inspect(frame),
    --   hs.inspect(winFrame),
    --   frameMarginX
    -- )

    -- don't set frame if nothing has changed!
    -- fixes issues with autogrid and infinite updates
    if
      winFrame.x ~= frame.x or
      winFrame.y ~= frame.y or
      winFrame.h ~= frame.h or
      winFrame.w ~= frame.w then
      win:setFrame(frame)
    end

    return grid
  end

  log.d('inited!')
end

return module
