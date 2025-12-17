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
	ScootsStats.frames.optionsButton:SetScript('OnClick', ScootsStats.openOptionsPanel)
    
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
        ScootsStats.forgePower = GetCustomGameData(29, 1494)
        ScootsStats.bopCoercion = GetCustomGameData(29, 1492)
        ScootsStats.boeCoercion = GetCustomGameData(29, 1493)
        ScootsStats.attuneMastery = GetCustomGameData(29, 1500)
        ScootsStats.luckyLoot = GetCustomGameData(29, 1557)
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
                    ['display'] = ScootsStats.setStatAccountAttunes,
                    ['onEnter'] = ScootsStats.enterAccountAttunes,
                    ['option'] = {'prestige', 'accattunes'}
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
                },
                {
                    ['display'] = ScootsStats.setStatLuckyLoot,
                    ['onEnter'] = ScootsStats.enterLuckyLoot,
                    ['option'] = {'prestige', 'luckyloot'},
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
                if(ScootsStats.options.fields[row.option[1]][row.option[2]] ~= true) then
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

ScootsStats.setStatAccountAttunes = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    PaperDollFrame_SetLabelAndText(frame, 'Acc. Attunes', string.format('%.2f', (100 / ScootsStats.totalAccountAttunes) * ScootsStats.accountAttunes) .. '%')
end

ScootsStats.enterAccountAttunes = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Account Attunes', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('This shows your progress towards attuning all possible items in the game.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(tostring(ScootsStats.accountAttunes) .. ' of ' .. tostring(ScootsStats.totalAccountAttunes) .. ' items attuned.', nil, nil, nil, true)
    GameTooltip:Show()
end

ScootsStats.setStatForgePower = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    local effect = ((ScootsStats.accountAttunesTF / 100) ^ 0.7) + ((ScootsStats.accountAttunesWF / 15) ^ 0.7) + (ScootsStats.accountAttunesLF ^ 0.7)
    
    if(ScootsStats.prestiged == true and ScootsStats.options.mergedPrestige == true) then
        effect = effect + ScootsStats.forgePower
    end
    
    PaperDollFrame_SetLabelAndText(frame, 'Forge Power', string.format('%.2f', effect) .. '%')
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
    
    if(ScootsStats.prestiged == true) then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            'Current effect',
            string.format('%.2f', ScootsStats.forgePower) .. '%',
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            HIGHLIGHT_FONT_COLOR.r,
            HIGHLIGHT_FONT_COLOR.g,
            HIGHLIGHT_FONT_COLOR.b
        )
        
        local earnedThisCycle = ((ScootsStats.accountAttunesTF / 100) ^ 0.7) + ((ScootsStats.accountAttunesWF / 15) ^ 0.7) + (ScootsStats.accountAttunesLF ^ 0.7)
        if(ScootsStats.options.mergedPrestige == true) then
            GameTooltip:AddDoubleLine(
                'Earned this cycle',
                string.format('%.2f', earnedThisCycle) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        else
            GameTooltip:AddDoubleLine(
                'Effect next cycle',
                string.format('%.2f', earnedThisCycle + ScootsStats.forgePower) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        end
    end
    
    GameTooltip:Show()
end

ScootsStats.setStatLootCoercion = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    local effect = (100 / ScootsStats.totalAccountAttunes) * ScootsStats.accountAttunes
    
    if(ScootsStats.prestiged == true and ScootsStats.options.mergedPrestige == true) then
        effect = (1 - ((1 - (ScootsStats.bopCoercion / 100)) * (1 - (effect / 100)))) * 100
    end
    
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
    
    if(ScootsStats.prestiged == true) then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            'Current effect',
            string.format('%.2f', ScootsStats.bopCoercion) .. '%',
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            HIGHLIGHT_FONT_COLOR.r,
            HIGHLIGHT_FONT_COLOR.g,
            HIGHLIGHT_FONT_COLOR.b
        )
        
        local earnedThisCycle = (100 / ScootsStats.totalAccountAttunes) * ScootsStats.accountAttunes
        if(ScootsStats.options.mergedPrestige == true) then
            GameTooltip:AddDoubleLine(
                'Earned this cycle',
                string.format('%.2f', earnedThisCycle) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        else
            GameTooltip:AddDoubleLine(
                'Effect next cycle',
                string.format('%.2f', (1 - ((1 - (ScootsStats.bopCoercion / 100)) * (1 - (earnedThisCycle / 100)))) * 100) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        end
    end
    
    GameTooltip:Show()
end

ScootsStats.setStatAffixCoercion = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    if(ScootsStats.totalAccountAffixes ~= nil) then
        local effect = ((100 / ScootsStats.totalAccountAffixes) * ScootsStats.attunedAffixes) / 4
    
        if(ScootsStats.prestiged == true and ScootsStats.options.mergedPrestige == true) then
            effect = (1 - ((1 - (ScootsStats.boeCoercion / 100)) * (1 - (effect / 100)))) * 100
        end
        
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
    
    if(ScootsStats.prestiged == true) then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            'Current effect',
            string.format('%.2f', ScootsStats.boeCoercion) .. '%',
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            HIGHLIGHT_FONT_COLOR.r,
            HIGHLIGHT_FONT_COLOR.g,
            HIGHLIGHT_FONT_COLOR.b
        )
        
        local earnedThisCycle = ((100 / ScootsStats.totalAccountAffixes) * ScootsStats.attunedAffixes) / 4
        if(ScootsStats.options.mergedPrestige == true) then
            GameTooltip:AddDoubleLine(
                'Earned this cycle',
                string.format('%.2f', earnedThisCycle) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        else
            GameTooltip:AddDoubleLine(
                'Effect next cycle',
                string.format('%.2f', (1 - ((1 - (ScootsStats.boeCoercion / 100)) * (1 - (earnedThisCycle / 100)))) * 100) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        end
    end
    
    GameTooltip:Show()
end

ScootsStats.setStatBonusExp = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    local effect = ScootsStats.bonusExpEffect
    
    if(ScootsStats.prestiged == true and ScootsStats.options.mergedPrestige == true) then
        effect = effect + ScootsStats.attuneMastery
    end

    PaperDollFrame_SetLabelAndText(frame, 'Attune Mastery', string.format('%.2f', effect) .. '%')
end

ScootsStats.enterBonusExp = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Attune Mastery', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('After prestige, you will be able to attune items in your inventory at this effectiveness.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Increased by attuning lightforged items with an item level above 200.', nil, nil, nil, true)
    GameTooltip:AddLine('Higher item levels yield higher effect.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    local s = 's'
    if(ScootsStats.highLevelLightForges == 1) then
        s = ''
    end
    GameTooltip:AddLine(ScootsStats.highLevelLightForges .. ' high item level lightforged attune' .. s .. '.')
    
    if(ScootsStats.prestiged == true) then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            'Current effect',
            string.format('%.2f', ScootsStats.attuneMastery) .. '%',
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            HIGHLIGHT_FONT_COLOR.r,
            HIGHLIGHT_FONT_COLOR.g,
            HIGHLIGHT_FONT_COLOR.b
        )
        
        if(ScootsStats.options.mergedPrestige == true) then
            GameTooltip:AddDoubleLine(
                'Earned this cycle',
                string.format('%.2f', ScootsStats.bonusExpEffect) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        else
            GameTooltip:AddDoubleLine(
                'Effect next cycle',
                string.format('%.2f', ScootsStats.bonusExpEffect + ScootsStats.attuneMastery) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        end
    end
    
    GameTooltip:Show()
end

ScootsStats.setStatLuckyLoot = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    local effect = ((100 / ScootsStats.totalAccountAttunes) * ScootsStats.accountAttunes) / 2
    
    if(ScootsStats.prestiged == true and ScootsStats.options.mergedPrestige == true) then
        effect = effect + ScootsStats.luckyLoot
    end
    
    PaperDollFrame_SetLabelAndText(frame, 'Lucky Loot', string.format('%.2f', effect) .. '%')
end

ScootsStats.enterLuckyLoot = function(frame)
    if(ScootsStats.queuedAttunedUpdate) then
        ScootsStats.countAttunes()
    end
    
    GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Lucky Loot', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:AddLine('After prestige, if a monster has a chance to drop from a pool of items and fails to do so, you will have this chance to roll for that pool of items again.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('Equal to your total account attunes relative to the total number of attunable items in the game, divided by two.', nil, nil, nil, true)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(ScootsStats.accountAttunes .. ' of ' .. ScootsStats.totalAccountAttunes .. ' items attuned.')
    
    if(ScootsStats.prestiged == true) then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            'Current effect',
            string.format('%.2f', ScootsStats.luckyLoot) .. '%',
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            HIGHLIGHT_FONT_COLOR.r,
            HIGHLIGHT_FONT_COLOR.g,
            HIGHLIGHT_FONT_COLOR.b
        )
        
        local earnedThisCycle = ((100 / ScootsStats.totalAccountAttunes) * ScootsStats.accountAttunes) / 2
        if(ScootsStats.options.mergedPrestige == true) then
            GameTooltip:AddDoubleLine(
                'Earned this cycle',
                string.format('%.2f', earnedThisCycle) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        else
            GameTooltip:AddDoubleLine(
                'Effect next cycle',
                string.format('%.2f', earnedThisCycle + ScootsStats.luckyLoot) .. '%',
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b
            )
        end
    end
    
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
            
            if(text == ITEM_SOULBOUND or text == ITEM_BIND_ON_PICKUP) then
                ScootsStats.frames.tooltip:Hide()
                return false
            end
        end
    end
    
    ScootsStats.frames.tooltip:Hide()
    return true
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