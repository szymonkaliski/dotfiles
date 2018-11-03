-- https://github.com/asmagill/hammerspoon-config/blob/07adccec1ba6b773fccddbaefb5321c5733ed310/_scratch/dash.lua
-- https://github.com/asmagill/hammerspoon-config/blob/07adccec1ba6b773fccddbaefb5321c5733ed310/utils/prompter.lua

local cache = {}
local module = { cache = cache }

local WIDTH = 360
local HEIGHT = 480

local script = [[
]]

local html = [[
]]

module.run = function()
  local frame = hs.mouse.getCurrentScreen():frame()

  cache.webview = hs.webview.new({
    x = frame.x + frame.w / 2 - WIDTH / 2,
    y = frame.y + frame.h / 2 - HEIGHT / 2,
    w = WIDTH,
    h = HEIGHT
  })

  cache.webview:allowTextEntry(true)
  cache.webview:shadow(true)
  cache.webview:html(html)

  cache.webview:show(0.5)

end

return module
