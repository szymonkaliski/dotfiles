return hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', function()
  hs.reload()

  hs.notify.new({
    title    = 'Hammerspoon',
    subTitle = 'Reloaded!'
  }):send()
end)
