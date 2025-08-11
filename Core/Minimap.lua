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
      if button == "RightButton" then AltTracker:OpenConfig() else AltTracker:ToggleMainFrame() end
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

-- Simple placeholder main frame toggle
function AltTracker:ToggleMainFrame()
  if not self.MainFrame then
    local f = CreateFrame("Frame", "AltTrackerMainFrame", UIParent, "BackdropTemplate")
    f:SetSize(720, 480)
    f:SetPoint("CENTER")
    f:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    f:SetBackdropColor(0,0,0,0.8)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("AltTracker")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT")

    self.MainFrame = f
  end
  if self.MainFrame:IsShown() then self.MainFrame:Hide() else self.MainFrame:Show() end
end
