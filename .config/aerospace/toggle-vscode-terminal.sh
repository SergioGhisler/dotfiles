#!/bin/bash

current_app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

echo "Current frontmost app: $current_app" >> ~/aerospace-toggle.log

if [[ "$current_app" == "ghostty" ]]; then
 
  open -a "Visual Studio Code"
else
  open -a "Ghostty"
fi
