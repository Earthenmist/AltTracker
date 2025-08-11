local AddonName = ...
local AltTracker = _G[AddonName]
local UI = AltTracker.UI

UI.Tabs = UI.Tabs or {}

local TAB_NAMES = {
  "Overview",      -- character overview table
  "Currencies",
  "Reputation",
  "Quests",
  "Inventory",
  "Professions",
  "Lockouts",
  "Collections",
}

local function SelectTab(index)
  local name = TAB_NAMES[index]
  AltTracker.db.profile.ui.lastTab = name
  for i, btn in ipairs(UI.Tabs.List) do
    if i == index then PanelTemplates_SelectTab(btn) else PanelTemplates_DeselectTab(btn) end
  end
  UI.TableView:SetMode(name)
end

function UI.Tabs:Init(parent)
  self.List = {}
  local last
  for i, name in ipairs(TAB_NAMES) do
    local btn = CreateFrame("Button", nil, parent, "PanelTabButtonTemplate")
    btn:SetText(name)
    btn:SetPoint("TOPLEFT", i == 1 and parent or last, i == 1 and "BOTTOMLEFT" or "BOTTOMRIGHT", i == 1 and 12 or -16, i == 1 and -6 or 0)
    btn:SetScript("OnClick", function() SelectTab(i) end)
    PanelTemplates_TabResize(btn, 0)
    self.List[i] = btn
    last = btn
  end
  PanelTemplates_SetNumTabs(parent, #self.List)

  -- Restore last selected
  local wanted = AltTracker.db.profile.ui.lastTab or "Overview"
  for i, n in ipairs(TAB_NAMES) do if n == wanted then SelectTab(i) break end end
end
