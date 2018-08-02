--------------------------------------------------
--
-- _______________.lua
-- created __/__/2018
-- by Pierre-Yves "Grogir" DUTREUILH & Florian "Khujara" FALAVEL
--
--------------------------------------------------

local AddonName,SKG=...
local _______________=SKG:NewModule("_______________","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
}}

function _______________:OnInitialize()
	self.db=SKG.db:RegisterNamespace("_______________",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("_______________",self.options,"L _______________")
end

-- _______________

function _______________:OnEnable()
end

function _______________:OnDisable()
end

function _______________:ApplySettings()
	if db.enabled then
		self:OnDisable()
		self:OnEnable()
	end
end

-- OPTIONS

local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	_______________:ApplySettings()
end
function _______________:GetOptions()
	return {
		order=9999,
		type="group",
		name="_______________",
		desc="_______________",
		childGroups="tab",
		get=getter,
		set=setter,
		args={
			enabled={
				type="toggle",
				name="Enable",
				desc="Enable the module",
				get=function() return self:IsEnabled() end,
				set=function(i,v) if v then self:Enable() else self:Disable() end db.enabled=v end,
				order=1,
			},
			_______________={
				type="header",
				name="_______________",
				order=10,
			},
		}
	}
end