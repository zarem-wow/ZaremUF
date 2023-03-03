-----------------
-- Author: Zarem
-- Version: Classic/WotLK

local config = {
    scale = 1.05,
    nameAlpha = 1,
    hideRest = true,
    hideAttack = true,
    hidePlayerFrame = true,
    playerFrameVis = "[combat] [@target,exists] [mod:shift] show; hide",
    customPos = true,
    position = {
        player = { "CENTER", UIParent, "CENTER", -470, 280 },
        target = { "CENTER", UIParent, "CENTER", -220, 280 },
    },
}

-----------------
-- Colors

local function ClassColors(frame, unit)
    local _, class = UnitClass(unit)
    if not class then return end
    local color = RAID_CLASS_COLORS[class]
    frame:SetStatusBarColor(color.r, color.g, color.b)
end

local function ReactionColors(frame, unit)
    local r, g, b
    if UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
        r, g, b = 0.5, 0.5, 0.5
    elseif UnitReaction(unit, "player") == 4 then
        r, g, b = 0.9, 0.8, 0.3
    elseif UnitIsFriend(unit, "player") then
        r, g, b = 0, 0.9, 0
    elseif UnitIsEnemy(unit, "player") then
        r, g, b = 0.9, 0.2, 0
    else
        r, g, b = 1, 1, 1
    end
    frame:SetStatusBarColor(r, g, b)
end

local function ApplyColors(frame, unit)
    if not unit then return end

    if UnitIsPlayer(unit) then 
        ClassColors(frame, unit) 
    else
        ReactionColors(frame, unit)
    end
end

hooksecurefunc("UnitFrameHealthBar_Update", function(self)
    ApplyColors(self, self.unit)
end)

hooksecurefunc("HealthBar_OnValueChanged", function(self)
    ApplyColors(self, self.unit)
end)

hooksecurefunc("TargetFrame_CheckFaction", function(self)
    self.nameBackground:SetAlpha(config.nameAlpha)

    if UnitIsDeadOrGhost(self.unit) then
        self.nameBackground:SetVertexColor(0.5, 0.5, 0.5)
    end
end)

-----------------
-- Position

if config.customPos then
    local function ApplyPosition()
        PlayerFrame_ResetUserPlacedPosition()
        TargetFrame_ResetUserPlacedPosition()

        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint(unpack(config.position.player))
        PlayerFrame:SetUserPlaced(true)

        TargetFrame:ClearAllPoints()
        TargetFrame:SetPoint(unpack(config.position.target))
        TargetFrame:SetUserPlaced(true)
    end

    local enteringWorld = CreateFrame("Frame")
    enteringWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
    enteringWorld:SetScript("OnEvent", ApplyPosition)
end

-----------------
-- Hide

if config.hidePlayerFrame then
    RegisterStateDriver(PlayerFrame, "visibility", config.playerFrameVis)
end

hooksecurefunc("PlayerFrame_UpdateStatus", function()
    if config.hideRest and IsResting() then 
        PlayerStatusTexture:Hide() 
        PlayerRestIcon:Hide()
        PlayerRestGlow:Hide()
        PlayerStatusGlow:Hide() 
    end

    if config.hideAttack and (PlayerFrame.inCombat or UnitAffectingCombat("player")) then
        --PlayerAttackIcon:Hide()
        PlayerStatusTexture:Hide()
        PlayerAttackGlow:Hide()
        PlayerStatusGlow:Hide() 
        PlayerAttackBackground:Hide()
    end
end)

-----------------
-- Scale

for _, v in pairs({ PlayerFrame, TargetFrame, FocusFrame }) do
    v:SetScale(config.scale)
end
