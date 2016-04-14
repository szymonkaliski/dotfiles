local application = require('ext.application')

return hs.application.watcher.new(function(name, event, app)
  if event == hs.application.watcher.activated then
    if hs.fnutils.some({ 'Safari', 'Google Chrome' }, function(appName) return appName == name end) then
      application.askBeforeQuitting(name, { enabled = true })
    end
  end

  if event == hs.application.watcher.deactivated or event == hs.application.watcher.terminated then
    if hs.fnutils.some({ 'Safari', 'Google Chrome' }, function(appName) return appName == name end) then
      application.askBeforeQuitting(name, { enabled = false })
    end
  end
end)
