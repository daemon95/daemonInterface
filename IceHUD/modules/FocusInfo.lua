local L = LibStub("AceLocale-3.0"):GetLocale("IceHUD", false)
local FocusInfo = IceCore_CreateClass(IceTargetInfo)

local EPSILON = 0.5

FocusInfo.prototype.mainHandEnchantTimeSet = 0
FocusInfo.prototype.mainHandEnchantEndTime = 0
FocusInfo.prototype.offHandEnchantTimeSet = 0
FocusInfo.prototype.offHandEnchantEndTime = 0
FocusInfo.prototype.scheduledEvent = nil

-- Constructor --
function FocusInfo.prototype:init()
	FocusInfo.super.prototype.init(self, "FocusInfo", "focus")
end

function FocusInfo.prototype:GetDefaultSettings()
	local settings = FocusInfo.super.prototype.GetDefaultSettings(self)

	--settings["enabled"] = false
	--settings["vpos"] = 545
	settings["buffSize"] = 24
	settings["ownBuffSize"] = 32
	--settings["buffOffset"] = {x=-10, y=0}
	settings["buffOffset"] = {x=0, y=0}
	--settings["buffAnchorTo"] = "TOPLEFT"
	--settings["buffGrowDirection"] = "Left"
	--settings["debuffOffset"] = {x=10, y=0}
	settings["debuffOffset"] = {x=0, y=0}
	--settings["debuffAnchorTo"] = "TOPRIGHT"
	--settings["debuffGrowDirection"] = "Right"
	--settings["perRow"] = 8
	--settings["line1Tag"] = "[Name:ClassColor]"
	settings["line2Tag"] = "[Level:DifficultyColor] [SmartRace:ClassColor] [SmartClass:ClassColor] [PvPIcon] [IsLeader ? 'Leader':Yellow] [InCombat ? 'Combat':Red] [Classification]"
	settings["line3Tag"] = ""
	settings["line4Tag"] = ""
-- Custom
	--settings["myTagVersion"] = 3
	settings["enabled"] = true
	settings["scale"] = 0.8
	settings["hpos"] = -345
	settings["vpos"] = 515
	settings["showBuffs"] = false
	settings["filterBuffs"] = "Always"
	settings["buffAnchorTo"] = "BOTTOMLEFT"
	settings["buffGrowDirection"] = "Right"
	settings["debuffAnchorTo"] = "BOTTOMRIGHT"
	settings["debuffGrowDirection"] = "Left"
	settings["perRow"] = 12
	settings["line1Tag"] = "[Name:ClassColor ' (Focus)']"

	return settings
end

function FocusInfo.prototype:GetOptions()
	local opts = FocusInfo.super.prototype.GetOptions(self)
	return opts
end

function FocusInfo.prototype:CreateFrame(redraw)
	FocusInfo.super.prototype.CreateFrame(self, redraw)

	self.frame.menu = function()
    ToggleDropDownMenu(1, nil, FocusFrameDropDown, "cursor")
	end
end

StaticPopupDialogs["ICEHUD_BUFF_DISMISS_UNAVAILABLE"] =
{
	text = "Sorry, but there is currently no way for custom mods to cancel buffs. This will be fixed whenever Blizzard fixes the API.",
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 0,
}

function FocusInfo.prototype:CreateIconFrames(parent, direction, buffs, type)
	local buffs = FocusInfo.super.prototype.CreateIconFrames(self, parent, direction, buffs, type)

	for i = 1, IceCore.BuffLimit do
		if (self.moduleSettings.mouseBuff) then
			buffs[i]:SetScript("OnMouseUp", function( self, button)
				if IceHUD.WowVer >= 40000 then
					StaticPopup_Show("ICEHUD_BUFF_DISMISS_UNAVAILABLE")
				end
			end)
		else
			buffs[i]:SetScript("OnMouseUp", nil)
		end
	end

	return buffs
end

function FocusInfo.prototype:Enable(core)
	FocusInfo.super.prototype.Enable(self, core)
	self.scheduledEvent = self:ScheduleRepeatingTimer("RepeatingUpdateBuffs", 1)
end

function FocusInfo.prototype:Disable(core)
	FocusInfo.super.prototype.Disable(self, core)

	self:CancelTimer(self.scheduledEvent, true)
end

function FocusInfo.prototype:RepeatingUpdateBuffs()
	self:UpdateBuffs(self.unit, true)
end

function FocusInfo.prototype:UpdateBuffs(unit, fromRepeated)
	if unit and unit ~= self.unit then
		return
	end

	if not fromRepeated then
		FocusInfo.super.prototype.UpdateBuffs(self)
	end

	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges
		= GetWeaponEnchantInfo()

	local startingNum = 0

	for i=1, IceCore.BuffLimit do
		if not self.frame.buffFrame.buffs[i]:IsVisible()
			or self.frame.buffFrame.buffs[i].type == "mh"
			or self.frame.buffFrame.buffs[i].type == "oh" then
			if startingNum == 0 then
				startingNum = i
			end
		end

		if self.frame.buffFrame.buffs[i]:IsVisible() then
			if (self.frame.buffFrame.buffs[i].type == "mh" and not hasMainHandEnchant)
				or (self.frame.buffFrame.buffs[i].type == "oh" and not hasOffHandEnchant) then
				self.frame.buffFrame.buffs[i]:Hide()
			end
		end
	end

	if hasMainHandEnchant or hasOffHandEnchant then
		local CurrTime = GetTime()

		if hasMainHandEnchant then
			if self.mainHandEnchantEndTime == 0 or
				abs(self.mainHandEnchantEndTime - (mainHandExpiration/1000)) > CurrTime - self.mainHandEnchantTimeSet + EPSILON then
				self.mainHandEnchantEndTime = mainHandExpiration/1000
				self.mainHandEnchantTimeSet = CurrTime
			end

			if not self.frame.buffFrame.buffs[startingNum]:IsVisible() or self.frame.buffFrame.buffs[startingNum].type ~= "mh" then
				self:SetUpBuff(startingNum,
					GetInventoryItemTexture(self.unit, GetInventorySlotInfo("MainHandSlot")),
					self.mainHandEnchantEndTime,
					CurrTime + (mainHandExpiration/1000),
					true,
					mainHandCharges,
					"mh")
			end

			startingNum = startingNum + 1
		end

		if hasOffHandEnchant then
			if self.offHandEnchantEndTime == 0 or
				abs(self.offHandEnchantEndTime - (offHandExpiration/1000)) > abs(CurrTime - self.offHandEnchantTimeSet) + EPSILON then
				self.offHandEnchantEndTime = offHandExpiration/1000
				self.offHandEnchantTimeSet = CurrTime
			end

			if not self.frame.buffFrame.buffs[startingNum]:IsVisible() or self.frame.buffFrame.buffs[startingNum].type ~= "oh" then
				self:SetUpBuff(startingNum,
					GetInventoryItemTexture(self.unit, GetInventorySlotInfo("SecondaryHandSlot")),
					self.offHandEnchantEndTime,
					CurrTime + (offHandExpiration/1000),
					true,
					offHandCharges,
					"oh")
			end

			startingNum = startingNum + 1
		end

		for i=startingNum, IceCore.BuffLimit do
			if self.frame.buffFrame.buffs[i]:IsVisible() then
				self.frame.buffFrame.buffs[i]:Hide()
			end
		end

		local direction = self.moduleSettings.buffGrowDirection == "Left" and -1 or 1
		self.frame.buffFrame.buffs = self:CreateIconFrames(self.frame.buffFrame, direction, self.frame.buffFrame.buffs, "buff")
	end
end

-- Load us up
IceHUD.FocusInfo = FocusInfo:new()
