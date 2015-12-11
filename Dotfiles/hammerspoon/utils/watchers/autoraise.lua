local module = {}
local cache  = {}

module.start = function()
  cache.eventtap = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, function()
    local screen   = hs.mouse.getCurrentScreen()
    local mousePos = hs.mouse.getRelativePosition()

    local windowsOnScreen = hs.fnutils.filter(hs.window.orderedWindows(), function(win)
      return win:screen() == screen
    end)

    local pickedWindow = hs.fnutils.find(windowsOnScreen, function(win)
      return hs.geometry.isPointInRect(mousePos, win:frame()) 
    end)

    if pickedWindow then
      pickedWindow:focus()
    end
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
