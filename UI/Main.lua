local AddonName = ...
local AltTracker = _G[AddonName]

AltTracker.UI = AltTracker.UI or {}
local UI = AltTracker.UI

local PADDING = 10

local function EnsureProfileDefaults()
  AltTracker.db = AltTracker.db or { profile = {} }
  AltTracker.db.profile.ui = AltTracker.db.profile.ui or {
    point = {"CENTER", nil, "CENTER", 0, 0},
    size = { width = 900, height = 560 },
    lastTab = "Overview",
    search = "",
    sortKey = "name",
    sortAsc = true,
  }
end

local function CreateFrameSkeleton()
  local f = CreateFrame("Frame", "AltTrackerMain", UIParent, "BackdropTemplate")
  f:SetClampedToScreen(true)
  f:SetResizable(true)
  f:SetMinResize(720, 420)

  local ui = AltTracker.db.profile.ui
  f:SetSize(ui.size.width, ui.size.height)
  f:SetPoint(unpack(ui.point))

  f:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
  f:SetBackdropColor(0,0,0,0.85)

  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local a, b, c, d, e = self:GetPoint()
    AltTracker.db.profile.ui.point = {a, b, c, d, e}
  end)

  -- Titlebar
  local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  title:SetPoint("TOPLEFT", PADDING, -PADDING)
  title:SetText("AltTracker")

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT")

  -- Resize handle
  local sizer = CreateFrame("Button", nil, f)
  sizer:SetPoint("BOTTOMRIGHT")
  sizer:SetSize(16,16)
  sizer:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
  sizer:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
  sizer:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
  sizer:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
  sizer:SetScript("OnMouseUp", function()
    f:StopMovingOrSizing()
    AltTracker.db.profile.ui.size.width, AltTracker.db.profile.ui.size.height = f:GetSize()
    if UI.TableView and UI.TableView.Relayout then UI.TableView:Relayout() end
  end)

  return f
end

-- Public API
function UI:Ensure()
  EnsureProfileDefaults()
  if self.Frame and self.Frame:IsForbidden() then self.Frame = nil end
  if self.Frame then return self.Frame end

  local f = CreateFrameSkeleton()
  self.Frame = f

  -- Create tabs and views
  UI.Tabs:Init(f)
  UI.TableView:Init(f)

  -- Search box
  local search = CreateFrame("EditBox", nil, f, "SearchBoxTemplate")
  search:SetSize(200, 22)
  search:SetPoint("TOPRIGHT", -48, -14)
  search:SetAutoFocus(false)
  search:SetScript("OnTextChanged", function(box)
    SearchBoxTemplate_OnTextChanged(box)
    AltTracker.db.profile.ui.search = box:GetText() or ""
    UI.TableView:Refresh()
  end)
  self.SearchBox = search

  f:Hide()
  return f
end

function UI:Toggle()
  local f = self:Ensure()
  if f:IsShown() then f:Hide() else f:Show(); self.SearchBox:SetText(AltTracker.db.profile.ui.search or ""); UI.TableView:Refresh() end
end
