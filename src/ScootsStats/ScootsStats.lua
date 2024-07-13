local textSize = 10
local sectionSpacing = 5
local foregroundStrata = "MEDIUM"
local backgroundStrata = "LOW"

local stats = {
	{
		["key"] = "misc",
		["name"] = "Miscellaneous",
		["data"] = {
			{"miscAtt", "ScootsStats_setAttune", nil, "ScootsStats_Attune_OnEnter"},
			{"miscIlv", "ScootsStats_SetItemLevel", nil, "ScootsStats_ItemLevel_OnEnter"},
			{"miscAil", "ScootsStats_SetAverageItemLevel", nil, "ScootsStats_ItemLevel_OnEnter"},
			{"MiscSpd", "ScootsStats_SetMovementSpeed"}
		},
		["classes"] = nil
	},
	{
		["key"] = "base",
		["name"] = "Base Stats",
		["data"] = {
			{"str", "PaperDollFrame_SetStat", 1},
			{"agi", "PaperDollFrame_SetStat", 2},
			{"sta", "PaperDollFrame_SetStat", 3},
			{"int", "PaperDollFrame_SetStat", 4},
			{"spi", "PaperDollFrame_SetStat", 5}
		},
		["classes"] = nil
	},
	{
		["key"] = "melee",
		["name"] = "Melee",
		["data"] = {
			{"meleeDam", "PaperDollFrame_SetDamage", nil, "CharacterDamageFrame_OnEnter"},
			{"meleeSpd", "PaperDollFrame_SetAttackSpeed"},
			{"meleePow", "PaperDollFrame_SetAttackPower"},
			{"meleeHit", "PaperDollFrame_SetRating", CR_HIT_MELEE},
			{"meleeCrt", "PaperDollFrame_SetMeleeCritChance"},
			{"meleeExp", "PaperDollFrame_SetExpertise"}
		},
		["classes"] = nil
	},
	{
		["key"] = "range",
		["name"] = "Ranged",
		["data"] = {
			{"rangeDam", "PaperDollFrame_SetRangedDamage", nil, "CharacterRangedDamageFrame_OnEnter"},
			{"rangeSpd", "PaperDollFrame_SetRangedAttackSpeed"},
			{"rangePow", "PaperDollFrame_SetRangedAttackPower"},
			{"rangeHit", "PaperDollFrame_SetRating", CR_HIT_RANGED},
			{"rangeCrt", "PaperDollFrame_SetRangedCritChance"}
		},
		["classes"] = {
			["DEATHKNIGHT"] = false,
			["DRUID"] = false,
			["HUNTER"] = true,
			["MAGE"] = false,
			["PALADIN"] = false,
			["PRIEST"] = false,
			["ROGUE"] = true,
			["SHAMAN"] = false,
			["WARLOCK"] = false,
			["WARRIOR"] = true
		},
	},
	{
		["key"] = "spell",
		["name"] = "Spells",
		["data"] = {
			{"spellDam", "PaperDollFrame_SetSpellBonusDamage", nil, "CharacterSpellBonusDamage_OnEnter"},
			{"spellHea", "PaperDollFrame_SetSpellBonusHealing"},
			{"spellHit", "PaperDollFrame_SetRating", CR_HIT_SPELL},
			{"spellCrt", "PaperDollFrame_SetSpellCritChance", nil, "CharacterSpellCritChance_OnEnter"},
			{"spellSpd", "PaperDollFrame_SetSpellHaste"},
			{"spellRgn", "PaperDollFrame_SetManaRegen"}
		},
		["classes"] = {
			["DEATHKNIGHT"] = true,
			["DRUID"] = true,
			["HUNTER"] = true,
			["MAGE"] = true,
			["PALADIN"] = true,
			["PRIEST"] = true,
			["ROGUE"] = true,
			["SHAMAN"] = true,
			["WARLOCK"] = true,
			["WARRIOR"] = false
		}
	},
	{
		["key"] = "def",
		["name"] = "Defences",
		["data"] = {
			{"defArm", "PaperDollFrame_SetArmor"},
			{"defDef", "PaperDollFrame_SetDefense"},
			{"defDod", "PaperDollFrame_SetDodge"},
			{"defPar", "PaperDollFrame_SetParry"},
			{"defBlk", "PaperDollFrame_SetBlock"},
			{"defRes", "PaperDollFrame_SetResilience"}
		},
		["classes"] = nil
	}
}

local loaded = false
local visible = true
local sFrame = CreateFrame("Frame", nil, PaperDollFrame)
local bgFrame = CreateFrame("Frame", nil, sFrame)
local borderFrames = {}
local toggleButton = CreateFrame("Button", nil, PaperDollFrame, "UIPanelButtonTemplate")
local playerClass = nil
local sectionFrames = {}
local textFrames = {}
local attuneFrames = {}

local items = {}
local itemCount = 0
local sumItemLevel = 0
local itemLevelTooltip = ""

local attuneData = {}
local attuneCount = 0

local slots = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"RangedSlot"
}

local friendlySlotNames = {
	INVTYPE_HEAD,
	INVTYPE_NECK,
	INVTYPE_SHOULDER,
	INVTYPE_CLOAK,
	INVTYPE_CHEST,
	INVTYPE_WRIST,
	INVTYPE_HAND,
	INVTYPE_WAIST,
	INVTYPE_LEGS,
	INVTYPE_FEET,
	INVTYPE_FINGER.." 1",
	INVTYPE_FINGER.." 2",
	INVTYPE_TRINKET.." 1",
	INVTYPE_TRINKET.." 2",
	INVTYPE_WEAPONMAINHAND,
	INVTYPE_WEAPONOFFHAND,
	INVTYPE_RANGED
}

function ScootsStats_OnLoad()
	local localizedClass, englishClass = UnitClass("player")
	playerClass = strupper(englishClass)
	
	ScootsStats_CreateFrames()
	ScootsStats_UpdateStats()
	_G["CharacterAttributesFrame"]:Hide()
	_G["CharacterModelFrame"]:SetHeight(310)
	loaded = true
end

function ScootsStats_CreateFrames()
	-- Toggle button
	toggleButton:SetSize(56, 20)
	toggleButton:SetText("Stats <<")
	toggleButton:SetPoint("BOTTOMLEFT", PaperDollFrame, "BOTTOMLEFT", 288, 80)
	toggleButton:SetFrameStrata(foregroundStrata)
	toggleButton:SetScript("OnClick", function()
		if(visible) then
			sFrame:Hide()
			visible = false
			toggleButton:SetText("Stats >>")
		else
			sFrame:Show()
			ScootsStats_UpdateStats()
			visible = true
			toggleButton:SetText("Stats <<")
		end
	end)

	-- Top-level frame
	sFrame:SetFrameStrata(foregroundStrata)
	sFrame:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -30, -18)
	
	bgFrame:SetPoint("TOPLEFT", sFrame, "TOPLEFT", 0, 5)
	bgFrame.texture = bgFrame:CreateTexture()
	bgFrame.texture:SetAllPoints()
	bgFrame.texture:SetTexture(0, 0, 0, 0.5)

	borderFrames.T = CreateFrame("Frame", nil, sFrame)
	borderFrames.R = CreateFrame("Frame", nil, sFrame)
	borderFrames.B = CreateFrame("Frame", nil, sFrame)
	borderFrames.L = CreateFrame("Frame", nil, sFrame)
	for key, borderFrame in pairs(borderFrames) do
		borderFrame.texture = borderFrame:CreateTexture()
		borderFrame.texture:SetAllPoints()
		borderFrame.texture:SetTexture(1, 1, 1, 0.5)
		borderFrame:SetWidth(1)
		borderFrame:SetHeight(1)
	end
	
	borderFrames.T:SetPoint("BOTTOM", sFrame, "TOP", 0, 5)
	borderFrames.B:SetPoint("TOP", sFrame, "BOTTOM", 0, -5)
	
	borderFrames.R:SetPoint("LEFT", sFrame, "RIGHT", 0, 0)
	borderFrames.L:SetPoint("RIGHT", sFrame, "LEFT", 0, 0)
	
	bgFrame:SetFrameStrata(backgroundStrata)
	borderFrames.T:SetFrameStrata(backgroundStrata)
	borderFrames.R:SetFrameStrata(backgroundStrata)
	borderFrames.B:SetFrameStrata(backgroundStrata)
	borderFrames.L:SetFrameStrata(backgroundStrata)
	
	-- Iterate over sections
	local sectionCount = table.getn(stats)
	local prevSection = nil
	for sectionIndex = 1, sectionCount do
		local section = stats[sectionIndex]
		if(section.classes == nil or section.classes[playerClass] == true) then
			
			-- Create section frame
			sectionFrames[section.key] = CreateFrame("Frame", nil)
			sectionFrames[section.key]:SetFrameStrata(foregroundStrata)
			
			if(prevSection == nil) then
				sectionFrames[section.key]:SetParent(sFrame)
				sectionFrames[section.key]:SetPoint("TOP", sFrame, "TOP")
			else
				sectionFrames[section.key]:SetParent(sectionFrames[prevSection])
				sectionFrames[section.key]:SetPoint("TOP", sectionFrames[prevSection], "BOTTOM", 0, 0 - sectionSpacing)
			end
			
			-- Create header frame
			textFrames["HEAD_"..section.key] = CreateFrame("Frame", nil, sectionFrames[section.key])
			textFrames["HEAD_"..section.key]:SetFrameStrata(foregroundStrata)
			textFrames["HEAD_"..section.key].text = textFrames["HEAD_"..section.key]:CreateFontString(nil, "ARTWORK")
			textFrames["HEAD_"..section.key].text:SetFont("Fonts\\FRIZQT__.TTF", textSize)
			textFrames["HEAD_"..section.key].text:SetPoint("CENTER", 0, 0)
			textFrames["HEAD_"..section.key].text:SetText(section.name)
			
			local stringHeight = textFrames["HEAD_"..section.key].text:GetStringHeight()
			textFrames["HEAD_"..section.key]:SetHeight(stringHeight)
			textFrames["HEAD_"..section.key]:SetPoint("TOP", sectionFrames[section.key], "TOP", 0, 0)
			
			-- Create data frames
			local dataCount = table.getn(section.data)
			local prevData = "HEAD_"..section.key
			for dataIndex = 1, dataCount do
				textFrames["DATA_"..section.data[dataIndex][1]] = CreateFrame("Frame", "ScootsStatsDataFrame_"..section.data[dataIndex][1], textFrames[prevData], "StatFrameTemplate")
				textFrames["DATA_"..section.data[dataIndex][1]]:SetPoint("TOP", textFrames[prevData], "BOTTOM")
				
				if(section.data[dataIndex][4] ~= nil) then
					textFrames["DATA_"..section.data[dataIndex][1]]:SetScript("OnEnter", _G[section.data[dataIndex][4]])
				end
				
				prevData = "DATA_"..section.data[dataIndex][1]
			end
			
			prevSection = section.key
		end
	end
	
	local stringWidth = 0
end

function ScootsStats_GetItemLevels()
	sumItemLevel = 0
	itemCount = 0
	local slotCount = table.getn(slots)
	
	for i = 1, slotCount do
		local slotId = GetInventorySlotInfo(slots[i])
		local itemId = GetInventoryItemID("player", slotId)
		
		if(itemId == nil) then
			items[slots[i]] = nil
		else
			local _, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(itemId)

			local item = {}
			item.type = itemEquipLoc
			item.level = itemLevel
			
			items[slots[i]] = item
		end
	end
	
	for i = 1, slotCount do
		if(slots[i] ~= "SecondaryHandSlot" or (items["MainHandSlot"] ~= nil and items["MainHandSlot"].type ~= "INVTYPE_2HWEAPON")) then
			itemCount = itemCount + 1
			if(items[slots[i]] ~= nil) then
				sumItemLevel = sumItemLevel + items[slots[i]].level
			end
		end
	end
end

function ScootsStats_setAttune(statFrame)
	attuneData = {}
	attuneCount = 0
	
	local attuneSum = 0
	
	local slotCount = table.getn(slots)
	for i = 1, slotCount do
		local slotId = GetInventorySlotInfo(slots[i])
		local itemLink = GetInventoryItemLink("player", slotId)
		local itemId = GetInventoryItemID("player", slotId)
		if(itemLink == nil or CanAttuneItemHelper(itemId) < 1) then
			attuneData[slots[i]] = nil
		else
			local attuneProgress = tonumber(GetItemLinkAttuneProgress(itemLink))
			attuneData[slots[i]] = attuneProgress
			
			if(attuneProgress < 100) then
				attuneCount = attuneCount + 1
				attuneSum = attuneSum + attuneData[slots[i]]
			end
		end
	end
	
	if(attuneCount == 0) then
		PaperDollFrame_SetLabelAndText(statFrame, "Attuning", "0 items")
	
		for i = 1, table.getn(slots) do
			if(attuneFrames[slots[i]] ~= nil) then
				attuneFrames[slots[i]]:Hide()
			end
		end
	else
		PaperDollFrame_SetLabelAndText(statFrame, "Attuning", string.format("%d", attuneCount) .. " items (" .. string.format("%d", attuneSum / attuneCount) .. "%)")
	end
	
	for i = 1, table.getn(slots) do
		if(attuneData[slots[i]] == nil) then
			if(attuneFrames[slots[i]] ~= nil) then
				attuneFrames[slots[i]]:Hide()
			end
		else
			if(attuneFrames[slots[i]] == nil) then
				attuneFrames[slots[i]] = CreateFrame('Frame', 'Character' .. slots[i] .. '_AttuneProgress', _G['Character' .. slots[i]])
				
				attuneFrames[slots[i]]:SetPoint('TOPLEFT', _G['Character' .. slots[i]], 'TOPLEFT', 0, 0)
				attuneFrames[slots[i]]:SetFrameStrata('MEDIUM')
				attuneFrames[slots[i]]:SetWidth(_G['Character' .. slots[i]]:GetWidth())
				attuneFrames[slots[i]]:SetHeight(14)
				
				attuneFrames[slots[i]].text = attuneFrames[slots[i]]:CreateFontString(nil, 'ARTWORK')
				attuneFrames[slots[i]].text:SetFont('Fonts\\FRIZQT__.TTF', 10, 'THINOUTLINE')
				attuneFrames[slots[i]].text:SetPoint('TOPLEFT', 0, -2)
				attuneFrames[slots[i]].text:SetJustifyH('LEFT')
				attuneFrames[slots[i]].text:SetShadowOffset(0, 0)
				attuneFrames[slots[i]].text:SetShadowColor(0, 0, 0, 1)
			end
			
			local r, g, b = ScootsStats_deriveRGB(attuneData[slots[i]])
			
			attuneFrames[slots[i]].text:SetTextColor(r, g, b)
			attuneFrames[slots[i]].text:SetText(string.format('%d', attuneData[slots[i]]) .. '%')
			attuneFrames[slots[i]]:Show()
		end
	end
end

function ScootsStats_deriveRGB(progress)
	local colours = {
		['0']   = {['r'] = 1.0, ['g'] = 0.1, ['b'] = 0.1},
		['50']  = {['r'] = 1.0, ['g'] = 1.0, ['b'] = 0.0},
		['100'] = {['r'] = 0.1, ['g'] = 1.0, ['b'] = 0.1}
	}
	
	if(progress == 0) then
		return colours['0']['r'], colours['0']['g'], colours['0']['b']
	elseif(progress == 50) then
		return colours['50']['r'], colours['50']['g'], colours['50']['b']
	elseif(progress == 100) then
		return colours['100']['r'], colours['100']['g'], colours['100']['b']
	end
	
	local lowerRGB = {}
	local upperRGB = {}
	
	if(progress < 50) then
		progress = progress * 2
		lowerRGB = colours['0']
		upperRGB = colours['50']
	else
		progress = (progress - 50) * 2
		lowerRGB = colours['50']
		upperRGB = colours['100']
	end
	
	local out = {}
	progress = progress / 100
	
	for _, key in ipairs({'r', 'g', 'b'}) do
		local lowerBound = math.min(lowerRGB[key], upperRGB[key])
		local upperBound = math.max(lowerRGB[key], upperRGB[key])
		
		out[key] = lowerBound + ((upperBound - lowerBound) * progress)
	end
	
	return out.r, out.g, out.b
end

function ScootsStats_SetItemLevel(statFrame)
	PaperDollFrame_SetLabelAndText(statFrame, "Item Level", sumItemLevel)
end

function ScootsStats_SetAverageItemLevel(statFrame)
	local avgItemLevel = 0
	if(sumItemLevel > 0 and itemCount > 0) then
		avgItemLevel = math.floor((sumItemLevel / itemCount) * 100) / 100
	end
	
	PaperDollFrame_SetLabelAndText(statFrame, "Avg. Item Level", avgItemLevel)
end

function ScootsStats_ItemLevel_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	GameTooltip:SetText("Item Level", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	
	local slotCount = table.getn(slots)
	for i = 1, table.getn(slots) do
		if(slots[i] ~= "SecondaryHandSlot" or (items["MainHandSlot"] ~= nil and items["MainHandSlot"].type ~= "INVTYPE_2HWEAPON")) then
			local value = 0
			if(items[slots[i]] == nil or items[slots[i]] == 100) then
				value = "-"
			else
				value = items[slots[i]].level
			end
			
			GameTooltip:AddDoubleLine(friendlySlotNames[i], value, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	end
	
	GameTooltip:Show()
end

function ScootsStats_Attune_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	GameTooltip:SetText("Item Attunements", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	
	local slotCount = table.getn(slots)
	for i = 1, table.getn(slots) do
		local value = "-"
		
		if(attuneData[slots[i]] ~= nil and attuneData[slots[i]] < 100) then
			value = string.format("%d", attuneData[slots[i]]) .. "%"
		end
	
		GameTooltip:AddDoubleLine(friendlySlotNames[i], value, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	GameTooltip:Show()
end

function ScootsStats_SetMovementSpeed(statFrame)
	PaperDollFrame_SetLabelAndText(statFrame, "Movement Speed", string.format("%d", (GetUnitSpeed("Player") / 7) * 100).."%")
end

function ScootsStats_UpdateStats()
	ScootsStats_GetItemLevels()

	-- Size frames to content
	local cumulativeHeight = 0
	local sectionHeights = {}
	local minWidth = 0
	
	local sectionCount = table.getn(stats)
	for sectionIndex = 1, sectionCount do
		local section = stats[sectionIndex]
		if(section.classes == nil or section.classes[playerClass] == true) then
			sectionHeights[section.key] = textFrames["HEAD_"..section.key]:GetHeight()
			
			local stringWidth = textFrames["HEAD_"..section.key].text:GetStringWidth()
			if(stringWidth > minWidth) then
				minWidth = stringWidth
			end
			
			local dataCount = table.getn(section.data)
			for dataIndex = 1, dataCount do
				_G[section.data[dataIndex][2]](textFrames["DATA_"..section.data[dataIndex][1]], section.data[dataIndex][3])
				
				local dataHeight = _G[textFrames["DATA_"..section.data[dataIndex][1]]:GetName().."Label"]:GetHeight()
				textFrames["DATA_"..section.data[dataIndex][1]]:SetHeight(dataHeight)
				sectionHeights[section.key] = sectionHeights[section.key] + dataHeight
				
				local labelWidth = _G[textFrames["DATA_"..section.data[dataIndex][1]]:GetName().."Label"]:GetWidth()
				local DataWidth = _G[textFrames["DATA_"..section.data[dataIndex][1]]:GetName().."StatText"]:GetWidth()
				if((labelWidth + DataWidth + 20) > minWidth) then
					minWidth = labelWidth + DataWidth + 20
				end
			end
			
			sectionFrames[section.key]:SetHeight(sectionHeights[section.key])
			cumulativeHeight = cumulativeHeight + sectionHeights[section.key] + sectionSpacing
		end
	end
	cumulativeHeight = cumulativeHeight - sectionSpacing
	
	minWidth = minWidth
	
	sFrame:SetWidth(minWidth + 10)
	sFrame:SetHeight(cumulativeHeight)
	
	bgFrame:SetWidth(minWidth + 10)
	borderFrames.T:SetWidth(minWidth + 12)
	borderFrames.B:SetWidth(minWidth + 12)
	
	bgFrame:SetHeight(cumulativeHeight + 10)
	borderFrames.R:SetHeight(cumulativeHeight + 10)
	borderFrames.L:SetHeight(cumulativeHeight + 10)
	
	for key, sectionFrame in pairs(sectionFrames) do
		sectionFrame:SetWidth(minWidth + 10)
	end
	
	for key, textFrame in pairs(textFrames) do
		textFrame:SetWidth(minWidth)
	end
end

function ScootsStats_sFrame_EventHandler()
	if(CanAttuneItemHelper ~= nil and GetItemLinkAttuneProgress ~= nil) then
		if(not loaded) then
			ScootsStats_OnLoad()
		else
			ScootsStats_UpdateStats()
		end
	end
end

sFrame:SetScript("OnEvent", ScootsStats_sFrame_EventHandler)

sFrame:SetScript("OnUpdate", function()
	if(not loaded and CanAttuneItemHelper ~= nil and GetItemLinkAttuneProgress ~= nil) then
		ScootsStats_sFrame_EventHandler()
	end
	
	if(loaded) then
		ScootsStats_SetMovementSpeed(textFrames["DATA_MiscSpd"])
	end
end)

sFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
sFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
sFrame:RegisterEvent("UNIT_AURA")
sFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
sFrame:RegisterEvent("PARTY_KILL")
sFrame:RegisterEvent("QUEST_TURNED_IN")
sFrame:RegisterEvent("PLAYER_AURAS_CHANGED")