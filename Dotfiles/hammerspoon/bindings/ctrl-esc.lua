-- adapted from https://github.com/jasonrudolph/ControlEscape.spoon

local cache  = {}
local module = { cache = cache }
local log    = hs.logger.new('ctrl-esc', 'debug');

local CANCEL_DELAY_SECONDS = 0.75

module.reset = function()
  cache.sendEscape = false
  cache.lastModifiers = {}
end

module.start = function()
  -- if `control` is held for this long, don't send `escape`
  cache.controlKeyTimer = hs.timer.delayed.new(CANCEL_DELAY_SECONDS, function()
    cache.sendEscape = false
  end)

  -- create an eventtap to run each time the modifier keys change (i.e., each
  -- time a key like control, shift, option, or command is pressed or released)
  cache.controlTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
    local newModifiers = event:getFlags()

    -- if this change to the modifier keys does not invole a *change* to the
    -- up/down state of the `control` key (i.e., it was up before and it's
    -- still up, or it was down before and it's still down), then don't take
    -- any action
    if cache.lastModifiers['ctrl'] == newModifiers['ctrl'] then
      return false
    end

    -- if the `control` key has changed to the down state, then start the
    -- timer. If the `control` key changes to the up state before the timer
    -- expires, then send `escape`
    if not cache.lastModifiers['ctrl'] then
      cache.lastModifiers = newModifiers
      cache.sendEscape = true
      cache.controlKeyTimer:start()
    else
      if cache.sendEscape then
        hs.eventtap.event.newKeyEvent({}, 'escape', true):post()
        hs.eventtap.event.newKeyEvent({}, 'escape', false):post()
      end

      cache.lastModifiers = newModifiers
      cache.controlKeyTimer:stop()
    end

    return false
  end)

  -- create an eventtap to run each time a normal key (i.e., a non-modifier key)
  -- enters the down state. We only want to send `escape` if `control` is
  -- pressed and released in isolation. If `control` is pressed in combination
  -- with any other key, we don't want to send `escape`
  cache.keyDownEventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function()
    cache.sendEscape = false
    return false
  end)

  -- this module should only run if I'm not using Ergodox
  -- ideally I could use eventtap based on input device, but for now this will do
  cache.watcher = hs.watchable.watch('status.isErgodoxAttached', function(_, _, _, _, isErgodoxAttached)
    if isErgodoxAttached then
      log.d('stopping...')
      module.stop()
    else
      log.d('starting...')
      module.reset()

      cache.controlTap:start()
      cache.keyDownEventTap:start()
    end
  end)
end

module.stop = function()
  -- FIXME: this breaks with `attempting to call nil value` on `:release`?
  -- cache.watcher:release()

  -- stop monitoring keystrokes
  cache.controlTap:stop()
  cache.keyDownEventTap:stop()
  cache.controlKeyTimer:stop()

  -- reset state
  module.reset()
end

return module
