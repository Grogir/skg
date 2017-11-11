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
	x=0,
	y=100,
	iconsize=100,
	spelllist=
	{
		-- MAGE
		[118]="S", -- Polymorph(base)
		[28272]="S", -- Polymorph(pig)
		[28271]="S", -- Polymorph(turtle)
		[61305]="S", -- Polymorph(black cat)
		[61025]="S" , -- Polymorph(serpent)
		[61721]="S", -- Polymorph(rabbit)
		[61780]="S", -- Polymorph(turkey)
		[126819]="S", -- Polymorph(pig2)
		[161353]="S", -- Polymorph(polar bear cub)
		[161355]="S", -- Polymorph(penguin)
		[161354]="S", -- Polymorph(monkey)
		[161372]="S", -- Polymorph(turtle2)
		[45438]="NS", -- Ice Block
		[12472]="NS", -- Icy Veins
		[11958]="NS", -- Cold Snap
		[44572]="NS", -- Deep Freeze
		[113724]="S", -- Ring of Frost

		-- SHAMAN
		[16188]="NS", -- Ancestral Swiftness
		[79206]="S", -- Spiritwalker's Grace
		[8143]="S", -- Temor Totem
		[8177]="S", -- Grounding Totem
		[108280]="S", -- Healing Tide Totem
		[114049]="NS", -- Ascendance
		[114050]="NS", -- Ascendance
		[114051]="NS", -- Ascendance
		[114052]="NS", -- Ascendance
		[51514]="S", -- Hex
		[108269]="NS", -- Capacitor Totem

		-- HUNTER
		[1499]="S", -- Freezing Trap
		[19574]="NS", -- Bestial Wrath
		[19386]="NS", -- Wyvern Sting

		-- DRUID
		[132158]="S", -- Nature's Swiftness
		[29166]="NS", -- Innervate
		[33786]="S", -- Cyclone
		[108291]="NS", -- Heart of the wild
		[108292]="NS", -- Heart of the wild
		[108293]="NS", -- Heart of the wild
		[108294]="NS", -- Heart of the wild
		[33891]="NS", -- Incarnation Tree of Life
		[102543]="NS", -- Incarnation King of the Jungle
		[102560]="NS", -- Incarnation Chosen of Elune
		[22812]="S", -- Barksin
		--[69369]="P", -- Predatory Swiftness

		-- PRIEST
		[605]="NS", -- Dominate Mind
		[586]="NS", -- Fade
		[10060]="S", -- Power Infusion
		[6346]="S", -- Fear Ward
		[8122]="NS", -- Psychic Scream
		[33206]="NS", -- Pain Suppression
		--[17]="S", -- TEST

		-- DEATHKNIGHT
		[108200]="NS", -- Remorseless Winter
		[77606]="S", -- Dark Simulacrum
		[108201]="NS", -- Desecrated Ground

		-- WARRIOR
		[23920]="S", --Spell Reflection
		[114028]="S", --Mass Spell Reflection
		[1719]="NS", -- Recklesness
		[107570]="S", --Storm Bolt

		-- ROGUE
		[51713]="NS", -- Shadow Dance
		[76577]="NS", -- Smoke Bomb
		[31224]="NS", -- Cloak of Shadows

		-- WARLOCK
		[5782]="S", -- Fear
		[108482]="NS", --Unbound Will
		[113861]="NS", -- Dark Souls
		[113858]="NS", -- Dark Souls
		[113860]="NS", -- Dark Souls

		-- MONK
		[122470]="NS", -- Touch of Karma

		-- PALADIN
		[1022]="S", -- Hand of Protection
		[6940]="S", -- Hand of Sacrifice
		[31821]="NS", -- Devotion Aura
		[31884]="NS", -- Avenging Wrath
		[31842]="NS", -- Avenging Wrath
		[1044]="NS", -- Hand of Freedom
		[20066]="S", -- Repentance
		[642]="NS" -- Divine Shield
	},
}}

function SpellAlerter:OnInitialize()
	self.db=SKG.db:RegisterNamespace("SpellAlerter",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("SpellAlerter",self.options,"L SpellAlerter")
end

-- TODO(flo) : add Soul Reaper !!! Change database!
-- TODO(flo) : customize icon display duration, maybe some sounds and later database?

-- SPELL ALERTER

function SpellAlerter:OnEnable()

local COMBATLOG_TARGET=COMBATLOG_OBJECT_TARGET --DEBUG
local COMBATLOG_FRIENDLY=COMBATLOG_OBJECT_REACTION_FRIENDLY --DEBUG
local COMBATLOG_HOSTILE=COMBATLOG_OBJECT_REACTION_HOSTILE
local COMBATLOG_PLAYER=COMBATLOG_OBJECT_TYPE_PLAYER --DEBUG
local SpellCastEvents={SPELL_CAST_START=1,SPELL_CAST_SUCCESS=1,SPELL_CREATE=1,SPELL_AURA_APPLIED=1}
local band=bit.band
local saDB = db.spelllist

local soundDB={NS=0,S=1,P=0,PS=1}
local COMBAT_LOG=COMBATLOG_HOSTILE
-- local COMBAT_LOG=COMBATLOG_PLAYER
self.sa=CreateFrame("FRAME")
sa = self.sa
local sat=sa:CreateTexture(nil,"BACKGROUND")
sat:SetAllPoints(self.sa)
sat:SetTexCoord(0.07,0.93,0.07,0.93)
sa:SetPoint("CENTER",UIParent,"CENTER",db.x,db.y)
sa:SetWidth(db.iconsize)
sa:SetHeight(db.iconsize)
sa:SetScript("OnEvent",function(self,event,...) self[event](self,...) end)
sa:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
currenticon=0
saStart=0
saDur=1.5
function sa:COMBAT_LOG_EVENT_UNFILTERED(_,eventtype,hideCaster,srcGUID,srcName,srcFlags,_,dstGUID,dstName,dstFlags,_,spellID,spellName,_,auraType)
	if SpellCastEvents[eventtype] and band(srcFlags,COMBAT_LOG)==COMBAT_LOG  and saDB[spellID] then
		if eventtype=="SPELL_AURA_APPLIED" and saDB[spellID]~="PS" and saDB[spellID]~="P" then return end
		Alert(spellID)
	end
end
function Alert(spellID)
	sa:SetScript("OnUpdate",SAOnUpdate)
	icon=select(3,GetSpellInfo(spellID))
	sat:SetTexture(icon)
	currenticon=1
	saStart=GetTime()
	sa:Show()
	if(soundDB[saDB[spellID]]==1) then
		PlaySound(5275)
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
	self.sa:SetWidth(db.iconsize)
	self.sa:SetHeight(db.iconsize)
	self.sa:SetPoint("CENTER",UIParent,"CENTER",db.x,db.y)
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
				order=1
			},
			sa={
				type="header",
				name="Spell Alerter",
				order=10
			},
			x={
				type="range",
				name="X",
				softMin=-1000,softMax=1000,step=1,bigStep=5,
				order=11
			},
			y={
				type="range",
				name="Y",
				softMin=-600,softMax=600,step=1,bigStep=5,
				order=12
			},
			iconsize={
				type="range",
				name="Icon Size",
				min=0,max=500,step=1,bigStep=5,softMax=200,
				order=13
			},
			test={
				type="execute",
				name="Test",
				func=function() Alert(118) end,
				order=14
			},
		}
	}
end
