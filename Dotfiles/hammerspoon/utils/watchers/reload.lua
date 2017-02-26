return hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', function(files)
  local shouldReload = false

  for _, file in pairs(files) do
    if file:sub(-4) == '.lua' then
      shouldReload = true
    end
  end

  if shouldReload then
    hs.reload()

    hs.notify.new({
      title    = 'Hammerspoon',
      subTitle = 'Reloaded'
    }):send()
  end
end)
