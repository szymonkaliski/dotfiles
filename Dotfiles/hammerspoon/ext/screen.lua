local template = require('ext.template')
local module   = {}

module.focusScreen = function(screen)
  local frame = screen:frame()

  -- if mouse is already on the given screen we can safely return
  if hs.geometry(hs.mouse.getAbsolutePosition()):inside(frame) then return false end

  -- "hide" cursor in the lower right side of screen
  -- it's invisible while we are changing spaces
  local mousePosition = {
    x = frame.x + frame.w - 1,
    y = frame.y + frame.h - 1
  }

  -- hs.mouse.setAbsolutePosition doesn't work for gaining proper screen focus
  -- moving the mouse pointer with cliclick (available on homebrew) works
  os.execute(template([[ /usr/local/bin/cliclick m:={X},{Y} ]], { X = mousePosition.x, Y = mousePosition.y }))
  hs.timer.usleep(1000)

  return true
end

return module
