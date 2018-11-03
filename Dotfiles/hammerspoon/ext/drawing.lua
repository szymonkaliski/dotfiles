local cache  = { borderDrawings = {}, borderDrawingFadeOuts = {} }
local module = { cache = cache }

-- returns 'graphite' or 'aqua'
local getOSXAppearance = function()
  local _, res = hs.applescript.applescript([[
    tell application "System Events"
      tell appearance preferences
        return appearance as string
      end tell
    end tell
  ]])

  return res
end

-- get appearance on start
cache.osxApperance = getOSXAppearance()

module.getHighlightWindowColor = function()
  local blueColor = { red = 50 / 255, green = 138 / 255, blue = 215 / 255, alpha = 1.0 }
  local grayColor = { red = 143 / 255, green = 143 / 255, blue = 143 / 255, alpha = 1.0 }

  return cache.osxApperance == 'graphite' and grayColor or blueColor
end

module.drawBorder = function()
  local focusedWindow = hs.window.focusedWindow()

  if not focusedWindow or focusedWindow:role() ~= "AXWindow" then
    if cache.borderDrawing then
      cache.borderDrawing:hide()
    end

    return
  end

  local alpha       = 0.6
  local borderWidth = 4
  local distance    = 4
  local roundRadix  = 6

  local isFullScreen = focusedWindow:isFullScreen()
  local frame        = focusedWindow:frame()

  if not cache.borderDrawing then
    cache.borderDrawing = hs.drawing.rectangle({ x = 0, y = 0, w = 0, h = 0 })
      :setFill(nil)
      :setStroke(true)
      :setStrokeWidth(borderWidth)
      :setStrokeColor(module.getHighlightWindowColor())
      :setBehaviorByLabels({ 'moveToActiveSpace', 'transient' })
      :setLevel(hs.drawing.windowLevels.normal)
      :setAlpha(alpha)
  end

  if isFullScreen then
    cache.borderDrawing
      :setFrame(frame)
      :setRoundedRectRadii(0, 0)
  else
    cache.borderDrawing
      :setFrame({
        x = frame.x - distance / 2,
        y = frame.y - distance / 2,
        w = frame.w + distance,
        h = frame.h + distance
      })
      :setRoundedRectRadii(roundRadix, roundRadix)
  end

  cache.borderDrawing:show()
end

module.highlightWindow = function(win)
  if window.highlightBorder then
    module.drawBorder()
  end

  if window.highlightMouse then
    local focusedWindow = win or hs.window.focusedWindow()
    if not focusedWindow or focusedWindow:role() ~= "AXWindow" then return end

    local frameCenter = hs.geometry.getcenter(focusedWindow:frame())

    hs.mouse.setAbsolutePosition(frameCenter)
  end
end

return module
