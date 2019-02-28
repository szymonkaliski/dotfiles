-- ctrl-i is tab in terminal, I want both in vim
-- remapping ctrl-i to F6, and mapping it in vim

local cache  = { bindings = {} }
local module = { cache = cache }

local rebindCtrlI = function(appName, options)
  local enabled = options.enabled or false

  if not enabled and cache.bindings[appName] then
    cache.bindings[appName]:disable()
    return
  end

  if cache.bindings[appName] then
    cache.bindings[appName]:enable()
  else
    cache.bindings[appName] = hs.hotkey.bind({ 'ctrl' }, 'i', function()
      hs.eventtap.keyStroke({}, 'F6')
    end)
  end
end

module.start = function()
  cache.filter = hs.window.filter.new({ 'iTerm', 'iTerm2', 'Terminal', 'kitty' })

  cache.filter:subscribe({
    hs.window.filter.windowFocused,
    hs.window.filter.windowUnfocused
  }, function(_, appName, event)
    rebindCtrlI(appName, { enabled = (event == "windowFocused") })
  end)
end

module.stop = function()
  cache.filter:unsubscribeAll()
end

return module
