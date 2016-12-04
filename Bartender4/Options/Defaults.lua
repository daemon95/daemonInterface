--[[
Copyright (c) 2009, CMTitan
All rights to be transferred to Nevcairiel upon inclusion into Bartender4.
All rights reserved, otherwise.
]]
-- fetch upvalues
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
local Bar = Bartender4.Bar.prototype

local DefaultsMod = Bartender4:NewModule("Defaults")

function DefaultsMod:ToggleModule(info, val)
	-- We are always enabled. Period.
	if not self:IsEnabled() then
		self:Enabled()
	end
end

local function SetBarLocation(config, point, x, y)
	if (not config) then return end
	config.position.point = point
	config.position.x = x
	config.position.y = y
end

-- Build Blizzard-like Layout --
--------------------------------
local function BuildBlizzardProfile()
	local dy, config
	dy = 0
	if not DefaultsMod.showRepBar then
		dy = dy - 8
	end
	if not DefaultsMod.showXPBar then
		dy = dy - 11
	end

	Bartender4.db.profile.blizzardVehicle = true
	Bartender4.db.profile.outofrange = "hotkey"
	Bartender4.db.profile.focuscastmodifier = false

	config = Bartender4.db:GetNamespace("ActionBars").profile
	config.actionbars[1].padding = 6
	SetBarLocation( config.actionbars[1], "BOTTOM", -510, 41.75 )
	config.actionbars[2].enabled = false
	config.actionbars[3].padding = 5
	config.actionbars[3].rows = 12
	SetBarLocation( config.actionbars[3], "BOTTOMRIGHT", -82, 610 )
	config.actionbars[4].padding = 5
	config.actionbars[4].rows = 12
	SetBarLocation( config.actionbars[4], "BOTTOMRIGHT", -42, 610 )
	config.actionbars[5].padding = 6
	SetBarLocation( config.actionbars[5], "BOTTOM", 3, 102 + dy )
	config.actionbars[6].padding = 6
	SetBarLocation( config.actionbars[6], "BOTTOM", -510, 102 + dy )

	config = Bartender4.db:GetNamespace("BagBar").profile
	config.onebag = true
	SetBarLocation( config, "BOTTOM", 463.5, 41.75 )

	config = Bartender4.db:GetNamespace("MicroMenu").profile
	config.position.scale = 1.0
	SetBarLocation( config, "BOTTOM", 37.5, 41.75 )

	if DefaultsMod.showRepBar then
		config = Bartender4.db:GetNamespace("RepBar").profile
		config.enabled = true
		Bartender4:GetModule("RepBar"):Enable()
		SetBarLocation( config, "BOTTOM", -516, 65 + dy ) -- Note that dy is actually correct since it's only incorrect for the RepBar if the RepBar itself does not exist
	end

	if DefaultsMod.showXPBar then
		config = Bartender4.db:GetNamespace("XPBar").profile
		config.enabled = true
		Bartender4:GetModule("XPBar"):Enable()
		SetBarLocation( config, "BOTTOM", -516, 57 )
	end

	config = Bartender4.db:GetNamespace("BlizzardArt").profile
	config.enabled = true
	Bartender4:GetModule("BlizzardArt"):Enable()
	SetBarLocation( config, "BOTTOM", -512, 47 )

	config = Bartender4.db:GetNamespace("PetBar").profile
	if GetNumShapeshiftForms() > 0 then
		SetBarLocation( config, "BOTTOM", -120, 135 + dy )
		config = Bartender4.db:GetNamespace("StanceBar").profile
		config.position.scale = 1.0
		SetBarLocation( config, "BOTTOM", -460, 135 + dy )
	else
		SetBarLocation( config, "BOTTOM", -460, 135 + dy )
	end
end

-- Build Custom Clean Layout --
-------------------------
local function BuildCleanUIProfile()
	local dy, config
	--dy = 0
	--if not DefaultsMod.showRepBar then
		--dy = dy - 8
	--end
	--if not DefaultsMod.showXPBar then
		--dy = dy - 11
	--end

	Bartender4.db.profile.blizzardVehicle = false
	Bartender4.db.profile.focuscastmodifier = false
	Bartender4.db.profile.outofrange = "hotkey"
	Bartender4.db.profile.tooltip = "nocombat"

	-- [Panels] --
	config = Bartender4.db:GetNamespace("ActionBars").profile
	-- [1] First ActionBar
	config.actionbars[1].position.growVertical = "UP"
	config.actionbars[1].visibility.possess = false
	SetBarLocation( config.actionbars[1], "BOTTOM", -221.0, 36.0 )
	-- [2] Second ActionBar
	config.actionbars[2].enabled = false
	config.actionbars[2].position.growVertical = "UP"
	SetBarLocation( config.actionbars[2], "BOTTOM", -221.0, 36.0 )
	-- [3] MultiBarRight
	config.actionbars[3].buttons = 10
	config.actionbars[3].fadeout = true
	config.actionbars[3].position.growHorizontal = "LEFT"
	config.actionbars[3].rows = 10
	SetBarLocation( config.actionbars[3], "RIGHT", 2.0, 185.0 )
	-- [4] MultiBarLeft
	config.actionbars[4].buttons = 10
	config.actionbars[4].fadeout = true
	config.actionbars[4].rows = 10
	SetBarLocation( config.actionbars[4], "LEFT", -2.0, 185.0 )
	-- [5] MultiBarBottomRight
	config.actionbars[5].position.growVertical = "UP"
	SetBarLocation( config.actionbars[5], "BOTTOM", -221.0, 72.0 )
	-- [6] MultiBarBottomLeft
	--config.actionbars[6].enabled = false
	config.actionbars[6].position.growVertical = "UP"
	config.actionbars[6].visibility.possess = true
	SetBarLocation( config.actionbars[6], "BOTTOM", -221.0, 0.0 )
		-- [7] Use as VehicleUIBar
	config.actionbars[7].enabled = true
	config.actionbars[7].buttons = 6
	config.actionbars[7].position.growHorizontal = "RIGHT"
	config.actionbars[7].position.growVertical = "UP"
	config.actionbars[7].position.scale = 2.0
	config.actionbars[7].states.enabled = true
	config.actionbars[7].states.possess = true
	config.actionbars[7].visibility.vehicleui = false
	config.actionbars[7].visibility.custom = true
	config.actionbars[7].visibility.customdata = "[vehicleui]show;hide"
	--SetBarLocation( config.actionbars[7], "BOTTOM", -226.0, 0.0 )
	SetBarLocation( config.actionbars[7], "BOTTOM", -226.0, 0.0 )
	-- [8] Use as CommonExtraBar
	config.actionbars[8].enabled = true
	config.actionbars[8].buttons = 8
	config.actionbars[8].position.growHorizontal = "LEFT"
	config.actionbars[8].position.growVertical = "UP"
	config.actionbars[8].position.scale = 0.8
	config.actionbars[8].padding = 2
--	config.actionbars[8].states.enabled = true
--	config.actionbars[8].states.possess = true
	config.actionbars[8].visibility.vehicleui = false
	SetBarLocation( config.actionbars[8], "BOTTOMRIGHT", -44.0, 34.0 )
	-- [9] Use as SpecialExtraBar
	config.actionbars[9].enabled = true
	config.actionbars[9].buttons = 9
	config.actionbars[9].position.growVertical = "UP"
	config.actionbars[9].position.scale = 0.8
	config.actionbars[9].padding = 4
--	config.actionbars[9].states.enabled = true
--	config.actionbars[9].states.possess = true
	config.actionbars[9].visibility.vehicleui = false
	SetBarLocation( config.actionbars[9], "BOTTOMLEFT", 0.0, 0.0 )

	-- [Bags] --
	config = Bartender4.db:GetNamespace("BagBar").profile
	config.keyring = true
	config.position.growHorizontal = "LEFT"
	config.rows = 6
	config.visibility.vehicleui = false
	SetBarLocation( config, "BOTTOMRIGHT", 2.0, 200.0 )

	-- [Menu] --
	config = Bartender4.db:GetNamespace("MicroMenu").profile
	config.position.scale = 0.9
	config.position.growVertical = "UP"
	config.visibility.vehicleui = false
	SetBarLocation( config, "BOTTOMRIGHT", -298.0, -22.0 )

	-- [RepXp] --
	config = Bartender4.db:GetNamespace("RepBar").profile
	if DefaultsMod.showRepBar then
		config.enabled = true
		config.fadeout = true
		Bartender4:GetModule("RepBar"):Enable()
		SetBarLocation( config, "TOP", -516.0, 4.0 )
	end
	config = Bartender4.db:GetNamespace("XPBar").profile
	if DefaultsMod.showXPBar then
		config.enabled = true
		config.fadeout = true
		Bartender4:GetModule("XPBar"):Enable()
		SetBarLocation( config, "TOP", -516.0, 4.0 )
	end

	-- [Art] --
	config = Bartender4.db:GetNamespace("BlizzardArt").profile
	--config.enabled = true
	config.artLayout = "CLASSIC"
	--Bartender4:GetModule("BlizzardArt"):Enable()
	SetBarLocation( config, "BOTTOM", -512.0, 46.0 )

	-- [Pet] --
	config = Bartender4.db:GetNamespace("PetBar").profile
	config.position.growVertical = "UP"
	SetBarLocation( config, "BOTTOM", -155.0, 106.0 )

	-- [Stance] --
	config = Bartender4.db:GetNamespace("StanceBar").profile
	config.hidehotkey = false
	config.padding = 10
	config.position.growVertical = "UP"
	config.position.scale = 1.0
	config.visibility.possess = false
	config.visibility.vehicleui = false
	SetBarLocation( config, "BOTTOMLEFT", 0.0, 0.0 )

	-- [Vehicle control] --
	config = Bartender4.db:GetNamespace("Vehicle").profile
	config.position.growHorizontal = "LEFT"
	config.position.growVertical = "UP"
	config.position.scale = 1.5
--	config.rows = 3
	config.visibility.vehicleui = false
	SetBarLocation( config, "BOTTOMRIGHT", -40.0, 28.0 )

	-- [Vehicle] --
	--config = Bartender4.db:GetNamespace("Vehicle").profile

	--config.enabled = false
	--config.padding = 0
	--config.position.scale = 1.5
	--SetBarLocation( config, "TOP", 213.0, 0.0 )
end

local function ResetProfile()
	if DefaultsMod.defaultType == "CLEANUI" then
--		Bartender4.db:ResetProfile()
		BuildCleanUIProfile()
	elseif DefaultsMod.defaultType == "BLIZZARD" then
--		Bartender4.db:ResetProfile()
		BuildBlizzardProfile()
	else
		-- Ace database will set all options to nil
		Bartender4.db:ResetProfile()
		return
	end
	Bartender4:UpdateModuleConfigs()
end

function DefaultsMod:SetupOptions()
	if not self.options then
    --DefaultsMod.defaultType = "BLIZZARD"
    --self.showXPBar = true
    --self.showRepBar = true
    DefaultsMod.defaultType = "CLEANUI"
    self.showXPBar = false
    self.showRepBar = false
		local otbl = {
			message1 = {
				order = 1,
				type = "description",
				name = L["You can use the preset defaults as a starting point for setting up your interface. Just choose your preferences here and click the button below to reset your profile to the preset default."]
			},
			message2 = {
				order = 2,
				type = "description",
				name = L["WARNING: Pressing the button will reset your complete profile! If you're not sure about this create a new profile and use that to experiment."],
			},
			preset = {
				order = 10,
				type = "select",
				name = L["Defaults"],
				values = { CLEANUI = L["CleanUI interface"], BLIZZARD = L["Blizzard interface"], RESET = L["Full reset"] },
				get = function() return DefaultsMod.defaultType end,
				set = function(info, val) DefaultsMod.defaultType = val end
			},
			nl1 = {
				order = 11,
				type = "description",
				name = ""
			},
			xpbar = {
				order = 20,
				type = "toggle",
				name = L["Show XP Bar"],
				get = function() return DefaultsMod.showXPBar end,
				set = function(info, val) DefaultsMod.showXPBar = val end,
				disabled = function() return DefaultsMod.defaultType == "RESET" end
			},
			nl2  = {
					order = 21,
					type = "description",
					name = ""
			},
			repbar = {
				order = 30,
				type = "toggle",
				name = L["Show Reputation Bar"],
				get = function() return DefaultsMod.showRepBar end,
				set = function(info, val) DefaultsMod.showRepBar = val end,
				disabled = function() return DefaultsMod.defaultType == "RESET" end
			},
			nl3 = {
				order = 31,
				type = "description",
				name = ""
			},
			button = {
				order = 40,
				type = "execute",
				name = L["Reset profile"],
				func = ResetProfile
			}
		}
		self.optionobject = Bartender4:NewOptionObject( otbl )
		self.options = {
			order = 200,
			type = "group",
			name = L["Defaults"],
			desc = L["Configure all of Bartender to preset defaults"],
			childGroups = "tab",
		}
		Bartender4:RegisterModuleOptions("Defaults", self.options)
	end
	self.options.args = self.optionobject.table
end
