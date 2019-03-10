--------------------------------------------------
--
-- Frames.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL & Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------
-- boss cast marche pas

local AddonName,SKG=...
local Frames=SKG:NewModule("Frames","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,

	playerx=-260,
	playery=-120,
	playerscale=1.0,
	targetx=260,
	targety=-120,
	targetscale=1.0,
	focusx=450,
	focusy=-260,
	focusscale=0,

	targettargetx=-35, -- -20
	targettargety=-10, -- -15
	focustargetx=-35,
	focustargety=-10,

	runeframex=54,
	runeframey=34,
	runeframescale=1,
	petframex=60,
	petframey=-75,
	totemframex=99,
	totemframey=38,

	arenax=290,
	arenay=80,
	arenaspace=50,
	arenascale=1.5,
	arenatexture=true,
	arenacastx=-5,
	arenacasty=-3,
	arenacastscale=1.0,
	arenanamesize=8,
	arenanamex=-19,
	arenanamey=10,
	arenapetx=45,
	arenapety=-40,

	partyx=-250,
	partyy=80,
	partyspace=65,
	partyscale=1.5,
	partytextsize=8,

	bossx=-260,
	bossy=-120,
	bossspace=75,
	bossscale=1.0,
	bosscastx=10,
	bosscasty=28,
	bosscastscale=1.0,

	hideart=true,
	disabledamage=true,
	disablewhisp=true,
	disablechaninv=false,
	minimaptweaks=true,
	classportrait=false,
	safequeue=true,
	macrolimit=true,
	floatingcombattext=false,
	framescolor=0.4,
	frameratex=0,
	frameratey=-350,
	eabx=0,
	eaby=-335,
	powerbaraltx=0,
	powerbaralty=-290,
	containerx=0,
	containery=10,
	talkingheadx=0,
	talkingheady=155,
	objtracker=true,
	objtrackerx=10,
}}
local arenatest=false
local partytest=false
local bosstest=false

function Frames:OnInitialize()
	self.db=SKG.db:RegisterNamespace("Frames",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("Frames",self.options,"L Frames")
end
function Frames:OnEnable()
	self:UnitFrames()
	self:Misc()
end
function Frames:OnDisable()
	ReloadUI()
end
function Frames:ApplySettings()
	if db.enabled then
		self:UnitFrames()
		self:Misc()
	end
end

-- FRAMES

function Frames:UnitFrames()
	-- Player & Targets frames
	PlayerFrame:ClearAllPoints()
	PlayerFrame:SetPoint("CENTER",UIParent,"CENTER",db.playerx,db.playery)
	PlayerFrame:SetUserPlaced(true)
	if db.playerscale>0 then PlayerFrame:SetScale(db.playerscale) end

	TargetFrame:ClearAllPoints()
	TargetFrame:SetPoint("CENTER",UIParent,"CENTER",db.targetx,db.targety)
	TargetFrame:SetUserPlaced(true)
	if db.targetscale>0 then TargetFrame:SetScale(db.targetscale) end

	FocusFrame:ClearAllPoints()
	FocusFrame:SetPoint("CENTER",UIParent,"CENTER",db.focusx,db.focusy)
	FocusFrame:SetUserPlaced(true)
	if db.focusscale>0 then FocusFrame:SetScale(db.focusscale) end

	TargetFrameToT:ClearAllPoints()
	TargetFrameToT:SetPoint("BOTTOMRIGHT",TargetFrame,"BOTTOMRIGHT",db.targettargetx,db.targettargety)
	TargetFrameToT:SetUserPlaced(true)
	FocusFrameToT:ClearAllPoints()
	FocusFrameToT:SetPoint("BOTTOMRIGHT",FocusFrame,"BOTTOMRIGHT",db.focustargetx,db.focustargety)
	FocusFrameToT:SetUserPlaced(true)

	local _,class=UnitClass("player")
	if RuneFrame:IsShown() then
		RuneFrame:ClearAllPoints()
		RuneFrame:SetPoint("TOP",PlayerFrame,"BOTTOM",db.runeframex,db.runeframey)
		if db.runeframescale>0 then RuneFrame:SetScale(db.runeframescale) end
	-- elseif WarlockPowerFrame:IsShown() then
		-- WarlockPowerFrame:ClearAllPoints()
		-- WarlockPowerFrame:SetPoint("TOP",PlayerFrame,"BOTTOM",db.runeframex,db.runeframey)
		-- if db.runeframescale>0 then WarlockPowerFrame:SetScale(db.runeframescale) end
	-- elseif PaladinPowerBarFrame:IsShown() then
		-- PaladinPowerBarFrame:ClearAllPoints()
		-- PaladinPowerBarFrame:SetPoint("TOP",PlayerFrame,"BOTTOM",db.runeframex,db.runeframey)
		-- if db.runeframescale>0 then PaladinPowerBarFrame:SetScale(db.runeframescale) end
	end
	-- PetFrame:ClearAllPoints()
	-- if not PetFrame.SetPointNew then PetFrame.SetPointNew=PetFrame.SetPoint PetFrame.SetPoint=nop end
	-- PetFrame:SetPointNew("TOPLEFT",PlayerFrame,"TOPLEFT",db.petframex,db.petframey)
	--:SetUserPlaced(true)
	--:SetMovable(true)
	-- TotemFrame:ClearAllPoints()
	-- if not TotemFrame.SetPointNew then TotemFrame.SetPointNew=TotemFrame.SetPoint TotemFrame.SetPoint=nop end
	-- TotemFrame:SetPointNew("TOPLEFT",PlayerFrame,"BOTTOMLEFT",db.totemframex,db.totemframey)
	
	-- Arena frames
	local function hbf(f,n)
		f.healthbar:SetMinMaxValues(0,100)
		f.healthbar:SetValue(n)
		f.healthbar.forceHideText=false
		f.manabar:SetMinMaxValues(0,100)
		f.manabar:SetValue(n)
		f.healthbar.forceHideText=false
		f.healthbar:SetStatusBarColor(0,1,0)
		f.manabar:SetStatusBarColor(0,0,1)
	end
	
	local foctex="Interface\\TARGETINGFRAME\\UI-TargetingFrame-NoLevel"
	for i=1,5 do
		local pt,rel,relpt,x,y

		for j,framename in ipairs({"ArenaEnemyFrame"..i,"ArenaPrepFrame"..i}) do
			local frame=_G[framename]
			local tex=_G[framename.."Texture"]
			local portrait=_G[framename.."ClassPortrait"]
			local back=_G[framename.."Background"]
			local spec=_G[framename.."SpecBorder"]
			local specportrait=_G[framename.."SpecPortrait"]
			local healthbar=_G[framename.."HealthBar"]
			local healthbartext=_G[framename.."HealthBarText"]
			local manabar=_G[framename.."ManaBar"]
			local manabartext=_G[framename.."ManaBarText"]

			frame:ClearAllPoints()
			if db.arenascale>0 then frame:SetScale(db.arenascale) end
			if not frame.SetPointNew then frame.SetPointNew=frame.SetPoint frame.SetPoint=nop end
			frame:SetPointNew("CENTER",UIParent,"CENTER",db.arenax,db.arenay-(i-1)*db.arenaspace)
			frame:SetUserPlaced(true)

			if db.arenatexture then
				_,rel,_,_,_=tex:GetPoint()
				tex:SetSize(156,78)
				tex:ClearAllPoints()
				tex:SetPoint("CENTER",rel,"CENTER",5,-10)
				tex:SetTexture(foctex)
				tex:SetTexCoord(0,1,0,1)
				tex:SetAlpha(1)

				portrait:SetSize(40,40)
				pt,rel,relpt,x,y=portrait:GetPoint()
				portrait:SetPoint(pt,rel,relpt,3,6) -- x+14,y+10

				pt,rel,relpt,x,y=back:GetPoint()
				back:SetPoint(pt,rel,relpt,2,0) -- x,y+10
				back:SetHeight(25)

				pt,rel,relpt,x,y=spec:GetPoint()
				spec:SetPoint(pt,rel,relpt,5,-1) -- x+5,y-5
				pt,rel,relpt,x,y=specportrait:GetPoint()
				specportrait:SetPoint(pt,rel,relpt,9,-5) -- x+7,y-7

				x,y=healthbar:GetSize()
				healthbar:SetSize(71,7) -- x+1,y-1
				x,y=manabar:GetSize()
				manabar:SetSize(71,5) -- x+1,y-3
				healthbartext:SetFont("Fonts\\FRIZQT__.TTF",8,"OUTLINE")
				healthbartext:SetPoint("CENTER",healthbar)
				manabartext:SetFont("Fonts\\FRIZQT__.TTF",8,"OUTLINE")
				manabartext:SetPoint("CENTER",manabar)
			end

			if arenatest and j==1 and i<4 then
				frame:Show()
				hbf(frame,100)
				spec:Show()
				tex=CLASS_ICON_TCOORDS[select(2,UnitClass("player"))]
				portrait:SetTexCoord(unpack(tex))
				if GetSpecialization() then tex=select(4,GetSpecializationInfo(GetSpecialization())) else tex="Interface\\Icons\\Spell_Nature_HealingTouch" end
				SetPortraitToTexture(specportrait,tex)
			end
		end

		local cast=_G["ArenaEnemyFrame"..i.."CastingBar"]
		local name=_G["ArenaEnemyFrame"..i.."Name"]
		local pet=_G["ArenaEnemyFrame"..i.."PetFrame"]

		pt,rel,relpt,x,y=cast:GetPoint()
		cast:SetPoint(pt,rel,relpt,db.arenacastx,db.arenacasty)
		if db.arenacastscale>0 then cast:SetScale(db.arenacastscale) end
		name:SetFont("Fonts\\FRIZQT__.TTF",db.arenanamesize)
		name:ClearAllPoints()
		name:SetPoint("CENTER",name:GetParent(),"CENTER",db.arenanamex,db.arenanamey)
		pt,rel,relpt,x,y=pet:GetPoint()
		pet:SetPoint(pt,rel,relpt,db.arenapetx,db.arenapety)

		if arenatest and i<4 then
			cast:Show()
			cast:SetAlpha(0.5)
			cast.fadeOut=nil
			name:SetText(PlayerName:GetText())
			pet:Show()
		end
	end
	if arenatest then ArenaEnemyFrames:Show() else ArenaEnemyFrames:Hide() end
	
	-- Party frames
	for i=1,4 do
		local party=_G["PartyMemberFrame"..i]
		party:ClearAllPoints()
		party:SetPoint("CENTER",UIParent,"CENTER",db.partyx,db.partyy-(i-1)*db.partyspace)
		party:SetScale(db.partyscale)
		party:SetUserPlaced(true)
		party.healthbar.TextString:SetFont("Fonts\\FRIZQT__.TTF",db.partytextsize,"OUTLINE")
		party.healthbar.TextString:SetPoint("CENTER",party.healthbar)
		party.manabar.TextString:SetFont("Fonts\\FRIZQT__.TTF",db.partytextsize,"OUTLINE")
		party.manabar.TextString:SetPoint("CENTER",party.manabar)
		party.name:SetFont("Fonts\\FRIZQT__.TTF",db.partytextsize)

		if partytest then
			party:Show()
			hbf(party,100)
			party.name:SetText(PlayerName:GetText())
			local tex=CLASS_ICON_TCOORDS[select(2,UnitClass("player"))]
			party.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			party.portrait:SetTexCoord(unpack(tex))
		else
			party:Hide()
		end
	end

	-- Boss frames
	for i=1,5 do
		local boss=_G["Boss"..i.."TargetFrame"]
		boss:SetScale(db.bossscale)
		boss:ClearAllPoints()
		if not boss.SetPointNew then
			boss.SetPointNew=boss.SetPoint
			boss.SetPoint=nop
		end
		boss:SetPointNew("TOPRIGHT",MinimapCluster,"BOTTOMRIGHT",db.bossx,db.bossy-(i-1)*db.bossspace)
		boss.spellbar:ClearAllPoints()
		if not boss.spellbar.SetPointNew then
			boss.spellbar.SetPointNew=boss.spellbar.SetPoint
			boss.spellbar.SetPoint=nop
		end
		boss.spellbar:SetPointNew("TOPLEFT",boss,"BOTTOMLEFT",db.bosscastx,db.bosscasty)
		boss.spellbar:SetScale(db.bosscastscale)
		if bosstest then
			boss:Show()
			boss.spellbar:Show()
			boss.spellbar:SetAlpha(0.3)
			boss.spellbar.fadeOut=nil
		else
			boss:Hide()
		end
	end
	
	if not self.classportrait then
		self.classportrait=true
		hooksecurefunc("UnitFramePortrait_Update",function(self)
			if self.portrait then
				if db.classportrait and UnitIsPlayer(self.unit) then
					local t=CLASS_ICON_TCOORDS[select(2,UnitClass(self.unit))]
					if t then
						self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
						self.portrait:SetTexCoord(unpack(t))
					end
				else
					self.portrait:SetTexCoord(0,1,0,1)
				end
			end
		end)
	end
	UnitFramePortrait_Update(PlayerFrame)
	UnitFramePortrait_Update(TargetFrame)
	UnitFramePortrait_Update(FocusFrame)
	UnitFramePortrait_Update(PartyMemberFrame1)
	UnitFramePortrait_Update(PartyMemberFrame2)
	UnitFramePortrait_Update(PartyMemberFrame3)
	UnitFramePortrait_Update(PartyMemberFrame4)
end

function Frames:Misc()
	-- Hide art
	MainMenuBarArtFrame.LeftEndCap:SetShown(not db.hideart)
	MainMenuBarArtFrame.RightEndCap:SetShown(not db.hideart)

	-- Disable text on portrait
	if not PlayerHitIndicator.ShowNew then
		PlayerHitIndicator.ShowNew=PlayerHitIndicator.Show
		PetHitIndicator.ShowNew=PetHitIndicator.Show
	end
	if db.disabledamage then
		PlayerHitIndicator.Show=nop
		PetHitIndicator.Show=nop
	else
		PlayerHitIndicator.Show=PlayerHitIndicator.ShowNew
		PetHitIndicator.Show=PetHitIndicator.ShowNew
	end

	-- Disable blinking whisp tab
	if not FCF_StartAlertFlashNew then
		FCF_StartAlertFlashNew=FCF_StartAlertFlash
	end
	if db.disablewhisp then
		FCF_StartAlertFlash=nop
	else
		FCF_StartAlertFlash=FCF_StartAlertFlashNew
	end
	-- Disable invites
	if db.disablechaninv then
		UIParent:UnregisterEvent("CHANNEL_INVITE_REQUEST")
	else
		UIParent:RegisterEvent("CHANNEL_INVITE_REQUEST")
	end
	-- Move some UIParent frames
	FramerateLabel.ignoreFramePositionManager=true
	FramerateLabel:ClearAllPoints()
	FramerateLabel:SetPoint("CENTER",UIParent,"CENTER",db.frameratex,db.frameratey)

	-- Extra Action
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER",UIParent,"CENTER",db.eabx,db.eaby)
	ExtraActionBarFrame.ignoreFramePositionManager=true
	-- /run ExtraActionBarFrame:Show() ExtraActionButton1:Show() ExtraActionButton1.style:SetTexture("Interface\\ExtraButton\\Default") ExtraActionBarFrame.outro:Stop() ExtraActionBarFrame.intro:Play()

	-- -- Power Bar Alt
	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetPoint("CENTER",UIParent,"CENTER",db.powerbaraltx,db.powerbaralty)
	PlayerPowerBarAlt:SetMovable(true)
	PlayerPowerBarAlt:SetUserPlaced(true)
	-- /run PlayerPowerBarAlt:Show() PlayerPowerBarAlt:SetSize(256,64) PlayerPowerBarAlt.frame:SetTexture("Interface/UnitPowerBarAlt/Fire_Horizontal_Frame")

	-- FramePositionManager
	UIPARENT_MANAGED_FRAME_POSITIONS.CONTAINER_OFFSET_X.baseX=db.containerx
	UIPARENT_MANAGED_FRAME_POSITIONS.CONTAINER_OFFSET_Y.yOffset=db.containery
	ObjectiveTrackerFrame:SetShown(db.objtracker)
	UIPARENT_MANAGED_FRAME_POSITIONS.OBJTRACKER_OFFSET_X.baseX=db.objtrackerx
	VISIBLE_CONTAINER_SPACING=-25
	CONTAINER_SPACING=-5

	-- Minimap Tweaks
	MinimapZoomIn:SetShown(not db.minimaptweaks)
	MinimapZoomOut:SetShown(not db.minimaptweaks)
	Minimap:EnableMouseWheel(db.minimaptweaks)
	if db.minimaptweaks then
		Minimap:SetScript("OnMouseWheel",function(self,delta)
			if delta>0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
		end)
		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint("TOPRIGHT",-26,7)
	else
		Minimap:SetScript("OnMouseWheel",nop)
		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint("TOPRIGHT",9,-45)
	end

	-- Dark Frames
	local clockbtn=TimeManagerClockButton:GetRegions()
	for i,v in pairs({PlayerFrameTexture,TargetFrameTextureFrameTexture,PetFrameTexture,PartyMemberFrame1Texture,PartyMemberFrame2Texture,PartyMemberFrame3Texture,PartyMemberFrame4Texture,
	PartyMemberFrame1PetFrameTexture,PartyMemberFrame2PetFrameTexture,PartyMemberFrame3PetFrameTexture,PartyMemberFrame4PetFrameTexture,FocusFrameTextureFrameTexture,
	TargetFrameToTTextureFrameTexture,FocusFrameToTTextureFrameTexture,BonusActionBarFrameTexture0,BonusActionBarFrameTexture1,BonusActionBarFrameTexture2,BonusActionBarFrameTexture3,
	BonusActionBarFrameTexture4,MainMenuBarTexture0,MainMenuBarTexture1,MainMenuBarTexture2,MainMenuBarTexture3,MainMenuMaxLevelBar0,MainMenuMaxLevelBar1,MainMenuMaxLevelBar2,
	MainMenuMaxLevelBar3,MinimapBorder,CastingBarFrameBorder,FocusFrameSpellBarBorder,TargetFrameSpellBarBorder,MiniMapTrackingButtonBorder,MiniMapLFGFrameBorder,MiniMapBattlefieldBorder,
	MiniMapMailBorder,MinimapBorderTop,clockbtn,
	ArenaEnemyFrame1Texture,ArenaEnemyFrame2Texture,ArenaEnemyFrame3Texture,ArenaEnemyFrame4Texture,ArenaEnemyFrame5Texture,
	ArenaEnemyFrame1SpecBorder,ArenaEnemyFrame2SpecBorder,ArenaEnemyFrame3SpecBorder,ArenaEnemyFrame4SpecBorder,ArenaEnemyFrame5SpecBorder,
	ArenaPrepFrame1Texture,ArenaPrepFrame2Texture,ArenaPrepFrame3Texture,ArenaPrepFrame4Texture,ArenaPrepFrame5Texture,
	ArenaPrepFrame1SpecBorder,ArenaPrepFrame2SpecBorder,ArenaPrepFrame3SpecBorder,ArenaPrepFrame4SpecBorder,ArenaPrepFrame5SpecBorder,
	ArenaEnemyFrame1PetFrameTexture,ArenaEnemyFrame2PetFrameTexture,ArenaEnemyFrame3PetFrameTexture,ArenaEnemyFrame4PetFrameTexture,ArenaEnemyFrame5PetFrameTexture,
	}) do
		v:SetVertexColor(db.framescolor,db.framescolor,db.framescolor)
	end

	-- SafeQueue
	if db.safequeue then
		PVPReadyDialog.leaveButton:Disable()
		if not self.sq then
			local sq=CreateFrame("FRAME",nil,UIParent)
			self.sq=sq
			sq.q={}
			sq:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
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
		end
		self.sq:Show()
	else
		PVPReadyDialog.leaveButton:Enable()
		if self.sq then
			self.sq:Hide()
		end
	end

	-- Macro Limit
	if db.macrolimit then
		self.macro=CreateFrame("FRAME")
		self.macro:RegisterEvent("ADDON_LOADED")-- à test
		self.macro:SetScript("OnEvent",function(_,_,name)
			if name=="Blizzard_MacroUI" then MAX_CHARACTER_MACROS=36 end
		end)
	end
	
	-- Floating Combat Text
	local function initFCT(self)
		if not self.init and CombatText_UpdateDisplayedMessages then
			self.init=true
			hooksecurefunc("CombatText_UpdateDisplayedMessages",function()
				COMBAT_TEXT_SPACING=5
				COMBAT_TEXT_LOCATIONS.startY=380
				COMBAT_TEXT_LOCATIONS.endY=480
				CombatText_ClearAnimationList()
			end)
			COMBAT_TEXT_HEIGHT=20
			COMBAT_TEXT_CRIT_MAXHEIGHT=30
			COMBAT_TEXT_CRIT_MINHEIGHT=24
			COMBAT_TEXT_SCROLLSPEED=1
			COMBAT_TEXT_FADEOUT_TIME=0
			CombatText_UpdateDisplayedMessages()
		end
	end
	if db.floatingcombattext and not self.fct then
		self.fct=CreateFrame("Frame")
		self.fct:RegisterEvent("PLAYER_ENTERING_WORLD")
		self.fct:SetScript("OnEvent",initFCT)
		initFCT(self.fct)
	end
end

-- Talking Head
Frames.talkinghead=CreateFrame("Frame") -- ne marche pas dans la fonction à cause du LoadAddOn ArenaUI qui devrait être delayé
Frames.talkinghead:RegisterEvent("ADDON_LOADED")
Frames.talkinghead:SetScript("OnEvent",
function(s,e,addon)
	if addon=="Blizzard_TalkingHeadUI" and db.enabled then
		TalkingHeadFrame.ignoreFramePositionManager=true
		TalkingHeadFrame:ClearAllPoints()
		TalkingHeadFrame:SetPoint("BOTTOM",UIParent,"BOTTOM",db.talkingheadx,db.talkingheady)
	end
end)

-- OPTIONS

local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	Frames:ApplySettings()
end
function Frames:GetOptions()
	return {
		order=1,
		type="group",
		name="Frames",
		desc="Configure the frames",
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
				order=0,
			},
			-- reset={
				-- type="execute",
				-- name="Reset settings",
				-- func=function() SKG:ResetOptions(Frames.options.args,db,defaults.global) self:ApplySettings() end,
				-- order=0,
			-- },
			playertargets={
				type="group",
				name="Player/Targeting",
				order=1,
				args={
					player={
						type="header",
						name="Player",
						order=0
					},
					playerx={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=20,
						order=1
					},
					playery={
						type="range",
						name="Y",
						softMin=-600,softMax=600,step=1,bigStep=20,
						order=2
					},
					playerscale={
						type="range",
						name="Scale",
						min=0.0,max=3.0,step=0.01,bigStep=0.1,
						order=3
					},
					target={
						type="header",
						name="Target",
						order=10
					},
					targetx={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=20,
						order=11
					},
					targety={
						type="range",
						name="Y",
						softMin=-600,softMax=600,step=1,bigStep=20,
						order=12
					},
					targetscale={
						type="range",
						name="Scale",
						min=0.0,max=3.0,step=0.01,bigStep=0.1,
						order=13
					},
					focus={
						type="header",
						name="Focus",
						order=20
					},
					focusx={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=20,
						order=21
					},
					focusy={
						type="range",
						name="Y",
						softMin=-600,softMax=600,step=1,bigStep=20,
						order=22
					},
					focusscale={
						type="range",
						name="Scale",
						min=0.0,max=3.0,step=0.01,bigStep=0.1,
						order=23
					},
					targettarget={
						type="header",
						name="Target of target",
						order=30
					},
					targettargetx={
						type="range",
						name="X",
						softMin=-150,softMax=150,step=1,bigStep=5,
						order=31
					},
					targettargety={
						type="range",
						name="Y",
						softMin=-100,softMax=100,step=1,bigStep=5,
						order=32
					},
					focustarget={
						type="header",
						name="Target of focus",
						order=40
					},
					focustargetx={
						type="range",
						name="X",
						softMin=-150,softMax=150,step=1,bigStep=5,
						order=41
					},
					focustargety={
						type="range",
						name="Y",
						softMin=-100,softMax=100,step=1,bigStep=5,
						order=42
					},
				}
			},
			resource={
				type="group",
				name="Resources/Pets",
				order=6,
				args={
					runeframe={
						type="header",
						name="DK Runes",
						order=0
					},
					runeframex={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=1,
						order=1
					},
					runeframey={
						type="range",
						name="Y",
						softMin=-1000,softMax=1000,step=1,bigStep=1,
						order=2
					},
					runeframescale={
						type="range",
						name="Scale",
						min=0.0,max=3.0,step=0.01,bigStep=0.1,
						order=3
					},
					petframe={
						type="header",
						name="Pet",
						order=10
					},
					petframex={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=1,
						order=11
					},
					petframey={
						type="range",
						name="Y",
						softMin=-1000,softMax=1000,step=1,bigStep=1,
						order=12
					},
					totemframe={
						type="header",
						name="Totems",
						order=20
					},
					totemframex={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=1,
						order=21
					},
					totemframey={
						type="range",
						name="Y",
						softMin=-1000,softMax=1000,step=1,bigStep=1,
						order=22
					},
				}
			},
			party={
				type="group",
				name="Party",
				order=9,
				args={
					partyframes={
						type="header",
						name="Party Frames",
						order=0
					},
					partyx={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=10,
						order=1
					},
					partyy={
						type="range",
						name="Y",
						softMin=-600,softMax=600,step=1,bigStep=10,
						order=2
					},
					partyscale={
						type="range",
						name="Scale",
						min=0,max=3.0,step=0.01,bigStep=0.1,
						order=3
					},
					partyspace={
						type="range",
						name="Space",
						softMin=-150,softMax=150,step=1,bigStep=5,
						order=4
					},
					partytextsize={
						type="range",
						name="Text Size",
						min=1,max=16,step=1,bigStep=1,
						order=5
					},
					partytest={
						type="toggle",
						name="Test",
						get=function() return partytest end,
						set=function(i,v) partytest=v self:ApplySettings() end,
						order=-1
					},
				}
			},
			arena={
				type="group",
				name="Arena",
				order=10,
				args={
					arenaframes={
						type="header",
						name="Arena Frames",
						order=0
					},
					arenax={
						type="range",
						name="Base X",
						softMin=-1000,softMax=1000,step=1,bigStep=10,
						order=1
					},
					arenay={
						type="range",
						name="Base Y",
						softMin=-600,softMax=600,step=1,bigStep=10,
						order=2
					},
					arenascale={
						type="range",
						name="Scale",
						min=0,max=3.0,step=0.01,bigStep=0.1,
						order=3
					},
					arenaspace={
						type="range",
						name="Space",
						softMin=-150,softMax=150,step=1,bigStep=5,
						order=4
					},
					arenatexture={
						type="toggle",
						name="Custom Texture",
						desc="Disabling needs a UI reload",
						order=5
					},
					arenatest={
						type="toggle",
						name="Test",
						get=function() return arenatest end,
						set=function(i,v) arenatest=v self:ApplySettings() end,
						order=6
					},
					arenacast={
						type="header",
						name="Cast Bar",
						order=10
					},
					arenacastx={
						type="range",
						name="X",
						softMin=-100,softMax=100,step=1,bigStep=1,
						order=11
					},
					arenacasty={
						type="range",
						name="Y",
						softMin=-100,softMax=100,step=1,bigStep=1,
						order=12
					},
					arenacastscale={
						type="range",
						name="Scale",
						min=0,max=3.0,step=0.01,bigStep=0.1,
						order=13
					},
					arenaname={
						type="header",
						name="Name",
						order=20
					},
					arenanamex={
						type="range",
						name="X",
						softMin=-100,softMax=100,step=1,bigStep=1,
						order=21
					},
					arenanamey={
						type="range",
						name="Y",
						softMin=-100,softMax=100,step=1,bigStep=1,
						order=22
					},
					arenanamesize={
						type="range",
						name="Size",
						min=1,max=16,step=1,bigStep=1,
						order=23
					},
					arenapet={
						type="header",
						name="Pet",
						order=30
					},
					arenapetx={
						type="range",
						name="X",
						softMin=-100,softMax=100,step=1,bigStep=1,
						order=31
					},
					arenapety={
						type="range",
						name="Y",
						softMin=-100,softMax=100,step=1,bigStep=1,
						order=32
					},
				}
			},
			boss={
				type="group",
				name="Boss",
				order=11,
				args={
					bossframes={
						type="header",
						name="Boss Frames",
						order=0
					},
					bossx={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=10,
						order=1
					},
					bossy={
						type="range",
						name="Y",
						softMin=-600,softMax=600,step=1,bigStep=10,
						order=2
					},
					bossscale={
						type="range",
						name="Scale",
						min=0,max=3.0,step=0.01,bigStep=0.1,
						order=3
					},
					bossspace={
						type="range",
						name="Space",
						softMin=-150,softMax=150,step=1,bigStep=5,
						order=4
					},
					-- bosstextsize={
						-- type="range",
						-- name="Text Size",
						-- min=1,max=16,step=1,bigStep=1,
						-- order=5
					-- },
					bosstest={
						type="toggle",
						name="Test",
						get=function() return bosstest end,
						set=function(i,v) bosstest=v self:ApplySettings() end,
						order=6
					},
					bosscast={
						type="header",
						name="Cast Bar",
						order=10
					},
					bosscastx={
						type="range",
						name="X",
						softMin=-100,softMax=100,step=1,bigStep=1,
						order=11
					},
					bosscasty={
						type="range",
						name="Y",
						softMin=-100,softMax=100,step=1,bigStep=1,
						order=12
					},
					bosscastscale={
						type="range",
						name="Scale",
						min=0,max=3.0,step=0.01,bigStep=0.1,
						order=13
					},
				}
			},
			misc={
				type="group",
				name="Misc",
				order=20,
				args={
					hideart={
						type="toggle",
						name="Hide Art",
						order=1
					},
					disabledamage={
						type="toggle",
						name="Disable Portrait Damage",
						order=2
					},
					disablewhisp={
						type="toggle",
						name="Disable Chat Blinking",
						order=3
					},
					disablechaninv={
						type="toggle",
						name="Disable Channel Invite",
						order=4
					},
					minimaptweaks={
						type="toggle",
						name="Minimap Tweaks",
						order=7
					},
					classportrait={
						type="toggle",
						name="Class Portrait",
						order=8
					},
					safequeue={
						type="toggle",
						name="Safe PVP Queue",
						order=9
					},
					macrolimit={
						type="toggle",
						name="Extend Macro Limit",
						order=10
					},
					floatingcombattext={
						type="toggle",
						name="Shorter Floating Combat Text",
						order=11
					},
					framerate={
						type="header",
						name="Frame Rate",
						order=15
					},
					frameratex={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=10,
						order=16
					},
					frameratey={
						type="range",
						name="Y",
						softMin=-600,softMax=600,step=1,bigStep=5,
						order=17
					},
					eab={
						type="header",
						name="Extra Action",
						order=20
					},
					eabx={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=5,
						order=21
					},
					eaby={
						type="range",
						name="Y",
						softMin=-600,softMax=600,step=1,bigStep=5,
						order=22
					},
					powerbaralt={
						type="header",
						name="Power Bar Alt",
						order=30
					},
					powerbaraltx={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=5,
						order=31
					},
					powerbaralty={
						type="range",
						name="Y",
						softMin=-600,softMax=600,step=1,bigStep=5,
						order=32
					},
					container={
						type="header",
						name="Bags",
						order=40
					},
					containerx={
						type="range",
						name="X",
						softMin=-500,softMax=500,step=1,bigStep=5,
						order=41
					},
					containery={
						type="range",
						name="Y",
						softMin=-500,softMax=500,step=1,bigStep=5,
						order=42
					},
					talkinghead={
						type="header",
						name="Talking Head",
						order=50
					},
					talkingheadx={
						type="range",
						name="X",
						softMin=-500,softMax=500,step=1,bigStep=5,
						order=51
					},
					talkingheady={
						type="range",
						name="Y",
						softMin=-500,softMax=500,step=1,bigStep=5,
						order=52
					},
					other={
						type="header",
						name="",
						order=100
					},
					framescolor={
						type="range",
						name="Frames Color",
						min=0,max=1,step=0.01,bigStep=0.1,
						order=101
					},
					objtrackerx={
						type="range",
						name="Objectives X",
						softMin=-500,softMax=500,step=1,bigStep=5,
						order=102
					},
					objtracker={
						type="toggle",
						name="Objective Tracker",
						order=103
					},
				}
			},
		}
	}
end
