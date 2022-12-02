local awful = require('awful')
require('config.your_startup_list')

-- List of apps to start once on start-up
local run_on_start_up = {
  'type -p compton >/dev/null || sudo apt install compton -y',
  'type -p picom >/dev/null || sudo apt install picom -y',
  'type -p nm-applet >/dev/null || sudo apt network-manager network-manager-gnome -y', -- wifi
  'type -p pnmixer >/dev/null || sudo apt install pnmixer -y', -- shows an audiocoRRntrol applet in systray when installed.
  'type -p blueman-applet >dev/null || sudo apt install blueman bluez bluez-obexd -y',
  'type -p /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >dev/null || sudo apt install policykit-1-gnome -y',
  'type -p xfce4-power-manager >dev/null || sudo apt install xfce4-power-manager -y',
  'type -p flameshot >/dev/null || flameshot',
  'type -p feh >/dev/null || sudo apt install feh -y && mkdir -p ~/wallpapers && cp -R /usr/share/backgrounds/* ~/wallpapers',
  'type -p slack >/dev/null || slack',
  'type -p discord >/dev/null || discord',
  'type -p pritunl-client-electron >/dev/null || pritunl-client-electron',
  'type -p google-chrome >/dev/null || google-chrome --profile-directory="Profile 1"',
  'compton --vsync opengl-swc --backend glx &',
  'picom --experimental-backends --config ~/.config/picom.conf',
  'nm-applet --indicator',
  'pnmixer',
  'blueman-applet',
  'numlockx on', -- enable numlock
  '/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)', -- credential manager
  'xfce4-power-manager', -- Power manager
  'flameshot',
  'synology-drive -minimized',
  'feh --recursive --randomize --bg-fill ~/wallpapers/*',
  '/usr/bin/variety',
  -- Add applications that need to be killed between reloads
  -- to avoid multipled instances, inside the awspawn script
  '~/.config/awesome/configuration/awspawn', -- Spawn "dirty" apps that can linger between sessions
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

