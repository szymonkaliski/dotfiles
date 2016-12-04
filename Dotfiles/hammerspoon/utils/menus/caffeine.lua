local cache  = {}
local module = { cache = cache }

local iconOff = os.getenv('HOME') .. '/.hammerspoon/assets/caffeine-3-off.png'
local iconOn  = os.getenv('HOME') .. '/.hammerspoon/assets/caffeine-3-on.png'

local updateCaffeineStatus

local updateMenuItem = function()
  local isDisplaySleepPrevented = hs.caffeinate.get('displayIdle')

  local generateCaffeineMenu = function(options)
    return {
      {
        title    = options.statusText,
        disabled = true
      },
      {
        title = options.subStatusText,
        fn    = function() updateCaffeineStatus(options.preventDisplaySleep) end
      }
    }
  end

  if isDisplaySleepPrevented then
    cache.menuItem
      :setMenu(generateCaffeineMenu({
        statusText          = 'Display Sleep: Disabled',
        subStatusText       = 'Enable Display Sleep',
        preventDisplaySleep = false
      }))
      :setIcon(iconOn)
  else
    cache.menuItem
      :setMenu(generateCaffeineMenu({
        statusText          = 'Display Sleep: Enabled',
        subStatusText       = 'Disable Display Sleep',
        preventDisplaySleep = true
      }))
      :setIcon(iconOff)
  end
end

updateCaffeineStatus = function(newStatus)
  if newStatus ~= nil then
    cache.displayIdle = newStatus
  end

  hs.caffeinate.set('displayIdle', cache.displayIdle)

  updateMenuItem()
end

module.start = function()
  cache.displayIdle = hs.settings.get('displayIdle') or false
  cache.menuItem    = hs.menubar.new()

  updateCaffeineStatus()
end

module.stop = function()
  hs.settings.set('displaySleepPrevented', cache.displayIdle)
end

return module
