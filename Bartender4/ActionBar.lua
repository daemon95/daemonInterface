--[[
	Copyright (c) 2009, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local StateBar = Bartender4.StateBar.prototype
local ActionBar = setmetatable({}, {__index = StateBar})
Bartender4.ActionBar = ActionBar

--[[===================================================================================
	ActionBar Prototype
===================================================================================]]--

local initialPosition
do
	-- Sets the Bar to its initial Position in the Center of the Screen
	function initialPosition(bar)
--		bar:ClearSetPoint("CENTER", 0, -250 + (bar.id-1) * 38)
		bar:ClearSetPoint("BOTTOM", 0, (bar.id - 1) * 38)
		bar:SavePosition()
	end
end

-- Apply the specified config to the bar and refresh all settings
function ActionBar:ApplyConfig(config)
	-- Position the bar frame
	local position = self.config.position
	local point, x, y = position.point, position.x, position.y
	if (not position) or (not point) or (not x) or (not y) then 
--		initialPosition(self)
		self:ClearSetPoint("BOTTOM", 0, (self.id - 1) * 38)
		self:SavePosition()
	end

	-- Recreate buttons
	self:UpdateButtons()
	-- Call Apply Config of the parent
	StateBar.ApplyConfig(self, config)
--	initialPosition(self)
end

-- Update the number of buttons in our bar, creating new ones if necessary
function ActionBar:UpdateButtons(numbuttons)
	-- 'numbuttons' indicate the number of active buttons
	-- on the bar
	if numbuttons then
		-- Save the number of buttons to the config
		self.config.buttons = min(numbuttons, 12)
	else
		-- Load the number of buttons from the config
		numbuttons = min(self.config.buttons, 12)
	end

	-- Get existing array of buttons or create a new one
	local buttons = self.buttons or {}

	-- Update if more buttons're are to be created
	local updateBindings = (numbuttons > #buttons)
	-- Create more buttons if the number of active buttons is more
	-- than the number of existing ones
	for i = (#buttons + 1), numbuttons do
		buttons[i] = Bartender4.Button:Create(i, self)
	end

	-- Show active buttons
	for i = 1, numbuttons do
		buttons[i]:SetParent(self)
		buttons[i]:Show()
		buttons[i]:SetAttribute("statehidden", nil)
		buttons[i]:Update()
	end

	-- Hide inactive buttons (if any)
	for i = (numbuttons + 1), #buttons do
		buttons[i]:Hide()
		buttons[i]:SetParent(UIParent)
		buttons[i]:SetAttribute("statehidden", true)
	end

	-- Remember the number of active buttons and the button array
	self.numbuttons = numbuttons
	self.buttons = buttons

	-- Call inherited ButtonBar:UpdateButtonLayout()
	self:UpdateButtonLayout()
	self:SetGrid()
	if updateBindings and self.id == "1" then
		self.module:ReassignBindings()
	end

	-- need to re-set clickthrough after creating new buttons
	self:SetClickThrough()
	self:UpdateSelfCast() -- update selfcast and states
end

function ActionBar:SkinChanged(...)
	StateBar.SkinChanged(self, ...)
	self:ForAll("Update")
end


--[[===================================================================================
	ActionBar Config Interface
===================================================================================]]--


-- get the current number of buttons
function ActionBar:GetButtons()
	return self.config.buttons
end

-- set the number of buttons and refresh layout
ActionBar.SetButtons = ActionBar.UpdateButtons

function ActionBar:GetEnabled()
	return true
end

function ActionBar:SetEnabled(state)
	if not state then
		self.module:DisableBar(self. id)
	end
end

function ActionBar:GetGrid()
	return self.config.showgrid
end

function ActionBar:SetGrid(state)
	if state ~= nil then
		self.config.showgrid = state
	end
	if self.config.showgrid then
		self:ForAll("ShowGrid")
	else
		self:ForAll("HideGrid")
	end
	self:ForAll("UpdateGrid")
end
