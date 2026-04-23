local _, ns = ...

local L = ns.L
local Concentration = ns.Concentration

-- Custom Settings System
local settingsCallbacks = {}

function ns:RegisterOptionCallback(key, callback)
	settingsCallbacks[key] = settingsCallbacks[key] or {}
	table.insert(settingsCallbacks[key], callback)
end

local function TriggerOptionCallbacks(key, value)
	if settingsCallbacks[key] then
		for _, callback in ipairs(settingsCallbacks[key]) do
			callback(value)
		end
	end
end

-- Settings Panel Creation
local function CreateSettingsPanel()
	local panel = CreateFrame("Frame", "ConcentrationRechargeSettingsPanel", UIParent)
	panel.name = "ConcentrationRecharge"
	panel.title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	panel.title:SetPoint("TOPLEFT", 16, -16)
	panel.title:SetText("ConcentrationRecharge Settings")
	
	local yOffset = -50
	local checkboxes = {}
	
	-- Main glow toggle
	local glowCheckbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
	glowCheckbox:SetPoint("TOPLEFT", 20, yOffset)
	glowCheckbox.Text:SetText(L["enable_glow_effects"])
	glowCheckbox:SetChecked(ConcentrationRechargeSettings.glow)
	glowCheckbox:SetScript("OnClick", function(self)
		ConcentrationRechargeSettings.glow = self:GetChecked()
		TriggerOptionCallbacks("glow", ConcentrationRechargeSettings.glow)
		
		-- Update profession-specific checkboxes
		for _, checkbox in pairs(checkboxes) do
			checkbox:SetEnabled(ConcentrationRechargeSettings.glow)
		end
	end)
	
	yOffset = yOffset - 30
	
	-- Profession-specific glow toggles
	for skillLine, _ in pairs(Concentration.skillLines) do
		local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLine)
		if profInfo then
			local checkbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
			checkbox:SetPoint("TOPLEFT", 40, yOffset)
			checkbox.Text:SetText(profInfo.professionName)
			checkbox:SetChecked(ConcentrationRechargeSettings["glow-" .. skillLine])
			checkbox:SetEnabled(ConcentrationRechargeSettings.glow)
			checkbox:SetScript("OnClick", function(self)
				local key = "glow-" .. skillLine
				ConcentrationRechargeSettings[key] = self:GetChecked()
				TriggerOptionCallbacks(key, ConcentrationRechargeSettings[key])
			end)
			
			checkboxes[skillLine] = checkbox
			yOffset = yOffset - 25
		end
	end
	
	yOffset = yOffset - 20
	
	-- Cooldown update during craft toggle
	local craftCheckbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
	craftCheckbox:SetPoint("TOPLEFT", 20, yOffset)
	craftCheckbox.Text:SetText(L["settings_cooldown_update_during_craft_title"])
	craftCheckbox:SetChecked(ConcentrationRechargeSettings.enable_cooldown_update_during_craft)
	craftCheckbox:SetScript("OnClick", function(self)
		ConcentrationRechargeSettings.enable_cooldown_update_during_craft = self:GetChecked()
	end)
	
	-- Add tooltip for craft checkbox
	craftCheckbox:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["settings_cooldown_update_during_craft_tooltip"], nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)
	craftCheckbox:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	return panel
end

function ns:RegisterSettings(settingsName, settings)
	-- Initialize default values if not already set
	if not _G[settingsName] then
		_G[settingsName] = {}
	end
	
	local savedSettings = _G[settingsName]
	
	-- Apply defaults for any missing settings
	for _, setting in ipairs(settings) do
		if savedSettings[setting.key] == nil then
			savedSettings[setting.key] = setting.default
		end
	end
	
	-- Create and register the settings panel
	local panel = CreateSettingsPanel()
	
	-- Try modern settings first, fallback to legacy
	if Settings and Settings.RegisterCanvasLayoutCategory then
		-- Modern settings (10.0+)
		local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
		Settings.RegisterAddOnCategory(category)
	else
		-- Legacy interface options
		if InterfaceOptions_AddCategory then
			InterfaceOptions_AddCategory(panel)
		else
			-- Fallback registration method
			panel.parent = "ConcentrationRecharge"
			table.insert(INTERFACEOPTIONS_ADDONCATEGORIES, panel)
		end
	end
end