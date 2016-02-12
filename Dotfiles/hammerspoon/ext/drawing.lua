local module = {}
local cache  = {}

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
  local blueColor = { red = 145 / 255, green = 196 / 255, blue = 239 / 255, alpha = 1.0 }
  local grayColor = { red = 143 / 255, green = 143 / 255, blue = 143 / 255, alpha = 1.0 }

  return getOSXAppearance() == 'graphite' and grayColor or blueColor
end

local getBezelColors = function()
  local whiteBezel = {
    fill = { red = 1, green = 1, blue = 1, alpha = 1.0 },
    text = { red = 0.43, green = 0.43, blue = 0.43, alpha = 1.0 }
  }

  local blackBezel = {
    fill = { red = 0.43, green = 0.43, blue = 0.43, alpha = 1.0 },
    text = { red = 1, green = 1, blue = 1, alpha = 1.0 }
  }

  return getOSXAppearance() == 'graphite' and blackBezel or whiteBezel
end

local highlightWindowColor = getHighlightWindowColor()
local bezelColors          = getBezelColors()

-- simple bezel-like notifications
-- imitate (poorly) brightness/volume style
module.bezel = function(text, textSize)
  -- if there's a timer, stop it - we always wait after last bezel info was displayed
  hs.fnutils.each({ cache.timer, cache.bezelTimer, cache.textTimer }, function(timer)
    if timer then timer:stop() end
  end)

  textSize = textSize or 27

  local screenFrame = hs.screen.mainScreen():frame()
  local size        = 200

  local bezelRect = {
    x = screenFrame.w / 2 - size / 2,
    y = screenFrame.h - 340,
    w = size,
    h = size
  }

  local textRect = {
    x = bezelRect.x,
    y = bezelRect.y + size / 2 - textSize + textSize / 3,
    w = size,
    h = size
  }

  cache.bezelDrawing = cache.bezelDrawing or hs.drawing.rectangle(bezelRect)
    :setBehaviorByLabels({ 'canJoinAllSpaces', 'stationary' })
    :setLevel(hs.drawing.windowLevels.overlay)
    :setStroke(false)
    :setFillColor(bezelColors.fill)
    :setRoundedRectRadii(24, 24)
    :show()

  cache.bezelDrawing:setAlpha(0.7)

  -- it's easier to remove text and re-add it
  if cache.textDrawing then
    cache.textDrawing:delete()
  end

  cache.textDrawing = hs.drawing.text(textRect, text)
    :setBehaviorByLabels({ 'canJoinAllSpaces', 'stationary' })
    :setLevel(hs.drawing.windowLevels.overlay)
    :setTextStyle({
      alignment = 'center',
      size      = textSize,
      color     = bezelColors.text
    })
    :show()

  cache.timer = hs.timer.doAfter(2, function()
    cache.bezelTimer = module.animateAlpha(cache.bezelDrawing, 0, {
      done = function()
        cache.bezelDrawing:delete()
        cache.bezelDrawing = nil
      end
    })

    cache.textTimer = module.animateAlpha(cache.textDrawing, 0, {
      done = function()
        cache.textDrawing:delete()
        cache.textDrawing = nil
      end
    })
  end)
end

module.highlightWindow = function()
  local borderWidth = 10

  local setBorderFrame = function()
    local focusedWindow = hs.window.focusedWindow()

    if not cache.borderDrawing then
      return
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
          x = frame.x - borderWidth / 2 - 2,
          y = frame.y - borderWidth / 2 - 2,
          w = frame.w + borderWidth + 4,
          h = frame.h + borderWidth + 4
        })
        :setRoundedRectRadii(borderWidth, borderWidth)
    end

    return borderDrawing
  end

  if not cache.borderDrawing then
    cache.borderDrawing = hs.drawing.rectangle({ x = 0, y = 0, w = 0, h = 0 })
      :setFill(nil)
      :setStroke(true)
      :setStrokeWidth(borderWidth)
      :setStrokeColor(highlightWindowColor)
      :setAlpha(0)
      :show()
  end

  if cache.borderDrawingAnimation then
    cache.borderDrawingAnimation:stop()
  end

  cache.borderDrawingAnimation = module.animateAlpha(cache.borderDrawing, 0.75, {
    speed  = 0.2,
    update = setBorderFrame,
    done   = function()
      cache.borderDrawingAnimation = module.animateAlpha(cache.borderDrawing, 0.0, {
        speed  = 0.2,
        update = setBorderFrame,
        done   = function()
          if cache.borderDrawing then
            cache.borderDrawing:delete()
            cache.borderDrawing          = nil
            cache.borderDrawingAnimation = nil
          end
        end
      })
    end
  })
end

module.animateAlpha = function(drawing, target, options)
  options = options or {}

  return hs.timer.doUntil(
    function()
      local isDone = math.abs(drawing:alpha() - target) <= 0.01

      if isDone then
        drawing:setAlpha(target)

        if options.done then options.done() end
      end

      return isDone
    end,
    function()
      local k = options.speed or 0.1

      if options.update then options.update() end

      drawing:setAlpha(drawing:alpha() * (1 - k) + target * k)
    end,
    0.01
  )
end

return module
