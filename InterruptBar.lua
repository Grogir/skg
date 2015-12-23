--------------------------------------------------
--
-- InterruptBar.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL
--
--------------------------------------------------

-- TODO(flo) :
	-- do i miss some spells ? find bugging spells
	-- split pet implementation, petc cc will have a line and there will be no comparison since
	-- there's no way to find pet's owner
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
				{{250, 251, 252}, 47476, 60, 0}, -- Strangulate
				{{250, 251, 252}, 47528, 15, 0}, -- Mind Freeze
				{{250, 251, 252}, 47481, 60, 1}, -- Gnaw
				{{250, 251, 252}, 91802, 30, 1}, -- Shambling Rush
				{{250, 251, 252}, 108194, 30, 0}, -- Asphyxiate
				{{250, 251, 252}, 49576, 25, 0}, -- Death Grip
				{{250, 251, 252}, 48707, 45, 0}, -- Anti-magic shell
				{{250, 251, 252}, 48743, 120, 0}, -- Death Pact
				{{250, 251, 252}, 48792, 180, 0}, -- Icebound Fortitude
				{{250, 251, 252}, 49028, 90, 0}, -- Dancing Rune Weapon
				{{250, 251, 252}, 49039, 120, 0}, -- Lichborne
				{{250, 251, 252}, 51052, 120, 0}, -- Anti magi zone
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
				{{102, 103, 104, 105}, 78675, 60, 0}, -- Solar Beam
				{{102, 103, 104, 105}, 106839, 15, 0}, -- Skull Bash
				{{102, 103, 104, 105}, 5211, 50, 0}, -- Mighty Bash
				{{102, 103, 104, 105}, 102359, 30, 0}, -- Mass Entanglement
				{{102, 103, 104, 105}, 99, 30, 0}, -- Incapacitating Roar
				{{102, 103, 104, 105}, 132158, 60, 0}, -- Nature's Swiftness
				{{102, 103, 104, 105}, 102280, 30, 0}, -- Displacer Beast
				{{102, 103, 104, 105}, 61391, 30, 0}, -- Typhoon
				{{102, 103, 104, 105}, 61336, 180, 0}, -- Survival Instincts
				{{102, 103, 104, 105}, 106951, 180, 0} -- Berserk
				-- {{102, 103, 104, 105}, 132469, 30}, -- Typhoon
				-- {{102, 103, 104, 105}, 50334, 180}, -- Berserk
			}
		},

	-- Hunter --------------------------------------------------------------------
		--253 - Beast Mastery
		--254 - Marksmanship
		--255 - Survival
		{"HUNTER",
			{
				{{253, 254, 255}, 147362, 24, 0}, -- Counter Shot
				{{253, 254}, 60192, 30, 0}, -- Freezing Trap
				{{255}, 60192, 20, 0}, -- Freezing Trap (Survival)
				{{253, 254}, 1499, 30, 0}, -- Freezing Trap
				{{255}, 1499, 20, 0}, -- Freezing Trap (Survival)
				{{253, 254, 255}, 19263, 180, 0}, -- Deterrence
				{{253, 254, 255}, 19386, 45, 0}, -- Wyvern Sting
				{{253, 254, 255}, 19574, 60, 0}, -- Bestial Wrath
				{{253, 254, 255}, 131894, 60, 0}, -- A murder of Crows
				{{253, 254, 255}, 19577, 60, 0} -- Intimidation
			}
		},

	-- Mage ----------------------------------------------------------------------
			--62 - Arcane
			--63 - Fire
			--64 - Frost
		{"MAGE",
			{
				{{62, 63, 64}, 2139, 24, 0}, -- Counterspell
				{{62, 63, 64}, 44572, 30, 0}, -- Deep Freeze
				{{62, 63, 64}, 113724, 45, 0}, -- Ring of Frost
				{{62, 63, 64}, 102051, 20, 0}, -- Frostjaw
				{{62, 63, 64}, 31661, 20, 0}, -- Dragon's Breath
				{{62, 63, 64}, 66, 300, 0}, -- Invisibility
				{{62, 63, 64}, 1953, 15, 0}, -- Blink
				{{62, 63, 64}, 11958, 180, 0}, -- Cold Snap
				{{62, 63, 64}, 12472, 180, 0}, -- Icy Veins
				{{62, 63, 64}, 45438, 300, 0}, -- Ice Block
			}
		},

	-- Monk ----------------------------------------------------------------------
		--268 - Brewmaster
		--269 - Windwalker
		--270 - Mistweaver
		{"MONK",
			{
				{{268, 269, 270}, 116705, 15, 0}, -- Spear Hand Strike (kick)
				{{268, 269, 270}, 115176, 180, 0}, -- Zen Meditation
				{{268, 269, 270}, 115203, 180, 0}, -- Fortifying Brew
				{{268, 269, 270}, 116844, 45, 0}, -- Ring of Peace
				{{268, 269, 270}, 116849, 120, 0}, -- Life Cocoon
				{{268, 269, 270}, 119381, 45, 0}, -- Leg Sweep
				{{268, 269, 270}, 119996, 25, 0}, -- Transcendence Transfer
				{{268, 269, 270}, 122470, 90, 0}, -- Touch of Karma
				{{268, 269, 270}, 122783, 90, 0}, -- Diffuse Magic
				{{268, 269, 270}, 137562, 120, 0} -- Nimber Brew
			}
		},

	-- Paladin -------------------------------------------------------------------
			--65 - Holy
			--66 - Protection
			--70 - Retribution
		{"PALADIN",
			{
				{{65, 66, 67}, 96231, 15, 0}, -- Rebuke
				{{65, 66, 67}, 853, 60, 0}, -- Hammer of Justice
				{{65, 66, 67}, 105593, 30, 0}, -- Fist of Justice
				{{65, 66, 67}, 20066, 15, 0}, -- Repentance
				{{65, 66, 67}, 15577, 120, 0}, -- Avenging Wrath
				{{65, 66, 67}, 31884, 120, 0}, -- Avenging Wrath
				{{65, 66, 67}, 31821, 180, 0}, -- Devotion Aura
				{{65, 66, 67}, 642, 300, 0}, -- Divine Shield
				{{65, 66, 67}, 1022, 300, 0}, -- Hand of Protection
				{{65, 66, 67}, 1044, 25, 0}, -- Hand of Freedom
				{{65, 66, 67}, 6940, 120, 0}, -- Hand of Sacrifice
				{{65, 66, 67}, 114039, 30, 0} -- Hand of Purity
			}
		},

	-- Priest --------------------------------------------------------------------
		--256 Discipline
		--257 Holy
		--258 Shadow
		{"PRIEST",
			{
				{{256, 257, 258}, 8122, 42, 0}, -- Psychic Scream
				{{256, 257, 258}, 15487, 45, 0}, -- Silence
				{{256, 257, 258}, 64044, 45, 0}, -- Psychic Horror
				{{256, 257, 258}, 33206, 180, 0}, -- Pain Suppression
				{{256, 257, 258}, 47585, 120, 0}, -- Dispersion
				{{256, 257, 258}, 47788, 180, 0} -- Guardian Spirit
			}
		},

	-- Rogue ---------------------------------------------------------------------
		--259 - Assassination
		--260 - Combat
		--261 - Subtlety
		{"ROGUE",
			{
				{{259, 260, 261}, 1766, 15, 0}, -- Kick
				{{259, 260, 261}, 408, 20, 0}, -- Kidney Shot
				{{259, 260, 261}, 1856, 120, 0}, -- Vanish
				{{259, 260, 261}, 2094, 120, 0}, -- Blind
				{{259, 260, 261}, 2983, 60, 0}, -- Sprint
				{{259, 260, 261}, 5277, 180, 0}, -- Evasion
				{{259, 260, 261}, 13750, 180, 0}, -- Adrenaline Rush
				{{259, 260, 261}, 14185, 300, 0}, -- Preparation
				{{259, 260, 261}, 31224, 60, 0}, -- Cloak of Shadows
				{{259, 260, 261}, 36554, 20, 0}, -- Shadow Step
				{{259, 260, 261}, 51713, 60, 0}, -- Shadow Dance
				{{259, 260, 261}, 74001, 120, 0}, -- Combat Readiness
				{{259, 260, 261}, 76577, 180, 0} -- Smoke Bomb
			}
		},

	-- Shaman --------------------------------------------------------------------
		--262 - Elemental
		--263 - Enhancement
		--264 - Restoration
		{"SHAMAN",
			{
				{{262, 263, 264}, 57994, 12, 0}, -- Wind Shear
				{{262, 263, 264}, 51490, 45, 0}, -- Thunderstorm
				{{262, 263, 264}, 51514, 45, 0}, -- Hex
				{{262, 263, 264}, 108269, 45, 0}, -- Capacitor Totem
				{{262, 263, 264}, 8143, 60, 0}, -- Tremor Totem
				{{262, 263, 264}, 8177, 25, 0}, -- Grounding Totem
				{{262, 263, 264}, 30823, 60, 0}, -- Shamanistic Rage
				{{262, 263, 264}, 108271, 90, 0}, -- Astral Shift
				{{262, 263, 264}, 108273, 60, 0}, -- Windwalk Totem
				{{262, 263, 264}, 98008, 180, 0}, -- Spirit Link Totem
				{{262, 263, 264}, 16188, 90, 0}, -- Ancestral Swiftness
				{{262, 263, 264}, 108285, 180, 0} -- Call of the Elements
			}
		},

	-- Warlock -------------------------------------------------------------------
			--265 - Affliction
			--266 - Demonology
			--267 - Destruction
		{"WARLOCK",
			{
				{{265, 266, 267}, 115781, 24, 1}, -- Optical Blast (Observer)
				{{265, 266, 267}, 19647, 24, 1}, -- Spell Lock (Felhunter)
				{{265, 266, 267}, 171138, 24, 1}, -- Shadow Lock (Doomguard, Terrorguard) NOTE(flo): exists ?
				{{265, 266, 267}, 89766, 30, 1}, -- Axe Toss (Felguard, Wrathguard)
				{{265, 266, 267}, 6358, 30, 1}, -- Seduction (Succubus)
				{{265, 266, 267}, 115268, 30, 1}, -- Mesmerize (Shivarra)
				{{265, 266, 267}, 115770, 25, 1}, -- Fellash (Shivarra)
				{{265, 266, 267}, 6360, 25, 1}, -- Whiplash (Succubus)
				{{265, 266, 267}, 48020, 26, 0}, -- Demonic Circle : Teleport
				{{265, 266, 267}, 113861, 120, 0}, -- Dark Souls Demonology
				{{265, 266, 267}, 113860, 120, 0}, -- Dark Souls Affliction
				{{265, 266, 267}, 113858, 120, 0} -- Dark Souls Destruction
			}
		},

	-- Warrior -------------------------------------------------------------------
			--71 - Arms
			--72 - Fury
			--73 - Protection
		{"WARRIOR",
			{
				{{71, 72, 73}, 6552, 15, 0}, -- Pummel
				{{71, 72, 73}, 1719, 180, 0}, -- Recklessness
				{{71, 72, 73}, 5246, 90, 0}, -- Intimidating Shout
				{{71, 72, 73}, 107570, 30, 0}, -- Storm Bolt
				{{71, 72, 73}, 46968, 20, 0}, -- Shockwave
				{{71, 72, 73}, 23920, 25, 0}, -- Spell Reflection
				{{71, 72, 73}, 114028, 30, 0}, -- Mass Spell Reflection
				{{71, 72, 73}, 3411, 30, 0}, -- Intervene
				{{71, 72, 73}, 114029, 30, 0}, -- Safeguard
				{{71, 72, 73}, 52174, 45, 0}, -- Heroic Leap
				{{71, 72, 73}, 18499,30, 0}, -- Berserker Rage
				{{71, 72, 73}, 118038, 120, 0} -- Parry
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
	self:Reset()
end

-- INTERRUPT BAR

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

function InterruptBar:ApplySettings()
	self:Move(Database.x, Database.y, Database.marginx, Database.marginy, Database.size)
end

function InterruptBar:Reset()
	InterruptBar:OnDisable()
	InterruptBar:OnEnable()
end

function InterruptBar:CreateFrame(LineIndex, SpellId, CDInSecs, PosX, PosY, Name)
	local _,_,Texture=GetSpellInfo(SpellId)
	local Frame=CreateFrame("Frame",nil,UIParent)
	Frame:SetPoint("CENTER", PosX, PosY)
	Frame:SetSize(Database.size, Database.size)
	Frame.Texture=Frame:CreateTexture(nil,"BORDER")
	Frame.Texture:SetAllPoints(true)
	Frame.Texture:SetTexture(Texture)
	Frame.CD=CreateFrame("Cooldown",nil,Frame)
	Frame.CD:SetAllPoints(Frame)
	Frame.CDInSecs = CDInSecs
	Frame.SpellID = SpellID
	Frame.GUID = Name
	return Frame
end

-- TODO(flo) : reimplement this from the debug one
function InterruptBar:AddArenaSpec()
	local ArenaEnemyCount = GetNumArenaOpponents()
	local ArenaEnemySpecKnown = GetNumArenaOpponentSpecs()
	print("Arena Enemy Count" .. ArenaEnemyCount)
	print("Known Arena Spec" .. ArenaEnemySpecKnow)
	if(ArenaEnemyCount ~= ArenaEnemySpecKnown) then
		return false
	end

	for EnemyIndex=1, ArenaEnemyCount do
		local SpecID = GetArenaOpponentSpec(EnemyIndex)
		self:AddSpec(SpecID)
	end
	return true
end

function InterruptBar:UpdateArenaSpec()
	local ArenaEnemyCount = GetNumArenaOpponents()
	local ArenaEnemySpecKnown = GetNumArenaOpponentSpecs()
	print("Arena Enemy Count" .. ArenaEnemyCount)
	print("Known Arena Spec" .. ArenaEnemySpecKnow)
	if(ArenaEnemyCount == ArenaEnemySpecKnow) then
		for EnemyIndex=1, ArenaEnemyCount do
			local SpecID = GetArenaOpponentSpec(EnemyIndex)
			self:AddSpec(SpecID, "arena" .. EnemyIndex)
		end
		self.mainframe:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	end
end

function InterruptBar:IsAlreadyInSourceNameList(TestSourceName)
	for Index=1, getn(self.sourcenamelist) do
		local SourceName = self.sourcenamelist[Index]
		if(TestSourceName == SourceName) then
			return true
		end
	end
	return false
end

function InterruptBar:FindNewSources()
	self.mainframe:SetScript("OnEvent", function(_,_,_,Event,_,SourceGUID,SourceName,SourceFlags,_,_,_,_,_,ID)
		if bit.band(SourceFlags,0x40)==0x40 then
			local AlreadyInList = self:IsAlreadyInSourceNameList(SourceGUID)
			if(not AlreadyInList) then
				print(SourceGUID)
				if(ClassName ~= nil) then
					for ClassIndex, ClassList in ipairs(self.list) do
						if(ClassName == ClassList[1]) then
							for SpellIndex, Spell in ipairs(ClassList[2]) do
								local SpecID = GetInspectSpecialization()
								-- if(self:IsSpecFoundForSpell(SpecID, Spell[1])) then -- TODO(find away to get the spec)
									if(Event=="SPELL_CAST_SUCCESS"and ID==Spell[2])then
										print("add " .. SourceGUID)
										table.insert(self.sourcenamelist, SourceGUID)
										self:AddClass(ClassName, SourceGUID, Spell[2])
									end
								-- end
							end
						end
					end
				end
			end
		end
	end)
	self.mainframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "FindNewSources")
end


function InterruptBar:OnEnable()
	_G.ibDEBUG = self
	self.framelist = {}
	self.list = Database.list
	self.linecount = 1
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Reset")
	local IsArena,_ = IsActiveBattlefieldArena()
	if(IsArena or IsArenaSkirmish()) then
		if(not self:AddArenaSpec()) then
			self.mainframe=CreateFrame("Frame", nil, UIParent)
			self.mainframe:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", "UpdateArenaSpec")
			self:UpdateArenaSpec()
		end
	else
		self.sourcenamelist = {}
		self.mainframe=CreateFrame("Frame", nil, UIParent)
		self:FindNewSources()
	end
end

function InterruptBar:OnDisable()
	if(self.framelist ~= nil) then
		for LineIndex=1, getn(self.framelist) do
			for FrameIndex=1, getn(self.framelist[LineIndex]) do
				self.framelist[LineIndex][FrameIndex]:Hide()
			end
		end
	end
	self.framelist = {}
	self.linecount = 1
	self.list = nil
	self.mainframe=nil
end

function InterruptBar:UpdateFrame(Frame, SpellId, SpellCD, IsPet)
    Frame:SetScript("OnEvent",function(_,_,_,Event,_,SourceGUID,SourceName,SourceFlags,_,_,_,_,_,ID)
        if(Event=="SPELL_CAST_SUCCESS"and ID==SpellId)then
            if bit.band(SourceFlags,0x40)==0x40 then -- 0x40 ==  COMBATLOG_OBJECT_REACTION_HOSTILE
							if(IsPet == 1) then
								self:Activatebtn(Frame.CD, GetTime(), SpellCD)
							else
								if(IsArena or IsArenaSkirmish()) then
									local TestGUID = UnitGUID(Frame.GUID)
									if (TestGUID == SourceGUID) then
		                self:Activatebtn(Frame.CD,GetTime(),SpellCD)
									end
								else
									if(Frame.GUID == SourceGUID) then
		                self:Activatebtn(Frame.CD,GetTime(),SpellCD)
									end
								end
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
				self.framelist[LineIndex][FrameIndexToRemove]:Hide()
				self.framelist[LineIndex][FrameIndexToRemove] = nil
			end
		end
end

function InterruptBar:AddClass(ClassName, GUID, SpellID)
	for ClassIndex, ClassList in ipairs(self.list) do
		if(ClassList[1] == ClassName) then
			if(self.linecount > Database.maxline) then
				self.linecount = 1
			end
			local LineIndex = self.linecount
			self:RemoveOldFrames(LineIndex)
			self.framelist[LineIndex] = {}
			local FrameIndex = 1
			for SpellIndex, Spell in pairs(ClassList[2]) do
				local PosX = self:GetPosXFromFrameIndex(FrameIndex, Database.x, Database.marginx, Database.size)
				local PosY = self:GetPosYFromLineIndex(LineIndex, Database.y, Database.marginy, Database.size)
				self.framelist[LineIndex][FrameIndex] =
					self:CreateFrame(LineIndex, Spell[2], Spell[3], PosX, PosY, GUID)
				local Frame = self.framelist[LineIndex][FrameIndex]
    		self.framelist[LineIndex][FrameIndex]:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				self:UpdateFrame(self.framelist[LineIndex][FrameIndex], Spell[2], Spell[3], Spell[4])
				if(SpellID == Spell[2]) then
					local FrameCD = self.framelist[LineIndex][FrameIndex].CD
					self:Activatebtn(FrameCD, GetTime(), Spell[3])
				end
				FrameIndex = FrameIndex + 1
			end
			self.linecount = self.linecount + 1
		end
	end
end

function InterruptBar:AddSpec(SpecID, GUID)
	local _,SpecName,_,_,_,_,ClassName =  GetSpecializationInfoByID(SpecID)
	for ClassIndex, ClassList in ipairs(self.list) do
		if(ClassList[1] == ClassName) then
			if(self.linecount > Database.maxline) then
				self.linecount = 1
			end
			local LineIndex = self.linecount
			self:RemoveOldFrames(LineIndex)
			self.framelist[LineIndex] = {}
			local FrameIndex = 1
			for SpellIndex, Spell in pairs(ClassList[2]) do
				if(self:IsSpecFoundForSpell(SpecID, Spell[1])) then
					local PosX = self:GetPosXFromFrameIndex(FrameIndex, Database.x, Database.marginx, Database.size)
					local PosY = self:GetPosYFromLineIndex(LineIndex, Database.y, Database.marginy, Database.size)
					self.framelist[LineIndex][FrameIndex] =
						self:CreateFrame(LineIndex, Spell[2], Spell[3], PosX, PosY, GUID)
					self:UpdateFrame(self.framelist[LineIndex][FrameIndex], Spell[2], Spell[3], Spell[4])
					FrameIndex = FrameIndex + 1
				end
			end
			self.linecount = self.linecount + 1
		end
	end
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

-- LOCAL FUNCTIONS

local function Test()
	for LineIndex=1, getn(InterruptBar.framelist) do
		for FrameIndex=1, getn(InterruptBar.framelist[LineIndex]) do
			local Frame = InterruptBar.framelist[LineIndex][FrameIndex]
			InterruptBar:Activatebtn(Frame.CD, GetTime(), Frame.CDInSecs)
		end
	end
end

local function StopTest()
	InterruptBar:ApplySettings()
end

local function AddSpec()
	InterruptBar:AddSpec(Database.spectoadd, nil)
end

local function Reset()
	InterruptBar:Reset()
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
			reset={
				type="execute",
				name="Reset",
				func=Reset,
				order=22
			}
		}
	}
end
