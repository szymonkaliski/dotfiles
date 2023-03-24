local windowMetadata = require('ext.window').windowMetadata
local template       = require('ext.template')
local log            = hs.logger.new("screenshot-with-meta", "debug")

local module = {}

local ADD_OCR_TO_IMAGE_PATH = os.getenv('HOME') .. '/Documents/Code/Scripts/add-ocr-to-image'
local SCREENSHOT_PATH       = os.getenv('HOME') .. '/Documents/Dropbox/Screenshots/'

local SCREENCAPTURE_PATH    = '/usr/sbin/screencapture'
local XATTR_PATH            = '/usr/bin/xattr'

local genScreenshotPath = function()
  local screenshotName = os.date('Screenshot %Y-%m-%d at %H.%M.%S.png')
  local fileName       = SCREENSHOT_PATH .. screenshotName
  return fileName
end

local sendNotification = function(fileName)
  local revealFile = function()
    os.execute('open -R "' .. fileName .. '"')
  end

  hs.notify.new(revealFile, {
    title        = 'Screenshot',
    subTitle     = 'Captured!',
    contentImage = fileName
  }):send()
end

local addMetaToScreenshot = function(win, fileName)
  local title, meta  = windowMetadata(win)
  local safeFileName = template([["{FILE}"]], { FILE = fileName })

  if meta ~= nil then
    -- URLs have to be double quoted, hence the `'"{META}"'`
    local kMDItemWhereFroms = ' -w com.apple.metadata:kMDItemWhereFroms ' .. template([['"{META}"']], { META = meta }) .. ' '
    local command = XATTR_PATH .. kMDItemWhereFroms .. safeFileName
    os.execute(command)
  end

  -- adds OCR to the image
  hs.task.new(
    ADD_OCR_TO_IMAGE_PATH,
    function(exitCode, stdOut, stdErr)
      if exitCode == 0 then
        return
      end

      hs.notify.new({
        title    = "Screenshot OCR failed",
        subTitle = "Look into Hammerspoon Console for more info"
      }):send()

      log.e(stdOut)
      log.e(stdErr)
    end,
    { fileName }
  ):start()

  -- storing title doesn't seem to work - the metadata is there, but mdfind is not importing it
  -- another idea would be to store an array in kMDItemWhereFroms, first entry would be the tile, and then the URL:
  --
  -- ```bash
  -- url="http://example.com"
  -- hexdump=$(echo "<plist><array><string>${url}</string></array></plist>" | /usr/bin/plutil -convert binary1 -o - - | /usr/bin/xxd -p | /usr/bin/tr -d "\n")
  -- /usr/bin/xattr -w com.apple.metadata:kMDItemWhereFroms "${hexdump}" "${file}"
  -- ```
  --
  -- source: https://github.com/reitermarkus/quarantine/blob/master/commands.md
  --
  -- if title ~= nil then
  --   local kMDItemTitle = ' -w com.apple.metadata:kMDItemTitle ' .. template([["{TITLE}"]], { TITLE = title })
  --   local command = XATTR_PATH .. kMDItemTitle .. safeFileName
  --   os.execute(command)
  -- end
end

module.start = function()
  -- capture the main screen
  -- TODO: capture screen with mouse, not sure how to calculate this for screencapture though
  hs.hotkey.bind({ 'cmd', 'shift' }, '3', function()
    local focusedWindow = hs.window.frontmostWindow()
    local fileName      = genScreenshotPath()

    hs.task.new(
      SCREENCAPTURE_PATH,
      function()
        hs.pasteboard.setContents(fileName)
        sendNotification(fileName)
        addMetaToScreenshot(focusedWindow, fileName)
      end,
      { "-D1", fileName }
    ):start()
  end)

  -- normal picker, with additional metadata for focused window
  hs.hotkey.bind({ 'cmd', 'shift' }, '4', function()
    local focusedWindow = hs.window.frontmostWindow()
    local fileName      = genScreenshotPath()

    hs.task.new(
      SCREENCAPTURE_PATH,
      function()
        hs.pasteboard.setContents(fileName)
        sendNotification(fileName)
        addMetaToScreenshot(focusedWindow, fileName)
      end,
      { "-i", fileName }
    ):start()
  end)

  -- fullscreen window screenshot
  --
  -- not using `hs.window.focusedWindow():snapshot():saveToFile(fileName)` because there's no window shadow then
  -- not using `-l` flag for `screencapture` since the window id it requires is _not_ the window id that Hammerspoon tracks
  --
  -- mouse click timings are fairly arbitrary, but seem to work
  hs.hotkey.bind({ 'cmd', 'shift' }, '6', function()
    local focusedWindow = hs.window.frontmostWindow()

    if not focusedWindow then
      return
    end

    local fileName      = genScreenshotPath()
    local mousePosition = hs.mouse.absolutePosition()
    local windowCenter  = hs.geometry.getcenter(focusedWindow:frame())

    -- center mouse in the window frame
    hs.mouse.absolutePosition(windowCenter)

    -- after we start the task above, the screencapture is running until the mouse click happens,
    -- that's why the `addMetaToScreenshot` is inside the callback when screencapture terminates,
    -- it will run _after_ the code which simulates mouse click:

    hs.task.new(
      SCREENCAPTURE_PATH,
      function()
        hs.pasteboard.setContents(fileName)
        sendNotification(fileName)
        addMetaToScreenshot(focusedWindow, fileName)
      end,
      { "-w", fileName }
    ):start()

    -- click
    hs.timer.usleep(100000)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, windowCenter):post()
    hs.timer.usleep(2000)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, windowCenter):post()

    -- restore original mouse position
    hs.mouse.absolutePosition(mousePosition)
  end)
end

module.stop = function()
end

return module
