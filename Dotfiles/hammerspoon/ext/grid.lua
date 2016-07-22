local module = {}

-- swap window screens using center between monitors as reflection mirror
-- since I use two monitors of the same size this let's me keep things on the edges to stay on the edges
module.swapScreens = function()
  local reflectScreenCenter = function(geom, screenGeom)
    local center = geom.x + geom.w / 2;
    center       = -center - geom.w / 2

    return hs.geometry.point(center, geom.y)
  end

  hs.fnutils.each(hs.window.visibleWindows(), function(win)
    local reflected             = reflectScreenCenter(win:frame(), win:screen():frame())
    local reflectedFrame        = win:frame()

    reflectedFrame.x            = reflected.x
    reflectedFrame.y            = reflected.y

    local lastAnimDuration      = hs.window.animationDuration
    hs.window.animationDuration = lastAnimDuration * 4

    win:setFrame(reflectedFrame)

    hs.window.animationDuration = lastAnimDuration
  end)
end

return module
