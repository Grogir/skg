--------------------------------------------------
--
-- ComboPoints.lua
-- created 12/11/2014
-- by Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------

local AddonName,SKG=...
local ComboPoints=SKG:NewModule("ComboPoints","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,

	iconsize=24,
	offx=20,
	offy=0,
	anchor="CENTER",
	parent="UIParent",
	paranchor="CENTER",
	x=0-20,
	y=-295+65,
	texoff="Interface\\COMMON\\Indicator-Gray",
	texon="Interface\\COMMON\\Indicator-Yellow",
}}

function ComboPoints:OnInitialize()
	self.db=SKG.db:RegisterNamespace("ComboPoints",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("ComboPoints",self.options,"L ComboPoints")

	self:RegisterEvent("PLAYER_ENTERING_WORLD","Reload") --PLAYER_LOGIN
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED","Reload")
end
function ComboPoints:Reload(e,u)
	if db.enabled and (e~="PLAYER_SPECIALIZATION_CHANGED" or u=="player") then
		self:OnDisable()
		self:OnEnable()
	end
end

-- CP TRACKER

ComboPoints.frame=CreateFrame("FRAME",nil,UIParent)
local COMBOS_TYPE=4
ComboPoints.specdata={
	[65]=SPELL_POWER_HOLY_POWER, -- holy paladin
	[66]=SPELL_POWER_HOLY_POWER, -- prot paladin
	[70]=SPELL_POWER_HOLY_POWER, -- ret paladin
	[103]=COMBOS_TYPE, -- feral druid
	[259]=COMBOS_TYPE, -- assass rogue
	[260]=COMBOS_TYPE, -- outlaw rogue
	[261]=COMBOS_TYPE, -- sub rogue
}
ComboPoints.points={}
function ComboPoints:OnEnable()
	local spec=GetSpecialization()
	if spec then spec=GetSpecializationInfo(spec) end
	local specdata=self.specdata[spec]
	if specdata then
		local maxcp=UnitPowerMax("player",specdata)
		-- local cfg=self.config
		self.frame:SetSize((maxcp-1)*abs(db.offx)+db.iconsize,(maxcp-1)*abs(db.offy)+db.iconsize)
		self.frame:SetPoint(db.anchor,db.parent,db.paranchor,db.x,db.y)
		self.count=-1
		for i=1,maxcp do
			local f=CreateFrame("FRAME",nil,self.frame)
			f:SetSize(db.iconsize,db.iconsize)
			-- f:SetPoint("TOPLEFT",(i-1)*db.offx,(i-1)*db.offy)
			f:SetPoint("CENTER",(i-(maxcp+1)/2)*db.offx,(i-(maxcp+1)/2)*db.offy)
			f.texoff=f:CreateTexture()
			f.texoff:SetAllPoints()
			f.texoff:SetTexture(db.texoff)
			f.texon=f:CreateTexture()
			f.texon:SetAllPoints()
			f.texon:SetTexture(db.texon)
			f.texon:Hide()
			f:Show()
			self.points[i]=f
		end
		self:RegisterEvent("UNIT_POWER","Update")
		self.combotype=specdata
	end
	-- self:ApplySettings()
end
function ComboPoints:OnDisable()
	for i=1,#self.points do
		self.points[i]:Hide()
	end
	wipe(self.points)
	self:UnregisterEvent("UNIT_POWER")
end
function ComboPoints:Update()
	local count=UnitPower("player",self.combotype)
	if count~=self.count then
		self.count=count
		for i=1,#self.points do
			self.points[i].texoff:SetShown(i>count)
			self.points[i].texon:SetShown(i<=count)
		end
	end
end
function ComboPoints:ApplySettings()
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
	ComboPoints:ApplySettings()
end
function ComboPoints:GetOptions()
	return {
		order=9,
		type="group",
		name="ComboPoints",
		desc="ComboPoints",
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
			cp={
				type="header",
				name="ComboPoints",
				order=10,
			},
			iconsize={
				type="range",
				name="Icon Size",
				min=0,max=500,step=1,bigStep=2,softMax=100,
				order=11
			},
			x={
				type="range",
				name="X",
				min=-1000,max=1000,step=1,bigStep=10,softMin=-500,softMax=500,
				order=12
			},
			y={
				type="range",
				name="Y",
				min=-600,max=600,step=1,bigStep=10,softMin=-400,softMax=400,
				order=13
			},
			offx={
				type="range",
				name="X Offset",
				min=-500,max=500,step=1,bigStep=2,softMin=-100,softMax=100,
				order=14
			},
			offy={
				type="range",
				name="Y Offset",
				min=-500,max=500,step=1,bigStep=2,softMin=-100,softMax=100,
				order=15
			},
			anchor={
				type="input",
				name="Anchor",
				order=20
			},
			parent={
				type="input",
				name="Parent Frame",
				order=21
			},
			paranchor={
				type="input",
				name="Parent Anchor",
				order=22
			},
			texoff={
				type="input",
				name="Off Texture",
				width="double",
				order=23
			},
			texon={
				type="input",
				name="On Texture",
				width="double",
				order=24
			},
		}
	}
end
