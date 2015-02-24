--------------------------------------------------
--
-- TrinketICd.lua
-- created 12/11/2014
-- by Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------

local AddonName,SKG=...
local TrinketICd=SKG:NewModule("TrinketICd","AceEvent-3.0")
-- SGT=TrinketICd
local db

local defaults={global={
	enabled=true,
}}

function TrinketICd:OnInitialize()
	self.db=SKG.db:RegisterNamespace("TrinketICd",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("TrinketICd",self.options,"L TrinketICd")
end

-- TRINKET CD TRACKER

TrinketICd.trinkets={
-- S15
[103347]={duration=115,proc=126707},
-- T16
[104476]={duration=115,proc=146308},
[102302]={duration=85,proc=148896},
-- S1
[115160]={duration=50,proc=126700},
[119937]={duration=50,proc=126700},
[115760]={duration=50,proc=126700},
[111233]={duration=50,proc=126700},
[115155]={duration=50,proc=126705},
[119932]={duration=50,proc=126705},
[115755]={duration=50,proc=126705},
[111228]={duration=50,proc=126705},
[115150]={duration=50,proc=126707},
[119927]={duration=50,proc=126707},
[115750]={duration=50,proc=126707},
[111223]={duration=50,proc=126707},
-- T17
[109262]={duration=55,proc=60233},
[112317]={duration=115,proc=162913},
[112318]={duration=115,proc=162915},
[112319]={duration=115,proc=162917},
[112320]={duration=115,proc=162919},
}
TrinketICd.procs={}

function TrinketICd:OnEnable()
	self.guid=UnitGUID("player")
	for id,t in pairs(self.trinkets) do
		t.start=0
		self.procs[t.proc]=id
	end
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
end
function TrinketICd:OnDisable()
	wipe(self.procs)
	self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
end
function TrinketICd:ApplySettings()
	self:OnDisable()
	self:OnEnable()
end

function TrinketICd:ACTIONBAR_SLOT_CHANGED(e,slot)
	self.update=1
end
function TrinketICd:COMBAT_LOG_EVENT_UNFILTERED(e,_,event,_,srcguid,_,_,_,_,_,_,_,aura)
	if event=="SPELL_AURA_APPLIED" and srcguid==self.guid and self.procs[aura] then
		self.trinkets[self.procs[aura]].start=GetTime()
		self.update=1
	end
end
function TrinketICd:PLAYER_EQUIPMENT_CHANGED(e,slot,eq)
	if slot==13 or slot==14 then
		local id=GetInventoryItemID("player",slot)
		if self.trinkets[id] then
			self.trinkets[id].start=GetTime()
			self.update=1
		end
	end
end

TrinketICd.frame=CreateFrame("FRAME")
TrinketICd.frame:SetScript("OnUpdate",function()
	if TrinketICd.update then
		TrinketICd.update=nil
		TrinketICd:StartCd()
	end
end)
function TrinketICd:CheckButton(button)
	local start,duration=0,0
	local action=button._state_action or button.action
	if type(action)=="number" and IsEquippedAction(action) then
		local act,id=GetActionInfo(action)
		if act=="macro" then
			local name,link=GetMacroItem(id)
			if link then id=tonumber(link:match(".-item:(%d+)")) end
		end
		local t=self.trinkets[id]
		if t then
			if t.start+t.duration>GetTime() then
				start=t.start
				duration=t.duration
				if not button.trkcd then
					button.trkcd=CreateFrame("Cooldown",nil,button,"CooldownFrameTemplate")
					button.trkcd:SetAllPoints(button)
					button.trkcd:SetDrawEdge(false)
					button.trkcd:SetFrameLevel(button:GetFrameLevel()+1)
				end
			end
		end
	end
	if button.trkcd then
		button.trkcd:SetCooldown(start,duration)
	end
end
function TrinketICd:StartCd()
-- /run EnableAddOn("Bartender4") /run DisableAddOn("Bartender4") /run TrinketICd:StartCd()
	for _,button in pairs(ActionBarButtonEventsFrame.frames) do
		self:CheckButton(button)
	end
	-- local lib=LibStub:GetLibrary("LibActionButton-1.0")
	local lib=LibStub("LibActionButton-1.0",true)
	if lib and lib.buttonRegistry then --activeButtons
		for button in next,lib.buttonRegistry do
			self:CheckButton(button)
		end
	end
end

-- OPTIONS

local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	TrinketICd:ApplySettings()
end
function TrinketICd:GetOptions()
	return {
		order=10,
		type="group",
		name="Trinket Cd",
		desc="Shows trinket's internal cooldowns",
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
			TrinketICd={
				type="header",
				name="TrinketICd",
				order=10,
			},
		}
	}
end