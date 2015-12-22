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

-- DEATHKNIGHT

-- DRUID

-- HUNTER

-- MAGE
-- MONK
-- PALADIN
-- PRIEST
-- ROGUE
-- SHAMAN
-- WARLOCK
-- WARRIOR


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
	spectoadd=65,
	list={

	-- Death Knight --------------------------------------------------------------
		--250 - Blood
		--251 - Frost
		--252 - Unholy
		{"DEATHKNIGHT",
			{
				{{250, 251, 252}, 47476, 60}, -- Strangulate
				{{250, 251, 252}, 47528, 15}, -- Mind Freeze
				{{250, 251, 252}, 47481, 60}, -- Gnaw
				{{250, 251, 252}, 91802, 30}, -- Shambling Rush
				{{250, 251, 252}, 108194, 30}, -- Asphyxiate
				{{250, 251, 252}, 49576, 25}, -- Death Grip
				{{250, 251, 252}, 48707, 45}, -- Anti-magic shell
				{{250, 251, 252}, 48743, 120}, -- Death Pact
				{{250, 251, 252}, 48792, 180}, -- Icebound Fortitude
				{{250, 251, 252}, 49028, 90}, -- Dancing Rune Weapon
				{{250, 251, 252}, 49039, 120}, -- Lichborne
				{{250, 251, 252}, 51052, 120}, -- Anti magi zone
				{{250, 251, 252}, 77606, 60} -- Dark Simulacrum
			}
		},

	-- Druid ---------------------------------------------------------------------
		--102 - Balance
		--103 - Feral Combat
		--104 - Guardian
		--105 - Restoration
		{"DRUID",
			{
				{{102, 103, 104, 105}, 78675, 60}, -- Solar Beam
				{{102, 103, 104, 105}, 106839, 15}, -- Skull Bash
				{{102, 103, 104, 105}, 5211, 50}, -- Mighty Bash
				{{102, 103, 104, 105}, 102359, 30}, -- Mass Entanglement
				{{102, 103, 104, 105}, 99, 30}, -- Incapacitating Roar
				{{102, 103, 104, 105}, 132158, 60}, -- Nature's Swiftness
				{{102, 103, 104, 105}, 102280, 30}, -- Displacer Beast
				{{102, 103, 104, 105}, 132469, 30}, -- Typhoon
				{{102, 103, 104, 105}, 61336, 180}, -- Survival Instincts
				{{102, 103, 104, 105}, 50334, 180} -- Berserk
			}
		},

	-- Hunter --------------------------------------------------------------------
		--253 - Beast Mastery
		--254 - Marksmanship
		--255 - Survival
		{"HUNTER",
			{
				{{253, 254}, 1499, 30}, -- Freezing Trap
				{{255}, 1499, 20}, -- Freezing Trap (Survival)
				{{253, 254, 255}, 19263, 180}, -- Deterrence
				{{253, 254, 255}, 19386, 45}, -- Wyvern Sting
				{{253, 254, 255}, 19574, 60}, -- Bestial Wrath
				{{253, 254, 255}, 131894, 60} -- A murder of Crows
			}
		},

	-- Mage ----------------------------------------------------------------------
			--62 - Arcane
			--63 - Fire
			--64 - Frost
		{"MAGE",
			{
				{{62, 63, 64}, 2139, 24}, -- Counterspell
				{{62, 63, 64}, 44572, 30}, -- Deep Freeze
				{{62, 63, 64}, 113724, 45}, -- Ring of Frost
				{{62, 63, 64}, 102051, 20}, -- Frostjaw
				{{62, 63, 64}, 31661, 20}, -- Dragon's Breath
				{{62, 63, 64}, 66, 300}, -- Invisibility
				{{62, 63, 64}, 1953, 15}, -- Blink
				{{62, 63, 64}, 11958, 180}, -- Cold Snap
				{{62, 63, 64}, 12472, 180}, -- Icy Veins
				{{62, 63, 64}, 45438, 300}, -- Ice Block
			}
		},

	-- Monk ----------------------------------------------------------------------
		--268 - Brewmaster
		--269 - Windwalker
		--270 - Mistweaver
		{"MONK",
			{
				{{268, 269, 270}, 116705, 15}, -- Spear Hand Strike (kick)
				{{268, 269, 270}, 115176, 180}, -- Zen Meditation
				{{268, 269, 270}, 115203, 180}, -- Fortifying Brew
				{{268, 269, 270}, 116844, 45}, -- Ring of Peace
				{{268, 269, 270}, 116849, 120}, -- Life Cocoon
				{{268, 269, 270}, 119381, 45}, -- Leg Sweep
				{{268, 269, 270}, 119996, 25}, -- Transcendence Transfer
				{{268, 269, 270}, 122470, 90}, -- Touch of Karma
				{{268, 269, 270}, 122783, 90}, -- Diffuse Magic
				{{268, 269, 270}, 137562, 120} -- Nimber Brew
			}
		},

	-- Paladin -------------------------------------------------------------------
			--65 - Holy
			--66 - Protection
			--70 - Retribution
		{"PALADIN",
			{
				{{65, 66, 67}, 96231, 15}, -- Rebuke
				{{65, 66, 67}, 853, 60}, -- Hammer of Justice
				{{65, 66, 67}, 105593, 30}, -- Fist of Justice
				{{65, 66, 67}, 20066, 15}, -- Repentance
				{{65, 66, 67}, 31884, 120}, -- Avenging Wrath
				{{65, 66, 67}, 31821, 180}, -- Devotion Aura
				{{65, 66, 67}, 642, 300}, -- Divine Shield
				{{65, 66, 67}, 1022, 300}, -- Hand of Protection
				{{65, 66, 67}, 1044, 25}, -- Hand of Freedom
				{{65, 66, 67}, 6940, 120}, -- Hand of Sacrifice
				{{65, 66, 67}, 114039, 30} -- Hand of Purity
			}
		},

	-- Priest --------------------------------------------------------------------
		--256 Discipline
		--257 Holy
		--258 Shadow
		{"PRIEST",
			{
				{{256, 257, 258}, 8122, 42}, -- Psychic Scream
				{{256, 257, 258}, 15487, 45}, -- Silence
				{{256, 257, 258}, 64044, 45}, -- Psychic Horror
				{{256, 257, 258}, 33206, 180}, -- Pain Suppression
				{{256, 257, 258}, 47585, 120}, -- Dispersion
				{{256, 257, 258}, 47788, 180} -- Guardian Spirit
			}
		},

	-- Rogue ---------------------------------------------------------------------
		--259 - Assassination
		--260 - Combat
		--261 - Subtlety
		{"ROGUE",
			{
				{{259, 260, 261}, 1766, 15}, -- Kick
				{{259, 260, 261}, 408, 20}, -- Kidney Shot
				{{259, 260, 261}, 1856, 120}, -- Vanish
				{{259, 260, 261}, 2094, 120}, -- Blind
				{{259, 260, 261}, 2983, 60}, -- Sprint
				{{259, 260, 261}, 5277, 180}, -- Evasion
				{{259, 260, 261}, 13750, 180}, -- Adrenaline Rush
				{{259, 260, 261}, 14185, 300}, -- Preparation
				{{259, 260, 261}, 31224, 60}, -- Cloak of Shadows
				{{259, 260, 261}, 36554, 20}, -- Shadow Step
				{{259, 260, 261}, 51713, 60}, -- Shadow Dance
				{{259, 260, 261}, 74001, 120}, -- Combat Readiness
				{{259, 260, 261}, 76577, 180} -- Smoke Bomb
			}
		},

	-- Shaman --------------------------------------------------------------------
		--262 - Elemental
		--263 - Enhancement
		--264 - Restoration
		{"SHAMAN",
			{
				{{262, 263, 264}, 57994, 12}, -- Wind Shear
				{{262, 263, 264}, 51490, 45}, -- Thunderstorm
				{{262, 263, 264}, 51514, 45}, -- Hex
				{{262, 263, 264}, 108269, 45}, -- Capacitor Totem
				{{262, 263, 264}, 8143, 60}, -- Tremor Totem
				{{262, 263, 264}, 8177, 25}, -- Grounding Totem
				{{262, 263, 264}, 30823, 60}, -- Shamanistic Rage
				{{262, 263, 264}, 108271, 90}, -- Astral Shift
				{{262, 263, 264}, 108273, 60}, -- Windwalk Totem
				{{262, 263, 264}, 98008, 180}, -- Spirit Link Totem
				{{262, 263, 264}, 16188, 90}, -- Ancestral Swiftness
				{{262, 263, 264}, 108285, 180} -- Call of the Elements
			}
		},

	-- Warlock -------------------------------------------------------------------
			--265 - Affliction
			--266 - Demonology
			--267 - Destruction
		{"WARLOCK",
			{
				{{265, 266, 267}, 115781, 24}, -- Optical Blast (Observer)
				{{265, 266, 267}, 19647, 24}, -- Spell Lock (Felhunter)
				{{265, 266, 267}, 171138, 24}, -- Shadow Lock (Doomguard, Terrorguard) NOTE(flo): exists ?
				{{265, 266, 267}, 89766, 30}, -- Axe Toss (Felguard, Wrathguard)
				{{265, 266, 267}, 6358, 30}, -- Seduction (Succubus)
				{{265, 266, 267}, 115268, 30}, -- Mesmerize (Shivarra)
				{{265, 266, 267}, 115770, 25}, -- Fellash (Shivarra)
				{{265, 266, 267}, 6360, 25}, -- Whiplash (Succubus)
				{{265, 266, 267}, 48020, 26}, -- Demonic Circle : Teleport
				{{265, 266, 267}, 113861, 120}, -- Dark Souls Demonology
				{{265, 266, 267}, 113860, 120}, -- Dark Souls Affliction
				{{265, 266, 267}, 113858, 120} -- Dark Souls Destruction
			}
		},

	-- Warrior -------------------------------------------------------------------
			--71 - Arms
			--72 - Fury
			--73 - Protection
		{"WARRIOR",
			{
				{{71, 72, 73}, 6552, 15}, -- Pummel
				{{71, 72, 73}, 1719, 180}, -- Recklessness
				{{71, 72, 73}, 23920, 25}, -- Spell Reflection
				{{71, 72, 73}, 114028, 30}, -- Mass Spell Reflection
				{{71, 72, 73}, 46968, 20}, -- Shockwave
				{{71, 72, 73}, 107570, 30}, -- Storm Bolt
				{{71, 72, 73}, 871, 180}, -- Shield wall
				{{71, 72, 73}, 3411, 30}, -- Intervene
				{{71, 72, 73}, 114029, 30}, -- Safeguard
				{{71, 72, 73}, 5246, 90}, -- Intimidating Shout
				{{71, 72, 73}, 6544, 45}, -- Heroic Leap
				{{71, 72, 73}, 18499,30} -- Berserker Rage
			}
		}

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

function InterruptBar:OnEnable()
	_G.ibDEBUG = self
	self.framelist = {}
	self.list = Database.list
	local Index = 1
	for ClassIndex, ClassList in ipairs(Database.list) do
		for SpellIndex, Spell in ipairs(ClassList[2]) do
			self:CreateFrame(Index, Spell[2],
				Database.x+(Database.size+1)*math.ceil((Index-1)%Database.line),
				Database.y-(Database.size+1)*math.ceil(Index/Database.line))
			self:UpdateFrame(self.framelist[Index],Spell[2],Spell[3])
			Index = Index + 1
		end
	end
	self:Launch()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Event")
end

function InterruptBar:OnDisable()
	local Index = 1
	for ClassIndex, ClassList in ipairs(Database.list) do
		for SpellIndex, Spell in ipairs(ClassList[2]) do
			self.framelist[Index]:Hide()
			self.framelist[Index] = nil
			Index = Index + 1
		end
	end
	self.framelist = {}
	self.list = nil
end

function InterruptBar:Launch()
		local Index = 1
		for ClassIndex, ClassList in ipairs(self.list) do
	    for SpellIndex, Spell in ipairs(ClassList[2]) do
	        local Frame=self.framelist[Index]
	        if(Database.fl==0)then
	            Frame:Show() Frame.CD:Show()
	        else
	            Frame:Hide() Frame.CD:Hide()
	        end
					Index = Index + 1
	    end
		end
end

local function Test()
	local Index = 1
	for ClassIndex, ClassList in ipairs(InterruptBar.list) do
		for SpellIndex, Spell in ipairs(ClassList[2]) do
      local Frame=InterruptBar.framelist[Index]
			InterruptBar:Activatebtn(Frame.CD, GetTime(), Spell[3])
			Index = Index + 1
		end
	end
end

local function StopTest()
	InterruptBar:ApplySettings()
end

local function AddSpec(SpecID)
end

function InterruptBar:IsSpecFoundForSpell(Spec, SpellSpecList)
	for Index=1, getn(SpellSpecList) do
		if(SpellSpecList[Index] == Spec) then
			return true
		end
	end
	return false
end

function InterruptBar:DEBUGGetList()
	for ClassIndex, ClassList in ipairs(self.list) do
		for SpellIndex, Spell in ipairs(ClassList[2]) do
			print(ClassList[1] .. " : " .. Spell[2] .. "," .. Spell[3])
		end
	end
end

function InterruptBar:DEBUGGetListForSpecifiedSpec(SpecID)
	local _,SpecName,_,_,_,_,ClassName =  GetSpecializationInfoByID(SpecID)
	for ClassIndex, ClassList in ipairs(self.list) do
		if (ClassList[1] == ClassName) then
			for SpellIndex, Spell in ipairs(ClassList[2]) do
				if(self:IsSpecFoundForSpell(SpecID, Spell[1])) then
					local SpellName = GetSpellInfo(Spell[2])
					print(ClassName .. SpellName .. "(" .. Spell[2] .. ")" .. ", " .. Spell[3])
				end
			end
		end
	end
end

-- TODO(flo) : reimplement this from the debug one
function InterruptBar:GetListForSpec()
	local ArenaEnemyCount = GetNumArenaOpponents()
	local ArenaEnemySpecKnown = GetNumArenaOpponentSpecs()

	print("Arena Enemy Count" .. ArenaEnemyCount)
	print("Known Arena Spec" .. ArenaEnemySpecKnow)
	-- TODO(flo) : compare ArenaEnemyCount and ArenaEnemySpecKnow and launch
	-- the rest of the function if they're equals otherwise relaunch?(when?)!
	for EnemyIndex=1, ArenaEnemyCount do
		local SpecID = GetArenaOpponentSpec(EnemyIndex)
		self:AddSpec(SpecID)
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
	return Database[info.arg or info[#info]]
end
local function setter(info,value)
	Database[info.arg or info[#info]]=value
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
				order=11,
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
						order=21
			},
			spectoadd={
							type="range",
							name="Spec To Add",
							min=65,max=270,step=1,bigStep=1,
							order=17
			},
			addspec={
				type="execute",
				name="Add Spec",
				func=AddSpec,
				order=18
			},
		}
	}
end
