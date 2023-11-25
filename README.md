# LuaHTML

This tool lets you create Roblox Lua User Interfaces with HTML

> Disclaimer: I have programmed this a while back and just now discovered it again. My code may be bad or unoptimized

## Sample Code

```lua
local LuaHTML = require('LuaHTML')

LuaHTML:create([[
<gui Name="TestUI">
    <Frame Name="MainFrame" BackgroundColor="#ff00ff" Size="0,100,0,100">
        <Button BackgroundTransparency="1" Name="Button1" Text="Click me!" Size="1,0,1,0" />
    </Frame>
</gui>
]])
```

## UNMAINTAINED

I've published this repository because I do not maintain it anymore. This might change in the future, but feel free to use it or extend it. I won't archive it so you guys can make pull requests.
