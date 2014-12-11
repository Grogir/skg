--------------------------------------------------
--
-- SimpleTracker.lua
-- created 27/10/2014
-- by Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------

local AddonName,SKG=...
local SimpleTracker=SKG:NewModule("SimpleTracker","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
	trinketx=10,
	trinkety=5,
	trinketsize=30,
	dispelx=40,
	dispely=5,
	dispelsize=30,
}}

function SimpleTracker:OnInitialize()
	self.db=SKG.db:RegisterNamespace("SimpleTracker",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("SimpleTracker",self.options,"L SimpleTracker")
end

-- TRINKET TRACKER

function SimpleTracker:OnEnable()
	self:Trinket()
	self:Dispel()
end
function SimpleTracker:OnDisable()
end
function SimpleTracker:ApplySettings()
	for i=1,5 do
		local arena=_G["ArenaEnemyFrame"..i]
		arena.trinket:ClearAllPoints()
		arena.trinket:SetPoint("TOPLEFT",arena,"TOPRIGHT",db.trinketx,db.trinkety)
		arena.trinket:SetSize(db.trinketsize,db.trinketsize)
		arena.dispel:ClearAllPoints()
		arena.dispel:SetPoint("TOPLEFT",arena,"TOPRIGHT",db.dispelx,db.dispely)
		arena.dispel:SetSize(db.dispelsize,db.dispelsize)
	end
end

-- TRINKET

function SimpleTracker:Trinket()

	local Trinket_TTX="Interface\\Icons\\inv_jewelry_trinketpvp_01"
	local Trinket_Shown=true
	local function Trinket_CreateFrame(i,p)
		local f=CreateFrame("Frame",nil,_G["ArenaEnemyFrame"..i])
		f:SetPoint("TOPLEFT",p,"TOPRIGHT",db.trinketx,db.trinkety)
		f:SetSize(db.trinketsize,db.trinketsize)
		f.c=CreateFrame("Cooldown",nil,f)
		f.c:SetAllPoints(f)
		f.t=f:CreateTexture(nil,"BORDER")
		f.t:SetAllPoints()
		f.t:SetTexture(Trinket_TTX)
		f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f.u="arena"..i
		-- f.u="target" -- debug
		f.l=0
		return f
	end
	local function Trinket_Filter(f,e,u,n,r,l,si)
		if(e=="PLAYER_ENTERING_WORLD")then
			f:SetShown(Trinket_Shown)
			f.c:SetCooldown(0,0)
		elseif(f.u==u)then
			if(si==59752 or si==42292)then
				f:Show()
				f.l=GetTime()+120
				f.c:SetCooldown(GetTime(),120)
			elseif si==7744 and GetTime()+30>f.l then
				f:Show()
				f.c:SetCooldown(GetTime(),30)
			end
		end
	end
	for i=1,5 do
		local arena=_G["ArenaEnemyFrame"..i]
		arena.trinket=Trinket_CreateFrame(i,arena)
		arena.trinket:SetScript("OnEvent",Trinket_Filter)
	end
	
end

-- DISPEL

function SimpleTracker:Dispel()

	local Dispel_TTX="Interface\\Icons\\spell_holy_dispelmagic"
	local Dispel_Shown=false
	local function Dispel_CreateFrame(i,p)
		local f=CreateFrame("Frame",nil,p)
		f:SetPoint("TOPLEFT",p,"TOPRIGHT",db.dispelx,db.dispely)
		f:SetSize(db.dispelsize,db.dispelsize)
		f.c=CreateFrame("Cooldown",nil,f)
		f.c:SetAllPoints(f)
		f.t=f:CreateTexture(nil,"BORDER")
		f.t:SetAllPoints()
		f.t:SetTexture(Dispel_TTX)
		f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f.u="arena"..i
		-- f.u="target" -- debug
		return f
	end
	local function Dispel_Filter(f,e,u,n,r,l,si)
		if(e=="PLAYER_ENTERING_WORLD")then
			f:SetShown(Dispel_Shown)
			f.c:SetCooldown(0,0)
		elseif(f.u==u)then
			if(si==527 or si==4987 or si==77130 or si==88423 or si==2782 or si==475 or si==115450)then
				f:Show()
				f.t:SetTexture(GetSpellTexture(si))
				f.c:SetCooldown(GetTime(),8)
			end
		end
	end
	-- 527 priest, 4987 paladin, 77130 shaman, 88423 rdruid, 2782 druid, 475 mage, 115450 monk
	for i=1,5 do
		local arena=_G["ArenaEnemyFrame"..i]
		arena.dispel=Dispel_CreateFrame(i,arena)
		arena.dispel:SetScript("OnEvent",Dispel_Filter)
	end

end

-- OPTIONS

local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	SimpleTracker:ApplySettings()
end
function SimpleTracker:GetOptions()
	return {
		order=2,
		type="group",
		name="Simple Tracker",
		desc="Arena trinket and dispel trackers",
		childGroups="tab",
		get=getter,
		set=setter,
		args={
			enabled={
				type="toggle",
				name="Enable",
				desc="Enable the module",
				order=1,
			},
			trinket={
				type="header",
				name="Trinket Tracker",
				order=10,
			},
			trinketx={
				type="range",
				name="X",
				min=-500,max=500,step=1,bigStep=5,
				order=11
			},
			trinkety={
				type="range",
				name="Y",
				min=-500,max=500,step=1,bigStep=5,
				order=12
			},
			trinketsize={
				type="range",
				name="Size",
				min=5,max=100,step=1,bigStep=5,
				order=13
			},
			dispel={
				type="header",
				name="Dispel Tracker",
				order=20,
			},
			dispelx={
				type="range",
				name="X",
				min=-500,max=500,step=1,bigStep=5,
				order=21
			},
			dispely={
				type="range",
				name="Y",
				min=-500,max=500,step=1,bigStep=5,
				order=22
			},
			dispelsize={
				type="range",
				name="Size",
				min=5,max=100,step=1,bigStep=5,
				order=23
			},
		}
	}
end
