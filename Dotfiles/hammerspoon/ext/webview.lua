local module = {}

local openSearchView = function(searchText)
  local screenFrame = hs.screen.mainScreen():frame()

  local w = 640
  local h = 920
  local x = screenFrame.x + screenFrame.w / 2 - w / 2
  local y = screenFrame.y + screenFrame.h / 2 - h / 2

  local url = 'https://duckduckgo.com/?q=' .. searchText:gsub(' ', '+')

  local searchView = hs.webview.new({ x = x, y = y, w = w, h = h })
    :url(url)
    :windowStyle({ 'closable', 'titled', 'resizable', 'utility', 'HUD', 'nonactivating' })
    :closeOnEscape(true)
    :deleteOnClose(true)
    :allowTextEntry(true)
    :allowMagnificationGestures(true)
    :allowNavigationGestures(true)
    :windowTitle(searchText)
    :show()

  searchView
    :asHSDrawing()
    :setAlpha(0.9)

  local win = searchView:asHSWindow()
  if win then win:becomeMain() end
end

module.search = function()
 local _, res = hs.applescript([[
   text returned of (display dialog "Search for:" default answer "")
 ]])

 if type(res) == 'string' then
   openSearchView(res)
 end
end

-- module.prompt = function()
--   local screenFrame = hs.screen.mainScreen():fullFrame()
--   local label       = ""
--   local frame       = { x = screenFrame.x + screenFrame.w / 2, y = screenFrame.y + screenFrame.h / 4, w = 1, h = 1 }
--   local callback    = function(input) print("prompter result:"..tostring(input)) end

--   local uccName = "prompter" .. hs.host.uuid():gsub("-","")
--   local view
--   local ucc = hs.webview.usercontent.new(uccName):setCallback(function(input)
--     if callback then
--       callback(input.body)
--     end

--     view:delete()
--   end)

--   view = hs.webview.new(frame, { developerExtrasEnabled = true }, ucc):html([[
--   <DOCTYPE html>
--   <script type="text/javascript">
--     window.alert("]] .. label .. [[");

--     /*
--     try {
--       webkit.messageHandlers.]] .. uccName .. [[.postMessage(textMsg);
--     }
--     catch(err) {
--       console.log('Controller ]] .. uccName .. [[ does not exist');
--       console.log(err)
--     }
--     */
--   </script>
--   ]]):show()

--   view:level(hs.drawing.windowLevels.screenSaver)

--   return view
-- end

return module
