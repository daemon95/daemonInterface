--[[
	Copyright (c) 2009, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
--[[ Generic Template for a Bar which contains Buttons ]]

local Bar = Bartender4.Bar.prototype
local ButtonBar = setmetatable({}, {__index = Bar})
local ButtonBar_MT = {__index = ButtonBar}

local defaults = Bartender4:Merge({
	-- Default was: padding = 2,
	padding = 0,
	rows = 1,
	hidemacrotext = false,
	hidehotkey = false,
	skin = {
		ID = "DreamLayout",
		Backdrop = true,
		Gloss = 0,
		Zoom = false,
		Colors = {},
	},
}, Bartender4.Bar.defaults)

Bartender4.ButtonBar = {}
Bartender4.ButtonBar.prototype = ButtonBar
Bartender4.ButtonBar.defaults = defaults

local LBF = LibStub("LibButtonFacade", true)

function Bartender4.ButtonBar:Create(id, config, name)
	local bar = setmetatable(Bartender4.Bar:Create(id, config, name), ButtonBar_MT)

	if LBF then
		bar.LBFGroup = LBF:Group("Bartender4", tostring(id))
		bar.LBFGroup.SkinID = config.skin.ID or "Blizzard"
		bar.LBFGroup.Backdrop = config.skin.Backdrop
		bar.LBFGroup.Gloss = config.skin.Gloss
		bar.LBFGroup.Colors = config.skin.Colors

		LBF:RegisterSkinCallback("Bartender4", self.SkinChanged, self)
	end

	return bar
end

local barregistry = Bartender4.Bar.barregistry
function Bartender4.ButtonBar:SkinChanged(SkinID, Gloss, Backdrop, Group, Button, Colors)
	local bar = barregistry[tostring(Group)]
	if not bar then return end

	bar:SkinChanged(SkinID, Gloss, Backdrop, Colors, Button)
end

ButtonBar.BT4BarType = "ButtonBar"

function ButtonBar:UpdateSkin()
	if not self.LBFGroup then return end
	local config = self.config
	self.LBFGroup:Skin(config.skin.ID, config.skin.Gloss, config.skin.Backdrop, config.skin.Colors)
end

function ButtonBar:ApplyConfig(config)
	Bar.ApplyConfig(self, config)
	ButtonBar.UpdateSkin(self)
	-- any module inherting this template should call UpdateButtonLayout after setting up its buttons, we cannot call it here
	--self:UpdateButtonLayout()
end

-- get the current padding
function ButtonBar:GetPadding()
	return self.config.padding
end

-- set the padding and refresh layout
function ButtonBar:SetPadding(pad)
	if pad ~= nil then
		self.config.padding = pad
	end
	self:UpdateButtonLayout()
end


-- get the current number of rows
function ButtonBar:GetRows()
	return self.config.rows
end

-- set the number of rows and refresh layout
function ButtonBar:SetRows(rows)
	if rows ~= nil then
		self.config.rows = rows
	end
	self:UpdateButtonLayout()
end

function ButtonBar:GetZoom()
	return self.config.skin.Zoom
end

function ButtonBar:SetZoom(zoom)
	self.config.skin.Zoom = zoom
	self:UpdateButtonLayout()
end

function ButtonBar:SetHideMacroText(state)
	if state ~= nil then
		self.config.hidemacrotext = state
	end
	self:ForAll("Update")
end

function ButtonBar:GetHideMacroText()
	return self.config.hidemacrotext
end

function ButtonBar:SetHideHotkey(state)
	if state ~= nil then
		self.config.hidehotkey = state
	end
	self:ForAll("Update")
end

function ButtonBar:GetHideHotkey()
	return self.config.hidehotkey
end

function ButtonBar:SetHGrowth(value)
	self.config.position.growHorizontal = value
	self:AnchorOverlay()
	self:UpdateButtonLayout()
end

function ButtonBar:GetHGrowth()
	return self.config.position.growHorizontal
end

function ButtonBar:SetVGrowth(value)
	self.config.position.growVertical = value
	self:AnchorOverlay()
	self:UpdateButtonLayout()
end

function ButtonBar:GetVGrowth()
	return self.config.position.growVertical
end


ButtonBar.ClickThroughSupport = true
function ButtonBar:SetClickThrough(click)
	if click ~= nil then
		self.config.clickthrough = click
	end
	self:ForAll("EnableMouse", not self.config.clickthrough)
end

local math_floor = math.floor
local math_ceil = math.ceil
-- align the buttons and correct the size of the bar overlay frame
ButtonBar.button_width = 36
ButtonBar.button_height = 36
function ButtonBar:UpdateButtonLayout()
	DEFAULT_CHAT_FRAME:AddMessage("++ " .. self:GetName() .. ":UpdateButtonLayout()")
	local buttons = self.buttons
	if not buttons then
--		DEFAULT_CHAT_FRAME:AddMessage(self:GetName() .. ":UpdateButtonLayout(): Error: Button array is empty")
	end
	local pad = self:GetPadding()

	local numbuttons = self.numbuttons or #buttons

	-- bail out if the bar has no buttons, for whatever reason
	-- (eg. stanceless class, or no stances learned yet, etc.)
	if numbuttons == 0 then return end

	local Rows = self:GetRows()
	local ButtonPerRow = math_ceil(numbuttons / Rows) -- just a precaution
	Rows = math_ceil(numbuttons / ButtonPerRow)
	if Rows > numbuttons then
		Rows = numbuttons
		ButtonPerRow = 1
	end

	local hpad = pad + (self.hpad_offset or 0)
	local vpad = pad + (self.vpad_offset or 0)

	self:SetSize((self.button_width + hpad) * ButtonPerRow - pad + 10, (self.button_height + vpad) * Rows - pad + 10)

	-- Dynamic edges
	local h1, h2, v1, v2 = "LEFT", "RIGHT", "TOP", "BOTTOM" 
	-- Adjustments for the first button
	local xOff, yOff = 5, -3
	if self.config.position.growHorizontal == "LEFT" then
		h1, h2 = "RIGHT", "LEFT"
		xOff = -3
--		xOff, yOff = yOff, xOff
		hpad = -hpad
	end

	if self.config.position.growVertical == "UP" then
		v1, v2 = "BOTTOM", "TOP"
		yOff = 5
--		xOff, yOff = yOff, xOff
		vpad = -vpad
	end

	-- anchor button 1
	local anchor = self:GetAnchor()
--	buttons[1]:ClearSetPoint(anchor, self, anchor, xOff - (self.hpad_offset or 0), yOff - (self.vpad_offset or 0))
	buttons[1]:ClearSetPoint(anchor, self, anchor, xOff, yOff)

	-- and anchor all other buttons relative to our button 1
	for i = 2, numbuttons do
		-- jump into a new row
		if ((i - 1) % ButtonPerRow) == 0 then
			buttons[i]:ClearSetPoint(v1 .. h1, buttons[i - ButtonPerRow], v2 .. h1, 0, -vpad)
		-- align to the previous button
		else
--			buttons[i]:ClearSetPoint("TOP" .. h1, buttons[i - 1], "TOP" .. h2, hpad, 0)
			buttons[i]:ClearSetPoint(h1, buttons[i - 1], h2, hpad, 0)
		end
	end

	if not LBF then
		for i = 1, #buttons do
			local button = buttons[i]
			if button.icon and self.config.skin.Zoom then
				button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
--				button.icon:SetTexCoord(0.0, 1.0, 0.0, 1.0)
			elseif button.icon then
				button.icon:SetTexCoord(0, 1, 0, 1)
			end
		end
	end
end

function ButtonBar:SkinChanged(SkinID, Gloss, Backdrop, Colors)
	self.config.skin.ID = SkinID
	self.config.skin.Gloss = Gloss
	self.config.skin.Backdrop = Backdrop
	self.config.skin.Colors = Colors
end

--[[===================================================================================
	Utility function
===================================================================================]]--

-- get a iterator over all buttons
function ButtonBar:GetAll()
	return pairs(self.buttons)
end

-- execute a member function on all buttons
function ButtonBar:ForAll(method, ...)
	if not self.buttons then return end
	for _, button in self:GetAll() do
		local func = button[method]
		if func then
			func(button, ...)
		end
	end
end
