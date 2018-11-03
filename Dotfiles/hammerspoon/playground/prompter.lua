local module = {}
local webview     = require("hs.webview")
local usercontent = webview.usercontent
local screen      = require("hs.screen")
local host        = require("hs.host")
local drawing     = require("hs.drawing")

module.prompt = function(...) -- (label, default, frame, callback)
    local pos = 1
    local argv = table.pack(...)
    if argv.n == 0 then
        print([[

module.prompt([label], [default], [point], [callback]) -> { webview }
Function
Prompt for user input using the javascript popup window from a webview.

Parameters:
  * label    - The prompt to display above the input field.  Defaults to "Your input:".
  * default  - input to pre-populate the input field with.  Defaults to an empty string.
  * point    - the middle point for the dialog box location.  Defaults to the approximate center of the main screen.
  * callback - the callback function which will be sent one argument: the user input as a string or nil if they chose cancel.  Defaults to a function which just prints the output to the Hammerspoon console.

Returns:
  * an array with one element: the webview object.  This table has a metatable assigned, so you can remove it early with `value:delete()`.

Notes:
  * The webview is self-deleting when you user chooses `OK` or `Cancel` (normal Return and Escape key behavior works as expected), but you can delete it before the user has responded if needed as described under `Returns:`.

  * All parameters are optional, but at least one must be specified or you'll see this text in the console.
  * If less than 4 parameters are provided, they are identified as follows in a single pass (i.e. they must be "in order"):
    * Check if the first argument is a string; if so, set it to `label` and move to next argument.
    * Check if the current argument is a string; if so, set it to `default` and move to the next argument.
    * Check if the current argument is a table; if so, set it to `frame` and move to the next argument.
    * Check if the current argument is a function; if so, set it to `callback`
  * If you want to set a default, but no label, you must set label to "" because the first string will always be assigned to `label`.

  * Technically, point is a frame, and a height of 1 and a width of 1 will be assigned if they are not provided.  This is because the webview can't be a zero height/width object, but we're really only interested in the javascript pop-up, so we make sure the webview is small enough to hide behind the dialog box. You can make it bigger if you like, but I'm not sure why you would -- If you need something more complex, you're better off writing a web form and not using the javascript pop-ups at all.  (see `dterm.lua` example in this repository).

]])
        return
    end
    local screenFrame = require("hs.screen").mainScreen():fullFrame()
    local label    = "Your input:"
    local default  = ""
    local frame    = { x = screenFrame.x + screenFrame.w / 2, y = screenFrame.y + screenFrame.h / 4 }
    local callback = function(input) print("prompter result:"..tostring(input)) end

    if type(argv[pos]) == "string" or type(argv[pos]) == "number" then
        label = tostring(argv[pos])
        pos = pos + 1
    end
    if type(argv[pos]) == "string" or type(argv[pos]) == "number" then
        default = argv[pos]
        pos = pos + 1
    end
    if type(argv[pos]) == "table"    then frame    = argv[pos] ; pos = pos + 1 end
    if type(argv[pos]) == "function" then callback = argv[pos] end

    -- there needs to be at least some height and width or it just shoves it in the upper left corner
    if not frame.h or frame.h < 1 then frame.h = 1 end
    if not frame.w or frame.w < 1 then frame.w = 1 end

    -- not sure if names only have to be unique to the webview or to Hammerspoon;
    -- just in case, use something almost guaranteed to be unique (but needs to
    -- start with a letter).
    local uccName = "prompter"..host.uuid():gsub("-","")
    local view
    local ucc = usercontent.new(uccName):setCallback(function(input)
--         print(inspect(input))
        if callback then
            callback(input.body)
        end
        view:delete()
    end)

    view = webview.new(frame, { developerExtrasEnabled = true }, ucc):html([[
        <script type="text/javascript">
        var textMsg = window.prompt("]]..label..[[", "]]..default..[[") ;
        try {
            webkit.messageHandlers.]]..uccName..[[.postMessage(textMsg) ;
        } catch(err) {
            console.log('Controller ]]..uccName..[[ does not exist');
            console.log(err)
        }
        </script>
    ]]):show()
    view:level(drawing.windowLevels.screenSaver)

    return setmetatable({view}, {
        __index = {
            delete = function(_)
                if getmetatable(_[1]) == hs.getObjectMetatable("hs.webview") then
                    _[1]:delete()
                    setmetatable(_, nil)
                end
            end
        },
-- will make it disappear if returned valua not saved.  Useful during debugging, though.
--         __gc    = function(_) _:delete() end
    })
end

return module