local cache  = {}
local module = { cache = cache }

local STYLE = {
  font = {
    name = hs.styledtext.defaultFonts.menuBar.name,
    size = 12.0
  },
  baselineOffset = 0.0
}

local setMenubarText = function(text)
  cache.menuItem:setTitle(hs.styledtext.new(text, STYLE))
end

local stringifyMinutes = function(minutes)
  local hours   = math.floor(minutes / 60)
  local minutes = minutes % 60

  return string.format('%02d:%02d', hours, minutes)
end

local batteryWatcher = function(_, _, _, _, battery)
  -- fully charged, leave menu item in the menubar so it doesn't move
  if battery.isCharged then
    setMenubarText("ϟ")
    return
  end

  -- we're charging right now
  if battery.isCharging then
    if battery.timeToFullCharge < 0 then
      -- still calculating
      setMenubarText("…")
      return
    end

    -- display leftover charging time
    setMenubarText('⇡ ' .. stringifyMinutes(battery.timeToFullCharge))
    return
  end

  if battery.timeRemaining < 0 then
    -- still calculating
    setMenubarText("…")
    return
  end

  -- we're discharging, display used watts and leftover time
  local wattage = battery.wattage * -1 -- we know we're discharging!
  local time = stringifyMinutes(battery.timeRemaining)

  setMenubarText(string.format('⇣ %.1fW ｜ ', wattage) .. time)
end

module.start = function()
  cache.menuItem = hs.menubar.new(true, 'battery-menubar')
  cache.watcher  = hs.watchable.watch('status.battery', batteryWatcher)
end

module.stop = function()
  cache.watcher:release()
end

return module
