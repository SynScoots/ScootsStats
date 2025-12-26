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

local old_PaperDollFrameItemFlyout_Show = PaperDollFrameItemFlyout_Show
local old_PaperDollFrameItemFlyout_OnShow = PaperDollFrameItemFlyout_OnShow
local old_PaperDollFrameItemFlyout_Hide = PaperDollFrameItemFlyout_Hide
local old_PaperDollFrameItemFlyout_OnHide = PaperDollFrameItemFlyout_OnHide
local old_PaperDollFrameItemFlyout_OnUpdate = PaperDollFrameItemFlyout_OnUpdate
ScootsStats.equipmentManagerActive = false

PaperDollFrameItemFlyout_Show = function() end
PaperDollFrameItemFlyout_OnShow = function() end
PaperDollFrameItemFlyout_Hide = function() end
PaperDollFrameItemFlyout_OnHide = function() end
PaperDollFrameItemFlyout_OnUpdate = function() end

_G['GearManagerToggleButton']:HookScript('OnClick', function()
    ScootsStats.equipmentManagerActive = not ScootsStats.equipmentManagerActive
    
    if(ScootsStats.equipmentManagerActive) then
        PaperDollFrameItemFlyout_Show = old_PaperDollFrameItemFlyout_Show
        PaperDollFrameItemFlyout_OnShow = old_PaperDollFrameItemFlyout_OnShow
        PaperDollFrameItemFlyout_Hide = old_PaperDollFrameItemFlyout_Hide
        PaperDollFrameItemFlyout_OnHide = old_PaperDollFrameItemFlyout_OnHide
        PaperDollFrameItemFlyout_OnUpdate = old_PaperDollFrameItemFlyout_OnUpdate
    else
        PaperDollFrameItemFlyout_Show = function() end
        PaperDollFrameItemFlyout_OnShow = function() end
        PaperDollFrameItemFlyout_Hide = function() end
        PaperDollFrameItemFlyout_OnHide = function() end
        PaperDollFrameItemFlyout_OnUpdate = function() end
    end
end)

_G['PaperDollFrame']:HookScript('OnHide', function()
    ScootsStats.equipmentManagerActive = false
    PaperDollFrameItemFlyout_Show = function() end
    PaperDollFrameItemFlyout_OnShow = function() end
    PaperDollFrameItemFlyout_Hide = function() end
    PaperDollFrameItemFlyout_OnHide = function() end
    PaperDollFrameItemFlyout_OnUpdate = function() end
end)

function ScootsStats.flyoutWatcher(slot)
    if(ScootsStats.equipmentManagerActive ~= true) then
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
    
    if(#items.toAttune == 0 and #items.attuned == 0 and #items.noAttune == 0 and items.unequip == false) then
        ScootsStats.hideFlyout()
        return false
    end
    
    local itemIndex = 0
    local labelWidth = 0
    local innerHeight = 16
    local anchor = nil
    
    ScootsStats.frames.flyoutToAttune:Hide()
    ScootsStats.frames.flyoutAttuned:Hide()
    ScootsStats.frames.flyoutNoAttune:Hide()
    ScootsStats.frames.flyoutUnequip:Hide()
    
    if(#items.toAttune == 0) then
        innerHeight = innerHeight - 2
    else
        ScootsStats.frames.flyoutToAttune:Show()
        labelWidth = ScootsStats.frames.flyoutToAttune.label:GetWidth()
        anchor = ScootsStats.frames.flyoutToAttune
    end
    
    if(#items.attuned == 0) then
        innerHeight = innerHeight - 2
    else
        ScootsStats.frames.flyoutAttuned:Show()
        labelWidth = math.max(labelWidth, ScootsStats.frames.flyoutAttuned.label:GetWidth())
        
        if(anchor) then
            ScootsStats.frames.flyoutAttuned:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, 0 - 2)
        else
            ScootsStats.frames.flyoutAttuned:SetPoint('TOPLEFT', ScootsStats.frames.flyout, 'TOPLEFT', 5, 0 - 5)
        end
        
        anchor = ScootsStats.frames.flyoutAttuned
    end
    
    if(#items.noAttune == 0) then
        innerHeight = innerHeight - 2
    else
        ScootsStats.frames.flyoutNoAttune:Show()
        labelWidth = math.max(labelWidth, ScootsStats.frames.flyoutNoAttune.label:GetWidth())
        
        if(anchor) then
            ScootsStats.frames.flyoutNoAttune:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, 0 - 2)
        else
            ScootsStats.frames.flyoutNoAttune:SetPoint('TOPLEFT', ScootsStats.frames.flyout, 'TOPLEFT', 5, 0 - 5)
        end
        
        anchor = ScootsStats.frames.flyoutNoAttune
    end
    
    if(items.unequip == false) then
        innerHeight = innerHeight - 2
    else
        ScootsStats.frames.flyoutUnequip:Show()
        labelWidth = math.max(labelWidth, ScootsStats.frames.flyoutUnequip.label:GetWidth())
        
        if(anchor) then
            ScootsStats.frames.flyoutUnequip:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, 0 - 2)
        else
            ScootsStats.frames.flyoutUnequip:SetPoint('TOPLEFT', ScootsStats.frames.flyout, 'TOPLEFT', 5, 0 - 5)
        end
        
        anchor = ScootsStats.frames.flyoutUnequip
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
    
    ScootsStats.frames.flyoutUnequip:SetSize(0, 0)
    if(items.unequip == true) then
        itemIndex = itemIndex + 1
        local button = ScootsStats.getFlyoutItemButton(itemIndex, nil)
        ScootsStats.attachFlyoutItemButtonToParent(labelWidth, button, 0, ScootsStats.frames.flyoutUnequip)
        
        innerHeight = innerHeight + ScootsStats.frames.flyoutUnequip:GetHeight()
    end
    
    ScootsStats.frames.flyout:SetHeight(innerHeight)
    
    ScootsStats.frames.flyout:SetWidth(math.max(
        ScootsStats.frames.flyoutToAttune:GetWidth(),
        ScootsStats.frames.flyoutAttuned:GetWidth(),
        ScootsStats.frames.flyoutNoAttune:GetWidth(),
        ScootsStats.frames.flyoutUnequip:GetWidth()
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
    
    if(itemArray == nil) then
        button.quality:Hide()
        
        button:SetNormalTexture('Interface\\PaperDollInfoFrame\\UI-GearManager-ItemIntoBag')
        
        button:SetScript('OnEnter', nil)
        
        button:SetScript('OnMouseUp', function(self, button)
            if(IsAltKeyDown() and button == 'LeftButton') then
                PickupInventoryItem(ScootsStats.slotIdMap[ScootsStats.currentFlyout])
                EquipmentManager_PutItemInInventory({
                    ['type'] = UNEQUIP_ITEM,
                    ['invSlot'] = ScootsStats.slotIdMap[ScootsStats.currentFlyout],
                })
            end
        end)
    else
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
        
        button.quality:Show()
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
    end
    
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
            {
                ['key'] = 'weaponSubTypeIdol',
                ['id'] = 50456,
                ['index'] = 7,
                ['fallback'] = 'Idols',
            },
            {
                ['key'] = 'weaponSubTypeLibram',
                ['id'] = 50460,
                ['index'] = 7,
                ['fallback'] = 'Librams',
            },
            {
                ['key'] = 'weaponSubTypeTotem',
                ['id'] = 50458,
                ['index'] = 7,
                ['fallback'] = 'Totems',
            },
            {
                ['key'] = 'weaponSubTypeSigil',
                ['id'] = 50462,
                ['index'] = 7,
                ['fallback'] = 'Sigils',
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
        ['unequip'] = false,
        ['toAttune'] = {},
        ['attuned'] = {},
        ['noAttune'] = {},
    }
    
    if(GetInventoryItemLink('player', ScootsStats.slotIdMap[ScootsStats.currentFlyout])) then
        items.unequip = true
    end
    
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
                elseif(itemSubType == ScootsStats.weaponSubTypeIdol) then
                    if(playerClass == 'DRUID') then
                        allowArmourType = true
                        break
                    end
                elseif(itemSubType == ScootsStats.weaponSubTypeLibram) then
                    if(playerClass == 'PALADIN') then
                        allowArmourType = true
                        break
                    end
                elseif(itemSubType == ScootsStats.weaponSubTypeTotem) then
                    if(playerClass == 'SHAMAN') then
                        allowArmourType = true
                        break
                    end
                elseif(itemSubType == ScootsStats.weaponSubTypeSigil) then
                    if(playerClass == 'DEATHKNIGHT') then
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
                [ScootsStats.weaponSubTypeIdol] = {
                    ['DRUID'] = true,
                },
                [ScootsStats.weaponSubTypeLibram] = {
                    ['PALADIN'] = true,
                },
                [ScootsStats.weaponSubTypeTotem] = {
                    ['SHAMAN'] = true,
                },
                [ScootsStats.weaponSubTypeSigil] = {
                    ['DEATHKNIGHT'] = true,
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
    
    ScootsStats.frames.flyoutUnequip = CreateFrame('Frame', 'ScootsStatsFlyout-Unequip', ScootsStats.frames.flyout)
    ScootsStats.frames.flyoutUnequip:SetFrameStrata('HIGH')
    ScootsStats.frames.flyoutUnequip:EnableMouse(true)
    
    ScootsStats.frames.flyoutUnequip.label = ScootsStats.frames.flyoutUnequip:CreateFontString(nil, 'ARTWORK')
    ScootsStats.frames.flyoutUnequip.label:SetFontObject('GameFontHighlightSmall')
    ScootsStats.frames.flyoutUnequip.label:SetPoint('TOPLEFT', ScootsStats.frames.flyoutUnequip, 'TOPLEFT', 0, 0 - 4)
    ScootsStats.frames.flyoutUnequip.label:SetJustifyH('LEFT')
    ScootsStats.frames.flyoutUnequip.label:SetText('Unequip: ')
    
    ScootsStats.frames.flyoutItems = {}
end

for slot, _ in pairs(ScootsStats.inventoryFrames) do
    _G[slot]:SetScript('OnUpdate', ScootsStats.flyoutWatcher)
end