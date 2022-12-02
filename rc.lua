-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err) })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "zenburn/theme.lua")
beautiful.init("/home/milton/.config/awesome/theme.lua")
local bling = require("bling")

bling.widget.task_preview.enable {
  x = 0,                    -- The x-coord of the popup
  y = 0,                    -- The y-coord of the popup
  height = 300,              -- The height of the popup
  width = 300,               -- The width of the popup
  placement_fn = function(c) -- Place the widget using awful.placement (this overrides x & y)
      awful.placement.bottom(c, {
          margins = {
            bottom = 30
          }
      })
  end
}

bling.module.window_swallowing.start()

bling.widget.tag_preview.enable {
  show_client_content = true, -- Whether or not to show the client content
  x = 10, -- The x-coord of the popup
  y = 10, -- The y-coord of the popup
  scale = 0.25, -- The scale of the previews compared to the screen
  honor_padding = false, -- Honor padding when creating widget size
  honor_workarea = false, -- Honor work area when creating widget size
  placement_fn = function(c) -- Place the widget using awful.placement (this overrides x & y)
    awful.placement.bottom(c, {
      margins = {
        bottom = 30,
        left = 30
      }
    })
  end,
  background_widget = wibox.widget { -- Set a background image (like a wallpaper) for the widget
    image                 = beautiful.wallpaper,
    horizontal_fit_policy = "fit",
    vertical_fit_policy   = "fit",
    widget                = wibox.widget.imagebox
  }
}

bling.widget.window_switcher.enable {
  type = "thumbnail", -- set to anything other than "thumbnail" to disable client previews

  -- keybindings (the examples provided are also the default if kept unset)
  hide_window_switcher_key = "Escape", -- The key on which to close the popup
  minimize_key = "n",                  -- The key on which to minimize the selected client
  unminimize_key = "N",                -- The key on which to unminimize all clients
  kill_client_key = "q",               -- The key on which to close the selected client
  cycle_key = "Tab",                   -- The key on which to cycle through all clients
  previous_key = "Left",               -- The key on which to select the previous client
  next_key = "Right",                  -- The key on which to select the next client
  vim_previous_key = "h",              -- Alternative key on which to select the previous client
  vim_next_key = "l",                  -- Alternative key on which to select the next client

  cycleClientsByIdx = awful.client.focus.byidx,               -- The function to cycle the clients
  filterClients = awful.widget.tasklist.filter.currenttags,   -- The function to filter the viewed clients
}


-- This is used later as the default terminal and editor to run.
-- terminal = "x-terminal-emulator"
-- terminal = "terminator"
terminal = "alacritty"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.magnifier,
  awful.layout.suit.max,
  -- awful.layout.suit.tile,
  -- awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  -- awful.layout.suit.fair,
  -- awful.layout.suit.fair.horizontal,
  -- awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
  -- awful.layout.suit.corner.nw,
  -- awful.layout.suit.max.fullscreen,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
  bling.layout.mstab,
  bling.layout.centered,
  -- bling.layout.vertical,
  -- bling.layout.horizontal,
  -- bling.layout.equalarea,
  bling.layout.deck,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
  { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
  mymainmenu = freedesktop.menu.build({
    before = { menu_awesome },
    after = { menu_terminal }
  })
else
  mymainmenu = awful.menu({
    items = {
      menu_awesome,
      { "Debian", debian.menu.Debian_menu.Debian },
      menu_terminal,
    }
  })
end


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
  menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal(
        "request::activate",
        "tasklist",
        { raise = true }
      )
    end
  end),
  awful.button({}, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
  end))

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Each screen has its own tag table.
  awful.tag(
    { "ws-1", "ws-2", "ws-3", "ws-4", "ws-5", "ws-6", "ws-7", "ws-8", "ws-9" },
    s,
    {
      bling.layout.deck,
      bling.layout.deck,
      bling.layout.deck,
      bling.layout.deck,
      bling.layout.deck,
      bling.layout.deck,
      bling.layout.deck,
      bling.layout.deck,
      bling.layout.deck,
    }
  )

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  -- s.mylayoutbox = awful.widget.layoutbox(s)
  -- s.mylayoutbox:buttons(gears.table.join(
  --     awful.button({}, 1, function() awful.layout.inc(1) end),
  --     awful.button({}, 3, function() awful.layout.inc(-1) end),
  --     awful.button({}, 4, function() awful.layout.inc(1) end),
  --     awful.button({}, 5, function() awful.layout.inc(-1) end)))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist {
    screen          = s,
    filter          = awful.widget.taglist.filter.noempty,
    style           = {
      shape = gears.shape.powerline
    },
    widget_template = {
      {
        {
          {
            {
              {
                id     = 'index_role',
                widget = wibox.widget.textbox,
              },
              margins = 0,
              widget  = wibox.container.margin,
            },
            widget = wibox.container.background,
          },
          -- {
          --   id     = 'text_role',
          --   widget = wibox.widget.textbox,
          -- },
          layout = wibox.layout.fixed.horizontal,
        },
        left   = 15,
        right  = 15,
        widget = wibox.container.margin
      },
      id              = 'background_role',
      widget          = wibox.container.background,
      -- Add support for hover colors and an index label
      create_callback = function(self, c3, index, objects) --luacheck: no unused args
        self:get_children_by_id('index_role')[1].markup = '<b> ' .. index .. ' </b>'
        self:connect_signal('mouse::enter', function()

          -- BLING: Only show widget when there are clients in the tag
          if #c3:clients() > 0 then
            -- BLING: Update the widget with the new tag
            awesome.emit_signal("bling::tag_preview::update", c3)
            -- BLING: Show the widget
            awesome.emit_signal("bling::tag_preview::visibility", s, true)
          end

          if self.bg ~= '#053d05' then
            self.backup     = self.bg
            self.has_backup = true
          end
          self.bg = '#053d05'
        end)
        self:connect_signal('mouse::leave', function()

          -- BLING: Turn the widget off
          awesome.emit_signal("bling::tag_preview::visibility", s, false)

          if self.has_backup then self.bg = self.backup end
        end)
      end,
      update_callback = function(self, c3, index, objects) --luacheck: no unused args
        self:get_children_by_id('index_role')[1].markup = '<b> ' .. index .. ' </b>'
      end,
    },
    buttons         = taglist_buttons
  }

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist {
      screen   = s,
      filter   = awful.widget.tasklist.filter.currenttags,
      buttons  = tasklist_buttons,
      layout   = {
          spacing_widget = {
              {
                  forced_width  = 5,
                  forced_height = 24,
                  thickness     = 1,
                  color         = '#777777',
                  widget        = wibox.widget.separator
              },
              valign = 'center',
              halign = 'center',
              widget = wibox.container.place,
          },
          spacing = 1,
          layout  = wibox.layout.fixed.horizontal
      },
      -- Notice that there is *NO* wibox.wibox prefix, it is a template,
      -- not a widget instance.
      widget_template = {
          {
              wibox.widget.base.make_widget(),
              -- forced_height = 2,
              id            = 'background_role',
              widget        = wibox.container.background,
          },
          {
              {
                  id     = 'clienticon',
                  widget = awful.widget.clienticon,
              },
              -- margins = 0,
              left   = 15,
              right  = 15,
              align  = "center",
              widget  = wibox.container.margin
          },
          nil,
          create_callback = function(self, c, index, objects) --luacheck: no unused args
              self:get_children_by_id('clienticon')[1].client = c

              -- BLING: Toggle the popup on hover and disable it off hover
              self:connect_signal('mouse::enter', function()
                      awesome.emit_signal("bling::task_preview::visibility", s,
                                          true, c)
                  end)
                  self:connect_signal('mouse::leave', function()
                      awesome.emit_signal("bling::task_preview::visibility", s,
                                          false, c)
                  end)
          end,
          layout = wibox.layout.align.vertical,
      },
  }

  -- Create the wibox
  s.mywibox = awful.wibar({ position = "bottom", screen = s, height = 25 })

  -- Add widgets to the wibox
  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      mylauncher,
      s.mytaglist,
      awful.widget.layoutlist {
        screen = s,
        style = {
          disable_name = true,
          spacing      = 0,
        },
        source = function() return awful.layout.layouts end
      },
      s.mypromptbox,
    },
    s.mytasklist, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      mykeyboardlayout,
      wibox.widget.systray(),
      mytextclock,
      -- s.mylayoutbox,
    },
  }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
  awful.button({}, 3, function() mymainmenu:toggle() end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
-- awful.menu.client_list({ theme = { width = 250 } }) # TODO: Criar shortcut
  awful.key({ modkey }, "p", function() awful.menu.client_list({ theme = { width = 250 } }) end,
    { description = "open client windows", group = "launcher" }),
  awful.key({ modkey, }, "s", hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }),
  awful.key({ modkey, }, "Left", awful.tag.viewprev,
    { description = "view previous", group = "tag" }),
  awful.key({ modkey, }, "Right", awful.tag.viewnext,
    { description = "view next", group = "tag" }),
  awful.key({ modkey, }, "Escape", awful.tag.history.restore,
    { description = "go back", group = "tag" }),

  awful.key({ modkey, }, "j",
    function()
      awful.client.focus.byidx(1)
    end,
    { description = "focus next by index", group = "client" }
  ),
  awful.key({ modkey, }, "k",
    function()
      awful.client.focus.byidx(-1)
    end,
    { description = "focus previous by index", group = "client" }
  ),
  awful.key({ modkey, }, "w", function() mymainmenu:show() end,
    { description = "show main menu", group = "awesome" }),

  -- Layout manipulation
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
    { description = "swap with next client by index", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
    { description = "swap with previous client by index", group = "client" }),
  awful.key({ modkey, "Control" }, "Left", function() awful.screen.focus_relative(1) end,
    { description = "focus the next screen", group = "screen" }),
  awful.key({ modkey, "Control" }, "Right", function() awful.screen.focus_relative(-1) end,
    { description = "focus the previous screen", group = "screen" }),
  awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),
  awful.key({ modkey, }, "c",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    { description = "go back", group = "client" }),

  -- Standard program
  awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey, "Shift" }, "r", awesome.restart,
    { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Control" }, "q", awesome.quit,
    { description = "quit awesome", group = "awesome" }),

  awful.key({ modkey, }, "g", function() awful.tag.incmwfact(0.05) end,
    { description = "increase master width factor", group = "layout" }),
  awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
    { description = "decrease master width factor", group = "layout" }),
  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
    { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
    { description = "decrease the number of master clients", group = "layout" }),
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
    { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
    { description = "decrease the number of columns", group = "layout" }),
  awful.key({ modkey, }, "Tab", function() awesome.emit_signal("bling::window_switcher::turn_on") end,
    { description = "select next", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
    { description = "select previous", group = "layout" }),

  awful.key({ modkey, "Control" }, "n",
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        c:emit_signal(
          "request::activate", "key.unminimize", { raise = true }
        )
      end
    end,
    { description = "restore minimized", group = "client" }),

  awful.key({ modkey }, "x",
    function()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end,
    { description = "lua execute prompt", group = "awesome" }),
  -- Menubar
  awful.key({ modkey }, "space", function() menubar.show() end,
    { description = "show the menubar", group = "launcher" }),
  awful.key({ modkey }, "r", function()
    awful.spawn("rofi -show combi -combi-modes 'window,run,ssh' -modes combi")
  end, { description = "show rofi window", group = "launcher" })
)

clientkeys = gears.table.join(
  awful.key({ modkey, }, "f",
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end,
    { description = "close", group = "client" }),
  awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
    { description = "toggle floating", group = "client" }),
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
    { description = "move to master", group = "client" }),
  awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
    { description = "move to screen", group = "client" }),
  awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
    { description = "toggle keep on top", group = "client" }),
  awful.key({ modkey, }, "n",
    function(c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end,
    { description = "minimize", group = "client" }),
  awful.key({ modkey, }, "m",
    function(c)
      c.maximized = not c.maximized
      c:raise()
    end,
    { description = "(un)maximize", group = "client" }),
  awful.key({ modkey, "Control" }, "m",
    function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end,
    { description = "(un)maximize vertically", group = "client" }),
  awful.key({ modkey, "Shift" }, "m",
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
    end,
    { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = gears.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      { description = "view tag #" .. i, group = "tag" }),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      { description = "toggle tag #" .. i, group = "tag" }),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      { description = "move focused client to tag #" .. i, group = "tag" }),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      { description = "toggle focused client on tag #" .. i, group = "tag" })
  )
end

clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules =
{
  -- All clients will match this rule.
  {
    rule = {},
    properties = { border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  },

  -- Floating clients.
  {
    rule_any = {
      instance = {
        "DTA", -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry",
      },
      class = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "MessageWin", -- kalarm.
        "Sxiv",
        "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui",
        "veromix",
        "xtightvncviewer"
      },

      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester", -- xev.
      },
      role = {
        "AlarmWindow", -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
      }
    }, properties = { floating = true }
  },

  -- Add titlebars to normal clients and dialogs
  {
    rule_any = {
      type = { "normal", "dialog" }
    }, properties = { titlebars_enabled = true }
  },

  -- Set Firefox to always map on the tag named "2" on screen 1.
  -- { rule = { class = "Firefox" },
  --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({}, 1, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.move(c)
    end),
    awful.button({}, 3, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c, { position = 'left', size = 17 }):setup {
    { -- Left
      {
        awful.titlebar.widget.closebutton(c),
        awful.titlebar.widget.maximizedbutton(c),
        awful.titlebar.widget.minimizebutton(c),
        layout = wibox.layout.fixed.vertical
      },
      widget = wibox.container.margin
    },
    { -- Middle
    {
      { -- Title
          align  = "center",
          widget = awful.titlebar.widget.titlewidget(c)
        },
        buttons = buttons,
        layout  = wibox.layout.flex.vertical
      },
      widget = wibox.container.rotate,
      direction = "east",
    },
    { -- Right
    -- awful.titlebar.widget.floatingbutton (c),
      awful.titlebar.widget.stickybutton(c),
      awful.titlebar.widget.ontopbutton(c),
      awful.titlebar.widget.iconwidget(c),
      layout = wibox.layout.fixed.vertical()
    },
    layout = wibox.layout.align.vertical
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:emit_signal("request::activate", "mouse_enter", {raise = false})
-- end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

require('config.startup')

--- Enable for lower memory consumption
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
