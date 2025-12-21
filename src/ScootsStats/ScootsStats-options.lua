ScootsStats.frames.options = CreateFrame('Frame', 'ScootsStats-Options', UIParent)
ScootsStats.frames.options.name = 'ScootsStats'
InterfaceOptions_AddCategory(ScootsStats.frames.options)

ScootsStats.frames.optionsFields = CreateFrame('Frame', 'ScootsStats-Options-FieldVisibility', UIParent)
ScootsStats.frames.optionsFields.parent = 'ScootsStats'
ScootsStats.frames.optionsFields.name = 'Field Visibility'
InterfaceOptions_AddCategory(ScootsStats.frames.optionsFields)

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
    
    for _, playerClass in pairs(ScootsStats.playerClasses) do
        if(playerClass == 'DEATHKNIGHT'
        or playerClass == 'DRUID'
        or playerClass == 'HUNTER'
        or playerClass == 'PALADIN'
        or playerClass == 'ROGUE'
        or playerClass == 'SHAMAN'
        or playerClass == 'WARRIOR') then
            for key, _ in pairs(ScootsStats.options.fields.melee) do
                ScootsStats.options.fields.melee[key] = true
            end
        end
        
        if(playerClass == 'HUNTER'
        or playerClass == 'ROGUE'
        or playerClass == 'WARRIOR') then
            for key, _ in pairs(ScootsStats.options.fields.ranged) do
                ScootsStats.options.fields.ranged[key] = true
            end
        end
        
        if(playerClass == 'DRUID'
        or playerClass == 'MAGE'
        or playerClass == 'PALADIN'
        or playerClass == 'PRIEST'
        or playerClass == 'SHAMAN'
        or playerClass == 'WARLOCK') then
            for key, _ in pairs(ScootsStats.options.fields.spells) do
                ScootsStats.options.fields.spells[key] = true
            end
        end
    end
    
    if(_G['SCOOTSSTATS_OPTIONS']) then
        if(_G['SCOOTSSTATS_OPTIONS'].fields == nil) then
            _G['SCOOTSSTATS_OPTIONS'] = {
                ['fields'] = _G['SCOOTSSTATS_OPTIONS'],
            }
        end
    
        for optionName, _ in pairs(ScootsStats.options) do
            if(optionName ~= 'fields' and _G['SCOOTSSTATS_OPTIONS'][optionName] ~= nil) then
                ScootsStats.options[optionName] = _G['SCOOTSSTATS_OPTIONS'][optionName]
            end
        end
    
        for sectionKey, _ in pairs(ScootsStats.options.fields) do
            for key, _ in pairs(ScootsStats.options.fields[sectionKey]) do
                if(_G['SCOOTSSTATS_OPTIONS'].fields[sectionKey][key] ~= nil) then
                    ScootsStats.options.fields[sectionKey][key] = _G['SCOOTSSTATS_OPTIONS'].fields[sectionKey][key]
                end
            end
        end
    end
    
    ScootsStats.optionsLoaded = true
end

ScootsStats.openOptionsPanel = function()
    InterfaceOptionsFrame_OpenToCategory(ScootsStats.frames.options)
end

ScootsStats.frames.options:HookScript('OnShow', function(frame)
    if(frame.rendered ~= nil) then
        return nil
    end
    
    frame.rendered = true

    local title = frame:CreateFontString('ScootsStats-Options-Main-Title', 'OVERLAY', 'GameFontNormalLarge')
    title:SetPoint('TOPLEFT', frame, 'TOPLEFT', 16, -10)
    title:SetText('ScootsStats')
    
    local version = frame:CreateFontString('ScootsStats-Options-Main-Version', 'OVERLAY', 'GameFontHighlight')
    version:SetPoint('BOTTOMLEFT', title, 'BOTTOMRIGHT', 5, 1)
    version:SetText(ScootsStats.version)
    
    local fieldsButton = CreateFrame('Button', 'ScootsStats-Options-Main-FieldsButton', frame, 'UIPanelButtonTemplate')
    fieldsButton:SetText('Field Visibility')
    fieldsButton:SetSize(120, 24)
    fieldsButton:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -10)
	fieldsButton:SetScript('OnClick', function()
        InterfaceOptionsFrame_OpenToCategory(ScootsStats.frames.optionsFields)
    end)
    
    if(ScootsStats.prestiged == true) then
        local mergedPrestigeCheck = CreateFrame('CheckButton', 'ScootsStats-Option-PrestigeBehaviour', frame, 'UICheckButtonTemplate')
        mergedPrestigeCheck:SetSize(24, 24)
        mergedPrestigeCheck:SetPoint('TOPLEFT', fieldsButton, 'TOPLEFT', 0, -30)
        mergedPrestigeCheck:SetChecked(ScootsStats.options.mergedPrestige)
        
        _G[mergedPrestigeCheck:GetName() .. 'Text']:SetText('Merged prestige stats')
        _G[mergedPrestigeCheck:GetName() .. 'Text']:ClearAllPoints()
        _G[mergedPrestigeCheck:GetName() .. 'Text']:SetPoint('TOPLEFT', mergedPrestigeCheck, 'TOPRIGHT', -2, -5)
        
        mergedPrestigeCheck:SetHitRectInsets(0, 0 - _G[mergedPrestigeCheck:GetName() .. 'Text']:GetWidth(), 0, 0)
        
        mergedPrestigeCheck:SetScript('OnClick', function()
            ScootsStats.options.mergedPrestige = (mergedPrestigeCheck:GetChecked() == 1)
            ScootsStats.updateStats()
        end)
        
        mergedPrestigeCheck:SetScript('OnEnter', function()
            GameTooltip:SetOwner(mergedPrestigeCheck, 'ANCHOR_TOPLEFT')
            GameTooltip:SetText('If enabled, prestige stats will show what value you will have after your next prestige instead of only what you have gained this cycle.', nil, nil, nil, nil, 1)
        end)
        
        mergedPrestigeCheck:SetScript('OnLeave', GameTooltip_Hide)
    end
end)

ScootsStats.frames.optionsFields:HookScript('OnShow', function(frame)
    if(frame.rendered ~= nil) then
        return nil
    end
    
    frame.rendered = true
    
    local scrollFrame = CreateFrame('ScrollFrame', 'ScootsStats-Options-Fields-ScrollFrame', frame, 'UIPanelScrollFrameTemplate')
    scrollFrame:SetWidth(663)
    
    local scrollChild = CreateFrame('Frame', 'ScootsStats-Options-Fields-ScrollChild', scrollFrame)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    
    local scrollBarName = scrollFrame:GetName()
    local scrollBar = _G[scrollBarName .. 'ScrollBar']
    local scrollUpButton = _G[scrollBarName .. 'ScrollBarScrollUpButton']
    local scrollDownButton = _G[scrollBarName .. 'ScrollBarScrollDownButton']

    scrollUpButton:ClearAllPoints()
    scrollUpButton:SetPoint('TOPRIGHT', scrollFrame, 'TOPRIGHT', -2, -2)

    scrollDownButton:ClearAllPoints()
    scrollDownButton:SetPoint('BOTTOMRIGHT', scrollFrame, 'BOTTOMRIGHT', -2, 2)

    scrollBar:ClearAllPoints()
    scrollBar:SetPoint('TOP', scrollUpButton, 'BOTTOM', 0, -2)
    scrollBar:SetPoint('BOTTOM', scrollDownButton, 'TOP', 0, 2)

    scrollFrame:SetScrollChild(scrollChild)
    scrollFrame:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, -5)
    scrollFrame:SetHeight(419)

    local title = scrollChild:CreateFontString('ScootsStats-Options-Fields-Title', 'OVERLAY', 'GameFontNormalLarge')
    title:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 16, -10)
    title:SetText('ScootsStats')
    
    local version = scrollChild:CreateFontString('ScootsStats-Options-Fields-Version', 'OVERLAY', 'GameFontHighlight')
    version:SetPoint('BOTTOMLEFT', title, 'BOTTOMRIGHT', 5, 1)
    version:SetText(ScootsStats.version)
    
    local map = {
        {
            ['key'] = 'Miscellaneous',
            ['title'] = 'Miscellaneous',
            ['rows'] = {
                {'Attune (Equip)', 'misc', 'attuning'},
                {'Attune (Inventory)', 'misc', 'attuninginv', ScootsStats.prestiged == true and ScootsStats.attuneMastery > 0},
                {'Current Speed', 'misc', 'movespeed'},
            }
        },
        {
            ['key'] = 'BaseStats',
            ['title'] = 'Base Stats',
            ['rows'] = {
                {'Strength', 'base', 'strength'},
                {'Agility', 'base', 'agility'},
                {'Stamina', 'base', 'stamina'},
                {'Intellect', 'base', 'intellect'},
                {'Spirit', 'base', 'spirit'},
            },
        },
        {
            ['key'] = 'Melee',
            ['title'] = 'Melee',
            ['rows'] = {
                {'Damage', 'melee', 'damage'},
                {'Speed', 'melee', 'speed'},
                {'Power', 'melee', 'power'},
                {'Hit Rating', 'melee', 'hit'},
                {'Crit Chance', 'melee', 'crit'},
                {'Expertise', 'melee', 'expertise'},
            },
        },
        {
            ['key'] = 'Ranged',
            ['title'] = 'Ranged',
            ['rows'] = {
                {'Damage', 'ranged', 'damage'},
                {'Speed', 'ranged', 'speed'},
                {'Power', 'ranged', 'power'},
                {'Hit Rating', 'ranged', 'hit'},
                {'Crit Chance', 'ranged', 'crit'},
            },
        },
        {
            ['key'] = 'Spells',
            ['title'] = 'Spells',
            ['rows'] = {
                {'Bonus Damage', 'spells', 'damage'},
                {'Bonus Healing', 'spells', 'healing'},
                {'Hit Rating', 'spells', 'hit'},
                {'Crit Chance', 'spells', 'crit'},
                {'Haste Rating', 'spells', 'haste'},
                {'Mana Regen', 'spells', 'regen'},
            },
        },
        {
            ['key'] = 'Defences',
            ['title'] = 'Defences',
            ['rows'] = {
                {'Armor', 'defences', 'armour'},
                {'Defense', 'defences', 'defense'},
                {'Dodge', 'defences', 'dodge'},
                {'Parry', 'defences', 'parry'},
                {'Block', 'defences', 'block'},
                {'Resilience', 'defences', 'resilience'},
            },
        },
        {
            ['key'] = 'Prestige',
            ['title'] = 'Prestige',
            ['rows'] = {
                {'Character Attunes', 'prestige', 'charattunes'},
                {'Account Attunes', 'prestige', 'accattunes'},
                {'Forge Power', 'prestige', 'forgepower'},
                {'BoP Coercion', 'prestige', 'lootcoercion'},
                {'BoE Coercion', 'prestige', 'affixcoercion'},
                {'Attune Mastery', 'prestige', 'bonusexp'},
                {'Lucky Loot', 'prestige', 'luckyloot'},
            },
        },
    }
    
    local frameHeight = title:GetHeight() + 20
    local prevGroup = title
    local groupFrames = {}
    
    for _, group in ipairs(map) do
        local groupFrame = CreateFrame('Frame', 'ScootsStats-Options-FieldVisibility-' .. group.key, scrollChild)
        groupFrame:SetPoint('TOPLEFT', prevGroup, 'BOTTOMLEFT', 0, -10)
        groupFrame:SetWidth(scrollFrame:GetWidth() - 32)
        groupFrame:SetBackdrop({
            bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
            edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {
                left = 5,
                right = 5,
                top = 5,
                bottom = 5,
            },
        })
        groupFrame:SetBackdropColor(0, 0, 0, 0.2)
        groupFrame:SetBackdropBorderColor(1, 1, 1, 0.5)

        local groupTitle = groupFrame:CreateFontString('ScootsStats-Options-Fields-Version', 'OVERLAY', 'GameFontHighlight')
        groupTitle:SetPoint('TOPLEFT', groupFrame, 'TOPLEFT', 16, -10)
        groupTitle:SetText(group.title)
        
        local groupHeight = groupTitle:GetHeight() + 20
        
        local prevField = groupTitle
        for _, row in ipairs(group.rows) do
            local fieldToggle = CreateFrame('CheckButton', 'ScootsStats-Option-' .. group.key .. '-' .. row[3], groupFrame, 'UICheckButtonTemplate')
            fieldToggle:SetSize(24, 24)
            fieldToggle:SetPoint('TOPLEFT', prevField, 'BOTTOMLEFT', 0, 0)
            fieldToggle:SetChecked(ScootsStats.options.fields[row[2]][row[3]])
            
            _G[fieldToggle:GetName() .. 'Text']:SetText(row[1])
            _G[fieldToggle:GetName() .. 'Text']:ClearAllPoints()
            _G[fieldToggle:GetName() .. 'Text']:SetPoint('TOPLEFT', fieldToggle, 'TOPRIGHT', -3, -6)
            
            fieldToggle:SetHitRectInsets(0, 0 - _G[fieldToggle:GetName() .. 'Text']:GetWidth(), 0, 0)
            
            fieldToggle:SetScript('OnClick', function()
                ScootsStats.options.fields[row[2]][row[3]] = (fieldToggle:GetChecked() == 1)
                ScootsStats.updateStats()
            end)
            
            groupHeight = groupHeight + fieldToggle:GetHeight()
            
            prevField = fieldToggle
        end
        
        groupFrame:SetHeight(groupHeight)
        frameHeight = frameHeight + groupHeight + 10
        
        prevGroup = groupFrame
        table.insert(groupFrames, groupFrame)
    end
    
    scrollChild:SetHeight(frameHeight)
    
    if(frameHeight <= scrollFrame:GetHeight()) then
        scrollBar:Hide()
    else
        scrollBar:Show()
    
        for _, groupFrame in pairs(groupFrames) do
            groupFrame:SetWidth(groupFrame:GetWidth() - scrollBar:GetWidth())
        end
    end
end)