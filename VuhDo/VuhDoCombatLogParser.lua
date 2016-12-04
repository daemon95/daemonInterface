local VUHDO_RAID = { };
local VUHDO_RAID_GUIDS = { };

local strsplit = strsplit;

local VUHDO_updateHealth;



--
function VUHDO_combatLogInitBurst()
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_RAID_GUIDS = VUHDO_GLOBAL["VUHDO_RAID_GUIDS"];
	VUHDO_updateHealth = VUHDO_GLOBAL["VUHDO_updateHealth"];
end



--
local tInfo;
local tNewHealth;
local function VUHDO_addUnitHealth(aUnit, aDelta)
	tInfo = VUHDO_RAID[aUnit];

	if (tInfo ~= nil and not tInfo["dead"]) then
		tNewHealth = tInfo["health"] + aDelta;

		if (tNewHealth < 0) then
			tNewHealth = 0;
		elseif (tNewHealth > tInfo["healthmax"]) then
			tNewHealth = tInfo["healthmax"];
		end

		if (tInfo["health"] ~= tNewHealth) then
			tInfo["health"] = tNewHealth;
			VUHDO_updateHealth(aUnit, 2); -- VUHDO_UPDATE_HEALTH
		end
	end
end



--
local tPrefix, tSuffix, tSpecial;
local function VUHDO_getTargetHealthImpact(aMessage, aMessage1, aMessage2, aMessage4)
	tPrefix, tSuffix, tSpecial = strsplit("_", aMessage);

	if ("SPELL" == tPrefix) then
		if (("HEAL" == tSuffix or "HEAL" == tSpecial) and "MISSED" ~= tSpecial) then
			return aMessage4;
		elseif ("DAMAGE" == tSuffix or "DAMAGE" == tSpecial) then
			return -aMessage4;
		end
	elseif ("DAMAGE" == tSuffix) then
		if ("SWING" == tPrefix) then
			return -aMessage1;
		elseif ("RANGE" == tPrefix) then
			return -aMessage4;
		elseif ("ENVIRONMENTAL" == tPrefix) then
			return -aMessage2
		end
	elseif ("DAMAGE" == tPrefix and "MISSED" ~= tSpecial and "RESISTED" ~= tSpecial) then
		return -aMessage4;
	end

	return 0;
end



--
local tUnit;
local tImpact;
function VUHDO_parseCombatLogEvent(aMessage, aDstGUID, aMessage1, aMessage2, aMessage4)
	tUnit = VUHDO_RAID_GUIDS[aDstGUID];
	if (tUnit == nil) then
		return;
	end

	tImpact = VUHDO_getTargetHealthImpact(aMessage, aMessage1, aMessage2, aMessage4);

	if (tImpact ~= 0) then
		VUHDO_addUnitHealth(tUnit, tImpact);
	end
end
