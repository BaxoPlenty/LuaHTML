local LuaHTML = require('LuaHTML')

LuaHTML:create([[
<gui Name="TestUI">
    <Frame Name="MainFrame" BackgroundColor="#ff00ff" Size="0,100,0,100">
        <Button BackgroundTransparency="1" Name="Button1" Text="Click me!" Size="1,0,1,0" />
    </Frame>
</gui>
]])