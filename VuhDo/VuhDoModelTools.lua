VUHDO_PANEL_MODELS = {};
VUHDO_PANEL_DYN_MODELS = {};

local tinsert = tinsert;
local tremove = tremove;
local table = table;
local ceil = ceil;



--
local tModelArray;
local tKeyArray;
local tCnt;
local tModelId;
function VUHDO_clearUndefinedModelEntries()
	for tKeyArray, tModelArray in pairs(VUHDO_PANEL_MODELS) do
		for tCnt = VUHDO_MAX_GROUPS_PER_PANEL, 1, -1 do
			tModelId = tModelArray[tCnt];

			if (tModelId == VUHDO_ID_UNDEFINED) then
				tremove(tModelArray, tCnt);
			end
		end
	end

	for tKeyArray, tModelArray in pairs(VUHDO_PANEL_MODELS) do
		if (tModelArray == nil or #tModelArray == 0) then
			VUHDO_PANEL_MODELS[tKeyArray] = nil;
		end
	end

end



--
local tCnt;
function VUHDO_initPanelModels()
	table.wipe(VUHDO_PANEL_MODELS);

	for tCnt = 1, VUHDO_MAX_PANELS do
		VUHDO_PANEL_MODELS[tCnt] = VUHDO_PANEL_SETUP[tCnt]["MODEL"].groups;
	end
end



--
local tIsShowModel;
local tIsOmitEmpty;
local tPanelNum, tModelArray;
local tModelIdx, tModelId;
local tMaxRows, tNumModels, tRepeatModels;
local tCnt;
function VUHDO_initDynamicPanelModels()

	if (VUHDO_isConfigPanelShowing()) then
		VUHDO_PANEL_DYN_MODELS = VUHDO_deepCopyTable(VUHDO_PANEL_MODELS);
		return;
	end

	table.wipe(VUHDO_PANEL_DYN_MODELS);

	for tPanelNum, tModelArray in pairs(VUHDO_PANEL_MODELS) do
		tIsOmitEmpty = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"].ommitEmptyWhenStructured;
		VUHDO_PANEL_DYN_MODELS[tPanelNum] = { };
		tMaxRows = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"].maxRowsWhenLoose;

		for tModelIdx, tModelId in pairs(tModelArray) do
			tNumModels = #VUHDO_getGroupMembers(tModelId);
			if ((not tIsOmitEmpty)
				or tNumModels > 0) then

				tRepeatModels = ceil(tNumModels / tMaxRows);
				if (tRepeatModels == 0) then
					tRepeatModels = 1;
				end

				for tCnt = 1, tRepeatModels do
					tinsert(VUHDO_PANEL_DYN_MODELS[tPanelNum], tModelId);
				end

			end
		end
	end
end
