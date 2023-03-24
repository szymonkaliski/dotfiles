local windowMetadata = require('ext.window').windowMetadata

local module = {}

module.init = function()
  -- some global functions for console
  inspect = hs.inspect

  dumpWindows = function()
    local windowList = {}

    hs.fnutils.each(hs.window.allWindows(), function(win)
      local title, meta = windowMetadata(win)
      local app         = win:application()
      local axWin       = hs.axuielement.windowElement(win)

      table.insert(windowList, {
        id               = win:id(),
        appName          = app:name(),
        bundleId         = app:bundleID(),
        role             = win:role(),
        subrole          = win:subrole(),
        frame            = win:frame().string,
        buttonZoom       = axWin:attributeValue('AXZoomButton') and 'exists' or 'doesn\'t exist',
        buttonFullScreen = axWin:attributeValue('AXFullScreenButton') and 'exists' or 'doesn\'t exist',
        isResizable      = axWin:isAttributeSettable('AXSize'),
        title            = title,
        meta             = meta,
      })
    end)

    print(hs.inspect(windowList))
  end

  dumpScreens = function()
    hs.fnutils.each(hs.screen.allScreens(), function(s)
      print(s:id(), s:position(), s:frame(), s:name())
    end)
  end

  timestamp = function(date)
    date = date or hs.timer.secondsSinceEpoch()
    return os.date("%F %T" .. ((tostring(date):match("(%.%d+)$")) or ""), math.floor(date))
  end

  -- console styling
  local grayColor = {
    red   = 24 * 4 / 255,
    green = 24 * 4 / 255,
    blue  = 24 * 4 / 255,
    alpha = 1
  }

  local blackColor = {
    red   = 24 / 255,
    green = 24 / 255,
    blue  = 24 / 255,
    alpha = 1
  }

  hs.console.consoleCommandColor(blackColor)
  hs.console.consoleResultColor(grayColor)
  hs.console.consolePrintColor(grayColor)

  -- no toolbar
  hs.console.toolbar(nil)
end

return module
