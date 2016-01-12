--------------------------------------------------
--
-- ObjectiveFrame.lua
-- created __/__/2014
-- by Pierre-Yves "Grogir" DUTREUILH & Florian "Khujara" FALAVEL
--
--------------------------------------------------

local AddonName,SKG=...
local ObjectiveFrame=SKG:NewModule("ObjectiveFrame","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
}}

function ObjectiveFrame:OnInitialize()
	self.db=SKG.db:RegisterNamespace("ObjectiveFrame",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("ObjectiveFrame",self.options,"L ObjectiveFrame")
end

-- Objective Frame

function ObjectiveFrame:OnEnable()
	if(db.enabled) then
		ObjectiveTrackerFrame:Hide()
	else
		ObjectiveTrackerFrame:Show()
	end
end

function ObjectiveFrame:OnDisable()
	ObjectiveTrackerFrame:Show()
end

function ObjectiveFrame:ApplySettings()
	self:OnDisable()
	self:OnEnable()
end

-- OPTIONS

local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	ObjectiveFrame:ApplySettings()
end
function ObjectiveFrame:GetOptions()
	return {
		order=11,
		type="group",
		name="Objective Frame",
		desc="Objective Frame",
		childGroups="tab",
		get=getter,
		set=setter,
		args={
			enabled={
				type="toggle",
				name="Enable",
				desc="Enable the module",
				get=getter,
				set=setter,
				order=1,
			},
			of={
				type="header",
				name="Objective Frame",
				order=10,
			},
		}
	}
end
