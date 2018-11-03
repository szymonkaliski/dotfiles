local cache  = {}
local module = { cache = cache }

local IMAGE_PATH = os.getenv('HOME') .. '/.hammerspoon/assets/health.png'

local MESSAGES = {
  'Stretch for a while',
  'Drink some water',
  'Stand up and walk for a bit',
  'Look away from the screen'
}

local MIN_DELAY = 15
local MAX_DELAY = 45

local randomMessage = function()
  return MESSAGES[math.random(#MESSAGES)]
end

local sendMessage = function()
  hs.notify.new({
    title        = 'Microbreak',
    subTitle     = randomMessage(),
    contentImage = IMAGE_PATH
  }):send()
end

local randomDelay = function()
  return math.random(MIN_DELAY, MAX_DELAY) * 60
end

local scheduleNextMessage

scheduleNextMessage = function()
  cache.timer = hs.timer.doAfter(randomDelay(), function()
    sendMessage()
    scheduleNextMessage()
  end)
end

module.start = function()
  scheduleNextMessage()
end

module.stop = function()
  cache.timer:stop()
end

return module
