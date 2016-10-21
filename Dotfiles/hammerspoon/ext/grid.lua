local module = {}

-- swap window screens using center between monitors as reflection mirror
-- since I use two monitors of the same size this is very useful,
-- but will probably break on different sized displays
module.swapScreens = function()
  local reflectScreenCenter = function(geom, screenGeom)
    local p = hs.geometry.point(geom.x, geom.y)

    if geom.x > screenGeom.w then
      local diff = geom.x - screenGeom.w
      p.x = screenGeom.w - diff - geom.w
    else
      local diff = screenGeom.w - geom.x
      p.x = screenGeom.w + diff - geom.w
    end

    return p
  end

  hs.fnutils.each(hs.window.visibleWindows(), function(win)
    print(win:title(), win:frame().x, win:screen():frame().x)

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
