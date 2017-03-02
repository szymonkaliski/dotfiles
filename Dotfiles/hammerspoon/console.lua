local reloadHS = require('ext.system').reloadHS

local module   = {}

module.init = function()
  -- some global functions for console
  inspect = hs.inspect
  reload  = reloadHS

  dumpWindows = function()
    hs.fnutils.each(hs.window.allWindows(), function(win)
      print(inspect({
        title   = win:title(),
        app     = win:application():name(),
        role    = win:role(),
        subrole = win:subrole()
      }))
    end)
  end
end

return module
