--------------------------------------------------
--
-- InterruptBar.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL
--
--------------------------------------------------

-- TODO(flo) :
	-- do i miss some spells ? find bugging spells
	-- maybe try UNIT_SPELL_SUCCEEDED to retrieve info about pets
-- TODO(flo) : classic interruptbar for openworld/battleground, splitted lines for arenas!
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
	marginx=1,
	marginy=1,
	spectoadd=65,
	maxline=10,
	list={

		-- 0 for player, 1 for pet
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
				{{250, 251, 252}, 77606, 60, 0} -- Dark Simulacrum
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
				{{102, 103, 104, 105}, 61391, 30}, -- Typhoon
				{{102, 103, 104, 105}, 61336, 180}, -- Survival Instincts
				{{102, 103, 104, 105}, 106951, 180, 0} -- Berserk
				-- {{102, 103, 104, 105}, 132469,}, -- Typhoon
				-- {{102, 103, 104, 105}, 50334, }, -- Berserk
			}
		},

	-- Hunter --------------------------------------------------------------------
		--253 - Beast Mastery
		--254 - Marksmanship
		--255 - Survival
		{"HUNTER",
			{
				{{253, 254, 255}, 147362, 24}, -- Counter Shot
				{{253, 254}, 60192, 30}, -- Freezing Trap
				{{255}, 60192, 20}, -- Freezing Trap (Survival)
				{{253, 254}, 1499, 30}, -- Freezing Trap
				{{255}, 1499, 20}, -- Freezing Trap (Survival)
				{{253, 254, 255}, 19263, 180}, -- Deterrence
				{{253, 254, 255}, 19386, 45}, -- Wyvern Sting
				{{253, 254, 255}, 19574, 60}, -- Bestial Wrath
				{{253, 254, 255}, 131894, 60}, -- A murder of Crows
				{{253, 254, 255}, 19577, 60, 0} -- Intimidation
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
				{{65, 66, 67}, 15577, 120}, -- Avenging Wrath
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
				{{71, 72, 73}, 5246, 90}, -- Intimidating Shout
				{{71, 72, 73}, 107570, 30}, -- Storm Bolt
				{{71, 72, 73}, 46968, 20}, -- Shockwave
				{{71, 72, 73}, 23920, 25}, -- Spell Reflection
				{{71, 72, 73}, 114028, 30}, -- Mass Spell Reflection
				{{71, 72, 73}, 3411, 30}, -- Intervene
				{{71, 72, 73}, 114029, 30}, -- Safeguard
				{{71, 72, 73}, 52174, 45}, -- Heroic Leap
				{{71, 72, 73}, 18499,30}, -- Berserker Rage
				{{71, 72, 73}, 118038, 120} -- Parry
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

function InterruptBar:ApplySettings()
	self:Move(Database.x, Database.y, Database.marginx, Database.marginy, Database.size)
end

function InterruptBar:OnEnable()
	self.framelist = {}
	self.list = Database.list
	self.poolframes = {}
	self.mainframe=CreateFrame("Frame", nil, UIParent)
	self.mainframe:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:UpdateArenaSpec()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "EnterWorld")
	self:RegisterEvent("PLAYER_LEAVING_WORLD", "QuitWorld")
end

function InterruptBar:OnDisable()
	if(self.framelist ~= nil) then
		for LineIndex=1, getn(self.framelist) do
			for FrameIndex=1, getn(self.framelist[LineIndex]) do
				local Frame = self.framelist[LineIndex][FrameIndex]
				DisableFrame(Frame)
			end
		end
	end
	self.framelist = nil
	self.list = nil
	self.mainframe= nil
	self.poolframes= nil
end

function InterruptBar:UpdateArenaSpec()
	self.mainframe:SetScript("OnEvent", function(Self, Event)
		local ArenaEnemySpecKnown = GetNumArenaOpponentSpecs()
		if(Event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS") then
			if(ArenaEnemySpecKnown >= 0) then
				self:AddArenaSpec(ArenaEnemySpecKnown)
			else
				self.mainframe:RegisterEvent("ARENA_OPPONENT_UPDATE")
			end
		elseif(Event == "ARENA_OPPONENT_UPDATE") then
			local ArenaEnemyCount = GetNumArenaOpponents()
			if(ArenaEnemySpecKnown ~= nil) then
				if(ArenaEnemyCount >= 0 and ArenaEnemyCount == ArenaEnemySpecKnown) then
					self.mainframe:UnregisterEvent("ARENA_OPPONENT_UPDATE")
					self.mainframe:SetScript("OnEvent", nil)
					self:AddArenaSpec(ArenaEnemyCount)
				end
			end
		end
	end)
end

-- INTERRUPT BAR

function InterruptBar:DisableFrame(Frame)
		Frame:SetScript("OnEvent", nil)
		Frame:UnregisterAllEvents()
		Frame.CD.start=Time
		Frame.CD.duration=CD
		Frame.CD:SetCooldown(0,0)
		Frame.CD:Hide()
		self:Deactivatebtn(Frame.CD)
		Frame:Hide()
		Frame.Texture:Hide()
end

function InterruptBar:GetPosXFromFrameIndex(FrameIndex, X, MarginX, Size)
	local PosX = X + (Size + MarginX)*math.ceil(FrameIndex-1)
	return PosX
end

function InterruptBar:GetPosYFromLineIndex(LineIndex, Y, MarginY, Size)
	local PosY = Y - (Size + MarginY)*math.ceil(LineIndex)
	return PosY
end

function InterruptBar:Move(X, Y, MarginX, MarginY, Size)
	local LineCount = getn(self.framelist)
	for LineIndex=1, LineCount do
		for FrameIndex=1, getn(self.framelist[LineIndex]) do
			local Frame = self.framelist[LineIndex][FrameIndex]
			local PosX = self:GetPosXFromFrameIndex(FrameIndex, X, MarginX, Size)
			local PosY = self:GetPosYFromLineIndex(LineIndex, Y, MarginY, Size)
			Frame:SetPoint("CENTER", PosX, PosY)
			Frame:SetSize(Size, Size)
		end
	end
end

function InterruptBar:QuitWorld()
		if(self.framelist ~= nil) then
			for LineIndex=1, getn(self.framelist) do
				for FrameIndex=1, getn(self.framelist[LineIndex]) do
					local Frame = self.framelist[LineIndex][FrameIndex]
					self:DisableFrame(Frame)
					table.insert(self.poolframes, Frame)
				end
			end
		end
		self.framelist = {}
end

function InterruptBar:ShowFrame(Frame)
	Frame:Show()
	Frame.CD:Show()
	Frame.Texture:Show()
end

function InterruptBar:HideFrame(Frame)
	Frame:Hide()
	Frame.CD:Hide()
	Frame.Texture:Hide()
end

function InterruptBar:RegisterFrame(Frame)
	Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if(Database.fl == 0) then
		self:ShowFrame(Frame)
	else
		self:HideFrame(Frame)
	end
end

function InterruptBar:EnterWorld()
	local _, InstanceType = IsInInstance()
	if(InstanceType ~= "arena") then
		InterruptBar:EnterNonArenaWorld()
	end
end

function InterruptBar:EnterNonArenaWorld()
	local FrameIndex = 1
	local LineIndex = 1
	self.framelist[LineIndex] = {}
	for ClassIndex, ClassList in ipairs(Database.list) do
		for SpellIndex, Spell in ipairs(ClassList[2]) do
			local NewLine = FrameIndex % Database.maxline
			if(NewLine == 0) then
				LineIndex = LineIndex + 1
				FrameIndex = 1
				self.framelist[LineIndex] = {}
			end
			local PosX = InterruptBar:GetPosXFromFrameIndex(FrameIndex, Database.x, Database.marginx, Database.size)
			local PosY = InterruptBar:GetPosYFromLineIndex(LineIndex, Database.y, Database.marginy, Database.size)
			self.framelist[LineIndex][FrameIndex] =
				self:CreateFrame(LineIndex, Spell[2], Spell[3], PosX, PosY)
			self:UpdateFrame(self.framelist[LineIndex][FrameIndex], Spell[2], Spell[3], "all")
			self:RegisterFrame(self.framelist[LineIndex][FrameIndex])
			FrameIndex = FrameIndex + 1
		end
	end
end

function InterruptBar:CreateFrame(LineIndex, SpellId, CDInSecs, PosX, PosY)
	local _,_,Texture=GetSpellInfo(SpellId)
	local Frame = nil
	if(getn(self.poolframes) > 0) then
		Frame=table.remove(self.poolframes)
	else
		Frame=CreateFrame("Frame",nil,UIParent)
	end
	Frame:SetPoint("CENTER", PosX, PosY)
	Frame:SetSize(Database.size, Database.size)
	if(Frame.Texture == nil) then
		Frame.Texture=Frame:CreateTexture(nil,"BORDER")
	end
	Frame.Texture:SetAllPoints(true)
	Frame.Texture:SetTexture(Texture)
	if(Frame.CD == nil) then
		Frame.CD=CreateFrame("Cooldown",nil,Frame)
	end
	Frame.CD:SetAllPoints(Frame)
	Frame.CDInSecs = CDInSecs
	Frame.SpellID = SpellID
	return Frame
end

function InterruptBar:AddArenaSpec(ArenaEnemyCount)
	for EnemyIndex=1, ArenaEnemyCount do
		local SpecID = GetArenaOpponentSpec(EnemyIndex)
		self:AddSpec(SpecID, "arena" .. EnemyIndex, EnemyIndex)
	end
end


function InterruptBar:UpdateFrame(Frame, SpellId, SpellCD, UnitID)
	Frame:SetScript("OnEvent",function(_,_,_,Event,_,SourceGUID,SourceName,SourceFlags,_,_,_,_,_,ID)
		if(Event=="SPELL_CAST_SUCCESS"and ID==SpellId) then
	    if bit.band(SourceFlags,0x40)==0x40 then -- 0x40 ==  COMBATLOG_OBJECT_REACTION_HOSTILE
				local _, InstanceType = IsInInstance()
				if(InstanceType == "arena") then
					local TestGUID = UnitGUID(UnitID)
					local TestGUIDPet = UnitGUID(UnitID .. "pet")
					if (TestGUID == SourceGUID or TestGUIDPet == SourceGUID) then
	        	self:Activatebtn(Frame.CD,GetTime(),SpellCD)
					end
				else
          self:Activatebtn(Frame.CD,GetTime(),SpellCD)
				end
			end
    end
  end)
end

function InterruptBar:IsSpecFoundForSpell(Spec, SpellSpecList)
	for Index=1, getn(SpellSpecList) do
		if(SpellSpecList[Index] == Spec) then
			return true
		end
	end
	return false
end

function InterruptBar:RemoveOldFrames(LineIndex)
		if(self.framelist[LineIndex] ~= nil) then
			for FrameIndexToRemove = 1, getn(self.framelist[LineIndex]) do
				self.framelist[LineIndex][FrameIndexToRemove]:UnregisterAllEvents()
				self.framelist[LineIndex][FrameIndexToRemove]:Hide()
				self.framelist[LineIndex][FrameIndexToRemove].Texture:Hide()
				self.framelist[LineIndex][FrameIndexToRemove].CD:Hide()
			end
		end
end

function InterruptBar:AddSpec(SpecID, UnitID, EnemyIndex)
	local _,_,_,_,_,_,ClassName =  GetSpecializationInfoByID(SpecID)
	for ClassIndex, ClassList in ipairs(self.list) do
		if(ClassList[1] == ClassName) then
			local LineIndex = EnemyIndex
			self:RemoveOldFrames(LineIndex)
			self.framelist[LineIndex] = {}
			local FrameIndex = 1
			for SpellIndex, Spell in pairs(ClassList[2]) do
				if(self:IsSpecFoundForSpell(SpecID, Spell[1])) then
					local PosX = self:GetPosXFromFrameIndex(FrameIndex, Database.x, Database.marginx, Database.size)
					local PosY = self:GetPosYFromLineIndex(LineIndex, Database.y, Database.marginy, Database.size)
					self.framelist[LineIndex][FrameIndex] =
						self:CreateFrame(LineIndex, Spell[2], Spell[3], PosX, PosY)
					self:UpdateFrame(self.framelist[LineIndex][FrameIndex], Spell[2], Spell[3], UnitID)
					self:RegisterFrame(self.framelist[LineIndex][FrameIndex])
					FrameIndex = FrameIndex + 1
				end
			end
		end
	end
end

local function InterruptBar_OnUpdate(self)
	if GetTime()>=self.start+self.duration then
		InterruptBar:Deactivatebtn(self)
    end
end

function InterruptBar:Activatebtn(Frame, Time ,CD)
	Frame:GetParent().Texture:Show()
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
	Frame:GetParent().Texture:Hide()
	Frame:SetScript("OnUpdate",nil)
end

-- LOCAL FUNCTIONS

local function GlobalTest()
	for LineIndex=1, getn(InterruptBar.framelist) do
		for FrameIndex=1, getn(InterruptBar.framelist[LineIndex]) do
			local Frame = InterruptBar.framelist[LineIndex][FrameIndex]
			InterruptBar:Activatebtn(Frame.CD, GetTime(), Frame.CDInSecs)
		end
	end
end

local function GlobalEnterWorld()
	InterruptBar:QuitWorld()
	InterruptBar:EnterWorld()
end

local function GlobalTestEnterArena()
	InterruptBar:QuitWorld()
	InterruptBar:AddSpec(259, "arena1", 1)
	InterruptBar:AddSpec(65, "arena2", 2)
	InterruptBar:AddSpec(268, "arena3", 3)
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
			maxline={
				type="range",
				name="Max Lines",
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
				func=GlobalTest,
				order=19
			},
			reset={
				type="execute",
				name="Reset",
				func=GlobalEnterWorld,
				order=22
			},
			resettest={
				type="execute",
				name="Test Arena",
				func=GlobalTestEnterArena,
				order=23
			},
		}
	}
end
