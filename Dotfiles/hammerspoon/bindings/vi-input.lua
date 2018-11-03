-- TODO: add visual mode: https://github.com/harob/dotfiles/blob/master/.hammerspoon/vim.lua#L248

local Modal = require('ext.modal')

local module = {}

module.start = function()
  local viModal = Modal:new({
    name = 'vi input',
    timeout = 0
  })

  -- hjkl
  hs.fnutils.each({
    { key = 'h', dir = 'Left' },
    { key = 'l', dir = 'Right' },
    { key = 'j', dir = 'Down' },
    { key = 'k', dir = 'Up' }
  }, function(obj)
    local keyStroke = function() hs.eventtap.keyStroke({}, obj.dir) end

    -- viModal:bind({}, obj.key, keyStroke, keyStroke)
    viModal:bind({}, obj.key, keyStroke)
  end)

  -- word motions
  local nextWordBegin = function()
    hs.eventtap.keyStroke({ 'alt' }, 'Right')
    hs.eventtap.keyStroke({ 'alt' }, 'Right')
    hs.eventtap.keyStroke({ 'alt' }, 'Left')
  end

  local nextWordEnd = function()
    hs.eventtap.keyStroke({ 'alt' }, 'Right')
  end

  local prevWord = function()
    hs.eventtap.keyStroke({ 'alt' }, 'Left')
  end

  viModal:bind({}, 'w', nextWordBegin)
  viModal:bind({}, 'e', nextWordEnd)
  viModal:bind({}, 'b', prevWord)

  -- line motions (H/L)
  local lineBegin = function()
    hs.eventtap.keyStroke({ 'cmd' }, 'Left')
  end

  local lineEnd = function()
    hs.eventtap.keyStroke({ 'cmd' }, 'Left')
  end

  viModal:bind({}, '0', lineBegin)
  viModal:bind({ 'shift' }, 'h', lineBegin)

  viModal:bind({ 'shift' }, '4', lineEnd)
  viModal:bind({ 'shift' }, 'l', lineEnd)

  -- begin/end of text - g/G
  local textBegin = function()
    hs.eventtap.keyStroke({ 'cmd' }, 'Up')
  end

  local textEnd = function()
    hs.eventtap.keyStroke({ 'cmd' }, 'Down')
  end

  viModal:bind({}, 'g', textBegin)
  viModal:bind({ 'shift' }, 'g', textEnd)

  -- insert/append
  viModal:bind({}, 'i', function()
    viModal.modal:exit()
  end)

  viModal:bind({}, 'I', function()
    hs.eventtap.keyStroke({ 'cmd' }, 'Left')
    viModal.modal:exit()
  end)

  viModal:bind({}, 'a', function()
    hs.eventtap.keyStroke({}, 'Right')
    -- normal:exit()
  end)

  viModal:bind({ 'shift' }, 'a', function()
    hs.eventtap.keyStroke({ 'cmd' }, 'Right')
    viModal.modal:exit()
  end)

  -- delete
  viModal:bind({}, 'd', function()
    hs.eventtap.keyStroke({}, 'delete')
  end)

  viModal:bind({}, 'x', function()
    hs.eventtap.keyStroke({}, 'forwarddelete')
  end)

  -- search
  viModal:bind({}, '/', function()
    hs.eventtap.keyStroke({ 'cmd' }, 'f')
  end)

  -- undo
  viModal:bind({}, 'u', function()
    hs.eventtap.keyStroke({ 'cmd' }, 'z')
  end)

  -- <c-r> - redo
  viModal:bind({ 'ctrl' }, 'r', function()
    hs.eventtap.keyStroke({ 'cmd', 'shift' }, 'z')
  end)

  -- y - yank
  viModal:bind({}, 'y', function()
    hs.eventtap.keyStroke({ 'cmd' }, 'c')
  end)

  -- p - paste
  viModal:bind({}, 'p', function()
    hs.eventtap.keyStroke({ 'cmd' }, 'v')
  end)

  -- ctrl-i to start vi insert
  -- FIXME: bad idea, think of something else...
  hs.hotkey.bind({ 'ctrl' }, 'i', function()
    viModal.modal:enter()
  end)
end

module.stop = function()
end

return module

