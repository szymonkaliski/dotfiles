local cache  = {}
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

cache.osxApperance = getOSXAppearance()

module.getHighlightWindowColor = function()
  local blueColor = { red = 50 / 255, green = 138 / 255, blue = 215 / 255, alpha = 1.0 }
  local grayColor = { red = 143 / 255, green = 143 / 255, blue = 143 / 255, alpha = 1.0 }

  return cache.osxApperance == 'graphite' and grayColor or blueColor
end

module.drawBorder = function(opts)
  local focusedWindow = hs.window.focusedWindow()

  local alpha         = 0.8
  local borderWidth   = 4
  local distance      = 2
  local roundRadix    = 8

  local fadeTime      = opts and opts.fadeTime or 0.5
  local showTime      = opts and opts.showTime or 0.0

  if not cache.borderDrawing then
    cache.borderDrawing = hs.drawing.rectangle({ x = 0, y = 0, w = 0, h = 0 })
      :setFill(nil)
      :setStroke(true)
      :setStrokeWidth(borderWidth)
      :setStrokeColor(module.getHighlightWindowColor())
      :setBehaviorByLabels({ 'moveToActiveSpace' })
      :setLevel(hs.drawing.windowLevels.floating)
      :setAlpha(alpha)
  end

  if not focusedWindow then
    cache.borderDrawing:hide(fadeTime)
    return
  end

  local isFullScreen = focusedWindow:isFullScreen()
  local frame        = focusedWindow:frame()

  if isFullScreen then
    cache.borderDrawing
      :setFrame(frame)
      :setRoundedRectRadii(0, 0)
  else
    cache.borderDrawing
      :setFrame({
        x = frame.x - borderWidth / 2 - distance / 2,
        y = frame.y - borderWidth / 2 - distance / 2,
        w = frame.w + borderWidth + distance,
        h = frame.h + borderWidth + distance
      })
      :setRoundedRectRadii(roundRadix, roundRadix)
  end

  cache.borderDrawing:show(fadeTime)

  if showTime > 0 then
    if cache.borderDrawingFadeOut then
      cache.borderDrawingFadeOut:stop()
    end

    cache.borderDrawingFadeOut = hs.timer.doAfter(showTime, function()
      cache.borderDrawing:hide(fadeTime)
      cache.borderDrawingFadeOut = nil
    end)
  end
end

module.highlightWindow = function()
  local focusedWindow = hs.window.focusedWindow()

  if not focusedWindow then return end

  if window.highlightMouseCenter then
    local frameCenter = hs.geometry.getcenter(focusedWindow:frame())

    hs.mouse.setAbsolutePosition(frameCenter)
  end

  -- TODO: test if this still works
  if window.highlightBorder then
    module.drawBorder({ fadeTime = 0.5, showTime = 0.5 })
  end
end

return module
