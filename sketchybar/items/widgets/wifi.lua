local constants = require("constants")
local settings = require("config.settings")

local popupWidth <const> = settings.dimens.graphics.popup.width + 20

local wifi = sbar.add("item", constants.items.WIFI .. ".padding", {
  position = "right",
  label = { drawing = false },
  padding_right = 0,
})

local wifiBracket = sbar.add("bracket", constants.items.WIFI .. ".bracket", {
  wifi.name,
}, {
  popup = { align = "center" }
})

local ssid = sbar.add("item", {
  align = "center",
  position = "popup." .. wifiBracket.name,
  width = popupWidth,
  height = 16,
  icon = {
    string = settings.icons.text.wifi.router,
    font = {
      style = settings.fonts.styles.bold
    },
  },
  label = {
    font = {
      style = settings.fonts.styles.bold,
      size = settings.dimens.text.label,
    },
    max_chars = 18,
    string = "????????????",
  },
})

sbar.add("item", { position = "right", width = settings.dimens.padding.item })

wifi:subscribe({ "wifi_change", "system_woke", "forced" }, function(env)
  wifi:set({
    icon = {
      string = settings.icons.text.wifi.disconnected,
      color = settings.colors.magenta,
    }
  })

  sbar.exec([[ipconfig getifaddr en0]], function(ip)
    local ipConnected = not (ip == "")

    local wifiIcon
    local wifiColor

    if ipConnected then
      wifiIcon = settings.icons.text.wifi.connected
      wifiColor = settings.colors.white
    end

    wifi:set({
      icon = {
        string = wifiIcon,
        color = wifiColor,
      }
    })

    sbar.exec([[sleep 2; scutil --nwi | grep -m1 'utun' | awk '{ print $1 }']], function(vpn)
      local isVPNConnected = not (vpn == "")

      if isVPNConnected then
        wifiIcon = settings.icons.text.wifi.vpn
        wifiColor = settings.colors.green
      end

      wifi:set({
        icon = {
          string = wifiIcon,
          color = wifiColor,
        }
      })
    end)
  end)
end)

local function hideDetails()
  wifiBracket:set({ popup = { drawing = false } })
end

local function toggleDetails()
  local shouldDrawDetails = wifiBracket:query().popup.drawing == "off"

  if shouldDrawDetails then
    wifiBracket:set({ popup = { drawing = true } })
    sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
      ssid:set({ label = result })
    end)
  else
    hideDetails()
  end
end

wifi:subscribe("mouse.clicked", toggleDetails)
ssid:subscribe("mouse.clicked", function(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec("echo \"" .. label .. "\" | pbcopy")
  sbar.set(env.NAME, { label = { string = settings.icons.text.clipboard, align = "center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end)