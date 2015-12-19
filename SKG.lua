--------------------------------------------------
--
-- SKG.lua
-- created 20/02/2013
-- by Pierre-Yves "Grogir" DUTREUILH & Florian "Khujara" FALAVEL
--
--------------------------------------------------
-- finir nameplates texte flottant

local AddonName,SKG=...
local db
_G.SKG=SKG
SKG=LibStub("AceAddon-3.0"):NewAddon(SKG,AddonName,"AceConsole-3.0")

local defaults={
	global={
	}
}

function SKG:OnInitialize()
	self.db=LibStub("AceDB-3.0"):New("SKGDB",defaults,true)
	self:SetupOptions()
	db=self.db
	LoadAddOn("Blizzard_ArenaUI")
end
-- local function getter(info)
	-- return db[info.arg or info[#info]]
-- end
function SKG:SetupOptions()
	self.options={
		type="group",
		name=AddonName,
		-- childGroups="tree",
		plugins={},
		args={
			-- reset={
				-- type="execute",
				-- name="Reset all settings",
				-- desc="Reset all settings",
				-- func=function() self.db:ResetDB() ReloadUI() end,
				-- order=1
			--}
		}
	}
	-- self.options.plugins.profiles={profiles=LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)}
	LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName,self.options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize(AddonName,760,600)
	local status=LibStub("AceConfigDialog-3.0"):GetStatusTable(AddonName)
	status.groups={treewidth=120}
	self:RegisterChatCommand("sg","ChatCommand")
	self:RegisterChatCommand("sk","ChatCommand")
	self:RegisterChatCommand("skg","ChatCommand")
end
function SKG:ChatCommand()
	if not input or input:trim()=="" then
		if not InCombatLockdown() then LibStub("AceConfigDialog-3.0"):Open(AddonName) end
	else
		LibStub("AceConfigCmd-3.0").HandleCommand(self,"skg",AddonName,input)
	end
end
function SKG:ResetOptions(args,db,def)
	for a,b in pairs(args) do
		if db[a]~=nil and db[a]~=def[a] then
			db[a]=def[a]
		end
		if b.type=="group" and b.args then
			self:ResetOptions(b.args,db,def)
		end
	end
end
function SKG:RegisterModuleOptions(key,table)
	if self.options then
		self.options.plugins[key]={[key]=table}
	end
end

-- TARGET PCT HEALTH

pct=CreateFrame("Frame",nil,UIParent)
pct:SetSize(50,50)
pct:SetPoint("CENTER",75+25-20,-293+67)
pct:SetAlpha(0)
pct.txt=pct:CreateFontString(nil,"OVERLAY")
pct.txt:SetFont("Fonts\\FRIZQT__.TTF",10,"OUTLINE")
pct.txt:SetAllPoints(pct)
pct:RegisterEvent("PLAYER_TARGET_CHANGED")
pct:RegisterEvent("UNIT_HEALTH")
pct:SetScript("OnEvent",function()
	if UnitCanAttack("player","target") then
		local h=UnitHealth("target")
		local hmax=UnitHealthMax("target")
		if h>0 and hmax>0 then
			local txt=format("%.1f%%",100*h/hmax)
			if txt=="100.0%" then txt="100%" end
			pct.txt:SetText(txt)
			if h/hmax>0.25 then pct:SetAlpha(0.5) else pct:SetAlpha(1) end
		else pct:SetAlpha(0) end
	else pct:SetAlpha(0) end
end)

-- SAFEQUEUE

PVPReadyDialog.leaveButton:Disable()
sq=CreateFrame("FRAME",nil,UIParent)
sq:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
sq.q={}
sq:SetScript("OnEvent",function()
	for i=1,GetMaxBattlefieldID() do
		local status=GetBattlefieldStatus(i)
		if status=="confirm" then
			if not sq.q[i] then
				sq.q[i]=GetTime()+GetBattlefieldPortExpiration(i)
			end
		else
			sq.q[i]=nil
		end
	end
end)
sq:SetScript("OnUpdate",function()
	for i=1,GetMaxBattlefieldID() do
		if sq.q[i] then
			local secs=sq.q[i]-GetTime()
			local color=secs>20 and "f20ff20" or secs>10 and "fffff00" or "fff0000"
			PVPReadyDialog.label:SetText("|cf"..color..SecondsToTime(secs).."|r")
		end
	end
end)

-- MACRO LIMIT

fmacro=CreateFrame("FRAME")
fmacro:RegisterEvent("ADDON_LOADED")
fmacro:SetScript("OnEvent",function(_,_,name)
	if name=="Blizzard_MacroUI" then MAX_CHARACTER_MACROS=36 end
end)

-- AURA VALUE TRACKER

-- CreateFrame("GameTooltip","AuraValueTooltip",nil,"GameTooltipTemplate"):SetOwner(WorldFrame,"ANCHOR_NONE")
-- AuraValueTooltip.trackedids={
	-- [GetSpellInfo(132365)]=true, --vengeance
	-- [GetSpellInfo(77535)]=true --blood shield
	-- [GetSpellInfo(73975)]=true --necrotic strike
	--}
-- hooksecurefunc("AuraButton_Update",function(buttonName,index,filter)
	-- if AuraValueTooltip.trackedids[UnitAura("player",index,filter)] then
		-- local buff=_G[buttonName..index]
		-- AuraValueTooltip:ClearLines()
		-- AuraValueTooltip:SetUnitAura("player",index,filter)
		-- local value=tonumber(AuraValueTooltipTextLeft2:GetText():match(".-(%d+)"))
		-- if value then
			-- buff.count:SetText(value>=1000 and ("%dk"):format(floor(value/1000+0.5)) or value)
			-- buff.count:Show()
			-- return true
		-- end
	-- end
-- end)

-- ARENA PET...

-- arenapetdebug=CreateFrame("Frame")
-- arenapetdebug.SMP=ArenaEnemyFrame_SetMysteryPlayer
-- ArenaEnemyFrame_SetMysteryPlayer=function(f)
	-- if not string.find(debugstack(),"ArenaEnemyPetFrame_OnEvent") then
		-- arenapetdebug.SMP(f)
	-- end
-- end

-- NAMEPLATES

plates=CreateFrame("Frame")
plates:RegisterEvent("PLAYER_ENTERING_WORLD")
plates:SetScript("OnEvent",function(self)
	if not self.init then
		self.init=true
		WorldFrame:SetScale(0.8)
		hooksecurefunc("CombatText_UpdateDisplayedMessages",function()
			COMBAT_TEXT_SPACING=COMBAT_TEXT_SPACING*0.8
			COMBAT_TEXT_MAX_OFFSET=COMBAT_TEXT_MAX_OFFSET*0.8
			COMBAT_TEXT_LOCATIONS.startY=COMBAT_TEXT_LOCATIONS.startY*0.8
			COMBAT_TEXT_LOCATIONS.endY=(COMBAT_TEXT_LOCATIONS.endY*0.8+COMBAT_TEXT_LOCATIONS.startY)*0.5
			CombatText_ClearAnimationList()
		end)
		COMBAT_TEXT_SCROLLSPEED=1
		COMBAT_TEXT_FADEOUT_TIME=0
	end
end)
plates.num=-1
plates.elapsed=0
plates:SetScript("OnUpdate",function(self,elapsed)
	self.elapsed=self.elapsed+elapsed
	if WorldFrame:GetNumChildren()~=self.num or self.elapsed>0.1 then
		self.num=WorldFrame:GetNumChildren()
		self.elapsed=0
		local t={WorldFrame:GetChildren()}
		for i,f in pairs(t) do
			if f:GetBackdrop() and f:GetBackdrop().bgFile=="Interface\\Tooltips\\ChatBubble-Background" then
				f:SetScale(1.25)
			end
		end
	end
end)

-- TC

snapshot=CreateFrame("Frame")
snapshot:Show()
snapshot.removed={[5215]=0,[145152]=0,[58984]=0}
snapshot.cache={[1079]={},[155722]={},[106830]={}}
function snapshot:Calc()
	local cp=UnitPower("player",4)
	if cp==0 then cp=5 end
	local mult=1
	if UnitBuff("player","Fureur du tigre") then mult=mult*1.15 end
	if UnitBuff("player","Rugissement sauvage") then mult=mult*1.4 end
	if UnitBuff("player","Griffes de sang") or GetTime()-snapshot.removed[145152]<0.05 then mult=mult*1.3 end
	local rakemult=1
	if UnitBuff("player","Incarnation : Roi de la jungle") or UnitBuff("player","Rôder") or GetTime()-snapshot.removed[5215]<0.05 or UnitBuff("player","Camouflage dans l'ombre") or GetTime()-snapshot.removed[58984]<0.05 then rakemult=2 end

	snapshot.cache[1079].value=cp/5*mult
	snapshot.cache[1079].valueget=mult
	snapshot.cache[155722].value=mult*rakemult
	snapshot.cache[106830].value=mult
end
snapshot:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
snapshot:SetScript("OnUpdate",function() snapshot:Calc() end)
snapshot:SetScript("OnEvent",function(_,_,_,param,_,src,_,_,_,dest,_,_,_,spell,_,_,_)
	if src==UnitGUID("player") then
		if snapshot.removed[spell] and param=="SPELL_AURA_REMOVED" then
			snapshot.removed[spell]=GetTime()
		end
		local cache=snapshot.cache[spell]
		if cache then
			if param=="SPELL_AURA_APPLIED" or param=="SPELL_AURA_REFRESH" then
				snapshot:Calc()
				cache[dest]=cache.value -- print(param,spell,cache.value)
			elseif param=="SPELL_AURA_REMOVED" then
				cache[dest]=nil -- print(param,spell)
			end
		end
	end
end)

-- ILVL CHECK

local ilvlcheck=CreateFrame("Frame")
-- ilvlcheck:RegisterEvent("PLAYER_ENTER_COMBAT")
ilvlcheck:RegisterEvent("PLAYER_REGEN_DISABLED")
ilvlcheck:SetScript("OnEvent",function()
	if UnitLevel("player")>=100 then
	   local limit=GetAverageItemLevel()*0.8
	   for i=1,17 do
		  if i~=4 then
			 local l=GetInventoryItemLink("player",i)
			 if not l then
				if i==17 then
				   l=GetInventoryItemLink("player",16)
				   if l then
					   local sub,_,t=select(7,GetItemInfo(l))
					   if t=="INVTYPE_2HWEAPON" or t=="INVTYPE_RANGED" or t=="INVTYPE_RANGEDRIGHT" and sub~=select(16,GetAuctionItemSubClasses(1)) then 
						  break
					   end
				   end
				end
				print("Warning: No item in slot",i)
			 else
				local _,_,_,ilvl=GetItemInfo(l)
				if ilvl and ilvl<limit and not (l:match(":512:22:%d:615:") or l:match(":512:22:%d:692:")) then
				   print("Warning: Item",l,"is",ilvl,"item level")
				end
			 end
		  end
	   end
	end
end)
