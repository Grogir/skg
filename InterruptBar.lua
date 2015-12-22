--------------------------------------------------
--
-- InterruptBar.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL
--
--------------------------------------------------

-- TODO(flo) :
	-- do i miss some spells ?
	-- try to implement one line par arena frame, use GetArenaOpponentSpec or UnitAura to set each line
	-- split arena from battlegrounds/worldmap implementations
	-- maybe make a file generator that contains all spells from wowdb?


local AddonName,SKG=...
local InterruptBar=SKG:NewModule("InterruptBar","AceEvent-3.0")
local Database

local Defaults={global={
	enabled=true,
	fl=1,
	x=-124,
	y=-50,
	size=30,
	line=9,
	list={
	-- Death Knight --------------------------------
		{47476,60}, -- Strangulate
		{47528,15}, -- Mind Freeze
		{47481,60}, -- Gnaw
		{91802,30}, -- Shambling Rush
		{108194 ,30}, -- Asphyxiate
		{49576,25}, -- Death Grip
		{48707,45}, -- Anti-magic shell
		{48743,120}, -- Death Pact
		{48792,180}, -- Icebound Fortitude
		{49028,90}, -- Dancing Rune Weapon
		{49039,120}, -- Lichborne
		{51052,120}, -- Anti magi zone
		{77606,60}, -- Dark Simulacrum
	-- Druid --------------------------------
		{78675,60}, -- Solar Beam
		{106839 ,15}, -- Skull Bash
		{5211 ,50}, -- Mighty Bash
		{102359 ,30}, -- Mass Entanglement
		{99,30}, -- Incapacitating Roar
		{132158 ,60}, -- Nature's Swiftness
		{102280,30}, -- Displacer Beast
		{132469 ,30}, -- Typhoon
		{61336,180 }, -- Survival Instincts
		{50334,180 }, -- Berserk
	-- Hunter --------------------------------
		{1499,30}, -- Freezing Trap -- TODO(flo): split spec ? (20 secs for survival hunter)
		{19263,180 }, -- Deterrence
		{19386,45}, -- Wyvern Sting
		{19574,60}, -- Bestial Wrath
		{131894 ,60}, -- A murder of Crows
	-- Mage --------------------------------
		{2139,24}, -- Counterspell
		{44572,30}, -- Deep Freeze
		{113724 ,45}, -- Ring of Frost
		{102051 ,20}, -- Frostjaw
		{31661,20}, -- Dragon's Breath
		{66 ,300 }, -- Invisibility
		{1953 ,15}, -- Blink
		{11958,180}, -- Cold Snap
		{12472,180 }, -- Icy Veins
		{45438,300 }, -- Ice Block
	-- Monk --------------------------------
		{116705,15}, -- Spear Hand Strike (kick)
		{115176 ,180 }, -- Zen Meditation
		{115203,180 }, -- Fortifying Brew
		{116844 ,45}, -- Ring of Peace
		{116849 ,120 }, -- Life Cocoon
		{119381 ,45}, -- Leg Sweep
		{119996 ,25}, -- Transcendence Transfer
		{122470 ,90}, -- Touch of Karma
		{122783 ,90}, -- Diffuse Magic
		{137562 ,120 }} -- Nimber Brew
	-- Paladin --------------------------------
		{96231,15}, -- Rebuke
		{853,60}, -- Hammer of Justice
		{105593,30}, -- Fist of Justice
		{20066,15}, -- Repentance
		{31884,120}, -- Avenging Wrath
		{31821,180}, -- Devotion Aura
		{642,300}, -- Divine Shield
		{1022,300}, -- Hand of Protection
		{1044,25}, -- Hand of Freedom
		{6940,120}, -- Hand of Sacrifice
		{114039,30}, -- Hand of Purity
	-- Priest --------------------------------
		{8122,42}, -- Psychic Scream
		{15487,45}, -- Silence
		{64044 ,45}, -- Psychic Horror
		{33206 ,180 }, -- Pain Suppression
		{47585 ,120 }, -- Dispersion
		{47788 ,180 }, -- Guardian Spirit
	-- Rogue --------------------------------
		{1766,15}, -- Kick
		{408 ,20}, -- Kidney Shot
		{1856 ,120 }, -- Vanish
		{2094 ,120 }, -- Blind
		{2983 ,60}, -- Sprint
		{5277 ,180 }, -- Evasion
		{13750,180 }, -- Adrenaline Rush
		{14185,300 }, -- Preparation
		{31224,60}, -- Cloak of Shadows
		{36554,20}, -- Shadow Step
		{51713,60}, -- Shadow Dance
		{74001,120 }, -- Combat Readiness
		{76577,180 }, -- Smoke Bomb
	-- Shaman --------------------------------
		{57994,12}, -- Wind Shear
		{51490,45}, -- Thunderstorm
		{51514 ,45}, -- Hex
		{108269 ,45}, -- Capacitor Totem
		{8143,60}, -- Tremor Totem
		{8177,25}, -- Grounding Totem
		{30823,60}, -- Shamanistic Rage
		{108271 ,90}, -- Astral Shift
		{108273 ,60}, -- Windwalk Totem
		{98008 ,180 }, -- Spirit Link Totem
		{16188 ,90 }, -- Ancestral Swiftness
		{108285 ,180 }, -- Call of the Elements
	-- Warlock --------------------------------
		{115781 ,24}, -- Optical Blast (Observer)
		{19647 ,24}, -- Spell Lock (Felhunter)
		{171138 ,24}, -- Shadow Lock (Doomguard, Terrorguard) NOTE(flo): exists ?
		{89766,30}, -- Axe Toss (Felguard, Wrathguard)
		{6358,30}, -- Seduction (Succubus)
		{115268 ,30}, -- Mesmerize (Shivarra)
		{115770 ,25}, -- Fellash (Shivarra)
		{6360,25}, -- Whiplash (Succubus)
		{48020,26}, -- Demonic Circle : Teleport
		{113861,120}, -- Dark Souls Demonology
		{113860,120}, -- Dark Souls Affliction
		{113858,120}, -- Dark Souls Destruction
	-- Warrior --------------------------------
		{6552,15}, -- Pummel
		{1719 ,180 }, -- Recklessness
		{23920,25}, -- Spell Reflection
		{114028 ,30}, -- Mass Spell Reflection
		{46968,20}, -- Shockwave
		{107570 ,30}, -- Storm Bolt
		{871 ,180 }, -- Shield wall
		{3411,30}, -- Intervene
		{114029 ,30}, -- Safeguard
		{5246 ,90}, -- Intimidating Shout
		{6544 ,45}, -- Heroic Leap
		{18499,30}, -- Berserker Rage
	}
}}

function InterruptBar:OnInitialize()
	self.db=SKG.db:RegisterNamespace("InterruptBar",Defaults,true)
	Database=self.db.global
	self:SetEnabledState(Database.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("InterruptBar",self.options,"L InterruptBar")
end

-- INTERRUPT BAR

function InterruptBar:ApplySettings()
	self:OnDisable()
	self:OnEnable()
end

function InterruptBar:Event()
    self:ApplySettings()
end

function InterruptBar:OnEnable()
	_G.InterruptBarDebug = self
	self.framelist = {}
	self.list = Database.list
	for Index, Spell in ipairs(Database.list) do
		_G["ib"..Index]=self:CreateFrame(Index, Spell[1],
			Database.x+(Database.size+1)*math.ceil((Index-1)%Database.line),
			Database.y-(Database.size+1)*math.ceil(Index/Database.line))
		self:UpdateFrame(_G["ib"..Index],Spell[1],Spell[2])
	end
	self:Launch()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Event")
end

function InterruptBar:OnDisable()
	for Index, Spell in ipairs(Database.list) do
		_G["ib"..Index]=nil
		self.framelist[Index]:Hide()
	end
	self.framelist = {}
	self.list = nil
	_G.InterruptBarDebug = nil
end

function InterruptBar:Launch()
    for Index,Spell in ipairs(self.list) do
        local Frame=_G["ib"..Index]
        if(Database.fl==0)then
            Frame:Show() Frame.CD:Show()
        else
            Frame:Hide() Frame.CD:Hide()
        end
    end
end

local function Test()
	for Index,Spell in ipairs(InterruptBar.list) do
        local Frame=_G["ib"..Index]
		InterruptBar:Activatebtn(Frame.CD, GetTime(), Spell[2])
	end
end

local function StopTest()
	InterruptBar:ApplySettings()
end


function InterruptBar:CreateFrame(Index, SpellId, PosX, PosY)
    local _,_,Texture=GetSpellInfo(SpellId)
    local Frame=CreateFrame("Frame",nil,UIParent)
	table.insert(self.framelist, Frame)
    Frame:SetPoint("CENTER", PosX, PosY)
    Frame:SetSize(Database.size, Database.size)
    Frame.Texture=Frame:CreateTexture(nil,"BORDER")
    Frame.Texture:SetAllPoints(true)
    Frame.Texture:SetTexture(Texture)
    Frame.CD=CreateFrame("Cooldown",nil,Frame)
    Frame.CD:SetAllPoints(Frame)
    return Frame
end

--Death Knight
	--250 - Blood
	--251 - Frost
	--252 - Unholy
--Druid
	--102 - Balance
	--103 - Feral Combat
	--104 - Guardian
	--105 - Restoration
--Hunter
	--253 - Beast Mastery
	--254 - Marksmanship
	--255 - Survival
--Mage
	--62 - Arcane
	--63 - Fire
	--64 - Frost
--Monk
	--268 - Brewmaster
	--269 - Windwalker
	--270 - Mistweaver
--Paladin
	--65 - Holy
	--66 - Protection
	--70 - Retribution
--Priest
	--256 Discipline
	--257 Holy
	--258 Shadow
--Rogue
--	259 - Assassination
--	260 - Combat
--	261 - Subtlety
--Shaman
	--262 - Elemental
	--263 - Enhancement
	--264 - Restoration
--Warlock
	--265 - Affliction
	--266 - Demonology
	--267 - Destruction
--Warrior
	--71 - Arms
	--72 - Fury
	--73 - Protection

function InterruptBar:DEBUGGetListForSpecifiedSpec(SpecID)
	local _,SpecName,_,_,_,_,ClassName =  GetSpecializationInfoByID(SpecID)
	print("Spec = " .. SpecName)
	print("Class = " .. ClassName)
	for Index, Spells in ipairs(self.list) do
		local SpellSpecName, SpellClassName = IsSpellClassOrSpec(Spells[1])
		print("ID = " .. Spells[1] .. " Class = " .. SpellClassName .. " Spec = " .. SpellSpecName)
		if(SpellSpec == nil) then
			if(ClassName == SpellClassName) then
				print(Spells[1] .. ", " .. Spells[2])
			end
		else
			if(ClassName == SpellClass and SpecName == SpellSpec) then
				print(Spells[1] .. ", " .. Spells[2])
			end
		end
	end
end

-- TODO(flo) : find a way to call this function and test it!
function InterruptBar:GetListForSpec()
	local ArenaEnemyCount = GetNumArenaOpponents()
	local ArenaEnemySpecKnown = GetNumArenaOpponentSpecs()

	print("Arena Enemy Count" .. ArenaEnemyCount)
	print("Known Arena Spec" .. ArenaEnemySpecKnow)
	-- TODO(flo) : compare ArenaEnemyCount and ArenaEnemySpecKnow and launch
	-- the rest of the function if they're equals otherwise relaunch?(when?)!
	self.arenalist = {}
	for EnemyIndex=1, ArenaEnemyCount do
		local SpecID = GetArenaOpponentSpec(EnemyIndex)
		local _,SpecName,_,_,_,_,ClassName =  GetSpecializationInfoByID(SpecID)
		local ListCount = 1;
		for Index, Spells in ipairs(self.list) do
			self.arenalist[EnemyIndex] = {}
			local SpellSpec, SpellClass = IsSpellClassOrSpec(Spells[1])
			if(SpellSpec == nil) then
				if(ClassName == SpellClass) then
					self.arenalist[EnemyIndex][ListCount] = {Spells[1], Spells[2]}
					ListCount = ListCount + 1
				end
			else
				if(ClassName == SpellClass and SpecName == SpellSpec) then
					self.arenalist[EnemyIndex][ListCount] = {Spells[1], Spells[2]}
					ListCount = ListCount + 1
				end
			end
		end
	end
end

function InterruptBar:UpdateFrame(Frame, SpellId, SpellCD)
    Frame:SetScript("OnEvent",function(_,_,_,Event,_,_,_,SourceFlags,_,_,_,_,_,ID)
        if(Event=="SPELL_CAST_SUCCESS"and ID==SpellId)then
            if bit.band(SourceFlags,0x40)==0x40 then --or bit.band(b,0x100)==0x100 then
							-- 0x40 ==  COMBATLOG_OBJECT_REACTION_HOSTILE
                self:Activatebtn(Frame.CD,GetTime(),SpellCD)
            end
        end
    end)
    Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local function InterruptBar_OnUpdate(self)
	if GetTime()>=self.start+self.duration then
		InterruptBar:Deactivatebtn(self)
    end
end


function InterruptBar:Activatebtn(Frame, Time ,CD)
	Frame:GetParent():Show()
	Frame.start=Time
	Frame.duration=CD
	Frame:SetCooldown(Time,CD)
	if(Database.fl==1) then
		Frame:SetScript("OnUpdate", InterruptBar_OnUpdate)
	end
end

function InterruptBar:Deactivatebtn(Frame)
	Frame:GetParent():Hide()
	Frame:SetScript("OnUpdate",nil)
end

-- OPTIONS

local function getter(info)
	return Db[info.arg or info[#info]]
end
local function setter(info,value)
	Db[info.arg or info[#info]]=value
	InterruptBar:ApplySettings()
end
function InterruptBar:GetOptions()
	return {
		order=3,
		type="group",
		name="Interrupt Bar",
		desc="Interrupt Bar",
		childGroups="tab",
		get=getter,
		set=setter,
		args={
			enabled={
				type="toggle",
				name="Enable",
				desc="Enable the module",
				get=getter,
				set=setter,
				order=1,
			},
			ib={
				type="header",
				name="Interrupt Bar",
				order=10,
			},
			x={
				type="range",
				name="X",
				min=-500,max=500,step=1,bigStep=5,
				order=11
			},
			y={
				type="range",
				name="Y",
				min=-500,max=500,step=1,bigStep=5,
				order=12
			},
			size={
				type="range",
				name="Size",
				min=5,max=100,step=1,bigStep=5,
				order=13
			},
			line={
				type="range",
				name="Icons per line",
				min=1,max=50,step=1,bigStep=1,
				order=14
			},
			fl={
				type="select",
				name="Display",
				values={[0]="Always","Standard","Persistent"},
				-- min=0,max=2,step=1,bigStep=1,
				order=15
			},
			test={
						type="execute",
						name="Test",
						func=Test,
						order=16
			},
			stoptest={
						type="execute",
						name="Stop Test",
						func=StopTest,
						order=16
			},
		}
	}
end
