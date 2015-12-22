--------------------------------------------------
--
-- InterruptBar.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL
--
--------------------------------------------------

-- TODO(flo) : http://wowprogramming.com/docs/api/GetArenaOpponentSpec
	-- add hunter/mage/monk/priest/rogue/shaman/warlock spells....
	-- try to implement one line par arena frame
	-- split arena from battlegrounds/worldmap implementations


local AddonName,SKG=...
local InterruptBar=SKG:NewModule("InterruptBar","AceEvent-3.0")
local Database

local defaults={global={
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
		{102359 ,30}, -- Mass Entanglement
		{99,30}, -- Incapacitating Roar
		{5211 ,50}, -- Mighty Bash
		{132469 ,30}, -- Typhoon
		{61336,180 }, -- Survival Instincts
		{50334,180 }, -- Berserk
	-- Hunter --------------------------------
	-- Mage --------------------------------
		{2139,24}, -- Counterspell
	-- Monk --------------------------------
		{116705,15}, -- Spear Hand Strike (kick)
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

	-- Rogue --------------------------------
		{1766,15}, -- Kick
	-- Shaman --------------------------------
		{57994,12}, -- Wind Shear
	-- Warlock --------------------------------
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
	self.db=SKG.db:RegisterNamespace("InterruptBar",defaults,true)
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

function InterruptBar:OnEnable()
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

function InterruptBar:Event()
    self:ApplySettings()
end

function InterruptBar:OnDisable()
	for Index, Spell in ipairs(Database.list) do
		_G["ib"..Index]=nil
		self.framelist[Index]:Hide()
	end
	self.framelist = {}
	self.list = nil
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
    return f
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
