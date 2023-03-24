local annotator = require('hhann')
local module    = {}

module.start = function()
  local ultra  = { 'ctrl', 'alt', 'cmd' }
  local hotkey = hs.hotkey.modal.new(ultra, 'a')

  function hotkey:entered()
    annotator.start()
    annotator.startAnnotating()
  end

  function hotkey:exited()
    annotator.stopAnnotating()
    annotator.hide()
  end

  hotkey:bind(ultra, 'c', function() annotator.clear()            end)
  hotkey:bind(ultra, 'a', function() hotkey:exit()                end)
  hotkey:bind(ultra, 't', function() annotator.toggleAnnotating() end)
end

module.stop = function()
end

return module
