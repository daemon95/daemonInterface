-- BURST CACHE ---------------------------------------------------
local VUHDO_HEAL_BUTTON_POSITIONS = { };
local VUHDO_PANEL_SETUP;
local VUHDO_getHeaderWidthHor;
local VUHDO_getHeaderWidthVer;
local VUHDO_getHeaderHeightHor;
local VUHDO_getHeaderHeightVer;
local VUHDO_getHeaderPosHor;
local VUHDO_getHeaderPosVer;
local VUHDO_getHealButtonPosHor;
local VUHDO_getHealButtonPosVer;
local VUHDO_isConfigPanelShowing;

function VUHDO_sizeCalculatorInitBurst()
	VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];
	VUHDO_sizeCalculatorInitBurstHor();
	VUHDO_sizeCalculatorInitBurstVer();

	VUHDO_getHeaderWidthHor = VUHDO_GLOBAL["VUHDO_getHeaderWidthHor"];
	VUHDO_getHeaderWidthVer = VUHDO_GLOBAL["VUHDO_getHeaderWidthVer"];
	VUHDO_getHeaderHeightHor = VUHDO_GLOBAL["VUHDO_getHeaderHeightHor"];
	VUHDO_getHeaderHeightVer = VUHDO_GLOBAL["VUHDO_getHeaderHeightVer"];
	VUHDO_getHeaderPosHor = VUHDO_GLOBAL["VUHDO_getHeaderPosHor"];
	VUHDO_getHeaderPosVer = VUHDO_GLOBAL["VUHDO_getHeaderPosVer"];
	VUHDO_getHealButtonPosHor = VUHDO_GLOBAL["VUHDO_getHealButtonPosHor"];
	VUHDO_getHealButtonPosVer = VUHDO_GLOBAL["VUHDO_getHealButtonPosVer"];
	VUHDO_isConfigPanelShowing = VUHDO_GLOBAL["VUHDO_isConfigPanelShowing"];
	table.wipe(VUHDO_HEAL_BUTTON_POSITIONS);
end

-- BURST CACHE ---------------------------------------------------


local sHealButtonWidthCache = { };

function resetSizeCalcCaches()
	table.wipe(sHealButtonWidthCache);
	resetSizeCalcCachesHor();
	resetSizeCalcCachesVer();
	table.wipe(VUHDO_HEAL_BUTTON_POSITIONS);
end



--
local tBarScaling;
local tTargetWidth;
local function VUHDO_getTargetBarWidth(aPanelNum)
	tBarScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];

	tTargetWidth = 0;
	if (tBarScaling.showTarget) then
		tTargetWidth = tTargetWidth + tBarScaling.targetSpacing + tBarScaling.targetWidth;
	end

	if (tBarScaling.showTot) then
		tTargetWidth = tTargetWidth + tBarScaling.totSpacing + tBarScaling.totWidth;
	end

	return tTargetWidth;
end



--
local tHotSlots, tCnt;
function VUHDO_getNumHotSlots(aPanelNum)
	tHotSlots = 0;

	for tCnt = 1, 5 do
		if (VUHDO_PANEL_SETUP["HOTS"]["SLOTS"][tCnt] ~= nil) then
			tHotSlots = tHotSlots + 1;
		end
	end

	if (VUHDO_PANEL_SETUP["HOTS"]["SLOTS"][9] ~= nil) then
		tHotSlots = tHotSlots + 1;
	end

	return tHotSlots;
end

local VUHDO_getNumHotSlots = VUHDO_getNumHotSlots;



--
local tHotCfg;
local tHotSlots;
local function VUHDO_getHotIconWidth(aPanelNum)
	tHotCfg = VUHDO_PANEL_SETUP["HOTS"];

	if (tHotCfg.show and (tHotCfg.radioValue == 1 or tHotCfg.radioValue == 4)) then
		tHotSlots = VUHDO_getNumHotSlots(aPanelNum);
		return VUHDO_PANEL_SETUP[aPanelNum]["SCALING"].barHeight * VUHDO_PANEL_SETUP[aPanelNum]["HOTS"].size * tHotSlots * 0.01;
	end

	return 0;
end



--
function VUHDO_getHealButtonWidth(aPanelNum)
	if (VUHDO_IS_PANEL_CONFIG and not VUHDO_CONFIG_SHOW_RAID) then
		return VUHDO_PANEL_SETUP[aPanelNum]["SCALING"].barWidth;
	elseif (sHealButtonWidthCache[aPanelNum] == nil) then
		sHealButtonWidthCache[aPanelNum] = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"].barWidth + VUHDO_getTargetBarWidth(aPanelNum) + VUHDO_getHotIconWidth(aPanelNum);
	end

	return sHealButtonWidthCache[aPanelNum];
end



-- Returns total header width
function VUHDO_getHeaderWidth(aPanelNum)
	if (VUHDO_PANEL_SETUP[aPanelNum]["SCALING"].arrangeHorizontal and not VUHDO_isConfigPanelShowing()) then
		return VUHDO_getHeaderWidthHor(aPanelNum);
	else
		return VUHDO_getHeaderWidthVer(aPanelNum)
	end
end



-- Returns total header height
function VUHDO_getHeaderHeight(aPanelNum)
	if (VUHDO_PANEL_SETUP[aPanelNum]["SCALING"].arrangeHorizontal and not VUHDO_isConfigPanelShowing()) then
		return VUHDO_getHeaderHeightHor(aPanelNum);
	else
		return VUHDO_getHeaderHeightVer(aPanelNum);
	end
end



--
function VUHDO_getHeaderPos(aHeaderPlace, aPanelNum)
	if (VUHDO_PANEL_SETUP[aPanelNum]["SCALING"].arrangeHorizontal and not VUHDO_isConfigPanelShowing()) then
		return VUHDO_getHeaderPosHor(aHeaderPlace, aPanelNum);
	else
		return VUHDO_getHeaderPosVer(aHeaderPlace, aPanelNum);
	end
end



--
local tIndex;
function VUHDO_getHealButtonPos(aPlaceNum, aRowNo, aPanelNum)
	tIndex = aPlaceNum + aRowNo * 1000 + aPanelNum * 100000;

	if (VUHDO_HEAL_BUTTON_POSITIONS[tIndex] == nil) then
		VUHDO_HEAL_BUTTON_POSITIONS[tIndex] = { };

		if (VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["arrangeHorizontal"] and not VUHDO_isConfigPanelShowing()) then
			VUHDO_HEAL_BUTTON_POSITIONS[tIndex][1], VUHDO_HEAL_BUTTON_POSITIONS[tIndex][2] = VUHDO_getHealButtonPosHor(aPlaceNum, aRowNo, aPanelNum);
		else
			VUHDO_HEAL_BUTTON_POSITIONS[tIndex][1], VUHDO_HEAL_BUTTON_POSITIONS[tIndex][2] = VUHDO_getHealButtonPosVer(aPlaceNum, aRowNo, aPanelNum);
		end
	end

	return VUHDO_HEAL_BUTTON_POSITIONS[tIndex][1], VUHDO_HEAL_BUTTON_POSITIONS[tIndex][2];
end



--
function VUHDO_getHealPanelWidth(aPanelNum)
	if (VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["arrangeHorizontal"] and not VUHDO_isConfigPanelShowing()) then
		return VUHDO_getHealPanelWidthHor(aPanelNum);
	else
		return VUHDO_getHealPanelWidthVer(aPanelNum);
	end
end



--
function VUHDO_getHealPanelHeight(aPanelNum)
	if (VUHDO_PANEL_SETUP[aPanelNum]["SCALING"].arrangeHorizontal and not VUHDO_isConfigPanelShowing()) then
		return VUHDO_getHealPanelHeightHor(aPanelNum);
	else
		return VUHDO_getHealPanelHeightVer(aPanelNum);
	end
end
