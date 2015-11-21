local application = require('ext.application')

return hs.application.watcher.new(function(name, event, app)
  if (event == hs.application.watcher.activated) then
    if hs.fnutils.some({ 'Finder', 'iTerm2' }, function(appName) return appName == name end) then
      app:selectMenuItem({ 'Window', 'Bring All to Front' })
    end
  end

  if (event == hs.application.watcher.activated) then
    if hs.fnutils.some({ 'Safari', 'Google Chrome' }, function(appName) return appName == name end) then
      application.askBeforeQuitting(name, true)
    end
  end

  if (event == hs.application.watcher.deactivated) then
    if hs.fnutils.some({ 'Safari', 'Google Chrome' }, function(appName) return appName == name end) then
      application.askBeforeQuitting(name, false)
    end
  end
end)
