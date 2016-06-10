#!/usr/bin/env osascript

on run argv
  set appName to item 1 of argv

  tell application appName
    activate

    display dialog "There are multiple windows opened.\nAre you sure you want to quit?" with icon 1 buttons {"Cancel", "Quit"} default button "Quit"
    set answer to button returned of result

    if result = "quit" then
      quit
    else
      activate
    end if
  end tell
end run
