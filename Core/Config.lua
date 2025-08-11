local L = LibStub("AceLocale-3.0"):GetLocale("AltTracker")
local AltTracker = AltTracker

-- Simple config using AceConfig-3.0 (optional). If you prefer Blizzard Settings API, swap this out.
local AceConfig = LibStub("AceConfig-3.0", true)
local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)

local options = {
  type = "group",
  name = L["AltTracker"],
  args = {
    general = {
      type = "group", name = L["General"], order = 1,
      args = {
        minimap = {
          type = "toggle", name = L["Minimap Button"],
          get = function() return not AltTracker.db.profile.minimap.hide end,
          set = function(_, val)
            AltTracker.db.profile.minimap.hide = not val
            AltTracker:RefreshMinimap()
          end,
        },
      },
    },
    modules = {
      type = "group", name = "Modules", order = 2,
      args = {}
    }
  }
}

local function BuildModuleOptions()
  local t = {}
  for name, mod in AltTracker:IterateModules() do
    t[name] = {
      type = "toggle", name = L[name] or name,
      get = function() return AltTracker.db.profile.enabledModules[name] ~= false end,
      set = function(_, val)
        AltTracker.db.profile.enabledModules[name] = val
        if val then mod:Enable() else mod:Disable() end
      end,
    }
  end
  options.args.modules.args = t
end

function AltTracker:OpenConfig()
  if not AceConfig or not AceConfigDialog then
    return self:Print("AceConfig is not embedded; no options UI.")
  end
  BuildModuleOptions()
  AceConfig:RegisterOptionsTable("AltTracker", options)
  AceConfigDialog:AddToBlizOptions("AltTracker", L["AltTracker"]) 
  AceConfigDialog:Open("AltTracker")
end
