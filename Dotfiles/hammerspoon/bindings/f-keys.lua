local module = {}

-- map ultra 1-0 to F1-F10, useful for my Ergodox config,
-- and probably will be useful for touchbar macbook

module.start = function()
  local ultra = { 'ctrl', 'alt', 'cmd' }

  hs.fnutils.each({
    { '1',  'F1' },
    { '2',  'F2' },
    { '3',  'F3' },
    { '4',  'F4' },
    { '5',  'F5' },
    { '6',  'F6' },
    { '7',  'F7' },
    { '8',  'F8' },
    { '9',  'F9' },
    { '0', 'F10' }
  }, function(mapping)
    hs.hotkey.bind(ultra, mapping[1], function()
      hs.eventtap.event.newKeyEvent({}, mapping[2], true):post()
      hs.eventtap.event.newKeyEvent({}, mapping[2], false):post()
    end)
  end)
end

module.stop = function()
end

return module
