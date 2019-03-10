--------------------------------------------------
--
-- SpellAlerter.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL
--
--------------------------------------------------
-- MAJ DB
-- TODO(flo) : maybe some sounds

local AddonName,SKG=...
local SpellAlerter=SKG:NewModule("SpellAlerter","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
	x=0,
	y=100,
	iconsize=100,
	duration=1.5,
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
		[45438]="N", -- Ice Block
		[12472]="N", -- Icy Veins
		[113724]="S", -- Ring of Frost

		-- SHAMAN
		[79206]="N", -- Spiritwalker's Grace
		[108280]="S", -- Healing Tide Totem
		[114049]="N", -- Ascendance
		[114050]="N", -- Ascendance
		[114051]="N", -- Ascendance
		[114052]="N", -- Ascendance
		[51514]="S", -- Hex
		[192058]="N", -- Capacitor Totem
		[204331]="N", -- Totem de réplique

		-- HUNTER
		-- [1499]="S", -- Freezing Trap
		[19574]="N", -- Bestial Wrath
		[19386]="N", -- Wyvern Sting

		-- DRUID
		[29166]="N", -- Innervate
		[33786]="S", -- Cyclone
		[33891]="N", -- Incarnation Tree of Life
		[102543]="N", -- Incarnation King of the Jungle
		[102560]="N", -- Incarnation Chosen of Elune
		[22812]="S", -- Barksin
		[774]="S", -- TEST

		-- PRIEST
		[605]="N", -- Dominate Mind
		[586]="N", -- Fade
		[10060]="S", -- Power Infusion
		[8122]="N", -- Psychic Scream
		[33206]="N", -- Pain Suppression
		--[17]="S", -- TEST

		-- DEATHKNIGHT
		[77606]="S", -- Dark Simulacrum
		[108201]="N", -- Desecrated Ground

		-- WARRIOR
		[23920]="S", --Spell Reflection
		[1719]="N", -- Recklesness
		[107570]="S", --Storm Bolt

		-- ROGUE
		-- [51713]="N", -- Shadow Dance
		[76577]="N", -- Smoke Bomb
		[31224]="N", -- Cloak of Shadows

		-- WARLOCK
		[5782]="S", -- Fear
		[113858]="N", -- Dark Souls
		[113860]="N", -- Dark Souls

		-- MONK
		[122470]="N", -- Touch of Karma

		-- PALADIN
		[1022]="S", -- Hand of Protection
		[6940]="S", -- Hand of Sacrifice
		[31821]="N", -- Devotion Aura
		[31884]="N", -- Avenging Wrath
		[1044]="N", -- Hand of Freedom
		[20066]="S", -- Repentance
		[642]="N", -- Divine Shield

		-- [12]="N", -- test
	},
}}

function SpellAlerter:OnInitialize()
	self.db=SKG.db:RegisterNamespace("SpellAlerter",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	self:LoadSpellList()
	SKG:RegisterModuleOptions("SpellAlerter",self.options,"L SpellAlerter")
end

-- SPELL ALERTER

function SpellAlerter:Alert(spellID)
	self.frame:SetScript("OnUpdate",function()
		if(self.currenticon==0) then self.frame:Hide() return end
		if(self.currenticon==1) then
			if GetTime()>self.start+db.duration then
				self.frame:Hide()
				self.currenticon=0
				self.start=0
				self.frame:SetScript("OnUpdate",nil)
			end
		end
	end)
	self.frame.t:SetTexture(select(3,GetSpellInfo(spellID)))
	self.currenticon=1
	self.start=GetTime()
	self.frame:Show()
	if db.spelllist[spellID]=="S" then
		PlaySound(5275)
	end
end

function SpellAlerter:OnEnable()
	local SpellCastEvents={SPELL_CAST_START=1,SPELL_CAST_SUCCESS=1,SPELL_CREATE=1}--,SPELL_AURA_APPLIED=1}
	local band=bit.band
	local COMBAT_LOG=COMBATLOG_OBJECT_REACTION_HOSTILE
	-- local COMBAT_LOG=COMBATLOG_OBJECT_TYPE_PLAYER -- debug purposes

	local f=CreateFrame("FRAME")
	self.frame=f
	f.t=f:CreateTexture(nil,"BACKGROUND")
	f.t:SetAllPoints(f)
	f.t:SetTexCoord(0.07,0.93,0.07,0.93)
	f:SetPoint("CENTER",UIParent,"CENTER",db.x,db.y)
	f:SetSize(db.iconsize,db.iconsize)
	
	f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	f:SetScript("OnEvent",function()
		local _,eventtype,_,_,_,srcFlags,_,_,_,_,_,spellID,_,_,_=CombatLogGetCurrentEventInfo()
		if SpellCastEvents[eventtype] and band(srcFlags,COMBAT_LOG)==COMBAT_LOG and db.spelllist[spellID] then
			-- if eventtype=="SPELL_AURA_APPLIED" and self.saDB[spellID]~="PS" and self.saDB[spellID]~="P" then return end
			self:Alert(spellID)
		end
	end)
	self.currenticon=0
	self.start=0
end

function SpellAlerter:OnDisable()
	if self.frame then
		self.frame:UnregisterAllEvents()
		self.frame:Hide()
		self.frame=nil
	end
end
function SpellAlerter:ApplySettings()
	self.frame:SetSize(db.iconsize,db.iconsize)
	self.frame:SetPoint("CENTER",UIParent,"CENTER",db.x,db.y)
end
function SpellAlerter:ReloadOptions()
	self.options=self:GetOptions()
	self:LoadSpellList()
	SKG:RegisterModuleOptions("SpellAlerter",self.options,"L SpellAlerter")
end

-- OPTIONS

local function getter(info)
	local name=info.arg or info[#info]
	if tonumber(name) then
		return db.spelllist[tonumber(name)]=="S" and true or false
	end
	return db[name]
end
local function setter(info,value)
	local name=info.arg or info[#info]
	if tonumber(name) then
		db.spelllist[tonumber(name)]=value and "S" or "N"
	else
		db[name]=value
	end
	SpellAlerter:ApplySettings()
end
function SpellAlerter:LoadSpellList()
	local i=1
	local t={}
	for id,s in pairs(db.spelllist) do
		if s then
			t[i]={id,s,GetSpellInfo(id) or "?"}
			i=i+1
		end
	end
	table.sort(t,function(a,b) return a[3]==b[3] and a[1]<b[1] or a[3]<b[3] end)
	for i=1,#t do
		local id,s=t[i][1],t[i][2]
		local name,_,icon=GetSpellInfo(id)
		name=name or "Invalid spell"
		SpellAlerter.options.args["d"..id]={
			type="description",
			name=name.." |cff666666("..id..")|r",
			fontSize="medium",
			image=icon,
			width="double",
			order=i*3+30
		}
		SpellAlerter.options.args[tostring(id)]={
			type="toggle",
			name="Sound",
			width="half",
			order=i*3+31
		}
		SpellAlerter.options.args["r"..id]={
			type="execute",
			name="Remove",
			func=function()
				if defaults.global.spelllist[id] then db.spelllist[id]=false else db.spelllist[id]=nil end --on ne peut pas supprimer les defaults
				self:ReloadOptions()
			end,
			width="half",
			order=i*3+32
		}
	end
end
local spellid=""
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
				get=function() return self:IsEnabled() end,
				set=function(i,v) db.enabled=v if v then self:Enable() else self:Disable() end end,
				order=1,
			},
			h1={
				type="header",
				name="Settings",
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
			duration={
				type="range",
				name="Alert Duration",
				min=0,max=60,step=0.1,bigStep=0.1,softMax=5,
				order=14
			},
			test={
				type="execute",
				name="Test",
				func=function() if db.enabled then self:Alert(118) end end,
				order=15
			},
			h2={
				type="header",
				name="Spell List",
				order=20
			},
			space={
				type="description",
				name="",
				width="normal",
				order=21
			},
			spellid={
				type="input",
				name="New spell",
				get=function() return spellid end,
				set=function(i,v) spellid=v end,
				desc="Spell id",
				order=22
			},
			add={
				type="execute",
				name="Add",
				width="half",
				func=function()
					local id=tonumber(spellid)
					if id and not db.spelllist[id] then db.spelllist[id]="N" end
					self:ReloadOptions()
				end,
				order=23
			},
		}
	}
end
