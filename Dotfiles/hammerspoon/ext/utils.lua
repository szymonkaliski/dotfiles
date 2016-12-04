local module = {}

-- run function without window animation
module.noAnim = function(callback)
  local lastAnimDuration      = hs.window.animationDuration
  hs.window.animationDuration = 0

  callback()

  hs.window.animationDuration = lastAnimDuration
end

return module
