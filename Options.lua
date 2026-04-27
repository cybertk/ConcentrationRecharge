local _, ns = ...

local Options = {}
ns.Options = Options

local Util = ns.Util
local CharacterStore = ns.CharacterStore

-- Character management frame
local function CreateCharacterManagementFrame(parent)
	local frame = CreateFrame("Frame", nil, parent, "InsetFrameTemplate")

	-- Create scroll container
	local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
	scrollBar:SetPoint("TOPRIGHT", -10, -5)
	scrollBar:SetPoint("BOTTOMRIGHT", -10, 5)

	local scrollBox = CreateFrame("Frame", nil, frame, "WowScrollBoxList")
	scrollBox:SetPoint("TOPLEFT", 5, -5)
	scrollBox:SetPoint("BOTTOMRIGHT", scrollBar, "BOTTOMLEFT", -3, 0)

	-- Helper function to create enable/disable button
	local function SetEnableButton(element)
		element.EnableButton = CreateFrame("Button", nil, element)
		element.EnableButton:SetNormalAtlas("common-icon-checkmark")
		element.EnableButton:SetPoint("TOPLEFT", 8, -2.5)
		element.EnableButton:SetSize(15, 15)

		element.EnableButton:SetScript("OnClick", function()
			local store = CharacterStore.Get()
			local character = store[element.characterGUID]
			if character then
				character.enabled = not character.enabled
				element:UpdateVisuals()
				Util:Debug("Toggled character:", character.name, "enabled:", character.enabled)
			end
		end)

		element.EnableButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(element.EnableButton, "ANCHOR_RIGHT")
			local store = CharacterStore.Get()
			local character = store[element.characterGUID]
			if character and character.enabled then
				GameTooltip:SetText("Hide character from tracking")
			else
				GameTooltip:SetText("Show character in tracking")
			end
			GameTooltip:Show()
		end)

		element.EnableButton:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end

	-- Helper function to create delete button
	local function SetDeleteButton(element)
		element.DeleteButton = CreateFrame("Button", nil, element)
		element.DeleteButton:SetNormalAtlas("transmog-icon-remove")
		element.DeleteButton:SetPoint("TOPRIGHT", -5, -2.5)
		element.DeleteButton:SetSize(15, 15)

		element.DeleteButton:SetScript("OnClick", function()
			local store = CharacterStore.Get()
			local character = store[element.characterGUID]
			if character then
				-- Confirm deletion
				StaticPopup_Show("CONCENTRATION_DELETE_CHARACTER", character.name, nil, {
					characterGUID = element.characterGUID,
					updateFunction = function()
						frame:UpdateList()
					end,
				})
			end
		end)

		element.DeleteButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(element.DeleteButton, "ANCHOR_RIGHT")
			GameTooltip:SetText("Delete character data")
			GameTooltip:AddLine("This will permanently remove all profession concentration data for this character.", 1, 1, 1, true)
			GameTooltip:Show()
		end)

		element.DeleteButton:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end

	-- Create character list view
	local view = CreateScrollBoxListLinearView()
	view:SetElementExtent(24)
	view:SetElementInitializer("Button", function(element, characterData)
		element:SetPushedTextOffset(0, 0)
		element:SetHighlightAtlas("search-highlight")
		element:SetNormalFontObject(GameFontHighlight)

		element.characterGUID = characterData.GUID

		-- Initialize buttons if needed
		if not element.EnableButton then
			SetEnableButton(element)
			SetDeleteButton(element)
		end

		-- Set character text with class color
		local displayName = characterData.name
		if characterData.realmName and characterData.realmName ~= GetRealmName() then
			displayName = displayName .. "-" .. characterData.realmName
		end

		element:SetText(displayName)
		element:GetFontString():SetPoint("LEFT", 30, 0)
		element:GetFontString():SetPoint("RIGHT", -25, 0)
		element:GetFontString():SetJustifyH("LEFT")

		-- Set class color
		if characterData.class then
			local classColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[characterData.class]
			if classColor then
				element:GetFontString():SetTextColor(classColor.r, classColor.g, classColor.b)
			else
				element:GetFontString():SetTextColor(1, 1, 1)
			end
		else
			element:GetFontString():SetTextColor(1, 1, 1)
		end

		-- Update visual function
		element.UpdateVisuals = function()
			local store = CharacterStore.Get()
			local character = store[element.characterGUID]
			if character then
				if character.enabled then
					element.EnableButton:GetNormalTexture():SetVertexColor(0, 1, 0) -- Green for enabled
					element.EnableButton:GetNormalTexture():SetAlpha(1)
				else
					element.EnableButton:GetNormalTexture():SetVertexColor(1, 0, 0) -- Red for disabled
					element.EnableButton:GetNormalTexture():SetAlpha(0.7)
				end
			end
		end

		-- Hide delete button for current character
		element.DeleteButton:SetShown(characterData.GUID ~= UnitGUID("player"))

		element:UpdateVisuals()
	end)

	ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)

	-- Update list function
	function frame:UpdateList()
		local store = CharacterStore.Get()
		if not store then
			return
		end

		local characters = {}
		for guid, character in pairs(store) do
			if type(character) == "table" and character.name then
				table.insert(characters, character)
			end
		end

		-- Sort by name
		table.sort(characters, function(a, b)
			if a.realmName == b.realmName then
				return a.name < b.name
			else
				return (a.realmName or "") < (b.realmName or "")
			end
		end)

		scrollBox:SetDataProvider(CreateDataProvider(characters), true)
	end

	-- Update list when shown
	frame:SetScript("OnShow", function()
		frame:UpdateList()
	end)

	return frame
end

-- Static popup for character deletion confirmation
StaticPopupDialogs["CONCENTRATION_DELETE_CHARACTER"] = {
	text = "Are you sure you want to delete character data for %s?\n\nThis action cannot be undone.",
	button1 = "Delete",
	button2 = "Cancel",
	OnAccept = function(self, data)
		local store = CharacterStore.Get()
		if store and store:RemoveCharacter(data.characterGUID) then
			Util:Debug("Character deleted via options")
			if data.updateFunction then
				data.updateFunction()
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- Initialize options
function Options:Initialize()
	local optionsFrame = CreateFrame("Frame")
	optionsFrame:Hide()

	-- Title
	local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Concentration Recharge")

	-- Version info
	local version = C_AddOns.GetAddOnMetadata("ConcentrationRecharge", "Version") or "Unknown"
	local versionText = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	versionText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	versionText:SetText("Version: " .. version)

	-- Character management section
	local characterHeader = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	characterHeader:SetPoint("TOPLEFT", versionText, "BOTTOMLEFT", 0, -20)
	characterHeader:SetText("Character Management")

	local characterDescription = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	characterDescription:SetPoint("TOPLEFT", characterHeader, "BOTTOMLEFT", 0, -8)
	characterDescription:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", -16, 0)
	characterDescription:SetText(
		"Manage which characters are included in concentration tracking. Click the checkmark to enable/disable, or the X to delete character data."
	)
	characterDescription:SetJustifyH("LEFT")
	characterDescription:SetWordWrap(true)
	characterDescription:SetHeight(40)

	-- Character management frame
	local characterFrame = CreateCharacterManagementFrame(optionsFrame)
	characterFrame:SetPoint("TOPLEFT", characterDescription, "BOTTOMLEFT", 0, -10)
	characterFrame:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", -16, 0)
	characterFrame:SetHeight(200)

	-- Register with WoW settings system
	local category = Settings.RegisterCanvasLayoutCategory(optionsFrame, "Concentration Recharge")
	Settings.RegisterAddOnCategory(category)

	Util:Debug("Options panel registered")
end
