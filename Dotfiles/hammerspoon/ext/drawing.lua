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

local getHighlightWindowColor = function()
  local blueColor = { red = 50 / 255, green = 138 / 255, blue = 215 / 255, alpha = 1.0 }
  local grayColor = { red = 143 / 255, green = 143 / 255, blue = 143 / 255, alpha = 1.0 }

  return getOSXAppearance() == 'graphite' and grayColor or blueColor
end

module.highlightWindow = function()
  local focusedWindow = hs.window.focusedWindow()

  if window.highlightMouseCenter then
    local frameCenter = hs.geometry.getcenter(focusedWindow:frame())

    hs.mouse.setAbsolutePosition(frameCenter)
  end

  if window.highlightBorder then
    local borderWidth = 6
    local fadeTime    = 0.5
    local stickTime   = 1.0
    local distance    = 4

    if not cache.borderDrawing then
      cache.borderDrawing = hs.drawing.rectangle({ x = 0, y = 0, w = 0, h = 0 })
        :setFill(nil)
        :setStroke(true)
        :setStrokeWidth(borderWidth)
        :setStrokeColor(getHighlightWindowColor())
        :setAlpha(0.75)
    end

    if not focusedWindow then
      cache.borderDrawing:delete()
      cache.borderDrawing = nil

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
        :setRoundedRectRadii(borderWidth, borderWidth)
    end

    cache.borderDrawing:show(fadeTime)

    if cache.borderDrawingFadeOut then
      cache.borderDrawingFadeOut:stop()
    end

    cache.borderDrawingFadeOut = hs.timer.doAfter(stickTime, function()
      cache.borderDrawing:hide(fadeTime)
      cache.borderDrawingFadeOut = nil
    end)
  end
end

return module
