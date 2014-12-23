--------------------------------------------------
--
-- Frames.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL & Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------
-- taint dk pet frame -- valable wod ??
-- taint objets de quete

local AddonName,SKG=...
local Frames=SKG:NewModule("Frames","AceEvent-3.0")
local db
-- _G.SGF=Frames

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
	
	runeframex=28,
	runeframey=25,
	runeframescale=1.3,
	totemframex=28,
	totemframey=-75,
	petframex=30,
	petframey=-85,
	
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
	framescolor=0.4,
	frameratex=0,
	frameratey=-350,
	eabx=0,
	eaby=-335,
	powerbaraltx=0,
	powerbaralty=-335,
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
	self:ApplySettings()
end
function Frames:OnDisable()
end
function Frames:ApplySettings()
	self:UnitFrames()
	self:Misc()
end
local function EmptyFunc() end

-- FRAMES

local hbf
function Frames:UnitFrames()
	-- Player & Targets frames
	PlayerFrame:ClearAllPoints()
	PlayerFrame:SetPoint("CENTER",UIParent,"CENTER",db.playerx,db.playery) -- -350,300
	PlayerFrame:SetUserPlaced(true)
	if db.playerscale>0 then PlayerFrame:SetScale(db.playerscale) end

	TargetFrame:ClearAllPoints()
	TargetFrame:SetPoint("CENTER",UIParent,"CENTER",db.targetx,db.targety) -- 280,300
	TargetFrame:SetUserPlaced(true)
	if db.targetscale>0 then TargetFrame:SetScale(db.targetscale) end

	FocusFrame:ClearAllPoints()
	FocusFrame:SetPoint("CENTER",UIParent,"CENTER",db.focusx,db.focusy) -- 400,-260 400,-100
	FocusFrame:SetUserPlaced(true)
	if db.focusscale>0 then FocusFrame:SetScale(db.focusscale) end

	TargetFrameToT:ClearAllPoints()
	TargetFrameToT:SetPoint("BOTTOMRIGHT",TargetFrame,"BOTTOMRIGHT",db.targettargetx,db.targettargety)
	TargetFrameToT:SetUserPlaced(true)
	FocusFrameToT:ClearAllPoints()
	FocusFrameToT:SetPoint("BOTTOMRIGHT",FocusFrame,"BOTTOMRIGHT",db.focustargetx,db.focustargety)
	FocusFrameToT:SetUserPlaced(true)

	local _,class=UnitClass("player")
	if class=="DEATHKNIGHT" then
		RuneFrame:ClearAllPoints()
		RuneFrame:SetPoint("TOP",PlayerFrame,"BOTTOM",db.runeframex,db.runeframey)
		if db.runeframescale>0 then RuneFrame:SetScale(db.runeframescale) end
		TotemFrame:ClearAllPoints()
		TotemFrame:SetPoint("TOPLEFT",PlayerFrame,"TOPLEFT",db.totemframex,db.totemframey)
		TotemFrame.SetPoint=EmptyFunc
		PetFrame:ClearAllPoints()
		PetFrame:SetPoint("TOPLEFT",PlayerFrame,"TOPLEFT",db.petframex,db.petframey)
	end

	-- Arena frames
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
			if not frame.SetPointNew then
				frame.SetPointNew=frame.SetPoint
				frame.SetPoint=EmptyFunc
			end
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
				portrait:SetPoint(pt,rel,relpt,3,6)
				-- portrait:SetPoint(pt,rel,relpt,x+14,y+10)
			
				pt,rel,relpt,x,y=back:GetPoint()
				back:SetPoint(pt,rel,relpt,2,0)
				-- back:SetPoint(pt,rel,relpt,x,y+10)
				back:SetHeight(25)
				
				pt,rel,relpt,x,y=spec:GetPoint()
				spec:SetPoint(pt,rel,relpt,5,-1)
				-- spec:SetPoint(pt,rel,relpt,x+5,y-5)
				pt,rel,relpt,x,y=specportrait:GetPoint()
				specportrait:SetPoint(pt,rel,relpt,9,-5)
				-- specportrait:SetPoint(pt,rel,relpt,x+7,y-7)
				
				x,y=healthbar:GetSize()
				healthbar:SetSize(71,7)
				-- healthbar:SetSize(x+1,y-1)
				x,y=manabar:GetSize()
				manabar:SetSize(71,5)
				-- manabar:SetSize(x+1,y-3)
				healthbartext:SetFont("Fonts\\FRIZQT__.TTF",8,"OUTLINE")
				healthbartext:SetPoint("CENTER",healthbar)
				manabartext:SetFont("Fonts\\FRIZQT__.TTF",8,"OUTLINE")
				manabartext:SetPoint("CENTER",manabar)
			end
		
			if arenatest and j==1 then
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
		
		if arenatest then
			cast:Show()
			cast:SetAlpha(0.5)
			cast.fadeOut=nil
			name:SetText(PlayerName:GetText())
			pet:Show()
		end
	end
	if arenatest then ArenaEnemyFrames:Show() else ArenaEnemyFrames:Hide() end
	-- ArenaEnemyBackground:SetPoint("RIGHT", "ArenaEnemyFrame1", "RIGHT", 30, 0)
	-- /run GetNumArenaOpponents=function() return 3 end UpdateArenaEnemyBackground(1)

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
			hbf(party,100) -- Debug
			party.name:SetText(PlayerName:GetText()) -- Debug
			local tex=CLASS_ICON_TCOORDS[select(2,UnitClass("player"))] --Debug
			party.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			party.portrait:SetTexCoord(unpack(tex)) --Debug
			-- SetPortraitToTexture(party.portrait,"Interface\\Icons\\Spell_Nature_HealingTouch") -- Debug
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
			boss.SetPoint=EmptyFunc
		end
		boss:SetPointNew("TOPRIGHT",MinimapCluster,"BOTTOMRIGHT",db.bossx,db.bossy-(i-1)*db.bossspace)
		boss.spellbar:ClearAllPoints()
		boss.spellbar:SetPoint("TOPLEFT",boss,"BOTTOMLEFT",db.bosscastx,db.bosscasty)
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
end

function Frames:Misc()
	-- Hide art
	if db.hideart then
		MainMenuBarLeftEndCap:Hide()
		MainMenuBarRightEndCap:Hide()
	else
		MainMenuBarLeftEndCap:Show()
		MainMenuBarRightEndCap:Show()
	end

	-- Disable text on portrait
	if not PlayerHitIndicator.ShowNew then
		PlayerHitIndicator.ShowNew=PlayerHitIndicator.Show
		PetHitIndicator.ShowNew=PetHitIndicator.Show
	end
	if db.disabledamage then
		PlayerHitIndicator.Show=EmptyFunc
		PetHitIndicator.Show=EmptyFunc
	else
		PlayerHitIndicator.Show=PlayerHitIndicator.ShowNew
		PetHitIndicator.Show=PetHitIndicator.ShowNew
	end

	-- Disable blinking whisp tab
	if not FCF_StartAlertFlashNew then
		FCF_StartAlertFlashNew=FCF_StartAlertFlash
	end
	if db.disablewhisp then
		FCF_StartAlertFlash=EmptyFunc
	else
		FCF_StartAlertFlash=FCF_StartAlertFlashNew
	end
	-- Disable invites
	if db.disablechaninv then
		UIParent:UnregisterEvent("CHANNEL_INVITE_REQUEST")
	end
	-- Move some UIParent frames
	FramerateLabel.ignoreFramePositionManager=true
	FramerateLabel:ClearAllPoints()
	FramerateLabel:SetPoint("CENTER",UIParent,"CENTER",db.frameratex,db.frameratey)

	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER",UIParent,"CENTER",db.eabx,db.eaby)
	ExtraActionBarFrame.ignoreFramePositionManager=true
	-- PlayerPowerBarAltCounterBar:ClearAllPoints()
	-- PlayerPowerBarAltCounterBar:SetPoint("CENTER",UIParent,"CENTER",0,-335)
	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetPoint("CENTER",UIParent,"CENTER",db.powerbaraltx,db.powerbaralty)
	PlayerPowerBarAlt.ignoreFramePositionManager=true
	UIPARENT_MANAGED_FRAME_POSITIONS.OBJTRACKER_OFFSET_X.baseX=30
	UIPARENT_MANAGED_FRAME_POSITIONS.CONTAINER_OFFSET_Y.yOffset=-20

	-- Minimap Tweaks
	if db.minimaptweaks then
		MinimapZoomIn:Hide()
		MinimapZoomOut:Hide()
		Minimap:EnableMouseWheel(true)
		Minimap:SetScript("OnMouseWheel",function(self,delta)
			if delta>0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
		end)
		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint("TOPRIGHT",-26,7)
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
end

-- PORTRAIT

-- hooksecurefunc("UnitFramePortrait_Update",function(self)
	-- if self.portrait then
		-- if UnitIsPlayer(self.unit) then
			-- local t=CLASS_ICON_TCOORDS[select(2,UnitClass(self.unit))]
			-- if t then
				-- self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				-- self.portrait:SetTexCoord(unpack(t))
			-- end
		-- else
			-- self.portrait:SetTexCoord(0,1,0,1)
		-- end
	-- end
-- end)

function arbre(f,str) -- /run print(arbre(ArenaEnemyFrame1))
	if not str then str="" end
	t={f:GetRegions()}
	for a,b in pairs(t) do
		name=b:GetName()
		if name then str=str..b:GetName().." ; " else str=str.."nil ; " end
	end
	t={f:GetChildren()}
	for a,b in pairs(t) do
		name=b:GetName()
		if name then str=str..b:GetName() else str=str.."nil" end
		if b:GetNumRegions() or b:GetNumChildren() then
			str=str.." { "
			str=arbre(b,str)
			str=str.."} "
		else
			 str=str.." ; "
		end
	end
	return str
end
function arbretex(f,str) -- /run print(arbretex(MainMenuBar))
	if not str then str="" end
	t={f:GetRegions()}
	for a,b in pairs(t) do
		if b:GetObjectType()=="Texture" then
			str=str..(b:GetName() or "name").." "..(b:GetTexture() or "tex").." ; "
		end
	end
	t={f:GetChildren()}
	for a,b in pairs(t) do
		if b:GetNumRegions() or b:GetNumChildren() then
			str=arbretex(b,str)
		end
	end
	return str
end
darktextures={
["arenaenemyframe\\ui-arenatargetingframe"]=1,
["auctionframe"]=1,
["bankframe"]=1,
-- ["buttons"]=1,
["characterframe\\totemborder"]=1,
["characterframe\\ui-characterframe-groupindicator"]=1,
["characterframe\\ui-deathknightframe"]=1,
["characterframe\\ui-player-portrait"]=1,
["dialogframe\\dialogframe-bot"]=1,
["dialogframe\\dialogframe-corners"]=1,
["dialogframe\\dialogframe-left"]=1,
["dialogframe\\dialogframe-right"]=1,
["dialogframe\\dialogframe-top"]=1,
["dialogframe\\ui-dialogbox-border"]=1,
["dialogframe\\ui-dialogbox-corner"]=1,
["dialogframe\\ui-dialogbox-divider"]=1,
["dialogframe\\ui-dialogbox-header"]=1,
["durability"]=1,
["framegeneral"]=1,
["groupframe\\ui-group-portrait"]=1,
["lootframe\\ui-lootpanel"]=1,
["mainmenubar\\ui-mainmenubar-dwarf"]=1,
["mainmenubar\\ui-mainmenubar-endcap-dwarf"]=1,
["mainmenubar\\ui-mainmenubar-endcap-human"]=1,
["mainmenubar\\ui-mainmenubar-human"]=1,
["mainmenubar\\ui-mainmenubar-keyring"]=1,
["mainmenubar\\ui-mainmenubar-maxlevel"]=1,
["mainmenubar\\ui-mainmenubar-nightelf"]=1,
["mainmenubar\\ui-xp-bar"]=1,
["mainmenubar\\ui-xp-mid"]=1,
-- ["merchantframe"]=1,
["minimap\\ui-minimap-border"]=1,
["minimap\\minimap-trackingborder"]=1,
["paperdoll"]=1,
["paperdollinfoframe"]=1,--
["petactionbar"]=1,
["petpaperdollframe\\ui-petframe-slots"]=1,
["petpaperdollframe\\ui-petframe-slots-companions"]=1,
["petpaperdollframe\\ui-petframe-slots-mounts"]=1,
["petpaperdollframe\\ui-petpaperdollframe-botleft"]=1,
["petpaperdollframe\\ui-petpaperdollframe-botright"]=1,
["petstableframe"]=1,
["playerframe\\ui-playerframe-deathknight"]=1,
["playerframe\\ui-playerframe-deathknight-background"]=1,
["playerframe\\ui-playerframe-deathknight-ring"]=1,
["pvpframe\\silvericonborder"]=1,
["pvpframe\\ui-character-pvp"]=1,
["pvpframe\\ui-character-pvp-elements"]=1,
-- ["questframe"]=1,
-- ["raidframe"]=1,
["shapeshiftbar"]=1,
["targetingframe\\numericthreatborder"]=1,
["targetingframe\\ui-focusframe-large"]=1,
["targetingframe\\ui-focustargetingframe"]=1,
["targetingframe\\ui-partyframe"]=1,
["targetingframe\\ui-smalltargetingframe"]=1,
["targetingframe\\ui-smalltargetingframe-nomana"]=1,
["targetingframe\\ui-targetingframe"]=1,
["targetingframe\\ui-targetingframe-minus"]=1,
-- ["targetingframe\\ui-targetingframe-elite"]=1,
["targetingframe\\ui-targetingframe-nolevel"]=1,
["targetingframe\\ui-targetingframe-nomana"]=1,
["targetingframe\\ui-targetingframe-plusmob"]=1,
-- ["targetingframe\\ui-targetingframe-rare"]=1,
-- ["targetingframe\\ui-targetingframe-rare-elite"]=1,
["targetingframe\\ui-targetingframe-raremob"]=1,
["targetingframe\\ui-targetoftargetframe"]=1,
["taxiframe\\ui-taxiframe-botleft"]=1,
["taxiframe\\ui-taxiframe-botright"]=1,
["taxiframe\\ui-taxiframe-topleft"]=1,
["taxiframe\\ui-taxiframe-topright"]=1,
-- ["timemanager"]=1,
["tooltips\\nameplate-border"]=1,
["tooltips\\nameplate-castbar"]=1,
["tooltips\\nameplate-castbar-shield"]=1,
["tooltips\\ui-statusbar-border"]=1,
-- ["tooltips\\ui-tooltip-b"]=1,--...
["tradeframe\\ui-tradeframe-botleft"]=1,
["tradeframe\\ui-tradeframe-botright"]=1,
["tradeframe\\ui-tradeframe-enchanticon"]=1,
["tradeframe\\ui-tradeframe-topleft"]=1,
["tradeframe\\ui-tradeframe-topright"]=1,
["tradeframe\\scaleddown"]=1,--
["tradeskillframe"]=1,
["vehicles\\seatindicator"]=1,
["vehicles\\ui-vehicle-frame"]=1,
["vehicles\\ui-vehicle-frame-alliance"]=1,
["vehicles\\ui-vehicle-frame-border"]=1,
["vehicles\\ui-vehicle-frame-organic"]=1,
["vehicles\\ui-vehicles-partyframe"]=1,
["vehicles\\ui-vehicles-partyframe-organic"]=1,
-- ["worldstateframe"]=1,
}
function checktex(f) -- /run checktex()
	if not f then f=UIParent end
	t={f:GetRegions()}
	for a,b in pairs(t) do
		if b:GetObjectType()=="Texture" then
			local texname=b:GetTexture()
			if texname then
				texname=texname:lower()
				local full=texname:match("interface\\(.+)")
				local folder=texname:match("interface\\(.+)\\")
				if darktextures[full] or darktextures[folder] then
					b:SetVertexColor(0.1,0.1,0.1)
					print("colored "..(b:GetName() or "tex"))
				end
			end
		end
	end
	t={f:GetChildren()}
	for a,b in pairs(t) do
		if not b:IsForbidden() and (b:GetNumRegions() or b:GetNumChildren()) then
			checktex(b)
		end
	end
end

hbf=function(f,n)
	f.healthbar:SetMinMaxValues(0,100);
	f.healthbar:SetValue(n);
	f.healthbar.forceHideText=false;
	f.manabar:SetMinMaxValues(0,100);
	f.manabar:SetValue(n);
	f.healthbar.forceHideText=false;
	f.healthbar:SetStatusBarColor(0,1,0);
	f.manabar:SetStatusBarColor(0,0,1);
end

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
				set=function(i,v) if v then self:Enable() else self:Disable() end db.enabled=v end,
				order=0,
			},
			reset={
				type="execute",
				name="Reset settings",
				func=function() SKG:ResetOptions(Frames.options.args,db,defaults.global) self:ApplySettings() end,
				order=0,
			},
			playertargets={
				type="group",
				name="Player - Targets",
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
				name="Resources - Pets",
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
						softMin=-100,softMax=100,step=1,bigStep=1,
						order=1
					},
					runeframey={
						type="range",
						name="Y",
						softMin=-100,softMax=100,step=1,bigStep=1,
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
						softMin=-200,softMax=200,step=1,bigStep=1,
						order=11
					},
					petframey={
						type="range",
						name="Y",
						softMin=-200,softMax=200,step=1,bigStep=1,
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
						softMin=-200,softMax=200,step=1,bigStep=1,
						order=21
					},
					totemframey={
						type="range",
						name="Y",
						softMin=-200,softMax=200,step=1,bigStep=1,
						order=22
					},
				}
			},
			-- pettotems={
				-- type="group",
				-- name="Pet & totems",
				-- order=7,
				-- args={
				-- }
			-- },
			-- petframe={
				-- type="group",
				-- name="Petframe",
				-- order=8,
				-- args={
				-- }
			-- },
			arena={
				type="group",
				name="Arena",
				order=9,
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
						desc="Disabling needs an UI reload",
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
			party={
				type="group",
				name="Party",
				order=10,
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
						name="Disable Blinking Chat",
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
					framescolor={
						type="range",
						name="Frames Color",
						min=0,max=1,step=0.01,bigStep=0.1,
						order=8
					},
					framerate={
						type="header",
						name="Frame Rate",
						order=10
					},
					frameratex={
						type="range",
						name="X",
						softMin=-1000,softMax=1000,step=1,bigStep=10,
						order=11
					},
					frameratey={
						type="range",
						name="Y",
						softMin=-600,softMax=600,step=1,bigStep=5,
						order=12
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
				}
			},
		}
	}
end