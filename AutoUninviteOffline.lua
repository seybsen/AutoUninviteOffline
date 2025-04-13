local frame = CreateFrame("Frame")
local addonEnabled = true
local checkInterval = 5 -- Seconds between checks
local lastCheck = GetTime()

-- Event registration
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
frame:RegisterEvent("PARTY_MEMBERS_CHANGED")

-- OnUpdate handler
frame:SetScript("OnUpdate", function(self)
    if not addonEnabled then return end

    local now = GetTime()
    if (now - lastCheck) >= checkInterval then
        CheckOfflineMembers()
        lastCheck = now
    end
end)

function CheckOfflineMembers()
    local inParty = GetNumPartyMembers() > 0
    local inRaid = GetNumRaidMembers() > 0
    if not (inParty or inRaid) then return end

    local isRaid = inRaid
    local numMembers = isRaid and GetNumRaidMembers() or GetNumPartyMembers()
    local unitPrefix = isRaid and "raid" or "party"

    for i = 1, numMembers do
        local unit = unitPrefix .. i
        if UnitExists(unit) then
            local name = UnitName(unit)
            local online = UnitIsConnected(unit)

            if not online then
                UninviteByName(name)
                print(name .. " uninvited (offline).")
            end
        end
    end
end

-- Slash command
SLASH_AUTOUNINVITE1 = "/auo"
SlashCmdList["AUTOUNINVITE"] = function()
    addonEnabled = not addonEnabled
    print("Auto Uninvite Offline: " .. (addonEnabled and "Enabled" or "Disabled"))
end
