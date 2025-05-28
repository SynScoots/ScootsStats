ScootsStats = {}
ScootsStats.initialised = false
ScootsStats.characterFrameOpen = false
ScootsStats.optionsOpen = false
ScootsStats.frames = {}
ScootsStats.frames.event = CreateFrame('Frame', 'ScootsStatsEventFrame', UIParent)
ScootsStats.frames.master = CreateFrame('Frame', 'ScootsStatsMasterFrame', _G['CharacterFrame'])
ScootsStats.queuedUpdate = false
ScootsStats.queuedAttunedUpdate = false
ScootsStats.hookedTabs = false

ScootsStats.frames.event:SetScript('OnUpdate', function()
    if(ScootsStats.addonLoaded) then
        if(CalculateAttunableAffixCount and ScootsStats.totalAccountAffixes == nil) then
            ScootsStats.totalAccountAffixes = CalculateAttunableAffixCount()
        end
    
        if(ScootsStats.characterFrameOpen == false) then
            if(_G['CharacterFrame']
            and _G['CharacterFrame']:IsVisible() == 1
            and MAX_ITEMID
            and CanAttuneItemHelper
            and HasAttunedAnyVariantOfItem
            and GetCustomGameDataCount
            and GetCustomGameData
            and GetItemInfoCustom
            and HasAttunedAnyVariantEx) then
                ScootsStats.characterFrameOpen = true
                ScootsStats.queuedUpdate = true
                
                if(not ScootsStats.initialised) then
                    ScootsStats.init()
                    ScootsStats.queuedAttunedUpdate = true
                    ScootsStats.queuedLightforgeUpdate = true
                end
            end
        else
            if(_G['CharacterFrame'] and _G['CharacterFrame']:IsVisible() ~= 1) then
                ScootsStats.characterFrameOpen = false
                
                if(ScootsStats.optionsOpen) then
                    ScootsStats.toggleOptionsPanel()
                end
            else
                if(ScootsStats.queuedUpdate == true or ScootsStats.queuedAttunedUpdate == true) then
                    ScootsStats.updateStats()
                    ScootsStats.setFrameLevels()
                    
                    ScootsStats.queuedUpdate = false
                end
            end
        end
        
        if(ScootsStats.characterFrameOpen) then
            ScootsStats.applyFixesToOtherFrames()
        end
    end
end)

ScootsStats.init = function()
    ScootsStats.initialised = true
    ScootsStats.loadOptions()
    ScootsStats.baseWidth = _G['CharacterFrame']:GetWidth()
    ScootsStats.strata = _G['CharacterFrame']:GetFrameStrata()
    ScootsStats.slotIds = {1, 2, 3, 15, 5, 9, 10, 6, 7, 8, 11, 12, 13, 14, 16, 17, 18}
    ScootsStats.sectionFrames = {}
    ScootsStats.rowFrames = {}
    ScootsStats.optionFrames = {}
    ScootsStats.optionToggleFrames = {}
    
	_G['CharacterAttributesFrame']:Hide()
	_G['CharacterModelFrame']:SetHeight(305)
    
    ScootsStats.frames.otherTabHolder = CreateFrame('Frame', 'ScootsStatsSecondaryFrameHolder', _G['CharacterFrame'])
    ScootsStats.frames.otherTabHolder:SetWidth(ScootsStats.baseWidth)
    ScootsStats.frames.otherTabHolder:SetHeight(_G['CharacterFrame']:GetHeight())
    ScootsStats.frames.otherTabHolder:SetPoint('TOPLEFT', _G['CharacterFrame'], 'TOPLEFT', 0, 0)
    
    ScootsStats.frames.master:SetPoint('TOPLEFT', ScootsStats.frames.otherTabHolder, 'TOPRIGHT', -35, 0)
    ScootsStats.frames.master:SetHeight(439)
    
    ScootsStats.frames.scrollFrame = CreateFrame('ScrollFrame', 'ScootsStatsScrollFrame', ScootsStats.frames.master, 'UIPanelScrollFrameTemplate')
    ScootsStats.frames.scrollFrame:SetFrameStrata(ScootsStats.strata)
    
    ScootsStats.frames.scrollChild = CreateFrame('Frame', 'ScootsStatsScrollChild', ScootsStats.frames.scrollFrame)
    ScootsStats.frames.scrollChild:SetFrameStrata(ScootsStats.strata)
    
    local scrollBarName = ScootsStats.frames.scrollFrame:GetName()
    ScootsStats.frames.scrollBar = _G[scrollBarName .. 'ScrollBar']
    ScootsStats.frames.scrollUpButton = _G[scrollBarName .. 'ScrollBarScrollUpButton']
    ScootsStats.frames.scrollDownButton = _G[scrollBarName .. 'ScrollBarScrollDownButton']

    ScootsStats.frames.scrollUpButton:ClearAllPoints()
    ScootsStats.frames.scrollUpButton:SetPoint('TOPRIGHT', ScootsStats.frames.scrollFrame, 'TOPRIGHT', -2, -2)

    ScootsStats.frames.scrollDownButton:ClearAllPoints()
    ScootsStats.frames.scrollDownButton:SetPoint('BOTTOMRIGHT', ScootsStats.frames.scrollFrame, 'BOTTOMRIGHT', -2, 2)

    ScootsStats.frames.scrollBar:ClearAllPoints()
    ScootsStats.frames.scrollBar:SetPoint('TOP', ScootsStats.frames.scrollUpButton, 'BOTTOM', 0, -2)
    ScootsStats.frames.scrollBar:SetPoint('BOTTOM', ScootsStats.frames.scrollDownButton, 'TOP', 0, 2)

    ScootsStats.frames.scrollFrame:SetScrollChild(ScootsStats.frames.scrollChild)
    ScootsStats.frames.scrollFrame:SetPoint('TOPLEFT', ScootsStats.frames.master, 'TOPLEFT', 0, -34)
    ScootsStats.frames.scrollFrame:SetHeight(403)
    
    ScootsStats.frames.optionsButton = CreateFrame('Button', 'ScootsStatsOptionsButton', ScootsStats.frames.master, 'UIPanelButtonTemplate')
	ScootsStats.frames.optionsButton:SetSize(56, 19)
	ScootsStats.frames.optionsButton:SetText('Options')
	ScootsStats.frames.optionsButton:SetPoint('TOPRIGHT', ScootsStats.frames.master, 'TOPRIGHT', -6, -15)
	ScootsStats.frames.optionsButton:SetFrameStrata(ScootsStats.strata)
	ScootsStats.frames.optionsButton:SetScript('OnClick', ScootsStats.toggleOptionsPanel)
    
    ScootsStats.frames.title = CreateFrame('Frame', 'ScootsStatsTitle', ScootsStats.frames.master)
    ScootsStats.frames.title:SetHeight(12)
    ScootsStats.frames.title:SetPoint('TOPLEFT', ScootsStats.frames.master, 'TOPLEFT', 5, -19)
	ScootsStats.frames.title:SetFrameStrata(ScootsStats.strata)
    ScootsStats.frames.title.text = ScootsStats.frames.title:CreateFontString(nil, 'ARTWORK')
    ScootsStats.frames.title.text:SetFont('Fonts\\FRIZQT__.TTF', 12)
    ScootsStats.frames.title.text:SetPoint('TOPLEFT', 0, 0)
    ScootsStats.frames.title.text:SetJustifyH('LEFT')
    ScootsStats.frames.title.text:SetTextColor(1, 1, 1)
    ScootsStats.frames.title.text:SetText('ScootsStats')
    ScootsStats.frames.title:SetWidth(ScootsStats.frames.title.text:GetStringWidth())
    
    ScootsStats.frames.background = CreateFrame('Frame', 'ScootsStatsBackground', ScootsStats.frames.master)
    ScootsStats.frames.background:SetPoint('TOPLEFT', ScootsStats.frames.master, 'TOPLEFT', -20, 0)
    ScootsStats.frames.background:SetHeight(ScootsStats.frames.master:GetHeight())
	ScootsStats.frames.background:SetFrameStrata(ScootsStats.strata)
    ScootsStats.frames.background.texture = ScootsStats.frames.background:CreateTexture()
    ScootsStats.frames.background.texture:SetTexture([[Interface\AddOns\ScootsStats\Textures\Frame-Flyout.blp]])
    ScootsStats.frames.background.texture:SetPoint('TOPRIGHT', 0, -1)
    ScootsStats.frames.background.texture:SetSize(512, 512)
    
    _G['CharacterNameFrame']:SetPoint('TOPRIGHT', ScootsStats.frames.master, 'TOPLEFT', 33, -19)
    _G['CharacterNameFrame']:SetWidth(ScootsStats.baseWidth)
    
    _G['CharacterFrameCloseButton']:SetPoint('TOPRIGHT', ScootsStats.frames.otherTabHolder, 'TOPRIGHT', -28, -9)
    
    _G['GearManagerToggleButton']:ClearAllPoints()
    _G['GearManagerToggleButton']:SetPoint('TOPLEFT', _G['CharacterFrame'], 'TOPLEFT', 315, -40)
    
    ScootsStats.sectionFrames = {}
    ScootsStats.rowFrames = {}
    
    ScootsStats.old_cu_uib = _cu_uib
    _cu_uib = function(type)
        ScootsStats.queuedUpdate = true
        return ScootsStats.old_cu_uib(type)
    end
    
    ScootsStats.totalCharacterAttunes = 0
    ScootsStats.totalAccountAttunes = 0
    for itemId = 1, MAX_ITEMID do
        local itemTags = GetItemTagsCustom(itemId)
        if(itemTags and bit.band(itemTags, 96) == 64) then
            ScootsStats.totalAccountAttunes = ScootsStats.totalAccountAttunes + 1
            
            if(CanAttuneItemHelper(itemId) > 0) then
                ScootsStats.totalCharacterAttunes = ScootsStats.totalCharacterAttunes + 1
            end
        end
    end
    
    if(ScootsStats.totalAccountAffixes == nil) then
        ScootsStats.totalAccountAffixes = CalculateAttunableAffixCount()
    end
end

ScootsStats.applyFixesToOtherFrames = function()
    local frames = {
        'PaperDollFrame',
        'PetPaperDollFrame',
        'ReputationFrame',
        'SkillFrame',
        'TokenFrame'
    }
    
    for _, frameName in pairs(frames) do
        if(_G[frameName] and _G[frameName]:IsVisible() and ScootsStats['moved' .. frameName] == nil) then
            _G[frameName]:SetParent(ScootsStats.frames.otherTabHolder)
            _G[frameName]:SetAllPoints()
            _G[frameName]:SetFrameLevel(_G['CharacterFrame']:GetFrameLevel() + 5)
            ScootsStats['moved' .. frameName] = true
        end
    end
    
    frames = {
        'ReputationDetailFrame'
    }
    
    for _, frameName in pairs(frames) do
        if(_G[frameName] and _G[frameName]:IsVisible() and ScootsStats['moved' .. frameName] == nil) then
            _G[frameName]:SetFrameLevel(_G['PaperDollFrame']:GetFrameLevel() + 5)
            ScootsStats['moved' .. frameName] = true
        end
    end
    
    local children = {_G['TokenFrame']:GetChildren()}
    for _, frame in pairs(children) do
       if(type(frame) == 'table' and frame.GetName and not frame:GetName()) then
          frame:Hide()
       end
    end
end

ScootsStats.setFrameLevels = function()
    local baseLevel = _G['PaperDollFrame']:GetFrameLevel()
    
    ScootsStats.frames.master:SetFrameLevel(baseLevel + 1)
    ScootsStats.frames.scrollFrame:SetFrameLevel(baseLevel + 2)
    ScootsStats.frames.scrollChild:SetFrameLevel(baseLevel + 3)
    ScootsStats.frames.scrollBar:SetFrameLevel(baseLevel + 3)
    ScootsStats.frames.scrollUpButton:SetFrameLevel(baseLevel + 3)
    ScootsStats.frames.scrollDownButton:SetFrameLevel(baseLevel + 3)
    ScootsStats.frames.optionsButton:SetFrameLevel(baseLevel + 1)
    ScootsStats.frames.title:SetFrameLevel(baseLevel + 1)
    ScootsStats.frames.background:SetFrameLevel(baseLevel - 1)
    
    for _, frame in pairs(ScootsStats.sectionFrames) do
        frame:SetFrameLevel(baseLevel + 4)
    end
    
    if(ScootsStats.frames.options) then
        ScootsStats.frames.options:SetFrameLevel(baseLevel + 1)
    end
    
    if(ScootsStats.frames.optionToggleFrames) then
        ScootsStats.frames.options:SetFrameLevel(baseLevel + 2)
        ScootsStats.frames.options.checkBorder:SetFrameLevel(baseLevel + 3)
        ScootsStats.frames.options.check:SetFrameLevel(baseLevel + 4)
    end
    
    for _, frame in pairs(ScootsStats.optionFrames) do
        frame:SetFrameLevel(baseLevel + 2)
    end
end

ScootsStats.countAttunes = function()
    if(ScootsStats.queuedLightforgeUpdate) then
        ScootsStats.highLevelLightForges = 0
        ScootsStats.bonusExpEffect = 0
        
        for itemId = 1, MAX_ITEMID do
            if(HasAttunedAnyVariantEx(itemId, 3)) then
                local _, _, _, itemLevel = GetItemInfoCustom(itemId)
                
                if(itemLevel > 200) then
                    ScootsStats.bonusExpEffect = ScootsStats.bonusExpEffect + (itemLevel - 200) / 84
                    ScootsStats.highLevelLightForges = ScootsStats.highLevelLightForges + 1
                end
            end
        end
    end
    
    ScootsStats.characterAttunes = CalculateAttunedCount(1)
    ScootsStats.accountAttunes, ScootsStats.accountAttunesTF, ScootsStats.accountAttunesWF, ScootsStats.accountAttunesLF = CalculateAttunedCount()
    ScootsStats.attunedAffixes = CalculateAttunedAffixCount()
    
    ScootsStats.queuedAttunedUpdate = false
    ScootsStats.queuedLightforgeUpdate = false
end

ScootsStats.updateStats = function()
    for _, frame in pairs(ScootsStats.sectionFrames) do
        frame:Hide()
    end
    
    local layout = {
        {
            ['title'] = 'Miscellaneous',
            ['rows'] = {
                {
                    ['display'] = ScootsStats.setStatAttune,
                    ['onEnter'] = ScootsStats.enterAttune,
                    ['option'] = {'misc', 'attuning'}
                },
                {
                    ['display'] = ScootsStats.setStatMovementSpeed,
                    ['onEnter'] = ScootsStats.enterMovementSpeed,
                    ['onUpdate'] = ScootsStats.setStatMovementSpeed,
                    ['option'] = {'misc', 'movespeed'}
                }
            }
        },
        {
            ['title'] = 'Base Stats',
            ['rows'] = {
                {
                    ['display'] = PaperDollFrame_SetStat,
                    ['argument'] = 1,
                    ['option'] = {'base', 'strength'}
                },
                {
                    ['display'] = PaperDollFrame_SetStat,
                    ['argument'] = 2,
                    ['option'] = {'base', 'agility'}
                },
                {
                    ['display'] = PaperDollFrame_SetStat,
                    ['argument'] = 3,
                    ['option'] = {'base', 'stamina'}
                },
                {
                    ['display'] = PaperDollFrame_SetStat,
                    ['argument'] = 4,
                    ['option'] = {'base', 'intellect'}
                },
                {
                    ['display'] = PaperDollFrame_SetStat,
                    ['argument'] = 5,
                    ['option'] = {'base', 'spirit'}
                }
            }
        },
        {
            ['title'] = 'Melee',
            ['rows'] = {
                {
                    ['display'] = PaperDollFrame_SetDamage,
                    ['onEnter'] = CharacterDamageFrame_OnEnter,
                    ['option'] = {'melee', 'damage'}
                },
                {
                    ['display'] = PaperDollFrame_SetAttackSpeed,
                    ['option'] = {'melee', 'speed'}
                },
                {
                    ['display'] = PaperDollFrame_SetAttackPower,
                    ['option'] = {'melee', 'power'}
                },
                {
                    ['display'] = PaperDollFrame_SetRating,
                    ['argument'] = CR_HIT_MELEE,
                    ['option'] = {'melee', 'hit'}
                },
                {
                    ['display'] = PaperDollFrame_SetMeleeCritChance,
                    ['option'] = {'melee', 'crit'}
                },
                {
                    ['display'] = PaperDollFrame_SetExpertise,
                    ['option'] = {'melee', 'expertise'}
                }
            }
        },
        {
            ['title'] = 'Ranged',
            ['rows'] = {
                {
                    ['display'] = PaperDollFrame_SetRangedDamage,
                    ['onEnter'] = CharacterRangedDamageFrame_OnEnter,
                    ['option'] = {'ranged', 'damage'}
                },
                {
                    ['display'] = PaperDollFrame_SetRangedAttackSpeed,
                    ['option'] = {'ranged', 'speed'}
                },
                {
                    ['display'] = PaperDollFrame_SetRangedAttackPower,
                    ['option'] = {'ranged', 'power'}
                },
                {
                    ['display'] = PaperDollFrame_SetRating,
                    ['argument'] = CR_HIT_RANGED,
                    ['option'] = {'ranged', 'hit'}
                },
                {
                    ['display'] = PaperDollFrame_SetRangedCritChance,
                    ['option'] = {'ranged', 'crit'}
                }
            }
        },
        {
            ['title'] = 'Spells',
            ['rows'] = {
                {
                    ['display'] = PaperDollFrame_SetSpellBonusDamage,
                    ['onEnter'] = CharacterSpellBonusDamage_OnEnter,
                    ['option'] = {'spells', 'damage'}
                },
                {
                    ['display'] = PaperDollFrame_SetSpellBonusHealing,
                    ['option'] = {'spells', 'healing'}
                },
                {
                    ['display'] = PaperDollFrame_SetRating,
                    ['argument'] = CR_HIT_SPELL,
                    ['option'] = {'spells', 'hit'}
                },
                {
                    ['display'] = PaperDollFrame_SetSpellCritChance,
                    ['onEnter'] = CharacterSpellCritChance_OnEnter,
                    ['option'] = {'spells', 'crit'}
                },
                {
                    ['display'] = PaperDollFrame_SetSpellHaste,
                    ['option'] = {'spells', 'haste'}
                },
                {
                    ['display'] = PaperDollFrame_SetManaRegen,
                    ['option'] = {'spells', 'regen'}
                }
            }
        },
        {
            ['title'] = 'Defences',
            ['rows'] = {
                {
                    ['display'] = PaperDollFrame_SetArmor,
                    ['option'] = {'defences', 'armour'}
                },
                {
                    ['display'] = PaperDollFrame_SetDefense,
                    ['option'] = {'defences', 'defense'}
                },
                {
                    ['display'] = PaperDollFrame_SetDodge,
                    ['option'] = {'defences', 'dodge'}
                },
                {
                    ['display'] = PaperDollFrame_SetParry,
                    ['option'] = {'defences', 'parry'}
                },
                {
                    ['display'] = PaperDollFrame_SetBlock,
                    ['option'] = {'defences', 'block'}
                },
                {
                    ['display'] = PaperDollFrame_SetResilience,
                    ['option'] = {'defences', 'resilience'}
                }
            }
        },
        {
            ['title'] = 'Prestige',
            ['rows'] = {
                {
                    ['display'] = ScootsStats.setStatCharacterAttunes,
                    ['onEnter'] = ScootsStats.enterCharacterAttunes,
                    ['option'] = {'prestige', 'charattunes'}
                },
                {
                    ['display'] = ScootsStats.setStatForgePower,
                    ['onEnter'] = ScootsStats.enterForgePower,
                    ['option'] = {'prestige', 'forgepower'},
                    ['attunementOnly'] = true
                },
                {
                    ['display'] = ScootsStats.setStatLootCoercion,
                    ['onEnter'] = ScootsStats.enterLootCoercion,
                    ['option'] = {'prestige', 'lootcoercion'},
                    ['attunementOnly'] = true
                },
                {
                    ['display'] = ScootsStats.setStatAffixCoercion,
                    ['onEnter'] = ScootsStats.enterAffixCoercion,
                    ['option'] = {'prestige', 'affixcoercion'},
                    ['attunementOnly'] = true
                },
                {
                    ['display'] = ScootsStats.setStatBonusExp,
                    ['onEnter'] = ScootsStats.enterBonusExp,
                    ['option'] = {'prestige', 'bonusexp'},
                    ['attunementOnly'] = true
                }
            }
        }
    }
    
    local prevFrame = nil
    local minWidth = ScootsStats.frames.title:GetWidth() + ScootsStats.frames.optionsButton:GetWidth() + 10
    local frameHeight = 5
    
    for sectionIndex, section in ipairs(layout) do
        local pushedHeader = false
        local sectionKey = '-' .. tostring(sectionIndex)
        
        for rowIndex, row in ipairs(section.rows) do
            local rowKey = sectionKey .. '-' .. tostring(rowIndex)
            
            if(ScootsStats.options[row.option[1]][row.option[2]] ~= true) then
                if(ScootsStats.rowFrames[rowKey]) then
                    ScootsStats.rowFrames[rowKey]:Hide()
                end
            else
                if(not pushedHeader) then
                    if(not ScootsStats.sectionFrames[sectionKey]) then
                        ScootsStats.sectionFrames[sectionKey] = CreateFrame('Frame', 'ScootsStatsSectionHead' .. sectionKey, ScootsStats.frames.scrollChild)
                        ScootsStats.sectionFrames[sectionKey]:SetHeight(10)
                        ScootsStats.sectionFrames[sectionKey]:SetFrameStrata(ScootsStats.strata)
                        ScootsStats.sectionFrames[sectionKey].text = ScootsStats.sectionFrames[sectionKey]:CreateFontString(nil, 'ARTWORK')
                        ScootsStats.sectionFrames[sectionKey].text:SetFont('Fonts\\FRIZQT__.TTF', 10)
                        ScootsStats.sectionFrames[sectionKey].text:SetPoint('CENTER', 0, 0)
                        ScootsStats.sectionFrames[sectionKey].text:SetJustifyH('CENTER')
                        ScootsStats.sectionFrames[sectionKey].text:SetTextColor(1, 1, 1)
                        ScootsStats.sectionFrames[sectionKey].text:SetText(section.title)
                    end
                        
                    if(prevFrame == nil) then
                        ScootsStats.sectionFrames[sectionKey]:SetPoint('TOPLEFT', ScootsStats.frames.scrollChild, 'TOPLEFT', 5, -5)
                    else
                        ScootsStats.sectionFrames[sectionKey]:SetPoint('TOPLEFT', prevFrame, 'BOTTOMLEFT', 0, -5)
                    end
                    
                    ScootsStats.sectionFrames[sectionKey]:Show()
                    minWidth = math.max(minWidth, ScootsStats.sectionFrames[sectionKey].text:GetWidth())
                    prevFrame = ScootsStats.sectionFrames[sectionKey]
                    pushedHeader = true
                    frameHeight = frameHeight + 15
                end
                
                if(not ScootsStats.rowFrames[rowKey]) then
                    ScootsStats.rowFrames[rowKey] = CreateFrame('Frame', 'ScootsStatsRow' .. rowKey, ScootsStats.frames.scrollChild, 'StatFrameTemplate')
                    ScootsStats.rowFrames[rowKey]:SetHeight(10)
                    ScootsStats.rowFrames[rowKey]:SetFrameStrata(ScootsStats.strata)
                    
                    if(row.onEnter) then
                        ScootsStats.rowFrames[rowKey]:SetScript('OnEnter', row.onEnter)
                    end
                    
                    if(row.onUpdate) then
                        ScootsStats.rowFrames[rowKey]:SetScript('OnUpdate', row.onUpdate)
                    end
                end
                
                ScootsStats.rowFrames[rowKey]:Show()
                row.display(ScootsStats.rowFrames[rowKey], row.argument)
                
                ScootsStats.rowFrames[rowKey]:SetPoint('TOPLEFT', prevFrame, 'BOTTOMLEFT', 0, -1)
                prevFrame = ScootsStats.rowFrames[rowKey]
                frameHeight = frameHeight + 10 + 1
				
				local labelWidth = _G[ScootsStats.rowFrames[rowKey]:GetName() .. 'Label']:GetWidth()
                
				local dataWidth = _G[ScootsStats.rowFrames[rowKey]:GetName() .. 'StatText']:GetWidth()
                if(row.option[1] == 'misc' and row.option[2] == 'movespeed') then
                    dataWidth = math.max(dataWidth, 30)
                end
                
                minWidth = math.max(minWidth, labelWidth + dataWidth + 10)
            end
        end
    end
    
    for _, frame in pairs(ScootsStats.sectionFrames) do
        frame:SetWidth(minWidth)
    end
    
    for _, frame in pairs(ScootsStats.rowFrames) do
        frame:SetWidth(minWidth)
    end
    
    local scrollWidth = 0
    if(frameHeight <= ScootsStats.frames.scrollFrame:GetHeight()) then
        ScootsStats.frames.scrollBar:Hide()
    else
        ScootsStats.frames.scrollBar:Show()
        scrollWidth = ScootsStats.frames.scrollBar:GetWidth()
    end
    
    ScootsStats.frames.scrollFrame:SetWidth(minWidth + 10 + scrollWidth)
    
    ScootsStats.frames.scrollChild:SetWidth(minWidth + 10)
    ScootsStats.frames.scrollChild:SetHeight(frameHeight)
    
    ScootsStats.frames.master:SetWidth(ScootsStats.frames.scrollChild:GetWidth() + 5 + scrollWidth)
    
    ScootsStats.frames.background:SetWidth(ScootsStats.frames.master:GetWidth() + 20)
    _G['CharacterFrame']:SetWidth(ScootsStats.baseWidth + ScootsStats.frames.master:GetWidth())
end

ScootsStats.setStatAttune = function(frame)
    local attuneCount = 0
    local attuneProgress = 0
    
    if(GetItemLinkAttuneProgress and CanAttuneItemHelper) then
        for _, slotId in pairs(ScootsStats.slotIds) do
            local itemId = GetInventoryItemID('player', slotId)
            
            if(itemId) then
                local itemLink = GetInventoryItemLink('player', slotId)
                local itemProgress = GetItemLinkAttuneProgress(itemLink)
                
                if(CanAttuneItemHelper(itemId) >= 1 and itemProgress < 100) then
                    attuneCount = attuneCount + 1
                    attuneProgress = attuneProgress + itemProgress
                end
            end
        end
    end
    
    if(attuneCount == 0) then
        PaperDollFrame_SetLabelAndText(frame, 'Attuning', '0 items')
    else
        local s = 's'
        if(attuneCount == 1) then
            s = ''
        end
        
        PaperDollFrame_SetLabelAndText(frame, 'Attuning', attuneCount .. ' item' .. s .. ' (' .. string.format('%d', attuneProgress / attuneCount) .. '%)')
    end
end

ScootsStats.enterAttune = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Item Attunements', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    
    local attuneCount = 0
    if(GetItemLinkAttuneProgress and CanAttuneItemHelper) then
        for _, slotId in ipairs(ScootsStats.slotIds) do
            local itemId = GetInventoryItemID('player', slotId)
            
            if(itemId) then
                local itemLink = GetInventoryItemLink('player', slotId)
                local itemProgress = GetItemLinkAttuneProgress(itemLink)
                
                if(CanAttuneItemHelper(itemId) >= 1 and itemProgress < 100) then
                    GameTooltip:AddDoubleLine(
                        select(1, GetItemInfo(itemId)),
                        string.format('%.2f', itemProgress) .. '%',
                        NORMAL_FONT_COLOR.r,
                        NORMAL_FONT_COLOR.g,
                        NORMAL_FONT_COLOR.b,
                        HIGHLIGHT_FONT_COLOR.r,
                        HIGHLIGHT_FONT_COLOR.g,
                        HIGHLIGHT_FONT_COLOR.b
                    )
                    
                    attuneCount = attuneCount + 1
                end
            end
        end
    end
    
    if(attuneCount > 0) then
        GameTooltip:Show()
    end
end

ScootsStats.setStatMovementSpeed = function(frame)
    if(ScootsStats.characterFrameOpen) then
        PaperDollFrame_SetLabelAndText(frame, 'Run Speed', string.format('%d', (GetUnitSpeed('Player') / 7) * 100) .. '%')
    end
end

ScootsStats.enterMovementSpeed = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Run Speed', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('Shows the speed you are currently moving at.', nil, nil, nil, true)
    GameTooltip:Show()
end

ScootsStats.setStatCharacterAttunes = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    PaperDollFrame_SetLabelAndText(frame, 'Char. Attunes', string.format('%.2f', (100 / ScootsStats.totalCharacterAttunes) * ScootsStats.characterAttunes) .. '%')
end

ScootsStats.enterCharacterAttunes = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Character Attunes', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows your progress towards attuning all items available for your current character.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(tostring(ScootsStats.characterAttunes) .. ' of ' .. tostring(ScootsStats.totalCharacterAttunes) .. ' items attuned.', nil, nil, nil, true)
end

ScootsStats.setStatForgePower = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    local titan = (ScootsStats.accountAttunesTF / 100) ^ 0.7
    local war = (ScootsStats.accountAttunesWF / 15) ^ 0.7
    local light = ScootsStats.accountAttunesLF ^ 0.7
    
    PaperDollFrame_SetLabelAndText(frame, 'Forge Power', string.format('%.2f', titan + war + light) .. '%')
end

ScootsStats.enterForgePower = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Forge Power', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows an increased chance to gain forged items after prestige.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Increased by attuning forged items across your entire account.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    
    local titanEffect = (ScootsStats.accountAttunesTF / 100) ^ 0.7
    local warEffect = (ScootsStats.accountAttunesWF / 15) ^ 0.7
    local lightEffect = ScootsStats.accountAttunesLF ^ 0.7
    
    local s = 's'
    if(ScootsStats.accountAttunesTF == 1) then
        s = ''
    end
    GameTooltip:AddDoubleLine(
        ScootsStats.accountAttunesTF .. ' titanforged item' .. s,
        string.format('%.2f', titanEffect) .. '%',
        NORMAL_FONT_COLOR.r,
        NORMAL_FONT_COLOR.g,
        NORMAL_FONT_COLOR.b,
        HIGHLIGHT_FONT_COLOR.r,
        HIGHLIGHT_FONT_COLOR.g,
        HIGHLIGHT_FONT_COLOR.b
    )
    
    s = 's'
    if(ScootsStats.accountAttunesWF == 1) then
        s = ''
    end
    GameTooltip:AddDoubleLine(
        ScootsStats.accountAttunesWF .. ' warforged item' .. s,
        string.format('%.2f', warEffect) .. '%',
        NORMAL_FONT_COLOR.r,
        NORMAL_FONT_COLOR.g,
        NORMAL_FONT_COLOR.b,
        HIGHLIGHT_FONT_COLOR.r,
        HIGHLIGHT_FONT_COLOR.g,
        HIGHLIGHT_FONT_COLOR.b
    )
    
    s = 's'
    if(ScootsStats.accountAttunesLF == 1) then
        s = ''
    end
    GameTooltip:AddDoubleLine(
        ScootsStats.accountAttunesLF .. ' lightforged item' .. s,
        string.format('%.2f', lightEffect) .. '%',
        NORMAL_FONT_COLOR.r,
        NORMAL_FONT_COLOR.g,
        NORMAL_FONT_COLOR.b,
        HIGHLIGHT_FONT_COLOR.r,
        HIGHLIGHT_FONT_COLOR.g,
        HIGHLIGHT_FONT_COLOR.b
    )
    
    GameTooltip:Show()
end

ScootsStats.setStatLootCoercion = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    local effect = (100 / ScootsStats.totalAccountAttunes) * ScootsStats.accountAttunes
    
    PaperDollFrame_SetLabelAndText(frame, 'Loot Coercion', string.format('%.2f', effect) .. '%')
end

ScootsStats.enterLootCoercion = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Loot Coercion', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows an increased chance for dropped bind-on-pickup items to be useful to you after prestige.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Equal to your total account attunes relative to the total number of attunable items in the game.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(ScootsStats.accountAttunes .. ' of ' .. ScootsStats.totalAccountAttunes .. ' items attuned.')
    GameTooltip:Show()
end

ScootsStats.setStatAffixCoercion = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    if(ScootsStats.totalAccountAffixes ~= nil) then
        local effect = ((100 / ScootsStats.totalAccountAffixes) * ScootsStats.attunedAffixes) / 4
        
        PaperDollFrame_SetLabelAndText(frame, 'Affix Coercion', string.format('%.2f', effect) .. '%')
    end
end

ScootsStats.enterAffixCoercion = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Affix Coercion', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows an increased chance for dropped bind-on-equip items with an affix (e.g. "of the Eagle") to have your preferred affix (based on your affix manager settings) after prestige.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Equal to a quarter of your total account affix attunes relative to the total number of attunable affixes in the game.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(ScootsStats.attunedAffixes .. ' of ' .. ScootsStats.totalAccountAffixes .. ' affixes attuned.')
    GameTooltip:Show()
end

ScootsStats.setStatBonusExp = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end

    PaperDollFrame_SetLabelAndText(frame, 'Bonus Exp.', string.format('%.2f', ScootsStats.bonusExpEffect) .. '%')
end

ScootsStats.enterBonusExp = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Bonus Experience', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows how much extra experience your attuning items will gain after prestige.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Increased by attuning lightforged items with an item level above 200.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    local s = 's'
    if(ScootsStats.highLevelLightForges == 1) then
        s = ''
    end
    GameTooltip:AddLine(ScootsStats.highLevelLightForges .. ' high item level lightforged attune' .. s .. '.')
    GameTooltip:Show()
end

ScootsStats.toggleOptionsPanel = function(frame)
    local blizzardFrames = {
        'CharacterModelFrame',
        'MagicResFrame1',
        'MagicResFrame2',
        'MagicResFrame3',
        'MagicResFrame4',
        'MagicResFrame5'
    }

    if(ScootsStats.optionsOpen) then
        ScootsStats.frames.optionsButton:SetText('Options')
        ScootsStats.frames.options:Hide()
        
        for _, frameName in pairs(blizzardFrames) do
            _G[frameName]:Show()
        end
        
        ScootsStats.optionsOpen = false
    else
        if(ScootsStats.frames.options == nil) then
            ScootsStats.frames.options = CreateFrame('Frame', 'ScootsStatsOptionsPanel', _G['PaperDollFrame'])
            ScootsStats.frames.options:SetPoint('TOPLEFT', _G['PaperDollFrame'], 'TOPLEFT', 70, -76)
            ScootsStats.frames.options:SetWidth(224)
            ScootsStats.frames.options:SetHeight(300)
            
            local map = {
                {
                    ['title'] = 'Miscellaneous',
                    ['rows'] = {
                        {'Attuning', 'misc', 'attuning'},
                        {'Run Speed', 'misc', 'movespeed'}
                    }
                },
                {
                    ['title'] = 'Base Stats',
                    ['rows'] = {
                        {'Strength', 'base', 'strength'},
                        {'Agility', 'base', 'agility'},
                        {'Stamina', 'base', 'stamina'},
                        {'Intellect', 'base', 'intellect'},
                        {'Spirit', 'base', 'spirit'}
                    }
                },
                {
                    ['title'] = 'Melee',
                    ['rows'] = {
                        {'Damage', 'melee', 'damage'},
                        {'Speed', 'melee', 'speed'},
                        {'Power', 'melee', 'power'},
                        {'Hit Rating', 'melee', 'hit'},
                        {'Crit Chance', 'melee', 'crit'},
                        {'Expertise', 'melee', 'expertise'}
                    }
                },
                {
                    ['title'] = 'Ranged',
                    ['rows'] = {
                        {'Damage', 'ranged', 'damage'},
                        {'Speed', 'ranged', 'speed'},
                        {'Power', 'ranged', 'power'},
                        {'Hit Rating', 'ranged', 'hit'},
                        {'Crit Chance', 'ranged', 'crit'}
                    }
                },
                {
                    ['title'] = 'Spells',
                    ['rows'] = {
                        {'Bonus Damage', 'spells', 'damage'},
                        {'Bonus Healing', 'spells', 'healing'},
                        {'Hit Rating', 'spells', 'hit'},
                        {'Crit Chance', 'spells', 'crit'},
                        {'Haste Rating', 'spells', 'haste'},
                        {'Mana Regen', 'spells', 'regen'}
                    }
                },
                {
                    ['title'] = 'Defences',
                    ['rows'] = {
                        {'Armor', 'defences', 'armour'},
                        {'Defense', 'defences', 'defense'},
                        {'Dodge', 'defences', 'dodge'},
                        {'Parry', 'defences', 'parry'},
                        {'Block', 'defences', 'block'},
                        {'Resilience', 'defences', 'resilience'}
                    }
                },
                {
                    ['title'] = 'Prestige',
                    ['rows'] = {
                        {'Char. Attunes', 'prestige', 'charattunes'},
                        {'Forge Power', 'prestige', 'forgepower'},
                        {'Loot Coercion', 'prestige', 'lootcoercion'},
                        {'Affix Coercion', 'prestige', 'affixcoercion'},
                        {'Bonus Exp.', 'prestige', 'bonusexp'}
                    }
                }
            }
            
            local prev = nil
            local toggleHeight = 14
            
            for sectionIndex, section in ipairs(map) do
                local headerFrame = CreateFrame('Frame', 'ScootsStatsOptionsHead-' .. sectionIndex, ScootsStats.frames.options)
                headerFrame:SetFrameStrata(ScootsStats.strata)
                headerFrame:SetWidth(ScootsStats.frames.options:GetWidth())
                headerFrame:SetHeight(10)
            
                if(sectionIndex == 1) then
                    headerFrame:SetPoint('TOPLEFT', ScootsStats.frames.options, 'TOPLEFT', 0, -5)
                else
                    headerFrame:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -5)
                end
                
                headerFrame.text = headerFrame:CreateFontString(nil, 'ARTWORK')
                headerFrame.text:SetFont('Fonts\\FRIZQT__.TTF', 10)
                headerFrame.text:SetPoint('CENTER', 0, 0)
                headerFrame.text:SetJustifyH('CENTER')
                headerFrame.text:SetTextColor(1, 1, 1)
                headerFrame.text:SetText(section.title)
                
                local holderFrame = CreateFrame('Frame', 'ScootsStatsOptionsHolder-' .. sectionIndex, ScootsStats.frames.options)
                holderFrame:SetFrameStrata(ScootsStats.strata)
                holderFrame:SetWidth(ScootsStats.frames.options:GetWidth())
                holderFrame:SetHeight(math.ceil(#section.rows / 3) * toggleHeight)
                holderFrame:SetPoint('TOPLEFT', headerFrame, 'BOTTOMLEFT', 0, 0)
                
                prev = holderFrame
        
                table.insert(ScootsStats.optionFrames, headerFrame)
                table.insert(ScootsStats.optionFrames, holderFrame)
                
                for rowIndex, row in ipairs(section.rows) do
                    local toggle = CreateFrame('Frame', 'ScootsStatsOptionsToggle-' .. sectionIndex .. '-' .. rowIndex, holderFrame)
                    toggle:SetFrameStrata(ScootsStats.strata)
                    toggle:SetWidth(ScootsStats.frames.options:GetWidth() / 3)
                    toggle:SetHeight(toggleHeight)
                    
                    local leftPos = ((rowIndex - 1) % 3) * (ScootsStats.frames.options:GetWidth() / 3)
                    local topPos = 0 - ((math.ceil(rowIndex / 3) - 1) * toggleHeight)
                    toggle:SetPoint('TOPLEFT', holderFrame, 'TOPLEFT', leftPos, topPos)
                    
                    toggle.text = toggle:CreateFontString(nil, 'ARTWORK')
                    toggle.text:SetFont('Fonts\\FRIZQT__.TTF', 8)
                    toggle.text:SetPoint('LEFT', toggleHeight, 0)
                    toggle.text:SetJustifyH('LEFT')
                    toggle.text:SetTextColor(1, 1, 1)
                    toggle.text:SetText(row[1])
                    toggle:EnableMouse(true)
                    
                    toggle.checkBorder = CreateFrame('Frame', 'ScootsStatsOptionsToggle-' .. sectionIndex .. '-' .. rowIndex .. '-Border', toggle)
                    toggle.checkBorder:SetFrameStrata(ScootsStats.strata)
                    toggle.checkBorder:SetSize(toggle:GetHeight(), toggle:GetHeight())
                    toggle.checkBorder:SetPoint('TOPLEFT', toggle, 'TOPLEFT', -2, -1)
                    toggle.checkBorder.texture = toggle.checkBorder:CreateTexture()
                    toggle.checkBorder.texture:SetAllPoints()
                    toggle.checkBorder.texture:SetTexture('Interface/AchievementFrame/UI-Achievement-Progressive-IconBorder')
                    toggle.checkBorder.texture:SetTexCoord(0, toggle:GetHeight() / 25, 0, toggle:GetHeight() / 25)
                    toggle.checkBorder:SetAlpha(0.8)
                    
                    toggle.check = CreateFrame('Frame', 'ScootsStatsOptionsToggle-' .. sectionIndex .. '-' .. rowIndex .. '-Check', toggle)
                    toggle.check:SetFrameStrata(ScootsStats.strata)
                    toggle.check:SetSize(toggle:GetHeight(), toggle:GetHeight())
                    toggle.check:SetPoint('TOPLEFT', toggle, 'TOPLEFT', -2, -2)
                    toggle.check.texture = toggle.check:CreateTexture()
                    toggle.check.texture:SetAllPoints()
                    toggle.check.texture:SetTexture('Interface/AchievementFrame/UI-Achievement-Criteria-Check')
                    toggle.check.texture:SetTexCoord(0, toggle:GetHeight() / 25, 0, 1)
                    
                    if(ScootsStats.options[row[2]][row[3]] ~= true) then
                        toggle.check:Hide()
                    end
                    
                    toggle:SetScript('OnEnter', function(self)
                        self.checkBorder:SetAlpha(1)
                    end)
                    
                    toggle:SetScript('OnLeave', function(self)
                        self.checkBorder:SetAlpha(0.8)
                    end)
                    
                    toggle:SetScript('OnMouseDown', function(self, button)
                        if(button == 'LeftButton') then
                            if(ScootsStats.options[row[2]][row[3]] == true) then
                                self.check:Hide()
                                ScootsStats.options[row[2]][row[3]] = false
                            else
                                self.check:Show()
                                ScootsStats.options[row[2]][row[3]] = true
                            end
                            
                            ScootsStats.updateStats()
                        end
                    end)
                    
                    table.insert(ScootsStats.optionToggleFrames, toggle)
                end
            end
        end
    
        ScootsStats.frames.optionsButton:SetText('Back')
        ScootsStats.frames.options:Show()
        
        for _, frameName in pairs(blizzardFrames) do
            _G[frameName]:Hide()
        end
        
        ScootsStats.optionsOpen = true
        ScootsStats.setFrameLevels()
    end
end

function ScootsStats.loadOptions()
    local playerClasses = {}
    
    if(CustomGetClassMask == nil) then
        local _, playerClass = UnitClass('player')
        table.insert(playerClasses, strupper(playerClass))
    else
        local mask = CustomGetClassMask()
        local classList = {
            ['DEATHKNIGHT'] = 6,
            ['DRUID'] = 11,
            ['HUNTER'] = 3,
            ['MAGE'] = 8,
            ['PALADIN'] = 2,
            ['PRIEST'] = 5,
            ['ROGUE'] = 4,
            ['SHAMAN'] = 7,
            ['WARLOCK'] = 9,
            ['WARRIOR'] = 1
        }
        
        for className, classId in pairs(classList) do
            if(bit.band(mask, bit.lshift(1, classId - 1)) > 0) then
                table.insert(playerClasses, className)
            end
        end
    end
    
    ScootsStats.options = {
        ['misc'] = {
            ['attuning'] = true,
            ['movespeed'] = true
        },
        ['base'] = {
            ['strength'] = true,
            ['agility'] = true,
            ['stamina'] = true,
            ['intellect'] = true,
            ['spirit'] = true
        },
        ['melee'] = {
            ['damage'] = false,
            ['speed'] = false,
            ['power'] = false,
            ['hit'] = false,
            ['crit'] = false,
            ['expertise'] = false
        },
        ['ranged'] = {
            ['damage'] = false,
            ['speed'] = false,
            ['power'] = false,
            ['hit'] = false,
            ['crit'] = false
        },
        ['spells'] = {
            ['damage'] = false,
            ['healing'] = false,
            ['hit'] = false,
            ['crit'] = false,
            ['haste'] = false,
            ['regen'] = false
        },
        ['defences'] = {
            ['armour'] = true,
            ['defense'] = true,
            ['dodge'] = true,
            ['parry'] = true,
            ['block'] = true,
            ['resilience'] = true
        },
        ['prestige'] = {
            ['charattunes'] = true,
            ['forgepower'] = true,
            ['lootcoercion'] = true,
            ['affixcoercion'] = true,
            ['bonusexp'] = true
        }
    }
    
    for _, playerClass in pairs(playerClasses) do
        if(playerClass == 'DEATHKNIGHT'
        or playerClass == 'DRUID'
        or playerClass == 'HUNTER'
        or playerClass == 'PALADIN'
        or playerClass == 'ROGUE'
        or playerClass == 'SHAMAN'
        or playerClass == 'WARRIOR') then
            for key, _ in pairs(ScootsStats.options.melee) do
                ScootsStats.options.melee[key] = true
            end
        end
        
        if(playerClass == 'HUNTER'
        or playerClass == 'ROGUE'
        or playerClass == 'WARRIOR') then
            for key, _ in pairs(ScootsStats.options.ranged) do
                ScootsStats.options.ranged[key] = true
            end
        end
        
        if(playerClass == 'DRUID'
        or playerClass == 'MAGE'
        or playerClass == 'PALADIN'
        or playerClass == 'PRIEST'
        or playerClass == 'SHAMAN'
        or playerClass == 'WARLOCK') then
            for key, _ in pairs(ScootsStats.options.spells) do
                ScootsStats.options.spells[key] = true
            end
        end
    end
    
    if(_G['SCOOTSSTATS_OPTIONS']) then
        for sectionKey, _ in pairs(ScootsStats.options) do
            for key, _ in pairs(ScootsStats.options[sectionKey]) do
                if(_G['SCOOTSSTATS_OPTIONS'][sectionKey][key] ~= nil) then
                    ScootsStats.options[sectionKey][key] = _G['SCOOTSSTATS_OPTIONS'][sectionKey][key]
                end
            end
        end
    end
    
    ScootsStats.optionsLoaded = true
end

ScootsStats.onLoad = function()
    if(CalculateAttunableAffixCount and ScootsStats.totalAccountAffixes == nil) then
        ScootsStats.totalAccountAffixes = CalculateAttunableAffixCount()
    end
    
    ScootsStats.addonLoaded = true
end

function ScootsStats.onLogout()
    if(ScootsStats.optionsLoaded) then
        _G['SCOOTSSTATS_OPTIONS'] = ScootsStats.options
    end
end

function ScootsStats.watchChatForAttunement(message)
    if(string.find(message, 'You have attuned with', 1, true)) then
        ScootsStats.queuedUpdate = true
        ScootsStats.queuedAttunedUpdate = true
        
        if(string.find(message, 'Lightforged', 1, true)) then
            ScootsStats.queuedLightforgeUpdate = true
        end
    end
end

function ScootsStats.eventHandler(self, event, arg1)
    if(event == 'ADDON_LOADED' and arg1 == 'ScootsStats') then
        ScootsStats.onLoad()
    elseif(event == 'PLAYER_LOGOUT') then
        ScootsStats.onLogout()
    elseif(event == 'CHAT_MSG_SYSTEM') then
        ScootsStats.watchChatForAttunement(arg1)
    else
        ScootsStats.queuedUpdate = true
    end
end

ScootsStats.frames.event:SetScript('OnEvent', ScootsStats.eventHandler)

ScootsStats.frames.event:RegisterEvent('ADDON_LOADED')
ScootsStats.frames.event:RegisterEvent('PLAYER_LOGOUT')
ScootsStats.frames.event:RegisterEvent('CHAT_MSG_SYSTEM')
ScootsStats.frames.event:RegisterEvent('PLAYER_ENTERING_WORLD')
ScootsStats.frames.event:RegisterEvent('UNIT_INVENTORY_CHANGED')
ScootsStats.frames.event:RegisterEvent('UNIT_AURA')
ScootsStats.frames.event:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
ScootsStats.frames.event:RegisterEvent('PARTY_KILL')
ScootsStats.frames.event:RegisterEvent('QUEST_TURNED_IN')
ScootsStats.frames.event:RegisterEvent('PLAYER_AURAS_CHANGED')