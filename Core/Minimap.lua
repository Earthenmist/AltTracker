local L = LibStub("AceLocale-3.0"):GetLocale("AltTracker")
local AltTracker = AltTracker

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBI = LibStub("LibDBIcon-1.0", true)

function AltTracker:EnableMinimap()
  if not LDB or not LDBI then return end
  self.ldbObject = self.ldbObject or LDB:NewDataObject("AltTracker", {
    type = "launcher",
    text = "AltTracker",
    icon = 136439, -- INV_Misc_GroupNeedMore
    OnClick = function(_, button)
      if button == "RightButton" then AltTracker:OpenConfig() else AltTracker.UI:Toggle() end
    end,
    OnTooltipShow = function(tt)
      tt:AddLine("AltTracker")
      tt:AddLine(L["Minimap Tooltip"], 1,1,1)
    end,
  })
  self:RefreshMinimap()
end

function AltTracker:RefreshMinimap()
  if not LDBI or not self.ldbObject then return end
  LDBI:Register("AltTracker", self.ldbObject, self.db.profile.minimap)
  if self.db.profile.minimap.hide then LDBI:Hide("AltTracker") else LDBI:Show("AltTracker") end
end
