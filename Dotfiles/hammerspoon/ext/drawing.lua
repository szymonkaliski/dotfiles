local module = {}

module.highlightWindow = function()
  local focusedWindow = hs.window.focusedWindow()

  if not focusedWindow then return end

  local borderWidth = 6

  local frame  = focusedWindow:frame()
  local border = hs.drawing.rectangle({
    x = frame.x - borderWidth / 2,
    y = frame.y - borderWidth / 2,
    w = frame.w + borderWidth,
    h = frame.h + borderWidth
  })

  border
    :setFill(nil)
    :setStroke(true)
    :setStrokeWidth(borderWidth)
    :setStrokeColor({ red = 145 / 255, green = 196 / 255, blue = 239 / 255, alpha = 1.0 })
    :setRoundedRectRadii(8, 8)
    :setAlpha(0)
    :show()

  module.animateAlpha(border, 0.75, function()
    module.animateAlpha(border, 0.0, function()
      border:delete()
    end)
  end)
end

module.animateAlpha = function(drawing, target, callback)
  return hs.timer.doUntil(
    function()
      local isDone = math.abs(drawing:alpha() - target) <= 0.01

      if isDone and callback then callback() end

      return isDone
    end,
    function()
      local k = 0.1
      drawing:setAlpha(drawing:alpha() * (1 - k) + target * k)
    end,
    0.01
  )
end

return module
