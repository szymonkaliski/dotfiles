local animateAlpha = require('ext.drawing').animateAlpha

local cache = {}

-- simple bezel-like notifications
-- imitate (poorly) brightness/volume style
return function(text, textSize)
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
    :setFillColor({ red = 1, green = 1, blue = 1, alpha = 1.0 })
    :setRoundedRectRadii(24, 24)
    :show()

  cache.bezelDrawing:setAlpha(0.15)

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
      color     = { red = 0.43, green = 0.43, blue = 0.43, alpha = 1.0 }
    })
    :show()

  cache.timer = hs.timer.doAfter(2, function()
    cache.bezelTimer = animateAlpha(cache.bezelDrawing, 0, {
      done = function()
        cache.bezelDrawing:delete()
        cache.bezelDrawing = nil
      end
    })

    cache.textTimer = animateAlpha(cache.textDrawing, 0, {
      done = function()
        cache.textDrawing:delete()
        cache.textDrawing = nil
      end
    })
  end)
end
