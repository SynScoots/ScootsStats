ScootsStats = {}
ScootsStats.version = '2.5.7'
ScootsStats.initialised = false
ScootsStats.characterFrameOpen = false
ScootsStats.optionsOpen = false
ScootsStats.frames = {}
ScootsStats.frames.event = CreateFrame('Frame', 'ScootsStatsEventFrame', UIParent)
ScootsStats.frames.master = CreateFrame('Frame', 'ScootsStatsMasterFrame', _G['CharacterFrame'])
ScootsStats.queuedUpdate = false
ScootsStats.queuedAttunedUpdate = false
ScootsStats.hookedTabs = false
ScootsStats.firstOpen = true
ScootsStats.prestiged = false

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
            and IsAttunableBySomeone
            and HasAttunedAnyVariantOfItem
            and GetCustomGameDataCount
            and GetCustomGameData
            and GetItemInfoCustom
            and HasAttunedAnyVariantEx
            and CustomExtractItemId
            and CMCGetMultiClassEnabled) then
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
    ScootsStats.frames.scrollFrame:SetPoint('TOPLEFT', ScootsStats.frames.master, 'TOPLEFT', 0, -36)
    ScootsStats.frames.scrollFrame:SetHeight(399)
    
    ScootsStats.frames.optionsButton = CreateFrame('Button', 'ScootsStatsOptionsButton', ScootsStats.frames.master, 'UIPanelButtonTemplate')
	ScootsStats.frames.optionsButton:SetSize(56, 19)
	ScootsStats.frames.optionsButton:SetText('Options')
	ScootsStats.frames.optionsButton:SetPoint('TOPRIGHT', ScootsStats.frames.master, 'TOPRIGHT', -6, -15)
	ScootsStats.frames.optionsButton:SetFrameStrata(ScootsStats.strata)
	ScootsStats.frames.optionsButton:SetScript('OnClick', ScootsStats.toggleOptionsPanel)
    
    ScootsStats.frames.title = CreateFrame('Frame', 'ScootsStatsTitle', ScootsStats.frames.master)
    ScootsStats.frames.title:SetHeight(18)
    ScootsStats.frames.title:SetPoint('TOPLEFT', ScootsStats.frames.master, 'TOPLEFT', 5, -16)
	ScootsStats.frames.title:SetFrameStrata(ScootsStats.strata)
    
    ScootsStats.frames.title.text = ScootsStats.frames.title:CreateFontString(nil, 'ARTWORK')
    ScootsStats.frames.title.text:SetFont('Fonts\\FRIZQT__.TTF', 10)
    ScootsStats.frames.title.text:SetPoint('TOPLEFT', 0, 0)
    ScootsStats.frames.title.text:SetJustifyH('LEFT')
    ScootsStats.frames.title.text:SetTextColor(1, 1, 1)
    ScootsStats.frames.title.text:SetText('ScootsStats')
    
    ScootsStats.frames.title.versionTitle = ScootsStats.frames.title:CreateFontString(nil, 'ARTWORK')
    ScootsStats.frames.title.versionTitle:SetFont('Fonts\\FRIZQT__.TTF', 8)
    ScootsStats.frames.title.versionTitle:SetPoint('TOPLEFT', ScootsStats.frames.title.text, 'BOTTOMLEFT', 0, 0)
    ScootsStats.frames.title.versionTitle:SetJustifyH('LEFT')
    ScootsStats.frames.title.versionTitle:SetTextColor(1, 1, 1)
    ScootsStats.frames.title.versionTitle:SetText('Version ')
    
    ScootsStats.frames.title.version = ScootsStats.frames.title:CreateFontString(nil, 'ARTWORK')
    ScootsStats.frames.title.version:SetFont('Fonts\\FRIZQT__.TTF', 8)
    ScootsStats.frames.title.version:SetPoint('TOPLEFT', ScootsStats.frames.title.versionTitle, 'TOPRIGHT', 0, 0)
    ScootsStats.frames.title.version:SetJustifyH('LEFT')
    ScootsStats.frames.title.version:SetTextColor(0.6, 0.98, 0.6)
    ScootsStats.frames.title.version:SetText(ScootsStats.version)
    
    ScootsStats.frames.title:SetWidth(ScootsStats.frames.title.text:GetStringWidth())
    
    ScootsStats.frames.background = _G['CharacterFrame']:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.background:SetTexture([[Interface\AddOns\ScootsStats\Textures\Frame-Flyout.blp]])
    ScootsStats.frames.background:SetPoint('TOPRIGHT', 6, -1)
    ScootsStats.frames.background:SetSize(512, 512)
    
    _G['CharacterNameFrame']:SetPoint('TOPRIGHT', ScootsStats.frames.master, 'TOPLEFT', 33, -19)
    _G['CharacterNameFrame']:SetWidth(ScootsStats.baseWidth)
    
    _G['CharacterFrameCloseButton']:SetPoint('TOPRIGHT', ScootsStats.frames.otherTabHolder, 'TOPRIGHT', -28, -9)
    
    _G['GearManagerToggleButton']:ClearAllPoints()
    _G['GearManagerToggleButton']:SetPoint('TOPLEFT', _G['CharacterFrame'], 'TOPLEFT', 315, -40)
    
    _G['TokenFrameCancelButton']:SetScript('OnClick', function()
        HideUIPanel(_G['CharacterFrame'])
    end)
    
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
    
    if((CMCGetMultiClassEnabled() or 1) == 2) then
        ScootsStats.prestiged = true
        ScootsStats.attuneMastery = GetCustomGameData(29, 1500)
    end

    for slot, _ in pairs(ScootsStats.inventoryFrames) do
        _G[slot]:SetScript('OnUpdate', ScootsStats.flyoutWatcher)
    end
end

ScootsStats.applyFixesToOtherFrames = function()
    local frames = {
        ['PetPaperDollFrame'] = 5,
        ['ReputationFrame'] = 5,
        ['SkillFrame'] = 5,
        ['TokenFrame'] = 5
    }
    
    for frameName, adjustment in pairs(frames) do
        if(_G[frameName] and _G[frameName]:IsVisible() and ScootsStats['moved' .. frameName] == nil) then
            _G[frameName]:SetParent(ScootsStats.frames.otherTabHolder)
            _G[frameName]:SetAllPoints()
            _G[frameName]:SetFrameLevel(_G['CharacterFrame']:GetFrameLevel() + adjustment)
            ScootsStats['moved' .. frameName] = true
        end
    end
    
    frames = {
        ['ReputationDetailFrame'] = 5,
        ['CharacterFrameTab1'] = 6,
        ['CharacterFrameTab2'] = 6,
        ['CharacterFrameTab3'] = 6,
        ['CharacterFrameTab4'] = 6,
        ['CharacterFrameTab5'] = 6
    }
    
    for frameName, adjustment in pairs(frames) do
        if(_G[frameName] and _G[frameName]:IsVisible()) then
            _G[frameName]:SetFrameLevel(_G['PaperDollFrame']:GetFrameLevel() + adjustment)
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
    ScootsStats.frames.otherTabHolder:SetFrameLevel(baseLevel + 2)
    ScootsStats.frames.scrollFrame:SetFrameLevel(baseLevel + 2)
    ScootsStats.frames.scrollChild:SetFrameLevel(baseLevel + 3)
    ScootsStats.frames.scrollBar:SetFrameLevel(baseLevel + 3)
    ScootsStats.frames.scrollUpButton:SetFrameLevel(baseLevel + 3)
    ScootsStats.frames.scrollDownButton:SetFrameLevel(baseLevel + 3)
    ScootsStats.frames.optionsButton:SetFrameLevel(baseLevel + 1)
    ScootsStats.frames.title:SetFrameLevel(baseLevel + 1)
    _G['CharacterNameFrame']:SetFrameLevel(baseLevel + 6)
    _G['CharacterFrameCloseButton']:SetFrameLevel(baseLevel + 10)
    
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
                    ['display'] = ScootsStats.setStatAttuneInv,
                    ['onEnter'] = ScootsStats.enterAttuneInv,
                    ['option'] = {'misc', 'attuninginv'}
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
            
            if(row.option[2] ~= 'attuninginv' or (ScootsStats.prestiged == true and ScootsStats.attuneMastery > 0)) then
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
                            ScootsStats.sectionFrames[sectionKey]:SetPoint('TOPLEFT', ScootsStats.frames.scrollChild, 'TOPLEFT', 5, -2)
                            frameHeight = frameHeight + 12
                        else
                            ScootsStats.sectionFrames[sectionKey]:SetPoint('TOPLEFT', prevFrame, 'BOTTOMLEFT', 0, -4)
                            frameHeight = frameHeight + 14
                        end
                        
                        ScootsStats.sectionFrames[sectionKey]:Show()
                        minWidth = math.max(minWidth, ScootsStats.sectionFrames[sectionKey].text:GetWidth())
                        prevFrame = ScootsStats.sectionFrames[sectionKey]
                        pushedHeader = true
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
    
    _G['CharacterFrame']:SetWidth(ScootsStats.baseWidth + ScootsStats.frames.master:GetWidth() - 40)
    
    if(ScootsStats.firstOpen) then
        ScootsStats.firstOpen = false
        HideUIPanel(_G['CharacterFrame'])
        ShowUIPanel(_G['CharacterFrame'])
    end
end

ScootsStats.setStatAttune = function(frame)
    local attuneCount = 0
    local attuneProgress = 0
    
    if(GetItemLinkAttuneProgress and CanAttuneItemHelper) then
        for _, slotId in pairs(ScootsStats.slotIds) do
            local itemId = GetInventoryItemID('player', slotId)
            
            if(itemId and CanAttuneItemHelper(itemId) >= 1) then
                local itemLink = GetInventoryItemLink('player', slotId)
                local itemProgress = GetItemLinkAttuneProgress(itemLink)
                
                if(itemProgress < 100) then
                    attuneCount = attuneCount + 1
                    attuneProgress = attuneProgress + itemProgress
                end
            end
        end
    end
    
    local label = 'Attuning'
    if(ScootsStats.prestiged) then
        label = label .. ' (Equip)'
    end
    
    if(attuneCount == 0) then
        PaperDollFrame_SetLabelAndText(frame, label, '0 items')
    else
        local s = 's'
        if(attuneCount == 1) then
            s = ''
        end
        
        PaperDollFrame_SetLabelAndText(frame, label, attuneCount .. ' item' .. s .. ' (' .. string.format('%d', attuneProgress / attuneCount) .. '%)')
    end
end

ScootsStats.enterAttune = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Item Attunements', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    
    local attuneCount = 0
    if(GetItemLinkAttuneProgress and CanAttuneItemHelper) then
        for _, slotId in ipairs(ScootsStats.slotIds) do
            local itemId = GetInventoryItemID('player', slotId)
            
            if(itemId and CanAttuneItemHelper(itemId) >= 1) then
                local itemLink = GetInventoryItemLink('player', slotId)
                local itemProgress = GetItemLinkAttuneProgress(itemLink)
                
                if(itemProgress < 100) then
                    GameTooltip:AddDoubleLine(
                        select(1, GetItemInfoCustom(itemId)),
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
    
    if(attuneCount == 0) then
        GameTooltip:AddLine('Not currently attuning any equipped items.', nil, nil, nil, true)
    end
    
    GameTooltip:Show()
end

ScootsStats.setStatAttuneInv = function(frame)
    local attuneCount = 0
    local attuneProgress = 0
    
    if(CustomExtractItemId and GetItemLinkAttuneProgress and CanAttuneItemHelper) then
        for bagIndex = 0, 4 do
            local bagSlots = GetContainerNumSlots(bagIndex)
            
            for slotIndex = 1, bagSlots do
                local itemLink = select(7, GetContainerItemInfo(bagIndex, slotIndex))
                local itemId = CustomExtractItemId(itemLink)
    
                if(itemId) then
                    if(CanAttuneItemHelper(itemId) >= 1 or ((IsAttunableBySomeone(itemId) or 0) ~= 0 and ScootsStats.itemIsNotBound(itemLink))) then
                        local itemProgress = GetItemLinkAttuneProgress(itemLink)
                        
                        if(itemProgress < 100) then
                            attuneCount = attuneCount + 1
                            attuneProgress = attuneProgress + itemProgress
                        end
                    end
                end
            end
        end
    end
    
    local label = 'Attuning'
    if(ScootsStats.prestiged) then
        label = label .. ' (Inv.)'
    end
    
    if(attuneCount == 0) then
        PaperDollFrame_SetLabelAndText(frame, label, '0 items')
    else
        local s = 's'
        if(attuneCount == 1) then
            s = ''
        end
        
        PaperDollFrame_SetLabelAndText(frame, label, attuneCount .. ' item' .. s .. ' (' .. string.format('%d', attuneProgress / attuneCount) .. '%)')
    end
end

ScootsStats.enterAttuneInv = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Inventory Attunements', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('Attuning equipment in your inventory at ' .. string.format('%.2f', ScootsStats.attuneMastery) .. '% effectiveness.', nil, nil, nil, true)
    
    GameTooltip:Show()
end

ScootsStats.setStatMovementSpeed = function(frame)
    if(ScootsStats.characterFrameOpen) then
        PaperDollFrame_SetLabelAndText(frame, 'Current Speed', string.format('%d', (GetUnitSpeed('Player') / 7) * 100) .. '%')
    end
end

ScootsStats.enterMovementSpeed = function(frame)
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Current Speed', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
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
    GameTooltip:Show()
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
    
    PaperDollFrame_SetLabelAndText(frame, 'BoP Coercion', string.format('%.2f', effect) .. '%')
end

ScootsStats.enterLootCoercion = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Bind-on-Pickup Coercion', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
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
        
        PaperDollFrame_SetLabelAndText(frame, 'BoE Coercion', string.format('%.2f', effect) .. '%')
    end
end

ScootsStats.enterAffixCoercion = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Bind-on-Equip Coercion', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows an increased chance to drop a bind-on-equip item you have not attuned after prestige.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('When this effect occurs for an affixed item, it will be useful to you as dictated by your affix manager settings.', nil, nil, nil, true)
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

    PaperDollFrame_SetLabelAndText(frame, 'Attune Mastery', string.format('%.2f', ScootsStats.bonusExpEffect) .. '%')
end

ScootsStats.enterBonusExp = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Attune Mastery', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('After prestige, you will be able to attune items in your inventory at this this effectiveness.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Increased by attuning lightforged items with an item level above 200.', nil, nil, nil, true)
    GameTooltip:AddLine('Higher item levels yield higher effect.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    local s = 's'
    if(ScootsStats.highLevelLightForges == 1) then
        s = ''
    end
    GameTooltip:AddLine(ScootsStats.highLevelLightForges .. ' high item level lightforged attune' .. s .. '.')
    GameTooltip:Show()
end

ScootsStats.itemIsNotBound = function(itemLink)
    if(not itemLink) then
        return false
    end
    
    if(ScootsStats.frames.tooltip == nil) then
        ScootsStats.frames.tooltip = CreateFrame('GameTooltip', 'ScootsStats-Tooltip', UIParent, 'GameTooltipTemplate')
        ScootsStats.frames.tooltip:Hide()
    end
    
    ScootsStats.frames.tooltip:SetOwner(UIParent)
    ScootsStats.frames.tooltip:ClearLines()
    ScootsStats.frames.tooltip:SetHyperlink(itemLink)
    
    for _, line in ipairs({ScootsStats.frames.tooltip:GetRegions()}) do
        if(line:IsObjectType('FontString')) then
            local text = line:GetText()
            
            if(text == ITEM_SOULBOUND) then
                ScootsStats.frames.tooltip:Hide()
                return false
            end
        end
    end
    
    ScootsStats.frames.tooltip:Hide()
    return true
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
                        {'Attune (Equip)', 'misc', 'attuning'},
                        {'Attune (Inv.)', 'misc', 'attuninginv', ScootsStats.prestiged == true and ScootsStats.attuneMastery > 0},
                        {'Current Speed', 'misc', 'movespeed'}
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
                        {'BoP Coercion', 'prestige', 'lootcoercion'},
                        {'BoE Coercion', 'prestige', 'affixcoercion'},
                        {'Attune Mastery', 'prestige', 'bonusexp'}
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
                
                local insertedRowIndex = 0
                for rowIndex, row in ipairs(section.rows) do
                    if(row[4] == nil or row[4] == true) then
                        insertedRowIndex = insertedRowIndex + 1
                        local toggle = CreateFrame('Frame', 'ScootsStatsOptionsToggle-' .. sectionIndex .. '-' .. rowIndex, holderFrame)
                        toggle:SetFrameStrata(ScootsStats.strata)
                        toggle:SetWidth(ScootsStats.frames.options:GetWidth() / 3)
                        toggle:SetHeight(toggleHeight)
                        
                        local leftPos = ((insertedRowIndex - 1) % 3) * (ScootsStats.frames.options:GetWidth() / 3)
                        local topPos = 0 - ((math.ceil(insertedRowIndex / 3) - 1) * toggleHeight)
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
    ScootsStats.playerClasses = {}
    
    if(CustomGetClassMask == nil) then
        local _, playerClass = UnitClass('player')
        table.insert(ScootsStats.playerClasses, strupper(playerClass))
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
                table.insert(ScootsStats.playerClasses, className)
            end
        end
    end
    
    ScootsStats.options = {
        ['misc'] = {
            ['attuning'] = true,
            ['attuninginv'] = true,
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
    
    for _, playerClass in pairs(ScootsStats.playerClasses) do
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
        
        if(event == 'PLAYER_EQUIPMENT_CHANGED' and ScootsStats.currentFlyout ~= nil) then
            ScootsStats.updateFlyoutContent()
        end
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
ScootsStats.frames.event:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')

-- ########## --

ScootsStats.inventoryFrames = {
    ['CharacterHeadSlot'] = {'INVTYPE_HEAD'},
    ['CharacterNeckSlot'] = {'INVTYPE_NECK'},
    ['CharacterShoulderSlot'] = {'INVTYPE_SHOULDER'},
    ['CharacterBackSlot'] = {'INVTYPE_CLOAK'},
    ['CharacterChestSlot'] = {'INVTYPE_CHEST', 'INVTYPE_ROBE'},
    ['CharacterShirtSlot'] = {'INVTYPE_BODY'},
    ['CharacterTabardSlot'] = {'INVTYPE_TABARD'},
    ['CharacterWristSlot'] = {'INVTYPE_WRIST'},
    ['CharacterHandsSlot'] = {'INVTYPE_HAND'},
    ['CharacterWaistSlot'] = {'INVTYPE_WAIST'},
    ['CharacterLegsSlot'] = {'INVTYPE_LEGS'},
    ['CharacterFeetSlot'] = {'INVTYPE_FEET'},
    ['CharacterFinger0Slot'] = {'INVTYPE_FINGER'},
    ['CharacterFinger1Slot'] = {'INVTYPE_FINGER'},
    ['CharacterTrinket0Slot'] = {'INVTYPE_TRINKET'},
    ['CharacterTrinket1Slot'] = {'INVTYPE_TRINKET'},
    ['CharacterMainHandSlot'] = {'INVTYPE_WEAPON', 'INVTYPE_2HWEAPON', 'INVTYPE_WEAPONMAINHAND'},
    ['CharacterSecondaryHandSlot'] = {'INVTYPE_SHIELD', 'INVTYPE_HOLDABLE', 'INVTYPE_WEAPONOFFHAND'},
    ['CharacterRangedSlot'] = {'INVTYPE_RANGED', 'INVTYPE_RANGEDRIGHT', 'INVTYPE_THROWN', 'INVTYPE_RELIC'},
}

ScootsStats.slotIdMap = {
    ['CharacterHeadSlot'] = 1,
    ['CharacterNeckSlot'] = 2,
    ['CharacterShoulderSlot'] = 3,
    ['CharacterBackSlot'] = 15,
    ['CharacterChestSlot'] = 5,
    ['CharacterShirtSlot'] = 4,
    ['CharacterTabardSlot'] = 19,
    ['CharacterWristSlot'] = 9,
    ['CharacterHandsSlot'] = 10,
    ['CharacterWaistSlot'] = 6,
    ['CharacterLegsSlot'] = 7,
    ['CharacterFeetSlot'] = 8,
    ['CharacterFinger0Slot'] = 11,
    ['CharacterFinger1Slot'] = 12,
    ['CharacterTrinket0Slot'] = 13,
    ['CharacterTrinket1Slot'] = 14,
    ['CharacterMainHandSlot'] = 16,
    ['CharacterSecondaryHandSlot'] = 17,
    ['CharacterRangedSlot'] = 18,
}

PaperDollFrameItemFlyout_Show = function() end
PaperDollFrameItemFlyout_OnShow = function() end
PaperDollFrameItemFlyout_Hide = function() end
PaperDollFrameItemFlyout_OnHide = function() end
PaperDollFrameItemFlyout_OnUpdate = function() end

function ScootsStats.flyoutWatcher(slot)
    if(IsAltKeyDown() and slot:IsMouseOver() and (not ScootsStats.frames.flyout or not ScootsStats.frames.flyout:IsMouseOver()) and ScootsStats.currentFlyout ~= slot:GetName()) then
        ScootsStats.showFlyout(slot)
        slot:SetFrameStrata('HIGH')
    elseif(not IsAltKeyDown() and ScootsStats.currentFlyout ~= nil) then
        ScootsStats.hideFlyout()
        slot:SetFrameStrata('MEDIUM')
        slot:SetFrameLevel(slot:GetParent():GetFrameLevel() + 1)
    elseif(slot:GetFrameStrata() == 'HIGH' and ScootsStats.currentFlyout ~= slot:GetName()) then
        slot:SetFrameStrata('MEDIUM')
        slot:SetFrameLevel(slot:GetParent():GetFrameLevel() + 1)
    end
end

function ScootsStats.hideFlyout()
    ScootsStats.currentFlyout = nil
    ScootsStats.frames.flyout:Hide()
end

function ScootsStats.showFlyout(slot)
    if(ScootsStats.frames.flyout == nil) then
        ScootsStats.createFlyout()
    end
    
    ScootsStats.frames.flyout:SetParent(slot)
    ScootsStats.frames.flyout:SetPoint('TOPLEFT', slot, 'TOPLEFT', 0, 0)
    
    ScootsStats.frames.flyout:ClearAllPoints()
    if(slot:GetName() == 'CharacterMainHandSlot' or slot:GetName() == 'CharacterSecondaryHandSlot' or slot:GetName() == 'CharacterRangedSlot') then
        ScootsStats.frames.flyout:SetPoint('TOPLEFT', slot, 'BOTTOMLEFT', 0, 0)
    else
        ScootsStats.frames.flyout:SetPoint('TOPLEFT', slot, 'TOPRIGHT', 0, 0)
    end
    
    ScootsStats.currentFlyout = slot:GetName()
    if(ScootsStats.updateFlyoutContent()) then
        ScootsStats.frames.flyout:Show()
    end
end

function ScootsStats.updateFlyoutContent()
    local items = ScootsStats.getFlyoutItems()
    
    for _, itemFrame in pairs(ScootsStats.frames.flyoutItems) do
        itemFrame:Hide()
        itemFrame:SetParent(UIParent)
    end
    
    if(#items.toAttune == 0 and #items.attuned == 0 and #items.noAttune == 0) then
        ScootsStats.hideFlyout()
        return false
    end
    
    local itemIndex = 0
    local labelWidth = 0
    local innerHeight = 14
    
    if(#items.toAttune == 0) then
        ScootsStats.frames.flyoutToAttune:Hide()
        ScootsStats.frames.flyoutAttuned:SetPoint('TOPLEFT', ScootsStats.frames.flyout, 'TOPLEFT', 5, 0 - 5)
        innerHeight = innerHeight - 2
    else
        ScootsStats.frames.flyoutToAttune:Show()
        labelWidth = ScootsStats.frames.flyoutToAttune.label:GetWidth()
        ScootsStats.frames.flyoutAttuned:SetPoint('TOPLEFT', ScootsStats.frames.flyoutToAttune, 'BOTTOMLEFT', 0, 0 - 2)
    end
    
    if(#items.attuned == 0) then
        ScootsStats.frames.flyoutAttuned:Hide()
        innerHeight = innerHeight - 2
        
        if(#items.toAttune == 0) then
            ScootsStats.frames.flyoutNoAttune:SetPoint('TOPLEFT', ScootsStats.frames.flyout, 'TOPLEFT', 5, 0 - 5)
        else
            ScootsStats.frames.flyoutNoAttune:SetPoint('TOPLEFT', ScootsStats.frames.flyoutToAttune, 'BOTTOMLEFT', 0, 0 - 2)
        end
    else
        ScootsStats.frames.flyoutAttuned:Show()
        labelWidth = math.max(labelWidth, ScootsStats.frames.flyoutAttuned.label:GetWidth())
        ScootsStats.frames.flyoutNoAttune:SetPoint('TOPLEFT', ScootsStats.frames.flyoutAttuned, 'BOTTOMLEFT', 0, 0 - 2)
    end
    
    if(#items.noAttune == 0) then
        ScootsStats.frames.flyoutNoAttune:Hide()
        innerHeight = innerHeight - 2
    else
        ScootsStats.frames.flyoutNoAttune:Show()
        labelWidth = math.max(labelWidth, ScootsStats.frames.flyoutNoAttune.label:GetWidth())
    end
    
    ScootsStats.frames.flyoutToAttune:SetSize(0, 0)
    if(#items.toAttune > 0) then
        local groupItemIndex = 0
        for _, item in ipairs(items.toAttune) do
            itemIndex = itemIndex + 1
            
            local button = ScootsStats.getFlyoutItemButton(itemIndex, item)
            ScootsStats.attachFlyoutItemButtonToParent(labelWidth, button, groupItemIndex, ScootsStats.frames.flyoutToAttune)
            
            groupItemIndex = groupItemIndex + 1
        end
        
        innerHeight = innerHeight + ScootsStats.frames.flyoutToAttune:GetHeight()
    end
    
    ScootsStats.frames.flyoutAttuned:SetSize(0, 0)
    if(#items.attuned > 0) then
        local groupItemIndex = 0
        for _, item in ipairs(items.attuned) do
            itemIndex = itemIndex + 1
            
            local button = ScootsStats.getFlyoutItemButton(itemIndex, item)
            ScootsStats.attachFlyoutItemButtonToParent(labelWidth, button, groupItemIndex, ScootsStats.frames.flyoutAttuned)
            
            groupItemIndex = groupItemIndex + 1
        end
        
        innerHeight = innerHeight + ScootsStats.frames.flyoutAttuned:GetHeight()
    end
    
    ScootsStats.frames.flyoutNoAttune:SetSize(0, 0)
    if(#items.noAttune > 0) then
        local groupItemIndex = 0
        for _, item in ipairs(items.noAttune) do
            itemIndex = itemIndex + 1
            
            local button = ScootsStats.getFlyoutItemButton(itemIndex, item)
            ScootsStats.attachFlyoutItemButtonToParent(labelWidth, button, groupItemIndex, ScootsStats.frames.flyoutNoAttune)
            
            groupItemIndex = groupItemIndex + 1
        end
        
        innerHeight = innerHeight + ScootsStats.frames.flyoutNoAttune:GetHeight()
    end
    
    ScootsStats.frames.flyout:SetHeight(innerHeight)
    
    ScootsStats.frames.flyout:SetWidth(math.max(
        ScootsStats.frames.flyoutToAttune:GetWidth(),
        ScootsStats.frames.flyoutAttuned:GetWidth(),
        ScootsStats.frames.flyoutNoAttune:GetWidth()
    ) + 10)
    
    local hTileCount = ScootsStats.frames.flyout:GetWidth() / 128
    ScootsStats.frames.flyout.borderBottom:SetTexCoord(0, hTileCount, 0, 1)
    ScootsStats.frames.flyout.borderTop:SetTexCoord(0, hTileCount, 0, 1)
    
    local vTileCount = ScootsStats.frames.flyout:GetHeight() / 128
    ScootsStats.frames.flyout.borderLeft:SetTexCoord(0, 1, 0, vTileCount)
    ScootsStats.frames.flyout.borderRight:SetTexCoord(0, 1, 0, vTileCount)
    
    ScootsStats.frames.flyout.background:SetTexCoord(0, hTileCount, 0, vTileCount)
    
    return true
end

function ScootsStats.getFlyoutItemButton(itemIndex, itemArray)
    if(ScootsStats.frames.flyoutItems[itemIndex] == nil) then
        local button = CreateFrame('Button', 'ScootsStatsFlyout-Button-' .. itemIndex, UIParent, 'ItemButtonTemplate')

        button:SetFrameStrata('HIGH')
        button:SetSize(22, 22)
        button:GetNormalTexture():SetAllPoints(button)
        
        button.quality = button:CreateTexture(nil, 'OVERLAY')
        button.quality:SetTexture('Interface\\Buttons\\UI-ActionButton-Border')
        button.quality:SetBlendMode('ADD')
        button.quality:SetAlpha(1)
        button.quality:SetSize(38, 38)
        button.quality:SetPoint('CENTER', 0, 0)
        
        button:SetScript('OnLeave', function()
            GameTooltip:Hide()
        end)
        
        ScootsStats.frames.flyoutItems[itemIndex] = button
    end
    
    local button = ScootsStats.frames.flyoutItems[itemIndex]
    local _, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfoCustom(CustomExtractItemId(itemArray[2]))
    
    button:SetNormalTexture(itemTexture)
    
    local colourMap = {
        [0] = {0.615, 0.615, 0.615},
        [1] = {1.000, 1.000, 1.000},
        [2] = {0.118, 1.000, 0.000},
        [3] = {0.000, 0.439, 0.867},
        [4] = {0.639, 0.208, 0.933},
        [5] = {1.000, 0.502, 0.000},
        [7] = {0.902, 0.800, 0.502},
    }
    
    button.quality:SetVertexColor(colourMap[itemQuality][1], colourMap[itemQuality][2], colourMap[itemQuality][3])
                
    button:SetScript('OnEnter', function()
        GameTooltip:SetOwner(button, 'ANCHOR_TOPLEFT')
        GameTooltip:SetHyperlink(itemArray[2])
        GameTooltip:Show()
    end)
    
    button:SetScript('OnMouseUp', function(self, button)
        if(IsAltKeyDown() and button == 'LeftButton') then
            if(itemArray[1] == 'equip') then
                PickupInventoryItem(itemArray[3])
                EquipCursorItem(ScootsStats.slotIdMap[ScootsStats.currentFlyout])
            elseif(itemArray[1] == 'bag') then
                PickupContainerItem(itemArray[3], itemArray[4])
                EquipCursorItem(ScootsStats.slotIdMap[ScootsStats.currentFlyout])
            end
        end
    end)
    
    return button
end

function ScootsStats.attachFlyoutItemButtonToParent(labelWidth, itemButton, groupItemIndex, parentFrame)
    local perRow = 6
    local padding = 2
    local size = 22
    
    local horizontalOffset = labelWidth + ((groupItemIndex % perRow) * (size + padding))
    local verticalOffset = 0 - math.floor(groupItemIndex / perRow) * (size + padding)
    
    parentFrame:SetWidth(math.max(parentFrame:GetWidth(), horizontalOffset + size))
    parentFrame:SetHeight(math.max(parentFrame:GetHeight(), math.abs(verticalOffset) + size))
    
    itemButton:SetParent(parentFrame)
    itemButton:SetPoint('TOPLEFT', parentFrame, 'TOPLEFT', horizontalOffset, verticalOffset)
    itemButton:Show()
end

function ScootsStats.getFlyoutItems()
    if(ScootsStats.armourType == nil) then
        -- Localisation for armour/weapon types due to no constants defined
        local map = {
            -- ## Armour
            {
                ['key'] = 'armourType',
                ['id'] = 50605,
                ['index'] = 6,
                ['fallback'] = 'Armor',
            },
            {
                ['key'] = 'armourSubTypeCloth',
                ['id'] = 14100,
                ['index'] = 7,
                ['fallback'] = 'Cloth',
            },
            {
                ['key'] = 'armourSubTypeLeather',
                ['id'] = 15053,
                ['index'] = 7,
                ['fallback'] = 'Leather',
            },
            {
                ['key'] = 'armourSubTypeMail',
                ['id'] = 50605,
                ['index'] = 7,
                ['fallback'] = 'Mail',
            },
            {
                ['key'] = 'armourSubTypePlate',
                ['id'] = 43586,
                ['index'] = 7,
                ['fallback'] = 'Plate',
            },
            {
                ['key'] = 'armourSubTypeShield',
                ['id'] = 49976,
                ['index'] = 7,
                ['fallback'] = 'Shields',
            },
            -- ## Melee
            {
                ['key'] = 'weaponType',
                ['id'] = 47239,
                ['index'] = 6,
                ['fallback'] = 'Weapon',
            },
            {
                ['key'] = 'weaponSubTypePolearm',
                ['id'] = 47239,
                ['index'] = 7,
                ['fallback'] = 'Polearms',
            },
            {
                ['key'] = 'weaponSubTypeStaff',
                ['id'] = 51799,
                ['index'] = 7,
                ['fallback'] = 'Staves',
            },
            {
                ['key'] = 'weaponSubTypeSword',
                ['id'] = 50427,
                ['index'] = 7,
                ['fallback'] = 'One-Handed Swords',
            },
            {
                ['key'] = 'weaponSubType2HSword',
                ['id'] = 50070,
                ['index'] = 7,
                ['fallback'] = 'Two-Handed Swords',
            },
            {
                ['key'] = 'weaponSubTypeAxe',
                ['id'] = 51795,
                ['index'] = 7,
                ['fallback'] = 'One-Handed Axes',
            },
            {
                ['key'] = 'weaponSubType2HAxe',
                ['id'] = 50415,
                ['index'] = 7,
                ['fallback'] = 'Two-Handed Axes',
            },
            {
                ['key'] = 'weaponSubTypeMace',
                ['id'] = 51798,
                ['index'] = 7,
                ['fallback'] = 'One-Handed Maces',
            },
            {
                ['key'] = 'weaponSubType2HMace',
                ['id'] = 51796,
                ['index'] = 7,
                ['fallback'] = 'Two-Handed Maces',
            },
            {
                ['key'] = 'weaponSubTypeDagger',
                ['id'] = 51800,
                ['index'] = 7,
                ['fallback'] = 'Daggers',
            },
            {
                ['key'] = 'weaponSubTypeFist',
                ['id'] = 51801,
                ['index'] = 7,
                ['fallback'] = 'Fist Weapons',
            },
            -- ## Ranged
            {
                ['key'] = 'weaponSubTypeBow',
                ['id'] = 50776,
                ['index'] = 7,
                ['fallback'] = 'Bows',
            },
            {
                ['key'] = 'weaponSubTypeGun',
                ['id'] = 50444,
                ['index'] = 7,
                ['fallback'] = 'Guns',
            },
            {
                ['key'] = 'weaponSubTypeCrossbow',
                ['id'] = 51802,
                ['index'] = 7,
                ['fallback'] = 'Crossbows',
            },
            {
                ['key'] = 'weaponSubTypeThrown',
                ['id'] = 50999,
                ['index'] = 7,
                ['fallback'] = 'Thrown',
            },
            {
                ['key'] = 'weaponSubTypeWand',
                ['id'] = 50472,
                ['index'] = 7,
                ['fallback'] = 'Wands',
            },
            -- ## Other
            {
                ['key'] = 'weaponSubTypeFishingPole',
                ['id'] = 44050,
                ['index'] = 7,
                ['fallback'] = 'Fishing Poles',
            },
        }

        for _, mapping in pairs(map) do
            local itemInfo = {GetItemInfoCustom(mapping.id)}
            ScootsStats[mapping.key] = itemInfo[mapping.index] or mapping.fallback
        end
    end
    
    local types = ScootsStats.inventoryFrames[ScootsStats.currentFlyout]
    local items = {
        ['toAttune'] = {},
        ['attuned'] = {},
        ['noAttune'] = {},
    }
    
    if(ScootsStats.currentFlyout == 'CharacterSecondaryHandSlot') then
        for _, playerClass in pairs(ScootsStats.playerClasses) do
            if(playerClass == 'DEATHKNIGHT' or playerClass == 'HUNTER' or playerClass == 'ROGUE' or playerClass == 'SHAMAN' or playerClass == 'WARRIOR') then
                table.insert(types, 'INVTYPE_WEAPON')
            end
            
            if(playerClass == 'WARRIOR') then
                table.insert(types, 'INVTYPE_2HWEAPON')
            end
        end
    end
    
    local map = {
        ['CharacterFinger0Slot'] = 'CharacterFinger1Slot',
        ['CharacterFinger1Slot'] = 'CharacterFinger0Slot',
        ['CharacterTrinket0Slot'] = 'CharacterTrinket1Slot',
        ['CharacterTrinket1Slot'] = 'CharacterTrinket0Slot',
    }
    
    for thisSlotName, otherSlotName in pairs(map) do
        if(ScootsStats.currentFlyout == thisSlotName) then
            local itemLink = GetInventoryItemLink('player', ScootsStats.slotIdMap[otherSlotName])
            if(itemLink) then
                local itemId = CustomExtractItemId(itemLink)
                if((IsAttunableBySomeone(itemId) or 0) == 0 or (CanAttuneItemHelper(itemId) or 0) <= 0) then
                    table.insert(items['noAttune'], {'equip', itemLink, ScootsStats.slotIdMap[otherSlotName]})
                else
                    if(GetItemLinkAttuneProgress(itemLink) < 100) then
                        table.insert(items['toAttune'], {'equip', itemLink, ScootsStats.slotIdMap[otherSlotName]})
                    else
                        table.insert(items['attuned'], {'equip', itemLink, ScootsStats.slotIdMap[otherSlotName]})
                    end
                end
            end
        end
    end
    
    if(ScootsStats.currentFlyout == 'CharacterMainHandSlot') then
        local itemLink = GetInventoryItemLink('player', ScootsStats.slotIdMap['CharacterSecondaryHandSlot'])
        if(itemLink) then
            local itemId = CustomExtractItemId(itemLink)
            local itemEquipLoc = select(9, GetItemInfoCustom(itemId))
            local canEquipHere = false
            
            for _, possibleEquipLoc in pairs(types) do
                if(itemEquipLoc == possibleEquipLoc) then
                    canEquipHere = true
                    break
                end
            end
            
            if(canEquipHere) then
                if((IsAttunableBySomeone(itemId) or 0) == 0 or (CanAttuneItemHelper(itemId) or 0) <= 0) then
                    table.insert(items['noAttune'], {'equip', itemLink, ScootsStats.slotIdMap['CharacterSecondaryHandSlot']})
                else
                    if(GetItemLinkAttuneProgress(itemLink) < 100) then
                        table.insert(items['toAttune'], {'equip', itemLink, ScootsStats.slotIdMap['CharacterSecondaryHandSlot']})
                    else
                        table.insert(items['attuned'], {'equip', itemLink, ScootsStats.slotIdMap['CharacterSecondaryHandSlot']})
                    end
                end
            end
        end
    end
    
    if(ScootsStats.currentFlyout == 'CharacterSecondaryHandSlot') then
        local itemLink = GetInventoryItemLink('player', ScootsStats.slotIdMap['CharacterMainHandSlot'])
        if(itemLink) then
            local itemId = CustomExtractItemId(itemLink)
            local _, _, _, _, _, _, itemSubType, _, itemEquipLoc = GetItemInfoCustom(itemId)
            local canEquipHere = false
            
            for _, possibleEquipLoc in pairs(types) do
                if(itemEquipLoc == possibleEquipLoc and itemSubType ~= ScootsStats.weaponSubTypePolearm and itemSubType ~= ScootsStats.weaponSubTypeStaff) then
                    canEquipHere = true
                    break
                end
            end
            
            if(canEquipHere) then
                if((IsAttunableBySomeone(itemId) or 0) == 0 or (CanAttuneItemHelper(itemId) or 0) <= 0) then
                    table.insert(items['noAttune'], {'equip', itemLink, ScootsStats.slotIdMap['CharacterMainHandSlot']})
                else
                    if(GetItemLinkAttuneProgress(itemLink) < 100) then
                        table.insert(items['toAttune'], {'equip', itemLink, ScootsStats.slotIdMap['CharacterMainHandSlot']})
                    else
                        table.insert(items['attuned'], {'equip', itemLink, ScootsStats.slotIdMap['CharacterMainHandSlot']})
                    end
                end
            end
        end
    end
    
    for bagIndex = 0, 4 do
        if(bagIndex == 0 or GetInventoryItemID('player', 19 + bagIndex)) then
            local bagSlots = GetContainerNumSlots(bagIndex)
            for slotIndex = 1, bagSlots do
                local itemLink = select(7, GetContainerItemInfo(bagIndex, slotIndex))
                
                if(itemLink ~= nil) then
                    local itemId = CustomExtractItemId(itemLink)
                    local itemEquipLoc = select(9, GetItemInfoCustom(itemId))
                    local canEquipHere = false
                    
                    for _, possibleEquipLoc in pairs(types) do
                        if(itemEquipLoc == possibleEquipLoc) then
                            canEquipHere = true
                            break
                        end
                    end
                    
                    if(canEquipHere) then
                        if(ScootsStats.canEquipItem(itemLink, ScootsStats.currentFlyout == 'CharacterSecondaryHandSlot')) then
                            
                            if((IsAttunableBySomeone(itemId) or 0) == 0 or (CanAttuneItemHelper(itemId) or 0) <= 0) then
                                table.insert(items['noAttune'], {'bag', itemLink, bagIndex, slotIndex})
                            else
                                if(GetItemLinkAttuneProgress(itemLink) < 100) then
                                    table.insert(items['toAttune'], {'bag', itemLink, bagIndex, slotIndex})
                                else
                                    table.insert(items['attuned'], {'bag', itemLink, bagIndex, slotIndex})
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return items
end

function ScootsStats.canEquipItem(itemLink, isOffHand)
    local itemId = CustomExtractItemId(itemLink)
    local _, _, _, _, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfoCustom(itemId)
    local playerLevel = UnitLevel('player')
    
    if(playerLevel < itemMinLevel) then
        return false
    end
    
    if(isOffHand and (itemSubType == ScootsStats.weaponSubTypePolearm or itemSubType == ScootsStats.weaponSubTypeStaff)) then
        return false
    end
    
    if(itemType == ScootsStats.armourType) then
        local noArmourCheck = {
            ['INVTYPE_NECK'] = true,
            ['INVTYPE_CLOAK'] = true,
            ['INVTYPE_BODY'] = true,
            ['INVTYPE_TABARD'] = true,
            ['INVTYPE_FINGER'] = true,
            ['INVTYPE_TRINKET'] = true,
            ['INVTYPE_HOLDABLE'] = true,
        }
        
        if(noArmourCheck[itemEquipLoc] ~= true) then
            local allowArmourType = false
            
            for _, playerClass in pairs(ScootsStats.playerClasses) do
                if(itemSubType == ScootsStats.armourSubTypeCloth) then
                    allowArmourType = true
                    break
                elseif(itemSubType == ScootsStats.armourSubTypeLeather) then
                    if(playerClass ~= 'MAGE' and playerClass ~= 'PRIEST' and playerClass ~= 'WARLOCK') then
                        allowArmourType = true
                        break
                    end
                elseif(itemSubType == ScootsStats.armourSubTypeMail) then
                    if(playerClass ~= 'MAGE' and playerClass ~= 'PRIEST' and playerClass ~= 'WARLOCK') then
                        if(playerLevel >= 40 or (playerClass ~= 'HUNTER' and playerClass ~= 'SHAMAN')) then
                            allowArmourType = true
                            break
                        end
                    end
                elseif(itemSubType == ScootsStats.armourSubTypePlate) then
                    if(playerClass == 'DEATHKNIGHT' or playerClass == 'PALADIN' or playerClass == 'WARRIOR') then
                        if(playerLevel >= 40) then
                            allowArmourType = true
                            break
                        end
                    end
                elseif(itemSubType == ScootsStats.armourSubTypeShield) then
                    if(playerClass == 'PALADIN' or playerClass == 'SHAMAN' or playerClass == 'WARRIOR') then
                        allowArmourType = true
                        break
                    end
                end
            end
            
            if(allowArmourType == false) then
                return false
            end
        end
    elseif(itemType == ScootsStats.weaponType) then
        local allowWeaponType = false
        
        if(itemSubType == ScootsStats.weaponSubTypeFishingPole) then
            allowWeaponType = true
        else
            local map = {
                [ScootsStats.weaponSubTypeDagger] = {
                    ['DRUID'] = true,
                    ['HUNTER'] = true,
                    ['MAGE'] = true,
                    ['PRIEST'] = true,
                    ['ROGUE'] = true,
                    ['SHAMAN'] = true,
                    ['WARLOCK'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeFist] = {
                    ['DRUID'] = true,
                    ['HUNTER'] = true,
                    ['ROGUE'] = true,
                    ['SHAMAN'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeSword] = {
                    ['DEATHKNIGHT'] = true,
                    ['HUNTER'] = true,
                    ['MAGE'] = true,
                    ['PALADIN'] = true,
                    ['ROGUE'] = true,
                    ['WARLOCK'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubType2HSword] = {
                    ['DEATHKNIGHT'] = true,
                    ['HUNTER'] = true,
                    ['PALADIN'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeAxe] = {
                    ['DEATHKNIGHT'] = true,
                    ['HUNTER'] = true,
                    ['PALADIN'] = true,
                    ['ROGUE'] = true,
                    ['SHAMAN'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubType2HAxe] = {
                    ['DEATHKNIGHT'] = true,
                    ['HUNTER'] = true,
                    ['PALADIN'] = true,
                    ['SHAMAN'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeMace] = {
                    ['DEATHKNIGHT'] = true,
                    ['DRUID'] = true,
                    ['PALADIN'] = true,
                    ['PRIEST'] = true,
                    ['ROGUE'] = true,
                    ['SHAMAN'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubType2HMace] = {
                    ['DEATHKNIGHT'] = true,
                    ['DRUID'] = true,
                    ['PALADIN'] = true,
                    ['SHAMAN'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypePolearm] = {
                    ['DEATHKNIGHT'] = true,
                    ['DRUID'] = true,
                    ['HUNTER'] = true,
                    ['PALADIN'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeStaff] = {
                    ['DRUID'] = true,
                    ['HUNTER'] = true,
                    ['MAGE'] = true,
                    ['PRIEST'] = true,
                    ['SHAMAN'] = true,
                    ['WARLOCK'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeThrown] = {
                    ['HUNTER'] = true,
                    ['ROGUE'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeBow] = {
                    ['HUNTER'] = true,
                    ['ROGUE'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeCrossbow] = {
                    ['HUNTER'] = true,
                    ['ROGUE'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeGun] = {
                    ['HUNTER'] = true,
                    ['ROGUE'] = true,
                    ['WARRIOR'] = true,
                },
                [ScootsStats.weaponSubTypeWand] = {
                    ['MAGE'] = true,
                    ['PRIEST'] = true,
                    ['WARLOCK'] = true,
                },
            }
    
            local noOffhandWeapons = {
                ['DRUID'] = true,
                ['MAGE'] = true,
                ['PRIEST'] = true,
                ['WARLOCK'] = true
            }
        
            if(map[itemSubType] == nil) then
                allowWeaponType = true
            else
                for _, playerClass in pairs(ScootsStats.playerClasses) do
                    if(map[itemSubType][playerClass]) then
                        if(itemEquipLoc ~= 'INVTYPE_WEAPONOFFHAND' or noOffhandWeapons[playerClass] == nil) then
                            allowWeaponType = true
                            break
                        end
                    end
                end
            end
        end
        
        if(allowWeaponType == false) then
            return false
        end
    end
    
    return true
end

function ScootsStats.createFlyout()
    ScootsStats.frames.flyout = CreateFrame('Frame', 'ScootsStatsFlyout', UIParent)
    ScootsStats.frames.flyout:SetFrameStrata('HIGH')
    ScootsStats.frames.flyout:EnableMouse(true)
    
    ScootsStats.frames.flyout.borderTopLeft = ScootsStats.frames.flyout:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.flyout.borderTopLeft:SetTexture('Interface\\AddOns\\ScootsStats\\Textures\\Item-Flyout-TopLeft')
    ScootsStats.frames.flyout.borderTopLeft:SetPoint('BOTTOMRIGHT', ScootsStats.frames.flyout, 'TOPLEFT', 0, 0)
    ScootsStats.frames.flyout.borderTopLeft:SetSize(16, 16)
    
    ScootsStats.frames.flyout.borderTop = ScootsStats.frames.flyout:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.flyout.borderTop:SetTexture('Interface\\AddOns\\ScootsStats\\Textures\\Item-Flyout-Top', 'REPEAT')
    ScootsStats.frames.flyout.borderTop:SetPoint('BOTTOMLEFT', ScootsStats.frames.flyout, 'TOPLEFT', 0, 0)
    ScootsStats.frames.flyout.borderTop:SetPoint('BOTTOMRIGHT', ScootsStats.frames.flyout, 'TOPRIGHT', 0, 0)
    ScootsStats.frames.flyout.borderTop:SetHeight(16)
    ScootsStats.frames.flyout.borderTop:SetHorizTile(true)
    
    ScootsStats.frames.flyout.borderTopRight = ScootsStats.frames.flyout:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.flyout.borderTopRight:SetTexture('Interface\\AddOns\\ScootsStats\\Textures\\Item-Flyout-TopRight')
    ScootsStats.frames.flyout.borderTopRight:SetPoint('BOTTOMLEFT', ScootsStats.frames.flyout, 'TOPRIGHT', 0, 0)
    ScootsStats.frames.flyout.borderTopRight:SetSize(16, 16)
    
    ScootsStats.frames.flyout.borderRight = ScootsStats.frames.flyout:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.flyout.borderRight:SetTexture('Interface\\AddOns\\ScootsStats\\Textures\\Item-Flyout-Right', 'CLAMP', 'REPEAT')
    ScootsStats.frames.flyout.borderRight:SetPoint('TOPLEFT', ScootsStats.frames.flyout, 'TOPRIGHT', 0, 0)
    ScootsStats.frames.flyout.borderRight:SetPoint('BOTTOMLEFT', ScootsStats.frames.flyout, 'BOTTOMRIGHT', 0, 0)
    ScootsStats.frames.flyout.borderRight:SetWidth(16)
    ScootsStats.frames.flyout.borderRight:SetVertTile(true)
    
    ScootsStats.frames.flyout.borderBottomRight = ScootsStats.frames.flyout:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.flyout.borderBottomRight:SetTexture('Interface\\AddOns\\ScootsStats\\Textures\\Item-Flyout-BottomRight')
    ScootsStats.frames.flyout.borderBottomRight:SetPoint('TOPLEFT', ScootsStats.frames.flyout, 'BOTTOMRIGHT', 0, 0)
    ScootsStats.frames.flyout.borderBottomRight:SetSize(16, 16)
    
    ScootsStats.frames.flyout.borderBottom = ScootsStats.frames.flyout:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.flyout.borderBottom:SetTexture('Interface\\AddOns\\ScootsStats\\Textures\\Item-Flyout-Bottom', 'REPEAT')
    ScootsStats.frames.flyout.borderBottom:SetPoint('TOPLEFT', ScootsStats.frames.flyout, 'BOTTOMLEFT', 0, 0)
    ScootsStats.frames.flyout.borderBottom:SetPoint('TOPRIGHT', ScootsStats.frames.flyout, 'BOTTOMRIGHT', 0, 0)
    ScootsStats.frames.flyout.borderBottom:SetHeight(16)
    ScootsStats.frames.flyout.borderBottom:SetHorizTile(true)
    
    ScootsStats.frames.flyout.borderBottomLeft = ScootsStats.frames.flyout:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.flyout.borderBottomLeft:SetTexture('Interface\\AddOns\\ScootsStats\\Textures\\Item-Flyout-BottomLeft')
    ScootsStats.frames.flyout.borderBottomLeft:SetPoint('TOPRIGHT', ScootsStats.frames.flyout, 'BOTTOMLEFT', 0, 0)
    ScootsStats.frames.flyout.borderBottomLeft:SetSize(16, 16)
    
    ScootsStats.frames.flyout.borderLeft = ScootsStats.frames.flyout:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.flyout.borderLeft:SetTexture('Interface\\AddOns\\ScootsStats\\Textures\\Item-Flyout-Left', 'CLAMP', 'REPEAT')
    ScootsStats.frames.flyout.borderLeft:SetPoint('TOPRIGHT', ScootsStats.frames.flyout, 'TOPLEFT', 0, 0)
    ScootsStats.frames.flyout.borderLeft:SetPoint('BOTTOMRIGHT', ScootsStats.frames.flyout, 'BOTTOMLEFT', 0, 0)
    ScootsStats.frames.flyout.borderLeft:SetWidth(16)
    ScootsStats.frames.flyout.borderLeft:SetVertTile(true)
    
    ScootsStats.frames.flyout.background = ScootsStats.frames.flyout:CreateTexture(nil, 'BACKGROUND')
    ScootsStats.frames.flyout.background:SetTexture('Interface\\AddOns\\ScootsStats\\Textures\\Item-Flyout-Middle', 'REPEAT', 'REPEAT')
    ScootsStats.frames.flyout.background:SetAllPoints()
    ScootsStats.frames.flyout.background:SetHorizTile(true)
    ScootsStats.frames.flyout.background:SetVertTile(true)
    
    ScootsStats.frames.flyoutToAttune = CreateFrame('Frame', 'ScootsStatsFlyout-ToAttune', ScootsStats.frames.flyout)
    ScootsStats.frames.flyoutToAttune:SetFrameStrata('HIGH')
    ScootsStats.frames.flyoutToAttune:EnableMouse(true)
    ScootsStats.frames.flyoutToAttune:SetPoint('TOPLEFT', ScootsStats.frames.flyout, 'TOPLEFT', 5, 0 - 5)
    
    ScootsStats.frames.flyoutToAttune.label = ScootsStats.frames.flyoutToAttune:CreateFontString(nil, 'ARTWORK')
    ScootsStats.frames.flyoutToAttune.label:SetFontObject('GameFontHighlightSmall')
    ScootsStats.frames.flyoutToAttune.label:SetPoint('TOPLEFT', ScootsStats.frames.flyoutToAttune, 'TOPLEFT', 0, 0 - 4)
    ScootsStats.frames.flyoutToAttune.label:SetJustifyH('LEFT')
    ScootsStats.frames.flyoutToAttune.label:SetText('To attune: ')
    
    ScootsStats.frames.flyoutAttuned = CreateFrame('Frame', 'ScootsStatsFlyout-Attuned', ScootsStats.frames.flyout)
    ScootsStats.frames.flyoutAttuned:SetFrameStrata('HIGH')
    ScootsStats.frames.flyoutAttuned:EnableMouse(true)
    
    ScootsStats.frames.flyoutAttuned.label = ScootsStats.frames.flyoutAttuned:CreateFontString(nil, 'ARTWORK')
    ScootsStats.frames.flyoutAttuned.label:SetFontObject('GameFontHighlightSmall')
    ScootsStats.frames.flyoutAttuned.label:SetPoint('TOPLEFT', ScootsStats.frames.flyoutAttuned, 'TOPLEFT', 0, 0 - 4)
    ScootsStats.frames.flyoutAttuned.label:SetJustifyH('LEFT')
    ScootsStats.frames.flyoutAttuned.label:SetText('Attuned: ')
    
    ScootsStats.frames.flyoutNoAttune = CreateFrame('Frame', 'ScootsStatsFlyout-NoAttune', ScootsStats.frames.flyout)
    ScootsStats.frames.flyoutNoAttune:SetFrameStrata('HIGH')
    ScootsStats.frames.flyoutNoAttune:EnableMouse(true)
    
    ScootsStats.frames.flyoutNoAttune.label = ScootsStats.frames.flyoutNoAttune:CreateFontString(nil, 'ARTWORK')
    ScootsStats.frames.flyoutNoAttune.label:SetFontObject('GameFontHighlightSmall')
    ScootsStats.frames.flyoutNoAttune.label:SetPoint('TOPLEFT', ScootsStats.frames.flyoutNoAttune, 'TOPLEFT', 0, 0 - 4)
    ScootsStats.frames.flyoutNoAttune.label:SetJustifyH('LEFT')
    ScootsStats.frames.flyoutNoAttune.label:SetText('Can\'t attune: ')
    
    ScootsStats.frames.flyoutItems = {}
end