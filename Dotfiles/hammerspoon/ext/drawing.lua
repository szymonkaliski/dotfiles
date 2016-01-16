local module = {}
local cache  = {}

module.highlightWindow = function()
  local borderWidth   = 6

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
          x = frame.x - borderWidth / 2,
          y = frame.y - borderWidth / 2,
          w = frame.w + borderWidth,
          h = frame.h + borderWidth
        })
        :setRoundedRectRadii(8, 8)
    end

    return borderDrawing
  end

  if not cache.borderDrawing then
    cache.borderDrawing = hs.drawing.rectangle({ x = 0, y = 0, w = 0, h = 0 })
      :setFill(nil)
      :setStroke(true)
      :setStrokeWidth(borderWidth)
      :setStrokeColor({ red = 145 / 255, green = 196 / 255, blue = 239 / 255, alpha = 1.0 })
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
