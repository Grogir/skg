--------------------------------------------------
--
-- SpellAlerter.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL
--
--------------------------------------------------

local AddonName,SKG=...
local SpellAlerter=SKG:NewModule("SpellAlerter","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
}}

function SpellAlerter:OnInitialize()
	self.db=SKG.db:RegisterNamespace("SpellAlerter",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("SpellAlerter",self.options,"L SpellAlerter")
end

-- SPELL ALERTER

function SpellAlerter:OnEnable()

local COMBATLOG_TARGET=COMBATLOG_OBJECT_TARGET --DEBUG
local COMBATLOG_FRIENDLY=COMBATLOG_OBJECT_REACTION_FRIENDLY --DEBUG
local COMBATLOG_HOSTILE=COMBATLOG_OBJECT_REACTION_HOSTILE
local COMBATLOG_PLAYER=COMBATLOG_OBJECT_TYPE_PLAYER --DEBUG
local SpellCastEvents={SPELL_CAST_START=1,SPELL_CAST_SUCCESS=1,SPELL_CREATE=1,SPELL_AURA_APPLIED=1}
local band=bit.band
local saDB={
--[22812]="S",[16974]="S",[139]="NS",[69369]="S",[33206]="NS",[6788]="NS",[33786]="NS",[127538]="S",
[118]="NS",[28272]="NS",[28271]="NS",[61305]="NS",[61025]="NS",[61721]="NS",[61780]="NS",[12043]="NS",[108978]="NS",[45438]="NS",[12472]="NS",[11958]="NS",--Mage
[16188]="NS",[79206]="NS",[8177]="NS",[108280]="NS",[16190]="NS",[51514]="S",[108269]="NS",--Chaman
[19503]="S",[60192]="NS",[1499]="NS",[1513]="S",[19574]="NS",[109259]="NS",[19386]="NS",--Chasseur
[132158]="NS",[29166]="NS",[33786]="S",[2637]="S",[50334]="NS",[106951]="NS",[108291]="NS",[108292]="NS",[108293]="NS",[108294]="NS",[33891]="NS",[102543]="NS",[102560]="NS",[69369]="P",[110700]="NS",[110696]="NS",--Druide
[113506]="S",[108921]="S",[605]="NS",[89485]="NS",[10060]="NS",[6346]="NS",--Prêtre
[108200]="NS",[77606]="NS",[46584]="NS",[108201]="NS",[49016]="NS",--Dk
[107574]="NS",[23920]="NS",[114028]="NS",[1719]="NS",--War
[51713]="NS",[76577]="NS",--Rogue
[5782]="NS",[108482]="NS",[113861]="NS",[113858]="NS",[113860]="NS",[111771]="NS",--Démo
[122470]="NS",--Monk
[1022]="NS",[6940]="NS",[1038]="NS",[31821]="NS",[31884]="NS",[1044]="NS",[20066]="S",[642]="NS"--Paladin
}
local soundDB={NS=0,S=1,P=0,PS=1}
local COMBAT_LOG=COMBATLOG_HOSTILE
-- local COMBAT_LOG=COMBATLOG_PLAYER
sa=CreateFrame("FRAME")
local sat=sa:CreateTexture(nil,"BACKGROUND")
sat:SetAllPoints(sa)
sat:SetTexCoord(0.07,0.93,0.07,0.93)
sa:SetPoint("CENTER",UIParent,"CENTER",110,50)
sa:SetWidth(60)
sa:SetHeight(60)
sa:SetScript("OnEvent",function(self,event,...) self[event](self,...) end)
sa:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
currenticon=0
saStart=0
saDur=1.5
function sa:COMBAT_LOG_EVENT_UNFILTERED(_,eventtype,hideCaster,srcGUID,srcName,srcFlags,_,dstGUID,dstName,dstFlags,_,spellID,spellName,_,auraType)
	--if(spellName) then print(srcName.."=>"..spellName.." : "..spellID.." : "..eventtype) end -- Permet de récupérer le type de l'event et les ID des spells
	if SpellCastEvents[eventtype] and band(srcFlags,COMBAT_LOG)==COMBAT_LOG  and saDB[spellID] then 
		if eventtype=="SPELL_AURA_APPLIED" and saDB[spellID]~="PS" and saDB[spellID]~="P" then return end
		self:SetScript("OnUpdate",SAOnUpdate)
		icon=select(3,GetSpellInfo(spellID))
		sat:SetTexture(icon)
		currenticon=1
		saStart=GetTime()
		sa:Show()
		if(soundDB[saDB[spellID]]==1) then
			PlaySoundFile("Interface\\Addons\\Prat-3.0\\sounds\\Text1.ogg") --"Sound\\Doodad\\BellTollAlliance.wav"
		end
	end
end
function SAOnUpdate()
	if(currenticon==0) then sa:Hide() return end
	if(currenticon==1) then 
		if(GetTime()>saStart+saDur) then
			sa:Hide()
			currenticon=0
			saStart=0
			sa:SetScript("OnUpdate",nil)
		end
	end
end

end
function SpellAlerter:OnDisable()
end
function SpellAlerter:ApplySettings()
end

-- OPTIONS

local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	SpellAlerter:ApplySettings()
end
function SpellAlerter:GetOptions()
	return {
		order=5,
		type="group",
		name="Spell Alerter",
		desc="Displays important spells",
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
			sa={
				type="header",
				name="Spell Alerter",
				order=10,
			},
		}
	}
end
