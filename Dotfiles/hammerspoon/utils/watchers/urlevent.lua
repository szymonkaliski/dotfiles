local module = {}

local browsers = { 'Safari', 'Google Chrome' }

module.start = function()
  -- watch for http and https events and open in currently running browser instead of default one
  -- change default system browser to Hammerspoon for it to work
  hs.urlevent.httpCallback = function(_, _, _, fullURL)
    local runningApplications = hs.application.runningApplications()

    local browser = hs.fnutils.find(runningApplications, function(app)
      return hs.fnutils.contains(browsers, app:name())
    end)

    local browserName = browser and browser:name() or browsers[1]

    hs.applescript.applescript(string.gsub([[
      tell application "{APP_NAME}"
        activate
        open location "{URL}"
      end tell
    ]], '{(.-)}', { APP_NAME = browserName, URL = fullURL }))
  end
end

module.stop = function()
  hs.urlevent.httpCallback = nil
end

return module
