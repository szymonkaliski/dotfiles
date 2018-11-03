--[[ configuration parameters ]]
local showHintMod = {'ctrl', 'cmd', 'alt'}
local showHintKey = 'E'

local hintKeys = {"A", "S", "D", "F", "J", "K", "L", ";", "G", "H", "Q", "W", "E", "R", "U", "I", "O", "P", "T", "Y", "Z", "X", "C", "V", "N", "M", ",", ".", "B"}
local hintDuration = 3
local maxDescriptorLength = 50

--[[ global record of active windows to be passed around
    during the hint mode ]]
local activeWindows = {}

--[[ is this window worth of being displayed?
    params : window (type hs.window)
    returns : bool ]]
function hintableWindow(window)
    return (window:title() ~= "") and (window:application():title() ~= "") and (window:isStandard())
end

--[[ get a list of visible windows that match our
    display criteria
    returns : list of window objects ]]
function hintableWindows()
    windows = hs.window.visibleWindows()
    return hs.fnutils.filter(windows, hintableWindow)
end

--[[ make a descriptive title for a window
    params : window, length (int)
    returns : string

    combines the application title and, if it's different, the window title
    too. the whole thing will get truncated if it's too long ]]
function windowDescriptor(window, maxDescriptorLength)
    out = window:application():title()
    wt = window:title()

    if (wt ~= out) then out = out .. " / " .. wt end
    if (out:len() > maxDescriptorLength) then
        out = out:sub(0, maxDescriptorLength)
    end

    return out
end

--[[ the actual string to be displayed when hint mode is entered. it shows the
    key to be pressed and the descriptor for the window
    params : list of windows
    returns : string ]]
function windowHints(windows)
    out = ""
    for i, window in pairs(windows) do
        out = out .. hintKeys[i] .. " / " .. windowDescriptor(window, maxDescriptorLength)
        if i ~= #windows then out = out .. "\n" end
    end
    return out
end

--[[ show the hints and set up a timer that will exit hint mode if no key
    is pressed ]]
function enterHintMode(hinter, time)
    -- show the hints
    activeWindows = hintableWindows()
    message = windowHints(activeWindows)
    hs.alert.show(message, time)

    -- set up a timer to close
    hs.timer.doAfter(time, function() hinter:exit() end)
end

--[[ factory for functions that will bind keys to the modal hinter.
    params : string, int, model hotkey

    the string is the keyboard key. the int is the index of the window in the
    window list that should be focused. if a key outside the range is pressed,
    do nothing. ]]
function takeHint(key, i, hinter)
    return function()
        if activeWindows[i] ~= nil then
            activeWindows[i]:focus()
            hinter:exit()
        end
    end
end

--[[ empty the active windows global and close the alert ]]
function cleanUpHints()
    activeWindows = {}
    hs.alert.closeAll() -- this is janky, since it might conflict with other notifications
end

--[[ create the modal key object, bind the appropriate functions and keys ]]
hinter = hs.hotkey.modal.new(showHintMod, showHintKey)
function hinter:entered() enterHintMode(hinter) end
function hinter:exited() cleanUpHints() end
hinter:bind({}, 'escape', function() hinter:exit() end)

for i, key in ipairs(hintKeys) do
    hinter:bind({}, key, takeHint(key, i, hinter))
end
