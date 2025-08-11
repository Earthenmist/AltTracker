local AddonName = ...
local AltTracker = _G[AddonName]
local UI = AltTracker.UI

UI.TableView = UI.TableView or {}
local TV = UI.TableView

local function getChars()
  local out = {}
  for realm, chars in pairs(AltTracker.db.global and AltTracker.db.global.chars or {}) do
    for name, data in pairs(chars) do
      table.insert(out, {
        realm = realm,
        name = name,
        level = data.character and data.character.level or 0,
        ilvl = data.character and data.character.ilvl or 0,
        faction = data.character and data.character.faction or "",
        gold = (data.inventory and data.inventory.gold) or 0,
        mplus = (data.lockouts and data.lockouts.mythicplus and data.lockouts.mythicplus.weeklyBest) or 0,
      })
    end
  end
  return out
end

local COLUMNS = {
  { key = "name",     title = "Character", width = 180 },
  { key = "level",    title = "Lvl",       width = 40, align = "CENTER" },
  { key = "ilvl",     title = "iLvl",      width = 60, align = "CENTER" },
  { key = "faction",  title = "Faction",   width = 70, align = "CENTER" },
  { key = "realm",    title = "Realm",     width = 160 },
  { key = "mplus",    title = "+ Weekly", width = 80, align = "CENTER" },
  { key = "gold",     title = "Gold",      width = 120, align = "RIGHT" },
}

local function formatGold(copper)
  local g = math.floor(copper/10000)
  local s = math.floor((copper%10000)/100)
  return string.format("%dg %ds", g, s)
end

local function sortFunc(a, b)
  local key = AltTracker.db.profile.ui.sortKey or "name"
  local asc = AltTracker.db.profile.ui.sortAsc ~= false
  local va, vb = a[key], b[key]
  if va == vb then return a.name < b.name end
  if asc then return va < vb else return va > vb end
end

local function filterRows(rows)
  local q = (AltTracker.db.profile.ui.search or ""):lower()
  if q == "" then return rows end
  local out = {}
  for _, r in ipairs(rows) do
    if tostring(r.name):lower():find(q, 1, true) or tostring(r.realm):lower():find(q, 1, true) or tostring(r.faction):lower():find(q, 1, true) then
      table.insert(out, r)
    end
  end
  return out
end

local function buildOverviewData()
  local rows = getChars()
  rows = filterRows(rows)
  table.sort(rows, sortFunc)
  local list = {}
  for _, r in ipairs(rows) do
    table.insert(list, r)
  end
  return list
end

local function buildDataByMode(mode)
  if mode == "Overview" then return buildOverviewData() end
  -- TODO: add specialized datasets per tab
  return buildOverviewData()
end

local function Header_OnClick(self)
  local key = self.key
  local ui = AltTracker.db.profile.ui
  if ui.sortKey == key then
    ui.sortAsc = not ui.sortAsc
  else
    ui.sortKey = key
    ui.sortAsc = true
  end
  TV:Refresh()
end

function TV:Init(parent)
  self.Parent = parent

  -- Header container
  local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 12, -56)
  header:SetPoint("TOPRIGHT", -12, -56)
  header:SetHeight(24)

  self.Headers = {}
  local x = 0
  for i, col in ipairs(COLUMNS) do
    local btn = CreateFrame("Button", nil, header)
    btn:SetPoint("LEFT", x, 0)
    btn:SetSize(col.width, 24)
    btn.key = col.key
    btn:SetNormalFontObject(GameFontHighlightSmall)
    btn:SetText(col.title)
    btn:SetScript("OnClick", Header_OnClick)
    self.Headers[i] = btn
    x = x + col.width + 8
  end

  -- ScrollBox + view
  local scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
  scrollBox:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
  scrollBox:SetPoint("BOTTOMRIGHT", -28, 16)

  local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
  scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 6, 0)
  scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 6, 0)

  local view = CreateScrollBoxListLinearView()
  view:SetElementInitializer("Button", function(button, data)
    button:SetHeight(24)
    if not button.cells then
      button.cells = {}
      local left = 0
      for i, col in ipairs(COLUMNS) do
        local fs = button:CreateFontString(nil, "OVERLAY", "GameFontWhite")
        fs:SetPoint("LEFT", left, 0)
        fs:SetWidth(col.width)
        fs:SetJustifyH(col.align or "LEFT")
        button.cells[i] = fs
        left = left + col.width + 8
      end
    end
    local values = {
      data.name,
      tostring(data.level),
      tostring(data.ilvl),
      tostring(data.faction or ""),
      tostring(data.realm),
      tostring(data.mplus or 0),
      formatGold(data.gold or 0),
    }
    for i, v in ipairs(values) do button.cells[i]:SetText(v) end
  end)

  ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)

  self.Header = header
  self.ScrollBox = scrollBox
  self.View = view
  self.Mode = AltTracker.db.profile.ui.lastTab or "Overview"
end

function TV:SetMode(name)
  self.Mode = name
  self:Refresh()
end

function TV:Refresh()
  if not self.ScrollBox then return end
  local rows = buildDataByMode(self.Mode)
  local provider = CreateDataProvider(rows)
  self.ScrollBox:SetDataProvider(provider, ScrollBoxConstants.RetainScrollPosition)
end

function TV:Relayout()
  self:Refresh()
end
