local windowMetadata = require("ext.window").windowMetadata

local log    = hs.logger.new("logger", "debug")
local cache  = {}
local module = { cache = cache }

module.sleepWatcher = function(_, _, _, _, event)
  if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemWillPowerOff then
    log.d("stopping logger")
    cache.timer:stop()
  end

  if event == hs.caffeinate.watcher.systemDidWake then
    log.d("starting logger")
    cache.timer:start()
  end
end

local sanitize = function(s)
  return s:gsub([[']], "''")
end

local prepareLogValues = function(win)
  local app = win:application()

  if app == nil then
    return nil, nil, nil
  end

  local name = sanitize(app:name())

  if name == "loginwindow" then
    return nil, nil, nil
  end

  local title, meta = windowMetadata(win)

  title = sanitize(title or "")
  meta  = sanitize(meta or "")

  return name, title, meta
end

module.start = function()
  cache.db = hs.sqlite3.open(config.logger.path)

  local result = cache.db:execute([[
    CREATE TABLE IF NOT EXISTS log (app TEXT NOT NULL, title TEXT NOT NULL, epoch INTEGER NOT NULL, meta TEXT);
    CREATE INDEX IF NOT EXISTS basic_search_idx ON log (app, title, meta);
    CREATE VIRTUAL TABLE IF NOT EXISTS ft_log USING FTS5(title, meta);

    CREATE TRIGGER IF NOT EXISTS ft_log_update AFTER INSERT ON log BEGIN
      INSERT INTO ft_log(title, meta)
      VALUES (new.title, new.meta);
    END
  ]])

  cache.watcherSleep = hs.watchable.watch("status.sleepEvent", module.sleepWatcher)

  cache.timer = hs.timer.doEvery(10, function()
    -- logging sometimes makes mouse lock up?
    if #hs.mouse.getButtons() ~= 0 then
      return
    end

    local win = hs.window.focusedWindow()
    if not win then return end

    local app, title, meta = prepareLogValues(win)
    if not app then return end

    local time      = os.time()
    local statement = "INSERT INTO log VALUES('" .. app .. "', '" .. title .. "', '" .. time .. "', '" .. meta .. "')"
    local insert    = cache.db:execute(statement)

    if insert ~= hs.sqlite3.OK then
      local errmsg = cache.db:errmsg()

      if errmsg ~= cache.lastError then
        hs.notify.new({
          title    = "Logger failed",
          subTitle = "Look into Hammerspoon Console for more info"
        }):send()

        log.e("failed insert: " .. errmsg .. "\n" .. statement)

        cache.lastError = errmsg
      end
    end
  end)
end

module.stop = function()
  cache.timer:stop()
  cache.timer = nil
end

return module
