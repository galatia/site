#!/bin/bash
if [[ $2 = "n" ]]; then
    L1=""
    L2=""
else
    L1="set theWindow's active tab index to theTabIndex"
    L2="tell window 1 to make new tab with properties {URL:\"$1\"}"
fi
cat >.reload.scpt <<EOF
delay 1.5
tell application "Google Chrome"
    
    if (count every window) = 0 then
        make new window
    end if
    
    set found to false
    set theTabIndex to -1
    repeat with theWindow in every window
        set theTabIndex to 0
        repeat with theTab in every tab of theWindow
            set theTabIndex to theTabIndex + 1
            if theTab's URL contains "$1" then
                set found to true
                tell theTab to reload
                exit
            end if
        end repeat
        
        if found then
            exit repeat
        end if
    end repeat
    
    if found then
        $L1
    else
        $L2
    end if
end tell
EOF
osascript .reload.scpt
rm -f .reload.scpt
