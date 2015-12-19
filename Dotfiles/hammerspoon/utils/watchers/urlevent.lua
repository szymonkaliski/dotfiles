local keys     = require('ext.table').keys
local template = require('ext.template');
local module   = {}

-- watch for http and https events and open in currently running browser instead of default one
-- click with 'cmd' to open in background
-- change default system browser to Hammerspoon for it to work
module.start = function()
  hs.urlevent.httpCallback = function(_, _, _, fullURL)
    local modifiers = hs.eventtap.checkKeyboardModifiers()
    local isCmd     = modifiers['cmd'] == true

    local runningBrowser = hs.fnutils.find(urlevent.browserPreference, function(browserName)
      return hs.application.get(browserName) ~= nil
    end)

    local browserName = runningBrowser or urlevent.browserPreference[1]

    hs.applescript.applescript(template([[
      tell application "{APP_NAME}"
        {ACTIVATE}
        open location "{URL}"
      end tell
    ]], {
      APP_NAME = browserName,
      URL      = fullURL,
      ACTIVATE = not isCmd and 'activate' or '' -- 'activate' brings to front if cmd is not clicked
    }))
  end
end

module.stop = function()
  hs.urlevent.httpCallback = nil
end

return module
