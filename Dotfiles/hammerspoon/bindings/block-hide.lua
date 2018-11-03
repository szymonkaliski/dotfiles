local module = {}

-- I keep hitting cmd-h by mistake, and I never use it

local noop = function() end

module.start = function()
  hs.hotkey.bind({ 'cmd' }, 'h', noop)
  hs.hotkey.bind({ 'cmd', 'alt' }, 'h', noop)
end

module.stop = function()
end

return module
