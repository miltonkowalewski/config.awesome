local filesystem = require('gears.filesystem')
local awful = require('awful')

-- List of apps to start once on start-up
run_on_start_up = {
    'compton &',
    'nm-applet --indicator', -- wifi
    'pnmixer', -- shows an audiocontrol applet in systray when installed.
    --'blueberry-tray', -- Bluetooth tray icon
    'numlockx on', -- enable numlock
    '/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)', -- credential manager
    'xfce4-power-manager', -- Power manager
    'flameshot',
    'synology-drive -minimized',
    'feh --randomize --bg-fill ~/Pictures/wallpapers/*',
    '/usr/bin/variety',
    -- Add applications that need to be killed between reloads
    -- to avoid multipled instances, inside the awspawn script
    '~/.config/awesome/configuration/awspawn' -- Spawn "dirty" apps that can linger between sessions
}

local function run_once(cmd)
    local findme = cmd
    local firstspace = cmd:find(' ')
    if firstspace then
      findme = cmd:sub(0, firstspace - 1)
    end
    awful.spawn.with_shell(string.format('pgrep -u $USER -x %s > /dev/null || (%s)', findme, cmd))
end

for _, app in ipairs(run_on_start_up) do
    run_once(app)
end
  