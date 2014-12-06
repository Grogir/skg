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
			-- }
		}
	}
	-- self.options.plugins.profiles={ profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) }
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

-- FRAME ACTIVATION

-- fract=CreateFrame("FRAME",nil,UIParent)
-- fract.db={{id=768,spec=103,f={"cybar1","combo","pct","tc"}}}
-- function fract:Load()
	-- for i=1,#fract.db do fract.db[i].active=nil end
	-- local spec=GetSpecialization()
	-- if spec then fract.spec=GetSpecializationInfo(spec) end
	-- fract:RegisterEvent("UNIT_AURA")
	-- fract:OnAura(_,"player")
-- end
-- function fract:Unload()
	-- fract:UnregisterEvent("UNIT_AURA")
-- end
-- function fract:OnAura(_,unit)
	-- if unit=="player" then
		-- for i,db in pairs(fract.db) do
			-- if not db.spec or fract.spec==db.spec then
				-- local active=true
				-- if db.id then
					-- local name=GetSpellInfo(db.id)
					-- active=active and select(11,UnitAura("player",name))==db.id
				-- end
				-- if active~=db.active then
					-- db.active=active
					-- for j=1,#db.f do
						-- local f=_G[db.f[j]]
						-- if f and f.SetShown then
							-- f:SetShown(active)
						-- end
					-- end
				-- end
			-- end
		-- end
	-- end
-- end
-- fract:SetScript("OnEvent",fract.OnAura)
-- fract.login=CreateFrame("FRAME",nil,UIParent)
-- fract.login:RegisterEvent("PLAYER_LOGIN")
-- fract.login:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
-- fract.login:SetScript("OnEvent",function()
	-- fract:Unload()
	-- fract:Load()
-- end)

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
	-- }
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
plates:RegisterEvent("PLAYER_LOGIN")
plates:SetScript("OnEvent",function()
	-- CombatText:SetScale(0.8)
	WorldFrame:SetScale(0.8)
end)
-- /run print(CombatText:GetPoint())
-- /run print(CombatText1:GetPoint())
-- /run print(CombatTextTemplate:GetPoint())
-- plates2=CreateFrame("Frame")
-- plates2:RegisterEvent("PLAYER_ENTERING_WORLD")
-- plates2:SetScript("OnEvent",function()
	-- a,b,c,d,e=CombatText1:GetPoint()
	-- CombatText1:SetPoint(a,b,c,d,e-100)
-- end)

bubbles=CreateFrame("Frame")
bubbles.num=-1
bubbles.elapsed=0
bubbles:SetScript("OnUpdate",function(self,elapsed)
	bubbles.elapsed=bubbles.elapsed+elapsed
	if WorldFrame:GetNumChildren()~=bubbles.num or bubbles.elapsed>0.1 then
		bubbles.num=WorldFrame:GetNumChildren()
		bubbles.elapsed=0
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
	if UnitBuff("player","Griffes de sang") or snapshot.removed[145152]==GetTime() then mult=mult*1.3 end
	local rakemult=1
	if UnitBuff("player","Incarnation : Roi de la jungle") or UnitBuff("player","Rôder") or snapshot.removed[5215]==GetTime() or UnitBuff("player","Camouflage dans l'ombre") or snapshot.removed[58984]==GetTime() then rakemult=2 end
	
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


-- SIMC

simc=CreateFrame("Frame",nil,UIParent)
simc:SetSize(36,36)
simc:SetPoint("CENTER",-200,0)
simc.t=simc:CreateTexture(nil,"BORDER")
simc.t:SetAllPoints()
-- simc.t:SetTexture(Trinket_TTX)
simc.spells={["faerie_fire"]=770,["weakened_armor"]=113746,["ferocious_bite"]=22568,["rip"]=1079,["rake"]=1822,["force_of_nature"]=106737,["healing_touch"]=5185,["dream_of_cenarius"]=108373,["predatory_swiftness"]=69369,["savage_roar"]=127538,["berserk"]=106951,["tigers_fury"]=5217,["omen_of_clarity"]=135700,["thrash_cat"]=106830,["feral_rage"]=146874,["feral_fury"]=144865,["ravage"]=6785,["mangle_cat"]=33876,["shred"]=5221,["stealthed"]=5215}
simc.special={["pool_resource"]=1,["run_action_list"]=1}
simc.actions={
"swap_action_list,name=aoe,if=active_enemies>=5",
"auto_attack",
"skull_bash_cat",
"force_of_nature,if=charges=3|(buff.rune_of_reorigination.react&buff.rune_of_reorigination.remains<1)|(buff.vicious.react&buff.vicious.remains<1)|target.time_to_die<20",
"ravage,if=buff.stealthed.up",
-- Keep Rip from falling off during execute range.",
"ferocious_bite,if=dot.rip.ticking&dot.rip.remains<=3&target.health.pct<=25",
"faerie_fire,if=debuff.weakened_armor.stack<3",
-- Proc Dream of Cenarius at 4+ CP or when PS is about to expire.",
"healing_touch,if=talent.dream_of_cenarius.enabled&buff.predatory_swiftness.up&buff.dream_of_cenarius.down&(buff.predatory_swiftness.remains<1.5|combo_points>=4)",
"savage_roar,if=buff.savage_roar.down",
"tigers_fury,if=energy<=35&!buff.omen_of_clarity.react",
"berserk,if=buff.tigers_fury.up|(target.time_to_die<18&cooldown.tigers_fury.remains>6)",
"thrash_cat,if=buff.omen_of_clarity.react&dot.thrash_cat.remains<3&target.time_to_die>=6",
"ferocious_bite,if=target.time_to_die<=1&combo_points>=3",
"savage_roar,if=buff.savage_roar.remains<=3&combo_points>0&target.health.pct<25",
-- Potion near or during execute range when Rune is up and we have 5 CP.",
"virmens_bite_potion,if=(combo_points>=5&(target.time_to_die*(target.health.pct-25)%target.health.pct)<15&buff.rune_of_reorigination.up)|target.time_to_die<=40",
-- Overwrite Rip if it's at least 15% stronger than the current.",
"rip,if=combo_points>=5&action.rip.tick_damage%dot.rip.tick_dmg>=1.15&target.time_to_die>30",
-- Use 4 or more CP to apply Rip if Rune of Reorigination is about to expire and it's at least close to the current rip in damage.",
"rip,if=combo_points>=4&action.rip.tick_damage%dot.rip.tick_dmg>=0.95&target.time_to_die>30&buff.rune_of_reorigination.up&buff.rune_of_reorigination.remains<=1.5",
-- Pool 50 energy for Ferocious Bite.",
"pool_resource,if=combo_points>=5&target.health.pct<=25&dot.rip.ticking&!(energy>=50|(buff.berserk.up&energy>=25))",
"ferocious_bite,if=combo_points>=5&dot.rip.ticking&target.health.pct<=25",
"rip,if=combo_points>=5&target.time_to_die>=6&dot.rip.remains<2&(buff.berserk.up|dot.rip.remains+1.9<=cooldown.tigers_fury.remains)",
"savage_roar,if=buff.savage_roar.remains<=3&combo_points>0&buff.savage_roar.remains+2>dot.rip.remains",
"savage_roar,if=buff.savage_roar.remains<=6&combo_points>=5&buff.savage_roar.remains+2<=dot.rip.remains&dot.rip.ticking",
-- Savage Roar if we're about to energy cap and it will keep our Rip from expiring around the same time as Savage Roar.",
"savage_roar,if=buff.savage_roar.remains<=12&combo_points>=5&energy.time_to_max<=1&buff.savage_roar.remains<=dot.rip.remains+6&dot.rip.ticking",
-- Refresh Rake as Re-Origination is about to end if Rake has <9 seconds left.",
"rake,if=buff.rune_of_reorigination.up&dot.rake.remains<9&buff.rune_of_reorigination.remains<=1.5",
-- Rake if we can apply a stronger Rake or if it's about to fall off and clipping the last tick won't waste too much damage.",
"rake,cycle_targets=1,if=target.time_to_die-dot.rake.remains>3&(action.rake.tick_damage>dot.rake.tick_dmg|(dot.rake.remains<3&action.rake.tick_damage%dot.rake.tick_dmg>=0.75))",
-- Pool energy for and maintain Thrash.",
"pool_resource,for_next=1",
"thrash_cat,if=target.time_to_die>=6&dot.thrash_cat.remains<3&(dot.rip.remains>=8&buff.savage_roar.remains>=12|buff.berserk.up|combo_points>=5)&dot.rip.ticking",
-- Pool energy for and clip Thrash if Rune of Re-Origination is expiring.",
"pool_resource,for_next=1",
"thrash_cat,if=target.time_to_die>=6&dot.thrash_cat.remains<9&buff.rune_of_reorigination.up&buff.rune_of_reorigination.remains<=1.5&dot.rip.ticking",
-- Pool to near-full energy before casting Ferocious Bite.",
"pool_resource,if=combo_points>=5&!(energy.time_to_max<=1|(buff.berserk.up&energy>=25)|(buff.feral_rage.up&buff.feral_rage.remains<=1))&dot.rip.ticking",
-- Ferocious Bite if we reached near-full energy without spending our CP on something else.",
"ferocious_bite,if=combo_points>=5&dot.rip.ticking",
-- Conditions under which we should execute a CP generator.",
"run_action_list,name=filler,if=buff.omen_of_clarity.react",
"run_action_list,name=filler,if=buff.feral_fury.react",
"run_action_list,name=filler,if=(combo_points<5&dot.rip.remains<3.0)|(combo_points=0&buff.savage_roar.remains<2)",
"run_action_list,name=filler,if=target.time_to_die<=8.5",
"run_action_list,name=filler,if=buff.tigers_fury.up|buff.berserk.up",
"run_action_list,name=filler,if=cooldown.tigers_fury.remains<=3",
"run_action_list,name=filler,if=energy.time_to_max<=1.0"
}
simc.actions.filler={
"ravage",
"rake,if=target.time_to_die-dot.rake.remains>3&action.rake.tick_damage*(dot.rake.ticks_remain+1)-dot.rake.tick_dmg*dot.rake.ticks_remain>action.mangle_cat.hit_damage",
"shred,if=(buff.omen_of_clarity.react|buff.berserk.up|energy.regen>=15)&buff.king_of_the_jungle.down",
"mangle_cat,if=buff.king_of_the_jungle.down"
}
simc.functions={}
simc.nextprocess=0
function simc:Process(actionlist)
	local i=0
	local pool=nil
	local result=nil
	while i<#actionlist and not result do
		i=i+1
		local action,param=actionlist[i]:match("([%a_]+),?(.*)")
		local id=simc.spells[action] or simc.special[action]
		local spelln=GetSpellInfo(id)
		local start,dur=GetSpellCooldown(id or 0)
		if id and (start==0 or dur<=1.5) and (IsUsableSpell(id) or pool==i) and GetSpellInfo(spelln) or simc.special[action] then
			pool=nil
			-- print(i,id)
			if param and param~="" then
				cond=param:match("if=([^,]+)")
				if cond then
					if not simc.functions[cond] then
						local code=cond
						code=code:gsub("dot%.","debuff.")
						code=code:gsub("%.ticking",".up")
						code=code:gsub("%.react",".up")
						code=code:gsub("health%.pct","health_pct")
						code=code:gsub("trinket%.proc","buff")
						code=code:gsub("charges([^%.])","charges."..id.."%1")
						code=code:gsub("energy([^%.])","energy.value%1")
						code=code:gsub("combo_points","GetComboPoints(\"player\")")
						
						code=code:gsub("&"," and ")
						code=code:gsub("|"," or ")
						code=code:gsub("([^!<>])=","%1==")
						code=code:gsub("!=","~=")
						code=code:gsub("!","not ")
						code=code:gsub("%%","/")
						code=code:gsub("debuff%.([%a_]+)","simc:Debuff(%1)")
						code=code:gsub("buff%.([%a_]+)","simc:Buff(%1)")
						code=code:gsub("target%.","simc:Target().")
						code=code:gsub("energy%.","simc:Power(3).")
						code=code:gsub("charges%.([%w_]+)","simc:Charges(%1)")
						code=code:gsub("talent%.([%a_]+)","simc:Talent(%1)")
						code=code:gsub("action%.([%a_]+)","simc:Action(%1)")
						code=code:gsub("cooldown%.([%a_]+)","simc:Cooldown(%1)")
						for sname,sid in pairs(simc.spells) do
							code=code:gsub(sname,sid)
						end
						print(code)
						local f,e=loadstring("return "..code)
						if f then
							simc.functions[cond]=f
						else
							simc.functions[cond]=0
							print(e)
						end
					end
					if not (type(simc.functions[cond])=="function" and simc.functions[cond]()) then
						id=nil
					end
				end
			end
			if id then
				if action=="pool_resource" and param:find("for_next=1") then
					pool=i+1
				elseif action=="run_action_list" then
					local name=param:match("name=([%a_]+)")
					if name and name~="" then
						local res=self:Process(simc.actions[name])
						if res then
							result=res
							-- print("run_action_list",name,res)
						end
					end
				else
					result=id
				end
			end
		end
	end
	-- print("result:",result)
	return result
end
function simc:Power(type)
	local power={}
	power.value=UnitPower("player",type)
	power.max=UnitPowerMax("player",type)
	power.pct=100*power.value/power.max
	power.deficit=power.max-power.value
	power.regen=GetPowerRegen()
	power.time_to_max=power.deficit/power.regen
	return power
end
function simc:Cooldown(id)
	local cooldown={}
	local start,dur=GetSpellCooldown(id)
	cooldown.duration=dur
	if start==0 then
		cooldown.up=1
		cooldown.remains=0
	else
		cooldown.remains=start+dur-GetTime()
	end
	return cooldown
end
function simc:Charges(id)
	return GetSpellCharges(id)
end
function simc:Talent(id)
	local talent={}
	if GetSpellInfo(GetSpellInfo(id)) then talent.enabled=1 end
	return talent
end
function simc:Action(id)
	local action={}
	if id==simc.spells["rake"] and tc.list and tc.list.rake and tc.list.rake.value then
		action.tick_damage=tc.list.rake.value
	end
	if id==simc.spells["rip"] and tc.list and tc.list.rip and tc.list.rip.value then
		action.tick_damage=tc.list.rip.value
	end
	if id==simc.spells["mangle_cat"] then
		action.hit_damage=50000
	end
	return action
end
function simc:Target()
	local target={}
	target.level=90
	target.adds=0
	target.adds_never=0
	target.time_to_die=60
	target.distance=0
	local h=UnitHealth("target")
	local hmax=UnitHealthMax("target")
	if h and hmax then target.health_pct=100*h/hmax else target.health_pct=100 end
	return target
end
function simc:Debuff(id)
	return simc:Buff(id,"target","HARMFUL")
end
function simc:Buff(id,unit,filter)
	local buff={}
	local name,rank=GetSpellInfo(id)
	local _,_,_,stack,_,dur,expi=UnitAura(unit or "player", name or "", rank or "", filter)
	buff.stack=stack or 0
	if buff.stack>0 then buff.react=buff.stack end
	-- buff.max_stack=99
	-- buff.stack_pct=100*buff.stack/buff.max_stack
	-- local cdstart,cddur=GetSpellCooldown(id)
	-- if cdstart==0 then buff.cooldown_remains=0 else buff.cooldown_remains=cdstart+cddur-GetTime() end
	if expi then
		buff.remains=expi-GetTime()
		buff.up=1
	else
		buff.remains=0
		buff.down=1
	end
	if id==1079 or id==1822 then
		AuraValueTooltip:ClearLines()
		AuraValueTooltip:SetUnitAura(unit, name or "", rank or "", filter)
		local txt=AuraValueTooltipTextLeft2:GetText()
		buff.tick_dmg=txt and tonumber(txt:match(".-(%d+)")) or 0
		buff.ticks_remain=buff.remains/2
		-- print("tick_dmg",buff.tick_dmg)
	end
	return buff
end
simc:SetScript("OnUpdate",function()
	-- if GetTime()>simc.nextprocess then
		-- simc.nextprocess=GetTime()+0.1
		-- local spell=simc:Process(simc.actions)
		-- if spell then
			-- simc.t:SetTexture(GetSpellTexture(spell))
		-- else
			-- simc.t:SetTexture("")
		-- end
	-- end
end)

-- mangle=CreateFrame("Frame",nil,UIParent)
-- mangle:SetSize(36,36)
-- mangle:SetPoint("CENTER",-200,-200)
-- mangle.t=mangle:CreateTexture(nil,"BORDER")
-- mangle.t:SetAllPoints()
-- mangle.t:SetTexture(GetSpellTexture(33876))
-- mangle.txt=mangle:CreateFontString(nil,"OVERLAY")
-- mangle.txt:SetFont("Fonts\\FRIZQT__.TTF",10,"OUTLINE")
-- mangle.txt:SetAllPoints()
-- table.insert(tc.list.mangle.observers,function(value) mangle.txt:SetText(format("%dk",value/1000+0.5)) end)

--tooltipfuncs={"AddDoubleLine","AddFontStrings","AddLine","AddSpellByID","AddTexture","AdvanceSecondaryCompareItem","AppendText","ClearLines","FadeOut","GetAnchorType","GetItem","GetMinimumWidth","GetOwner","GetPadding","GetSpell","GetUnit","IsEquippedItem","IsUnit","NumLines","ResetSecondaryCompareItem","SetAchievementByID","SetAction","SetAnchorType","SetAuctionItem","SetAuctionSellItem","SetBackpackToken","SetBagItem","SetBuybackItem","SetCompareItem","SetCurrencyByID","SetCurrencyToken","SetCurrencyTokenByID","SetEquipmentSet","SetExistingSocketGem","SetFrameStack","SetGlyph","SetGlyphByID","SetGuildBankItem","SetHyperlink","SetInboxItem","SetInstanceLockEncountersComplete","SetInventoryItem","SetInventoryItemByID","SetItemByID","SetLFGCompletionReward","SetLFGDungeonReward","SetLFGDungeonShortageReward","SetLootCurrency","SetLootItem","SetLootRollItem","SetMerchantCostItem","SetMerchantItem","SetMinimumWidth","SetMissingLootItem","SetMountBySpellID","SetOwner","SetPadding","SetPetAction","SetPossession","SetQuestCurrency","SetQuestItem","SetQuestLogCurrency","SetQuestLogItem","SetQuestLogRewardSpell","SetQuestLogSpecialItem","SetQuestRewardSpell","SetSendMailItem","SetShapeshift","SetSocketGem","SetSocketedItem","SetSpellBookItem","SetSpellByID","SetTalent","SetText","SetTotem","SetToyByItemID","SetTradePlayerItem","SetTradeSkillItem","SetTradeTargetItem","SetTrainerService","SetTransmogrifyItem","SetUnit","SetUnitAura","SetUnitBuff","SetUnitConsolidatedBuff","SetUnitDebuff","SetUpgradeItem","SetVoidDepositItem","SetVoidItem","SetVoidWithdrawalItem"}

-- svtime=CreateFrame("Frame")
-- svtime.min=nil
-- svtime:SetScript("OnUpdate",function()
	-- hour,minute=GetGameTime()
	-- if minute~=svtime.min then
		-- svtime.min=minute
		-- Stopwatch_Clear()
		-- Stopwatch_Play()
	-- end
-- end)






