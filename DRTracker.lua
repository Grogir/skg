--------------------------------------------------
--
-- DRTracker.lua
-- created 27/10/2014
-- by Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------
-- maintenir la db

local AddonName,SKG=...
local DRTracker=SKG:NewModule("DRTracker","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
	x=-100,
	y=20,
	iconsize=30,
	cdalpha=0.8,
	disorient=true,
	incap=true,
	root=true,
	stun=true,
	silence=true,
}}

function DRTracker:OnInitialize()
	self.db=SKG.db:RegisterNamespace("DRTracker",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("DRTracker",self.options,"L DRTracker")
end

-- DR TRACKER

SpellDatabase={
[221527]="disorient", --Emprisonnement
[206961]="disorient", --Tremblez devant moi
[217832]="disorient", --Emprisonnement ---------- test dr
[213691]="disorient", --Flèche de dispersion
[2094]="disorient", --Cécité
[31661]="disorient", --Souffle du dragon
[145067]="disorient", --Renvoi du mal
[5484]="disorient", --Hurlement de terreur
[5246]="disorient", --Cri d’intimidation
[207167]="disorient", --Grésil aveuglant
[115268]="disorient", --Envoûtement
[130616]="disorient", --Peur
[8122]="disorient", --Cri psychique
[105421]="disorient", --Lumière aveuglante
[6358]="disorient", --Séduction
[33786]="disorient", --Cyclone
[209753]="disorient", --Cyclone
[118699]="disorient", --Peur
[226943]="disorient", --Explosion mentale
[202274]="disorient", --Boisson incendiaire
[207685]="disorient", --Sigil de supplice

[61025]="incap", --Métamorphose
[118]="incap", --Métamorphose
[3355]="incap", --Piège givrant
[142895]="incap", --Anneau de paix ---------- test
[20066]="incap", --Repentir
[61305]="incap", --Métamorphose
[161353]="incap", --Métamorphose
[161354]="incap", --Métamorphose
[67769]="incap", --Bombe à fragmentation en cobalt
[161355]="incap", --Métamorphose
[99]="incap", --Rugissement incapacitant
[126819]="incap", --Métamorphose
[6770]="incap", --Assommer
[61721]="incap", --Métamorphose
[28271]="incap", --Métamorphose
[6789]="incap", --Voile de mort
[19386]="incap", --Piqûre de wyverne
[9484]="incap", --Entraves des Morts-vivants ---------- test dr
[51514]="incap", --Maléfice
[82691]="incap", --Anneau de givre
[1776]="incap", --Suriner
[30216]="incap", --Bombe en gangrefer
[605]="incap", --Contrôle mental ---------- test dr
[115078]="incap", --Paralysie
[28272]="incap", --Métamorphose
[209790]="incap", --Flèche givrante
[161372]="incap", --Métamorphose
[61780]="incap", --Métamorphose
[88625]="incap", --Mot sacré : Châtier ---------- test
[710]="incap", --Bannir ---------- test dr
[30217]="incap", --Grenade en adamantite
[107079]="incap", --Paume vibratoire
[200196]="incap", --Mot sacré : Châtier
[210873]="incap", --Maléfice
[236748]="incap", --Rugissement d'intimidation

[122]="root", --Nova de givre
[64803]="root", --Piège
[114404]="root", --Étreinte de la vrille du Vide
[33395]="root", --Gel
[53148]="root", --Charge
[170855]="root", --Sarments
[102359]="root", --Enchevêtrement de masse
[135373]="root", --Piège
[136634]="root", --Chas de l’aiguille
[116706]="root", --Handicap
[339]="root", --Sarments
[157997]="root", --Nova de glace
[228600]="root", --Pointe glaciaire
[64695]="root", --Poigne de terre
[96294]="root", --Chaînes de glace
[207171]="root", --L’hiver approche ---------- test
[235963]="root", --Sarments
[233582]="root", --Prison de flammes
[55536]="root", --Filet en tisse-givre
[190927]="root", --Harpon
[212638]="root", --Filet de pisteur
[205365]="root", --Tir de bola
[233395]="root", --Cœur gelé
[198121]="root", --Morsure de givre
[162480]="root", --Piège d’acier
[204085]="root", --Froid de la mort
[186456]="root", --Sarments
[12024]="root", --Filet
[235235]="root", --Nova de givre
[235612]="root", --Souffle de givre ---------- test dr
[220128]="root", --Nova de givre
[232978]="root", --Harpon

[45334]="rndroot", --Immobilisé ---------- test dr
[105771]="rndroot", --Charge ---------- test dr
[91807]="rndroot", --Ruée titubante ---------- test dr
[199042]="rndroot", --Foudroyé ---------- test dr
[230138]="rndroot", --Surprise ---------- test dr

[221562]="stun", --Asphyxier
[408]="stun", --Aiguillon perfide
[196958]="stun", --Frappe des ombres
[171017]="stun", --Frappe météore
[211881]="stun", --Éruption gangrenée
[30283]="stun", --Furie de l’ombre
[171018]="stun", --Frappe météore
[1833]="stun", --Coup bas
[205290]="stun", --Traînée de cendres
[179057]="stun", --Nova du chaos
[203123]="stun", --Estropier
[232055]="stun", --Poings de fureur
[118345]="stun", --Pulvérisation
[119381]="stun", --Balayement de jambe
[163505]="stun", --Griffure
[118905]="stun", --Charge statique
[200166]="stun", --Métamorphose
[132169]="stun", --Éclair de tempête
[132168]="stun", --Onde de choc
[89766]="stun", --Lancer de hache
[853]="stun", --Marteau de la justice
[24394]="stun", --Intimidation
[117526]="stun", --Tir de lien
[5211]="stun", --Rossée puissante
[108194]="stun", --Asphyxier
[91800]="stun", --Ronger
[120086]="stun", --Poings de fureur
[91797]="stun", --Coup monstrueux
[200200]="stun", --Mot sacré : Châtier
[64044]="stun", --Horreur psychique
[199804]="stun", --Entre les deux yeux
[213688]="stun", --Enchaînement gangrené
[204399]="stun", --Rage de la terre
[197214]="stun", --Fracture
[248406]="stun", --Cœur froid
[255941]="stun", --Traînée de cendres
[199085]="stun", --Sentier de la guerre
[222897]="stun", --Éclair de tempête
[205630]="stun", --Emprise d’Illidan
[213491]="stun", --Piétinement démoniaque ---------- test dr
[204437]="stun", --Lasso de foudre
[221792]="stun", --Aiguillon perfide
[235692]="stun", --Onde de choc

[22703]="rndstun", --Éveil de l'infernal ---------- test dr
[77505]="rndstun", --Séisme ---------- test dr
[20549]="rndstun", --Choc martial ---------- test dr
[7922]="rndstun", --Porteguerre ---------- test

[87204]="nodr", --Péché et punition ---------- test dr
[31117]="nodr", --Affliction instable ---------- test
[196364]="nodr", --Affliction instable ---------- test

[31935]="silence", --Bouclier du vengeur
[1330]="silence", --Garrot - Silence
[230122]="silence", --Garrot - Silence
[47476]="silence", --Strangulation
[15487]="silence", --Silence
[78675]="silence", --Rayon solaire ---------- test dr
[81261]="silence", --Rayon solaire ---------- test dr
[202933]="silence", --Piqûre d’araignée
[217824]="silence", --Bouclier de vertu
[205421]="silence", --Flèche gémissante
[204490]="silence", --Sigil de silence
[214459]="silence", --Flammes asphyxiantes

[88611]="buff", --Bombe fumigène
[122783]="buff", --Diffusion de la magie
[212800]="buff", --Voile corrompu
[22812]="buff", --Ecorce
[23920]="buff", --Renvoi de sort
[102342]="buff", --Ecorcefer
[108271]="buff", --Transfert astral
[210655]="buff", --Protection d’Ashamane
[120954]="buff", --Boisson fortifiante
[118038]="buff", --Par le fil de l’épée
[5277]="buff", --Évasion
[108359]="buff", --Sombre régénération
[108416]="buff", --Sombre pacte
[8178]="buff", --Effet du Totem de glèbe
[199754]="buff", --Riposte

[124488]="aura", --Focalisation zen
[131558]="aura", --Égide de marcheur des esprits
[31821]="aura", --Maîtrise des auras

[871]="def", --Mur protecteur
[45438]="def", --Bloc de glace
[33206]="def", --Suppression de la douleur
[61336]="def", --Instincts de survie
[125174]="def", --Toucher du karma
[48707]="def", --Carapace anti-magie
[47585]="def", --Dispersion
[198111]="def", --Bouclier temporel
[48792]="def", --Robustesse glaciale
[1022]="def", --Bénédiction de protection
[115018]="def", --Terre profanée
[31224]="def", --Cape d'ombre
[74001]="def", --Promptitude au combat
[104773]="def", --Résolution interminable
[19263]="def", --Dissuasion
[186265]="def", --Aspect de la tortue
[642]="def", --Bouclier divin
[498]="def", --Protection divine
}

local drduration=18
local drtimeout=26
-- local drignore={rndroot=1,nodr=1,buff=1,aura=1,def=1,immune=1,playerbuff=1}
local arenamax=3

DRTracker.units={}
function DRTracker:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","CombatLogEvent")
	for i=1,arenamax do
		self.units[i]=CreateFrame("Frame")
		self.units[i]:SetPoint("TOPLEFT",_G["ArenaEnemyFrame"..i],"TOPLEFT",db.x,db.y)
		self.units[i]:SetSize(db.iconsize,db.iconsize)
		self.units[i].trackers={}
	end
end

function DRTracker:OnDisable()
	self:UnregisterAllEvents()
	for i=1,arenamax do
		self.units[i]:Hide()
	end
	wipe(self.units)
end

function DRTracker:CombatLogEvent()
	local _,eventType,_,_,_,_,_,destGUID,_,_,_,spellID,_,_,auraType=CombatLogGetCurrentEventInfo()
	local unit
	for i=1,arenamax do
		if destGUID==UnitGUID("arena"..i) then unit=i break end
	end
	-- if UnitGUID("target")==destGUID then unit=1 end -- debug
	if unit and SpellDatabase[spellID] and auraType=="DEBUFF" and db[SpellDatabase[spellID]] then
		if eventType=="SPELL_AURA_REFRESH" or eventType=="SPELL_AURA_APPLIED" then
			self:Applied(unit,spellID)
		elseif eventType=="SPELL_AURA_REMOVED" then
			self:Faded(unit,spellID)
		end
	end
end

function DRTracker:GetTrack(unit,cat)
	local track=self.units[unit].trackers[cat]
	if not track then
		track=CreateFrame("Frame",nil,self.units[unit])
		self.units[unit].trackers[cat]=track
		track:SetPoint("CENTER",0,0)
		track:SetSize(db.iconsize,db.iconsize)
		track.cd=CreateFrame("Cooldown",nil,track,"CooldownFrameTemplate")
		track.cd:SetDrawEdge(false)
		track.cd:SetAllPoints(track)
		track.cd:SetAlpha(db.cdalpha)
		track.t=track:CreateTexture(nil,"BORDER")
		track.t:SetAllPoints()
		track.txt=track:CreateFontString(nil,"OVERLAY")
		track.txt:SetFont("Fonts\\FRIZQT__.TTF",10,"OUTLINE")
		track.txt:SetPoint("BOTTOMRIGHT",2,0)
		track.active=0
		track.endtime=0
		track:SetScript("OnUpdate",function(f,elapsed)
			if f.endtime>0 and GetTime()>f.endtime then
				f.active=0
				f:Hide()
				DRTracker:Layout(unit)
			end
		end)
	end
	return track
end

function DRTracker:Applied(unit,spellID)
	local cat=SpellDatabase[spellID]
	local track=self:GetTrack(unit,cat)
	track.t:SetTexture(GetSpellTexture(spellID))
	track.active=track.active+1
	track.endtime=GetTime()+drtimeout
	if track.active==1 then track.txt:SetText("\194\189") track.txt:SetTextColor(0,1,0) end
	if track.active==2 then track.txt:SetText("\194\188") track.txt:SetTextColor(1,0.5,0) end
	if track.active==3 then track.txt:SetText("0") track.txt:SetTextColor(1,0,0) end
	track.cd:Hide()
	track:Show()
	self:Layout(unit)
end

function DRTracker:Faded(unit,spellID)
	local cat=SpellDatabase[spellID]
	local track=self:GetTrack(unit,cat)
	track.cd:SetCooldown(GetTime(),drduration)
	if track.active==0 then track.active=1 end
	track.endtime=GetTime()+drduration
	track:Show()
	self:Layout(unit)
end

function DRTracker:Layout(unit)
	local x=0
	for cat,track in pairs(self.units[unit].trackers) do
		track:ClearAllPoints()
		if track.active>0 then
			track:SetPoint("CENTER",self.units[unit],"CENTER",x,0)
			x=x+db.iconsize
		end
	end
end

function DRTracker:ApplySettings()
	if db.enabled then
		for i=1,arenamax do
			self.units[i]:SetPoint("TOPLEFT",_G["ArenaEnemyFrame"..i],"TOPLEFT",db.x,db.y)
			self.units[i]:SetSize(db.iconsize,db.iconsize)
			for cat,track in pairs(self.units[i].trackers) do
				track:SetSize(db.iconsize,db.iconsize)
				track.cd:SetAlpha(db.cdalpha)
			end
			self:Layout(i)
		end
	end
end

-- OPTIONS

local testspells={118,130616,853,339,15487}
local itest=1
local function Test()
	if db.enabled then
		local s=testspells[itest]
		if db[SpellDatabase[s]] then
			for i=1,arenamax do
				DRTracker:Applied(i,s)
				DRTracker:Faded(i,s)
			end
		end
		itest=itest%#testspells+1
	end
end
local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	DRTracker:ApplySettings()
end
function DRTracker:GetOptions()
	return {
		order=6,
		type="group",
		name="DR Tracker",
		desc="Arena diminishing returns tracker",
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
				order=1,
			},
			drt={
				type="header",
				name="DR Tracker",
				order=10,
			},
			x={
				type="range",
				name="X",
				softMin=-500,softMax=500,step=1,bigStep=5,
				order=11,
			},
			y={
				type="range",
				name="Y",
				softMin=-500,softMax=500,step=1,bigStep=5,
				order=12
			},
			test={
				type="execute",
				name="Test",
				func=Test,
				order=13
			},
			nl1={
				type="description",
				name="",
				order=14
			},
			iconsize={
				type="range",
				name="Icon Size",
				softMin=-100,softMax=100,step=1,bigStep=5,
				order=15
			},
			cdalpha={
				type="range",
				name="Cooldown Alpha",
				min=0,max=1,step=0.1,
				order=16
			},
			nl2={
				type="description",
				name="",
				order=17
			},
			disorient={
				type="toggle",
				name="Draw Disorients",
				width="full",
				order=20
			},
			incap={
				type="toggle",
				name="Draw Incapacitates",
				width="full",
				order=21
			},
			root={
				type="toggle",
				name="Draw Roots",
				width="full",
				order=22
			},
			stun={
				type="toggle",
				name="Draw Stuns",
				width="full",
				order=23
			},
			silence={
				type="toggle",
				name="Draw Silences",
				width="full",
				order=24
			},
		}
	}
end
