local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/macbook.png'

return function(message)
  hs.notify.new({
    title        = 'ControlPlane',
    subTitle     = message,
    contentImage = imagePath
  }):send()
end
