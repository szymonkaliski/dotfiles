local cache  = {}
local module = { cache = cache }

local ICON   = os.getenv('HOME') .. '/.hammerspoon/assets/task.png'

local splitLines = function(str)
  local t = {}

  local helper = function(line)
    table.insert(t, line)
    return ""
  end

  helper(str:gsub("(.-)\r?\n", helper))

  return t
end

local timeStringToNumber = function(dateStr)
  local hours   = tonumber(string.sub(dateStr, 1, 2));
  local minutes = tonumber(string.sub(dateStr, 4, 5));

  return hours * 60 + minutes
end

local numberToDuration = function(num)
  local hours   = math.floor(num / 60)
  local minutes = math.floor(num - hours * 60)

  if hours > 0 then
    return string.format("%02dh %02dm", hours, minutes)
  else
    return string.format("%02dm", minutes)
  end
end

local getTitle = function(line)
  return line:gsub('^• ', ''):gsub(' .Tracking.', '')
end

local getTimeSpan = function(line)
  return line:gsub('^    today at ', '')
end

local buildMenu = function(lines)
  local menuItems = {}

  for idx=1,#lines - 1,2 do
    local timeSpan = hs.styledtext.new(getTimeSpan(lines[idx + 1]) .. "\t", {
      font = {
        name = hs.styledtext.defaultFonts.menu,
        size = 10.0
      }
    })

    local taskName = hs.styledtext.new(getTitle(lines[idx]), {
      font = {
        name = hs.styledtext.defaultFonts.menu,
        size = 13.0
      }
    })

    table.insert(menuItems, { title = timeSpan .. taskName })
  end

  return menuItems
end

local updateMenubar = function()
  hs.task.new(
    '/usr/local/bin/icalBuddy',
    function(_, stdOut)
      if string.len(stdOut) == 0 then
        if cache.menuItem then
          cache.menuItem:delete()
          cache.menuItem = nil
        end

        return
      end

      if not cache.menuItem then
        cache.menuItem = hs.menubar.new()
        cache.menuItem:setIcon(ICON)
      end

      local lines              = splitLines(stdOut)
      local currentTask        = getTitle(lines[1])
      local startTime          = getTimeSpan(lines[2]):sub(0, 5)
      local endTime            = getTimeSpan(lines[2]):sub(9, 14)
      local currentTime        = os.date('%H:%M')

      local startTimeMinutes   = timeStringToNumber(startTime)
      local endTimeMinutes     = timeStringToNumber(endTime)
      local currentTimeMinutes = timeStringToNumber(currentTime)

      if currentTimeMinutes >= startTimeMinutes then
        local timeLeftMinutes = endTimeMinutes - currentTimeMinutes
        local text = currentTask .. ' ' .. numberToDuration(timeLeftMinutes)

        cache.menuItem:setTitle(hs.styledtext.new(text, {
          font = {
            name = hs.styledtext.defaultFonts.menuBar.name,
            size = 11.0
          },
          baselineOffset = -1.0
        }))
      else
        cache.menuItem:setTitle()
      end

      cache.menuItem:setMenu(buildMenu(lines))
    end,
    { '-ea', '-ic', 'Tracking', 'eventsFrom:now', 'to:today' }
  ):start()
end

module.start = function()
  updateMenubar()

  -- start timer at next full minute
  local nextFullMinute = os.date('%H:%M', math.ceil(os.time() / 60) * 60)

  hs.timer.doAt(nextFullMinute, function()
    cache.timer = hs.timer.doEvery(60, updateMenubar):start()
  end):start()
end

module.stop = function()
  cache.timer:stop()
end

return module
