local cache = {}

-- simple bezel-like notifications
-- imitate (poorly) brightness/volume style
return function(text, textSize)
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
    :setFillColor({ red = 1, green = 1, blue = 1, alpha = 0.15 })
    :setRoundedRectRadii(24, 24)
    :show()

  -- it's easier to remove text and re-add it
  if cache.textDrawing then
    cache.textDrawing:delete()
  end

  cache.textDrawing = hs.drawing.text(textRect, text)
    :setBehaviorByLabels({ 'canJoinAllSpaces', 'stationary' })
    :setLevel(hs.drawing.windowLevels.overlay)
    :setTextStyle({
      alignment = 'center',
      size      = textSize
    })
    :show()

  -- if there's a timer, stop it
  -- we always wait after last bezel info was displayed
  if cache.timer then cache.timer:stop() end

  -- TODO: add animation like in OS X bezels
  cache.timer = hs.timer.doAfter(2, function()
    cache.bezelDrawing:delete()
    cache.textDrawing:delete()

    cache.bezelDrawing = nil
    cache.textDrawing  = nil
  end)
end
