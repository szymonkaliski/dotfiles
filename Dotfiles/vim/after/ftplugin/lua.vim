syn region luaFunctionBlock transparent fold matchgroup=luaFunction start='\<function\>' end ='\<end\>' contains=ALLBUT,luaTodo,luaSpecial,luaCond,luaCondElseif,luaCondEnd,luaRepeat
