SS = {}
SS.initialised = false
SS.characterFrameOpen = false
SS.optionsOpen = false
SS.frames = {}
SS.frames.event = CreateFrame('Frame', 'ScootsStatsEventFrame', UIParent)
SS.frames.master = CreateFrame('Frame', 'ScootsStatsMasterFrame', _G['CharacterFrame'])
SS.queuedUpdate = false
SS.queuedAttunedUpdate = false
SS.hookedTabs = false

SS.frames.event:SetScript('OnUpdate', function()
    if(SS.addonLoaded) then
        if(SS.characterFrameOpen == false) then
            if(_G['CharacterFrame'] and _G['CharacterFrame']:IsVisible() == 1 and MAX_ITEMID and CanAttuneItemHelper and GetItemAttuneProgress) then
                SS.characterFrameOpen = true
                SS.queuedUpdate = true
                
                if(not SS.initialised) then
                    SS.init()
                    SS.queuedAttunedUpdate = true
                end
            end
        else
            if(_G['CharacterFrame'] and _G['CharacterFrame']:IsVisible() ~= 1) then
                SS.characterFrameOpen = false
                
                if(SS.optionsOpen) then
                    SS.toggleOptionsPanel()
                end
            else
                if(SS.queuedUpdate == true or SS.queuedAttunedUpdate == true) then
                    SS.updateStats()
                    SS.setFrameLevels()
                    
                    SS.queuedUpdate = false
                    SS.queuedAttunedUpdate = false
                end
            end
        end
        
        if(SS.characterFrameOpen) then
            SS.applyFixesToOtherFrames()
        end
    end
end)

SS.init = function()
    SS.initialised = true
    SS.loadOptions()
    SS.baseWidth = _G['CharacterFrame']:GetWidth()
    SS.strata = _G['CharacterFrame']:GetFrameStrata()
    SS.slotIds = {1, 2, 3, 15, 5, 9, 10, 6, 7, 8, 11, 12, 13, 14, 16, 17, 18}
    SS.sectionFrames = {}
    SS.rowFrames = {}
    SS.optionFrames = {}
    SS.optionToggleFrames = {}
    
	_G['CharacterAttributesFrame']:Hide()
	_G['CharacterModelFrame']:SetHeight(305)
    
    SS.frames.otherTabHolder = CreateFrame('Frame', 'ScootsStatsSecondaryFrameHolder', _G['CharacterFrame'])
    SS.frames.otherTabHolder:SetWidth(SS.baseWidth)
    SS.frames.otherTabHolder:SetHeight(_G['CharacterFrame']:GetHeight())
    SS.frames.otherTabHolder:SetPoint('TOPLEFT', _G['CharacterFrame'], 'TOPLEFT', 0, 0)
    
    SS.frames.master:SetPoint('TOPLEFT', SS.frames.otherTabHolder, 'TOPRIGHT', -35, 0)
    SS.frames.master:SetHeight(439)
    
    SS.frames.scrollFrame = CreateFrame('ScrollFrame', 'ScootsStatsScrollFrame', SS.frames.master, 'UIPanelScrollFrameTemplate')
    SS.frames.scrollFrame:SetFrameStrata(SS.strata)
    
    SS.frames.scrollChild = CreateFrame('Frame', 'ScootsStatsScrollChild', SS.frames.scrollFrame)
    SS.frames.scrollChild:SetFrameStrata(SS.strata)
    
    local scrollBarName = SS.frames.scrollFrame:GetName()
    SS.frames.scrollBar = _G[scrollBarName .. 'ScrollBar']
    SS.frames.scrollUpButton = _G[scrollBarName .. 'ScrollBarScrollUpButton']
    SS.frames.scrollDownButton = _G[scrollBarName .. 'ScrollBarScrollDownButton']

    SS.frames.scrollUpButton:ClearAllPoints()
    SS.frames.scrollUpButton:SetPoint('TOPRIGHT', SS.frames.scrollFrame, 'TOPRIGHT', -2, -2)

    SS.frames.scrollDownButton:ClearAllPoints()
    SS.frames.scrollDownButton:SetPoint('BOTTOMRIGHT', SS.frames.scrollFrame, 'BOTTOMRIGHT', -2, 2)

    SS.frames.scrollBar:ClearAllPoints()
    SS.frames.scrollBar:SetPoint('TOP', SS.frames.scrollUpButton, 'BOTTOM', 0, -2)
    SS.frames.scrollBar:SetPoint('BOTTOM', SS.frames.scrollDownButton, 'TOP', 0, 2)

    SS.frames.scrollFrame:SetScrollChild(SS.frames.scrollChild)
    SS.frames.scrollFrame:SetPoint('TOPLEFT', SS.frames.master, 'TOPLEFT', 0, -34)
    SS.frames.scrollFrame:SetHeight(403)
    
    SS.frames.optionsButton = CreateFrame('Button', 'ScootsStatsOptionsButton', SS.frames.master, 'UIPanelButtonTemplate')
	SS.frames.optionsButton:SetSize(56, 19)
	SS.frames.optionsButton:SetText('Options')
	SS.frames.optionsButton:SetPoint('TOPRIGHT', SS.frames.master, 'TOPRIGHT', -6, -15)
	SS.frames.optionsButton:SetFrameStrata(SS.strata)
	SS.frames.optionsButton:SetScript('OnClick', SS.toggleOptionsPanel)
    
    SS.frames.title = CreateFrame('Frame', 'ScootsStatsTitle', SS.frames.master)
    SS.frames.title:SetHeight(12)
    SS.frames.title:SetPoint('TOPLEFT', SS.frames.master, 'TOPLEFT', 5, -19)
	SS.frames.title:SetFrameStrata(SS.strata)
    SS.frames.title.text = SS.frames.title:CreateFontString(nil, 'ARTWORK')
    SS.frames.title.text:SetFont('Fonts\\FRIZQT__.TTF', 12)
    SS.frames.title.text:SetPoint('TOPLEFT', 0, 0)
    SS.frames.title.text:SetJustifyH('LEFT')
    SS.frames.title.text:SetTextColor(1, 1, 1)
    SS.frames.title.text:SetText('ScootsStats')
    SS.frames.title:SetWidth(SS.frames.title.text:GetStringWidth())
    
    SS.frames.background = CreateFrame('Frame', 'ScootsStatsBackground', SS.frames.master)
    SS.frames.background:SetPoint('TOPLEFT', SS.frames.master, 'TOPLEFT', -20, 0)
    SS.frames.background:SetHeight(SS.frames.master:GetHeight())
	SS.frames.background:SetFrameStrata(SS.strata)
    SS.frames.background.texture = SS.frames.background:CreateTexture()
    SS.frames.background.texture:SetTexture([[Interface\AddOns\ScootsStats\Textures\Frame-Flyout.blp]])
    SS.frames.background.texture:SetPoint('TOPRIGHT', 0, -1)
    SS.frames.background.texture:SetSize(512, 512)
    
    _G['CharacterNameFrame']:SetPoint('TOPRIGHT', SS.frames.master, 'TOPLEFT', 33, -19)
    _G['CharacterNameFrame']:SetWidth(SS.baseWidth)
    
    _G['CharacterFrameCloseButton']:SetPoint('TOPRIGHT', SS.frames.otherTabHolder, 'TOPRIGHT', -28, -9)
    
    _G['GearManagerToggleButton']:ClearAllPoints()
    _G['GearManagerToggleButton']:SetPoint('TOPLEFT', _G['CharacterFrame'], 'TOPLEFT', 315, -40)
    
    SS.sectionFrames = {}
    SS.rowFrames = {}
    
    SS.old_cu_uib = _cu_uib
    _cu_uib = function(type)
        SS.queuedUpdate = true
        return SS.old_cu_uib(type)
    end
    
    SS.totalAccountAttunes = 0
    
    for itemId = 1, MAX_ITEMID do
        local itemTags = GetItemTagsCustom(itemId)
        if itemTags and bit.band(itemTags, 96) == 64 then
            SS.totalAccountAttunes = SS.totalAccountAttunes + 1
        end
    end
end

SS.applyFixesToOtherFrames = function()
    local frames = {
        'PaperDollFrame',
        'PetPaperDollFrame',
        'ReputationFrame',
        'SkillFrame',
        'TokenFrame'
    }
    
    for _, frameName in pairs(frames) do
        if(_G[frameName] and _G[frameName]:IsVisible() and SS['moved' .. frameName] == nil) then
            _G[frameName]:SetParent(SS.frames.otherTabHolder)
            _G[frameName]:SetAllPoints()
            _G[frameName]:SetFrameLevel(_G['CharacterFrame']:GetFrameLevel() + 5)
            SS['moved' .. frameName] = true
        end
    end
end

SS.setFrameLevels = function()
    local baseLevel = _G['PaperDollFrame']:GetFrameLevel()
    
    SS.frames.master:SetFrameLevel(baseLevel + 1)
    SS.frames.scrollFrame:SetFrameLevel(baseLevel + 2)
    SS.frames.scrollChild:SetFrameLevel(baseLevel + 3)
    SS.frames.scrollBar:SetFrameLevel(baseLevel + 3)
    SS.frames.scrollUpButton:SetFrameLevel(baseLevel + 3)
    SS.frames.scrollDownButton:SetFrameLevel(baseLevel + 3)
    SS.frames.optionsButton:SetFrameLevel(baseLevel + 1)
    SS.frames.title:SetFrameLevel(baseLevel + 1)
    SS.frames.background:SetFrameLevel(baseLevel - 1)
    
    for _, frame in pairs(SS.sectionFrames) do
        frame:SetFrameLevel(baseLevel + 4)
    end
    
    if(SS.frames.options) then
        SS.frames.options:SetFrameLevel(baseLevel + 1)
    end
    
    if(SS.frames.optionToggleFrames) then
        SS.frames.options:SetFrameLevel(baseLevel + 2)
        SS.frames.options.checkBorder:SetFrameLevel(baseLevel + 3)
        SS.frames.options.check:SetFrameLevel(baseLevel + 4)
    end
    
    for _, frame in pairs(SS.optionFrames) do
        frame:SetFrameLevel(baseLevel + 2)
    end
end

SS.countAttunes = function()
    SS.characterAttunes = 0
    SS.totalCharacterAttunes = 0
    
    for itemId = 1, MAX_ITEMID do
        if(CanAttuneItemHelper(itemId) > 0) then
            SS.totalCharacterAttunes = SS.totalCharacterAttunes + 1
            
            if(GetItemAttuneProgress(itemId) >= 100) then
                SS.characterAttunes = SS.characterAttunes + 1
            end
        end
    end
    
    SS.accountAttunes, SS.accountAttunesTF, SS.accountAttunesWF, SS.accountAttunesLF = CalculateAttunedCount()
end

SS.updateStats = function()
    if(SS.queuedAttunedUpdate) then
        SS.countAttunes()
    end

    for _, frame in pairs(SS.sectionFrames) do
        frame:Hide()
    end
    
    local layout = {
        {
            ['title'] = 'Miscellaneous',
            ['rows'] = {
                {
                    ['display'] = SS.setStatAttune,
                    ['onEnter'] = SS.enterAttune,
                    ['option'] = {'misc', 'attuning'}
                },
                {
                    ['display'] = SS.setStatMovementSpeed,
                    ['onEnter'] = SS.enterMovementSpeed,
                    ['onUpdate'] = SS.setStatMovementSpeed,
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
                    ['display'] = SS.setStatCharacterAttunes,
                    ['onEnter'] = SS.enterCharacterAttunes,
                    ['option'] = {'prestige', 'charattunes'}
                },
                {
                    ['display'] = SS.setStatForgePower,
                    ['onEnter'] = SS.enterForgePower,
                    ['option'] = {'prestige', 'forgepower'},
                    ['attunementOnly'] = true
                },
                {
                    ['display'] = SS.setStatLootCoercion,
                    ['onEnter'] = SS.enterLootCoercion,
                    ['option'] = {'prestige', 'lootcoercion'},
                    ['attunementOnly'] = true
                },
                {
                    ['display'] = SS.setStatBonusExp,
                    ['onEnter'] = SS.enterBonusExp,
                    ['option'] = {'prestige', 'bonusexp'},
                    ['attunementOnly'] = true
                }
            }
        }
    }
    
    local prevFrame = nil
    local minWidth = SS.frames.title:GetWidth() + SS.frames.optionsButton:GetWidth() + 10
    local frameHeight = 5
    
    for sectionIndex, section in ipairs(layout) do
        local pushedHeader = false
        local sectionKey = '-' .. tostring(sectionIndex)
        
        for rowIndex, row in ipairs(section.rows) do
            local rowKey = sectionKey .. '-' .. tostring(rowIndex)
            
            if(SS.options[row.option[1]][row.option[2]] ~= true) then
                if(SS.rowFrames[rowKey]) then
                    SS.rowFrames[rowKey]:Hide()
                end
            else
                if(not pushedHeader) then
                    if(not SS.sectionFrames[sectionKey]) then
                        SS.sectionFrames[sectionKey] = CreateFrame('Frame', 'ScootsStatsSectionHead' .. sectionKey, SS.frames.scrollChild)
                        SS.sectionFrames[sectionKey]:SetHeight(10)
                        SS.sectionFrames[sectionKey]:SetFrameStrata(SS.strata)
                        SS.sectionFrames[sectionKey].text = SS.sectionFrames[sectionKey]:CreateFontString(nil, 'ARTWORK')
                        SS.sectionFrames[sectionKey].text:SetFont('Fonts\\FRIZQT__.TTF', 10)
                        SS.sectionFrames[sectionKey].text:SetPoint('CENTER', 0, 0)
                        SS.sectionFrames[sectionKey].text:SetJustifyH('CENTER')
                        SS.sectionFrames[sectionKey].text:SetTextColor(1, 1, 1)
                        SS.sectionFrames[sectionKey].text:SetText(section.title)
                    end
                        
                    if(prevFrame == nil) then
                        SS.sectionFrames[sectionKey]:SetPoint('TOPLEFT', SS.frames.scrollChild, 'TOPLEFT', 5, -5)
                    else
                        SS.sectionFrames[sectionKey]:SetPoint('TOPLEFT', prevFrame, 'BOTTOMLEFT', 0, -5)
                    end
                    
                    SS.sectionFrames[sectionKey]:Show()
                    minWidth = math.max(minWidth, SS.sectionFrames[sectionKey].text:GetWidth())
                    prevFrame = SS.sectionFrames[sectionKey]
                    pushedHeader = true
                    frameHeight = frameHeight + 15
                end
                
                local newlyCreated = false
                if(not SS.rowFrames[rowKey]) then
                    newlyCreated = true
                    SS.rowFrames[rowKey] = CreateFrame('Frame', 'ScootsStatsRow' .. rowKey, SS.frames.scrollChild, 'StatFrameTemplate')
                    SS.rowFrames[rowKey]:SetHeight(10)
                    SS.rowFrames[rowKey]:SetFrameStrata(SS.strata)
                    
                    if(row.onEnter) then
                        SS.rowFrames[rowKey]:SetScript('OnEnter', row.onEnter)
                    end
                    
                    if(row.onUpdate) then
                        SS.rowFrames[rowKey]:SetScript('OnUpdate', row.onUpdate)
                    end
                end
                
                SS.rowFrames[rowKey]:Show()
                
                if(newlyCreated or SS.queuedAttunedUpdate or not row.attunementOnly) then
                    row.display(SS.rowFrames[rowKey], row.argument)
                end
                
                SS.rowFrames[rowKey]:SetPoint('TOPLEFT', prevFrame, 'BOTTOMLEFT', 0, -1)
                prevFrame = SS.rowFrames[rowKey]
                frameHeight = frameHeight + 10 + 1
				
				local labelWidth = _G[SS.rowFrames[rowKey]:GetName() .. 'Label']:GetWidth()
                
				local dataWidth = _G[SS.rowFrames[rowKey]:GetName() .. 'StatText']:GetWidth()
                if(row.option[1] == 'misc' and row.option[2] == 'movespeed') then
                    dataWidth = math.max(dataWidth, 30)
                end
                
                minWidth = math.max(minWidth, labelWidth + dataWidth + 10)
            end
        end
    end
    
    for _, frame in pairs(SS.sectionFrames) do
        frame:SetWidth(minWidth)
    end
    
    for _, frame in pairs(SS.rowFrames) do
        frame:SetWidth(minWidth)
    end
    
    local scrollWidth = 0
    if(frameHeight <= SS.frames.scrollFrame:GetHeight()) then
        SS.frames.scrollBar:Hide()
    else
        SS.frames.scrollBar:Show()
        scrollWidth = SS.frames.scrollBar:GetWidth()
    end
    
    SS.frames.scrollFrame:SetWidth(minWidth + 10 + scrollWidth)
    
    SS.frames.scrollChild:SetWidth(minWidth + 10)
    SS.frames.scrollChild:SetHeight(frameHeight)
    
    SS.frames.master:SetWidth(SS.frames.scrollChild:GetWidth() + 5 + scrollWidth)
    
    SS.frames.background:SetWidth(SS.frames.master:GetWidth() + 20)
    _G['CharacterFrame']:SetWidth(SS.baseWidth + SS.frames.master:GetWidth())
end

SS.setStatAttune = function(frame)
    local attuneCount = 0
    local attuneProgress = 0
    
    if(GetItemLinkAttuneProgress and CanAttuneItemHelper) then
        for _, slotId in pairs(SS.slotIds) do
            local itemId = GetInventoryItemID('player', slotId)
            local itemLink = GetInventoryItemLink('player', slotId)
            local itemProgress = GetItemLinkAttuneProgress(itemLink)
            
            if(CanAttuneItemHelper(itemId) >= 1 and itemProgress < 100) then
                attuneCount = attuneCount + 1
                attuneProgress = attuneProgress + itemProgress
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

SS.enterAttune = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Item Attunements', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    
    local attuneCount = 0
    if(GetItemLinkAttuneProgress and CanAttuneItemHelper) then
        for _, slotId in ipairs(SS.slotIds) do
            local itemId = GetInventoryItemID('player', slotId)
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
    
    if(attuneCount > 0) then
        GameTooltip:Show()
    end
end

SS.setStatMovementSpeed = function(frame)
    if(SS.characterFrameOpen) then
        PaperDollFrame_SetLabelAndText(frame, 'Run Speed', string.format('%d', (GetUnitSpeed('Player') / 7) * 100) .. '%')
    end
end

SS.enterMovementSpeed = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Run Speed', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('Shows the speed you are currently moving at.', nil, nil, nil, true)
    GameTooltip:Show()
end

SS.setStatCharacterAttunes = function(frame)
    PaperDollFrame_SetLabelAndText(frame, 'Char. Attunes', string.format('%.2f', (100 / SS.totalCharacterAttunes) * SS.characterAttunes) .. '%')
end

SS.enterCharacterAttunes = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Character Attunes', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows your progress towards attuning all items available for your current character.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(tostring(SS.characterAttunes) .. ' of ' .. tostring(SS.totalCharacterAttunes) .. ' items attuned.', nil, nil, nil, true)
end

SS.setStatForgePower = function(frame)
    local titan = (SS.accountAttunesTF / 100) ^ 0.7
    local war = (SS.accountAttunesWF / 15) ^ 0.7
    local light = SS.accountAttunesLF ^ 0.7
    
    PaperDollFrame_SetLabelAndText(frame, 'Forge Power', string.format('%.2f', titan + war + light) .. '%')
end

SS.enterForgePower = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Forge Power', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows an increased chance to gain forged items after prestige.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Increased by attuning forged items across your entire account.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    
    local titanEffect = (SS.accountAttunesTF / 100) ^ 0.7
    local warEffect = (SS.accountAttunesWF / 15) ^ 0.7
    local lightEffect = SS.accountAttunesLF ^ 0.7
    
    local s = 's'
    if(SS.accountAttunesTF == 1) then
        s = ''
    end
    GameTooltip:AddDoubleLine(
        SS.accountAttunesTF .. ' titanforged item' .. s,
        string.format('%.2f', titanEffect) .. '%',
        NORMAL_FONT_COLOR.r,
        NORMAL_FONT_COLOR.g,
        NORMAL_FONT_COLOR.b,
        HIGHLIGHT_FONT_COLOR.r,
        HIGHLIGHT_FONT_COLOR.g,
        HIGHLIGHT_FONT_COLOR.b
    )
    
    s = 's'
    if(SS.accountAttunesWF == 1) then
        s = ''
    end
    GameTooltip:AddDoubleLine(
        SS.accountAttunesWF .. ' warforged item' .. s,
        string.format('%.2f', warEffect) .. '%',
        NORMAL_FONT_COLOR.r,
        NORMAL_FONT_COLOR.g,
        NORMAL_FONT_COLOR.b,
        HIGHLIGHT_FONT_COLOR.r,
        HIGHLIGHT_FONT_COLOR.g,
        HIGHLIGHT_FONT_COLOR.b
    )
    
    s = 's'
    if(SS.accountAttunesLF == 1) then
        s = ''
    end
    GameTooltip:AddDoubleLine(
        SS.accountAttunesLF .. ' lightforged item' .. s,
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

SS.setStatLootCoercion = function(frame)
    local effect = (100 / SS.totalAccountAttunes) * SS.accountAttunes
    
    PaperDollFrame_SetLabelAndText(frame, 'Loot Coercion', string.format('%.2f', effect) .. '%')
end

SS.enterLootCoercion = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Loot Coercion', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows an increased chance for dropped items to be useful to you after prestige.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Equal to your total account attunes relative to the total number of attunable items in the game.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(SS.accountAttunes .. ' of ' .. SS.totalAccountAttunes .. ' items attuned.')
    GameTooltip:Show()
end

SS.setStatBonusExp = function(frame)
    local effect = 0
    SS.highLevelLightForges = 0
    
    if(GetCustomGameDataCount and GetCustomGameData and GetItemInfoCustom) then
        local attunedItemCount = GetCustomGameDataCount(11)
        for i = 1, attunedItemCount do
            local itemId = GetCustomGameDataIndex(11, i)
            
            if(bit.band(itemId, 0x00FF0000) == 0 and bit.rshift(itemId, 24) == 3 and GetCustomGameData(11, itemId) >= 100) then
                _, _, _, itemLevel = GetItemInfoCustom(bit.band(itemId, 0xffff))
                if(itemLevel > 200) then
                    effect = effect + (itemLevel - 200) / 84
                    SS.highLevelLightForges = SS.highLevelLightForges + 1
                end
            end
        end
    end

    PaperDollFrame_SetLabelAndText(frame, 'Bonus Exp.', string.format('%.2f', effect) .. '%')
end

SS.enterBonusExp = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Bonus Experience', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows how much extra experience your attuning items will gain after prestige.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Increased by attuning lightforged items with an item level above 200.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    local s = 's'
    if(SS.highLevelLightForges == 1) then
        s = ''
    end
    GameTooltip:AddLine(SS.highLevelLightForges .. ' high item level lightforged attune' .. s .. '.')
    GameTooltip:Show()
end

SS.toggleOptionsPanel = function(frame)
    local blizzardFrames = {
        'CharacterModelFrame',
        'MagicResFrame1',
        'MagicResFrame2',
        'MagicResFrame3',
        'MagicResFrame4',
        'MagicResFrame5'
    }

    if(SS.optionsOpen) then
        SS.frames.optionsButton:SetText('Options')
        SS.frames.options:Hide()
        
        for _, frameName in pairs(blizzardFrames) do
            _G[frameName]:Show()
        end
        
        SS.optionsOpen = false
    else
        if(SS.frames.options == nil) then
            SS.frames.options = CreateFrame('Frame', 'ScootsStatsOptionsPanel', _G['PaperDollFrame'])
            SS.frames.options:SetPoint('TOPLEFT', _G['PaperDollFrame'], 'TOPLEFT', 70, -76)
            SS.frames.options:SetWidth(224)
            SS.frames.options:SetHeight(300)
            
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
                        {'Bonus Exp.', 'prestige', 'bonusexp'}
                    }
                }
            }
            
            local prev = nil
            local toggleHeight = 14
            
            for sectionIndex, section in ipairs(map) do
                local headerFrame = CreateFrame('Frame', 'ScootsStatsOptionsHead-' .. sectionIndex, SS.frames.options)
                headerFrame:SetFrameStrata(SS.strata)
                headerFrame:SetWidth(SS.frames.options:GetWidth())
                headerFrame:SetHeight(10)
            
                if(sectionIndex == 1) then
                    headerFrame:SetPoint('TOPLEFT', SS.frames.options, 'TOPLEFT', 0, -5)
                else
                    headerFrame:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -5)
                end
                
                headerFrame.text = headerFrame:CreateFontString(nil, 'ARTWORK')
                headerFrame.text:SetFont('Fonts\\FRIZQT__.TTF', 10)
                headerFrame.text:SetPoint('CENTER', 0, 0)
                headerFrame.text:SetJustifyH('CENTER')
                headerFrame.text:SetTextColor(1, 1, 1)
                headerFrame.text:SetText(section.title)
                
                local holderFrame = CreateFrame('Frame', 'ScootsStatsOptionsHolder-' .. sectionIndex, SS.frames.options)
                holderFrame:SetFrameStrata(SS.strata)
                holderFrame:SetWidth(SS.frames.options:GetWidth())
                holderFrame:SetHeight(math.ceil(#section.rows / 3) * toggleHeight)
                holderFrame:SetPoint('TOPLEFT', headerFrame, 'BOTTOMLEFT', 0, 0)
                
                prev = holderFrame
        
                table.insert(SS.optionFrames, headerFrame)
                table.insert(SS.optionFrames, holderFrame)
                
                for rowIndex, row in ipairs(section.rows) do
                    local toggle = CreateFrame('Frame', 'ScootsStatsOptionsToggle-' .. sectionIndex .. '-' .. rowIndex, holderFrame)
                    toggle:SetFrameStrata(SS.strata)
                    toggle:SetWidth(SS.frames.options:GetWidth() / 3)
                    toggle:SetHeight(toggleHeight)
                    
                    local leftPos = ((rowIndex - 1) % 3) * (SS.frames.options:GetWidth() / 3)
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
                    toggle.checkBorder:SetFrameStrata(SS.strata)
                    toggle.checkBorder:SetSize(toggle:GetHeight(), toggle:GetHeight())
                    toggle.checkBorder:SetPoint('TOPLEFT', toggle, 'TOPLEFT', -2, -1)
                    toggle.checkBorder.texture = toggle.checkBorder:CreateTexture()
                    toggle.checkBorder.texture:SetAllPoints()
                    toggle.checkBorder.texture:SetTexture('Interface/AchievementFrame/UI-Achievement-Progressive-IconBorder')
                    toggle.checkBorder.texture:SetTexCoord(0, toggle:GetHeight() / 25, 0, toggle:GetHeight() / 25)
                    toggle.checkBorder:SetAlpha(0.8)
                    
                    toggle.check = CreateFrame('Frame', 'ScootsStatsOptionsToggle-' .. sectionIndex .. '-' .. rowIndex .. '-Check', toggle)
                    toggle.check:SetFrameStrata(SS.strata)
                    toggle.check:SetSize(toggle:GetHeight(), toggle:GetHeight())
                    toggle.check:SetPoint('TOPLEFT', toggle, 'TOPLEFT', -2, -2)
                    toggle.check.texture = toggle.check:CreateTexture()
                    toggle.check.texture:SetAllPoints()
                    toggle.check.texture:SetTexture('Interface/AchievementFrame/UI-Achievement-Criteria-Check')
                    toggle.check.texture:SetTexCoord(0, toggle:GetHeight() / 25, 0, 1)
                    
                    if(SS.options[row[2]][row[3]] ~= true) then
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
                            if(SS.options[row[2]][row[3]] == true) then
                                self.check:Hide()
                                SS.options[row[2]][row[3]] = false
                            else
                                self.check:Show()
                                SS.options[row[2]][row[3]] = true
                            end
                            
                            SS.updateStats()
                        end
                    end)
                    
                    table.insert(SS.optionToggleFrames, toggle)
                end
            end
        end
    
        SS.frames.optionsButton:SetText('Back')
        SS.frames.options:Show()
        
        for _, frameName in pairs(blizzardFrames) do
            _G[frameName]:Hide()
        end
        
        SS.optionsOpen = true
        SS.setFrameLevels()
    end
end

function SS.loadOptions()
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
    
    SS.options = {
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
            for key, _ in pairs(SS.options.melee) do
                SS.options.melee[key] = true
            end
        end
        
        if(playerClass == 'HUNTER'
        or playerClass == 'ROGUE'
        or playerClass == 'WARRIOR') then
            for key, _ in pairs(SS.options.ranged) do
                SS.options.ranged[key] = true
            end
        end
        
        if(playerClass == 'DRUID'
        or playerClass == 'MAGE'
        or playerClass == 'PALADIN'
        or playerClass == 'PRIEST'
        or playerClass == 'SHAMAN'
        or playerClass == 'WARLOCK') then
            for key, _ in pairs(SS.options.spells) do
                SS.options.spells[key] = true
            end
        end
    end
    
    if(_G['SCOOTSSTATS_OPTIONS']) then
        for sectionKey, _ in pairs(SS.options) do
            for key, _ in pairs(SS.options[sectionKey]) do
                if(_G['SCOOTSSTATS_OPTIONS'][sectionKey][key] ~= nil) then
                    SS.options[sectionKey][key] = _G['SCOOTSSTATS_OPTIONS'][sectionKey][key]
                end
            end
        end
    end
end

function SS.onLogout()
    _G['SCOOTSSTATS_OPTIONS'] = SS.options
end

function SS.watchChatForAttunement(message)
    if(string.find(message, 'You have attuned with', 1, true)) then
        SS.queuedUpdate = true
        SS.queuedAttunedUpdate = true
    end
end

function SS.eventHandler(self, event, arg1)
    if(event == 'ADDON_LOADED' and arg1 == 'ScootsStats') then
        SS.addonLoaded = true
    elseif(event == 'PLAYER_LOGOUT') then
        SS.onLogout()
    elseif(event == 'CHAT_MSG_SYSTEM') then
        SS.watchChatForAttunement(arg1)
    else
        SS.queuedUpdate = true
    end
end

SS.frames.event:SetScript('OnEvent', SS.eventHandler)

SS.frames.event:RegisterEvent('ADDON_LOADED')
SS.frames.event:RegisterEvent('PLAYER_LOGOUT')
SS.frames.event:RegisterEvent('CHAT_MSG_SYSTEM')
SS.frames.event:RegisterEvent('PLAYER_ENTERING_WORLD')
SS.frames.event:RegisterEvent('UNIT_INVENTORY_CHANGED')
SS.frames.event:RegisterEvent('UNIT_AURA')
SS.frames.event:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
SS.frames.event:RegisterEvent('PARTY_KILL')
SS.frames.event:RegisterEvent('QUEST_TURNED_IN')
SS.frames.event:RegisterEvent('PLAYER_AURAS_CHANGED')