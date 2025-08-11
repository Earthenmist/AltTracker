local AltTracker = AltTracker
local Mod = AltTracker:NewModule("Achievements", "AceEvent-3.0")

function Mod:OnEnable()
  self:RegisterEvent("NEW_MOUNT_ADDED", "RefreshMounts")
  self:RegisterEvent("COMPANION_LEARNED", "RefreshPets")
  self:RegisterEvent("TOYS_UPDATED", "RefreshToys")
  self:RegisterEvent("PLAYER_LOGIN", function() self:RefreshMounts(); self:RefreshPets(); self:RefreshToys() end)
end

function Mod:RefreshMounts()
  local store = AltTracker:GetCharStore()
  store.achievements = store.achievements or {}
  store.achievements.mounts = {}
  if C_MountJournal and C_MountJournal.GetNumMounts then
    local num = C_MountJournal.GetNumMounts()
    for i = 1, num do
      local id, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(i)
      if id then store.achievements.mounts[id] = isCollected and true or false end
    end
  end
end

function Mod:RefreshPets()
  local store = AltTracker:GetCharStore()
  store.achievements = store.achievements or {}
  store.achievements.pets = {}
  if C_PetJournal and C_PetJournal.GetNumPets then
    local num = C_PetJournal.GetNumPets(false)
    for i = 1, num do
      local petID, _, owned = C_PetJournal.GetPetInfoByIndex(i)
      if petID then store.achievements.pets[petID] = owned end
    end
  end
end

function Mod:RefreshToys()
  local store = AltTracker:GetCharStore()
  store.achievements = store.achievements or {}
  store.achievements.toys = {}
  if C_ToyBox and C_ToyBox.GetNumToys then
    local num = C_ToyBox.GetNumToys()
    for i = 1, num do
      local itemID = C_ToyBox.GetToyFromIndex(i)
      store.achievements.toys[itemID] = PlayerHasToy(itemID)
    end
  end
end
