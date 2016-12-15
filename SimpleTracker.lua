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
	trinketshown=true,
	dispelx=40,
	dispely=5,
	dispelsize=30,
	dispelshown=false,
}}

function SimpleTracker:OnInitialize()
	self.db=SKG.db:RegisterNamespace("SimpleTracker",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("SimpleTracker",self.options,"L SimpleTracker")
end

-- SIMPLE TRACKER

function SimpleTracker:OnEnable()
	for i=1,5 do
		local arena=_G["ArenaEnemyFrame"..i]
		arena.trinket=self:TrinketFrame(i,arena)
		arena.dispel=self:DispelFrame(i,arena)
	end
end
function SimpleTracker:OnDisable()
	for i=1,5 do
		local arena=_G["ArenaEnemyFrame"..i]
		if arena.trinket then
			arena.trinket:UnregisterAllEvents()
			arena.trinket:Hide()
			arena.trinket=nil
		end
		if arena.dispel then
			arena.dispel:UnregisterAllEvents()
			arena.dispel:Hide()
			arena.dispel=nil
		end
	end
end
function SimpleTracker:ApplySettings()
	if db.enabled then
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
end

-- TRINKET

function SimpleTracker:TrinketFrame(i,p)
	local f=CreateFrame("Frame",nil,p)
	f:SetPoint("TOPLEFT",p,"TOPRIGHT",db.trinketx,db.trinkety)
	f:SetSize(db.trinketsize,db.trinketsize)
	f:SetShown(db.trinketshown)
	f.c=CreateFrame("Cooldown",nil,f,"CooldownFrameTemplate")
	f.c:SetDrawEdge(false)
	f.c:SetAllPoints(f)
	f.t=f:CreateTexture(nil,"BORDER")
	f.t:SetAllPoints()
	f.t:SetTexture(GetSpellTexture(208683))
	f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent",self.TrinketFilter)
	f.u="arena"..i
	-- f.u="target" -- debug
	f.exp=0
	return f
end
function SimpleTracker:TrinketFilter(e,u,_,_,_,id)
	local f=self
	if e=="PLAYER_ENTERING_WORLD" then
		f:SetShown(db.trinketshown)
		f.c:SetCooldown(0,0)
	elseif f.u==u then
		if id==208683 then
			f:Show()
			f.exp=GetTime()+120
			f.c:SetCooldown(GetTime(),120)
		elseif (id==7744 or id==59752) and GetTime()+30>f.exp then
			f:Show()
			f.c:SetCooldown(GetTime(),30)
		end
	end
end

-- DISPEL

function SimpleTracker:DispelFrame(i,p)
	local f=CreateFrame("Frame",nil,p)
	f:SetPoint("TOPLEFT",p,"TOPRIGHT",db.dispelx,db.dispely)
	f:SetSize(db.dispelsize,db.dispelsize)
	f:SetShown(db.dispelshown)
	f.c=CreateFrame("Cooldown",nil,f,"CooldownFrameTemplate")
	f.c:SetDrawEdge(false)
	f.c:SetAllPoints(f)
	f.t=f:CreateTexture(nil,"BORDER")
	f.t:SetAllPoints()
	f.t:SetTexture("Interface\\Icons\\spell_holy_dispelmagic")
	f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent",self.DispelFilter)
	f.u="arena"..i
	-- f.u="target" -- debug
	return f
end
function SimpleTracker:DispelFilter(e,u,_,_,_,id)
	local f=self
	if e=="PLAYER_ENTERING_WORLD" then
		f:SetShown(db.dispelshown)
		f.c:SetCooldown(0,0)
	elseif f.u==u then
		-- 527 priest, 4987 paladin, 77130 shaman, 88423 rdruid, 2782 druid, 475 mage, 115450 monk
		if id==527 or id==4987 or id==77130 or id==88423 or id==2782 or id==475 or id==115450 then
			f:Show()
			f.t:SetTexture(GetSpellTexture(id))
			f.c:SetCooldown(GetTime(),8)
		end
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
				get=function() return self:IsEnabled() end,
				set=function(i,v) if v then self:Enable() else self:Disable() end db.enabled=v end,
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
			trinketshown={
				type="toggle",
				name="Shown at start",
				order=14,
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
			dispelshown={
				type="toggle",
				name="Shown at start",
				order=24,
			},
		}
	}
end
