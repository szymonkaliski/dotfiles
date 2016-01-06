local module = {}
local cache  = {}

module.highlightWindow = function()
  local borderWidth   = 6

  local setBorderFrame = function(borderDrawing)
    local focusedWindow = hs.window.focusedWindow()

    if not borderDrawing then
      return
    end

    if not focusedWindow then
      borderDrawing:delete()
      borderDrawing = nil

      return
    end

    local isFullScreen = focusedWindow:isFullScreen()
    local frame        = focusedWindow:frame()

    if isFullScreen then
      borderDrawing
        :setFrame(frame)
        :setRoundedRectRadii(0, 0)
    else
      borderDrawing
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

  local updateFrame = function()
    if cache.borderDrawing then setBorderFrame(cache.borderDrawing) end
  end

  cache.borderDrawing = cache.borderDrawing or hs.drawing.rectangle({ x = 0, y = 0, w = 0, h = 0 })

  cache.borderDrawing
    :setFill(nil)
    :setStroke(true)
    :setStrokeWidth(borderWidth)
    :setStrokeColor({ red = 145 / 255, green = 196 / 255, blue = 239 / 255, alpha = 1.0 })
    :setAlpha(0)
    :show()

  if cache.borderDrawingAnimation then
    cache.borderDrawingAnimation:stop()
  end

  cache.borderDrawingAnimation = module.animateAlpha(cache.borderDrawing, 0.75, {
    update = updateFrame,
    done   = function()
      cache.borderDrawingAnimation = module.animateAlpha(cache.borderDrawing, 0.0, {
        update = updateFrame,
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
  return hs.timer.doUntil(
    function()
      local isDone = math.abs(drawing:alpha() - target) <= 0.01

      if isDone and options.done then options.done() end

      return isDone
    end,
    function()
      local k = 0.1

      if options.update then options.update() end

      drawing:setAlpha(drawing:alpha() * (1 - k) + target * k)
    end,
    0.01
  )
end

return module
