--------------------------------------------------
--
-- DRTracker.lua
-- created 27/10/2014
-- by Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------

local AddonName,SKG=...
local DRTracker=SKG:NewModule("DRTracker","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
	x=-100,
	y=20,
	iconsize=30,
}}

function DRTracker:OnInitialize()
	self.db=SKG.db:RegisterNamespace("DRTracker",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("DRTracker",self.options,"L DRTracker")
end

-- DR TRACKER

function DRTracker:OnEnable()

SpellDatabase={
[33786]="fear", --Cyclone
[31661]="fear", --Souffle du dragon
[105421]="fear", --Lumière aveuglante
[10326]="fear", --Renvoi du mal
[145067]="fear", --Renvoi du mal
[8122]="fear", --Cri psychique
[2094]="fear", --Cécité
[130616]="fear", --Peur
[118699]="fear", --Peur
[5484]="fear", --Hurlement de terreur
[115268]="fear", --Envoûtement
[6358]="fear", --Séduction
[5246]="fear", --Cri d’intimidation

[99]="sheep", --Rugissement incapacitant
[3355]="sheep", --Piège givrant
[19386]="sheep", --Piqûre de wyverne
[61025]="sheep", --Métamorphose
[118]="sheep", --Métamorphose
[61305]="sheep", --Métamorphose
[61721]="sheep", --Métamorphose
[28271]="sheep", --Métamorphose
[28272]="sheep", --Métamorphose
[61780]="sheep", --Métamorphose
[82691]="sheep", --Anneau de givre
[123393]="sheep", --Souffle de feu
[115078]="sheep", --Paralysie
[137460]="sheep", --Réduit au silence --A TEST
[20066]="sheep", --Repentir
[9484]="sheep", --Entraves des morts-vivants
[88625]="sheep", --Mot sacré : Châtier
[64044]="sheep", --Horreur psychique
[605]="sheep", --Emprise
[1776]="sheep", --Suriner
[6770]="sheep", --Assommer
[51514]="sheep", --Maléfice
[710]="sheep", --Bannir
[137143]="sheep", --Horreur sanglante
[6789]="sheep", --Voile de mort
[107079]="sheep", --Paume vibratoire
[30216]="sheep", --Bombe en gangrefer
[30217]="sheep", --Grenade en adamantite
[67769]="sheep", --Bombe à fragmentation en cobalt

[96294]="root", --Chaînes de glace
[339]="root", --Sarments
[113770]="root", --Sarments
[102359]="root", --Enchevêtrement de masse
[53148]="root", --Charge
[64803]="root", --Piège
[136634]="root", --Chas de l’aiguille
--[128405]="root", --Chas de l’aiguille
[122]="root", --Nova de givre
[115757]="root", --Nova de givre
[33395]="root", --Gel
[111340]="root", --Garde glaciale
[116706]="root", --Handicap
[114404]="root", --Etreinte de la vrille du Vide
[64695]="root", --Poigne de terre
[63685]="root", --Puissance gelée

[47476]="silence", --Strangulation
[81261]="silence", --Rayon solaire
[78675]="silence", --Rayon solaire
[102051]="silence", --Givregueule
[31935]="silence", --Bouclier du vengeur
[15487]="silence", --Silence
[1330]="silence", --Garrot - Silence

[91800]="stun", --Ronger
--[47481]="stun", --Ronger
[91797]="stun", --Coup monstrueux
[108194]="stun", --Asphyxier
[115001]="stun", --Hiver impitoyable
[22570]="stun", --Estropier
[163505]="stun", --Griffure
[5211]="stun", --Rossée puissante
[117526]="stun", --Tir de lien
[24394]="stun", --Intimidation
[44572]="stun", --Congélation
[119392]="stun", --Onde de la charge du buffle
[120086]="stun", --Poings de fureur
[119381]="stun", --Balayement de jambe
[105593]="stun", --Poing de la justice
[853]="stun", --Marteau de la justice
[119072]="stun", --Colère divine
[1833]="stun", --Coup bas
[408]="stun", --Aiguillon perfide
[118905]="stun", --Charge statique
[118345]="stun", --Pulvérisation
[89766]="stun", --Lancer de hache
[171017]="stun", --Frappe météore --A TEST
[171018]="stun", --Frappe météore --A TEST
[30283]="stun", --Furie de l’ombre
[132168]="stun", --Onde de choc
--[46968]="stun", --Onde de choc
[132169]="stun", --Eclair de tempête
--[107570]="stun", --Eclair de tempête

--A TEST
[105771]="rndroot", --Charge
[87194]="rndroot", --Glyphe d’attaque mentale
[107566]="rndroot", --Cri ahurissant --obsolete?
[45334]="rndroot", --Immobilisé
[91807]="rndroot", --Ruée titubante
[114238]="silence", --Silence des lucioles
[80483]="silence", --Torrent arcanique
[25046]="silence", --Torrent arcanique
[50613]="silence", --Torrent arcanique
[28730]="silence", --Torrent arcanique
[129597]="silence", --Torrent arcanique
[69179]="silence", --Torrent arcanique
[18498]="silence", --Réduit au silence - Imposition du silence
[20549]="rndstun", --Choc martial
[113801]="rndstun", --Sonner --obsolete?
[118895]="rndstun", --Rugissement de dragon
[77505]="rndstun", --Séisme
[22703]="rndstun", --Eveil de l'infernal
[7922]="rndstun", --Porteguerre
[87204]="nodr", --Péché et punition
[31117]="nodr", --Affliction instable

[88611]="buff", --Bombe fumigène
[122783]="buff", --Diffusion de la magie
[89523]="buff", --Totem de glèbe
[8178]="buff", --Effet du Totem de glèbe
[23920]="buff", --Renvoi de sort
[115760]="buff", --Glyphe de bloc de glace
[108416]="buff", --Pacte sacrificiel
[108359]="buff", --Sombre régénération
[5277]="buff", --Evasion
[118038]="buff", --Par le fil de l’épée
[62606]="buff", --Défense sauvage
[102342]="buff", --Ecorcefer
[108271]="buff", --Transfert astral
[120954]="buff", --Boisson fortifiante
[3411]="buff", --Intervention
[22812]="buff", --Ecorce
[114028]="buff", --Renvoi de sort de masse
[114029]="buff", --Protéger
[49039]="buff", --Changeliche

[124488]="aura", --Focalisation zen
[31821]="aura", --Aura de dévotion
[131558]="aura", --Egide de marcheur des esprits
-- priest ?
-- drood ?

[871]="def", --Mur protecteur
[125174]="def", --Toucher du karma
[19263]="def", --Dissuasion
[48707]="def", --Carapace anti-magie
[104773]="def", --Résolution interminable
[74001]="def", --Promptitude au combat
[110913]="def", --Sombre marché
[148467]="def", --Dissuasion
[31224]="def", --Cape d'ombre
[61336]="def", --Instincts de survie
[115018]="def", --Terre profanée
[33206]="def", --Suppression de la douleur
[498]="def", --Protection divine
[1022]="def", --Main de protection
[47585]="def", --Dispersion
[30823]="def", --Rage du chaman
[48792]="def", --Robustesse glaciale
[45438]="def", --Bloc de glace
[642]="def" --Bouclier divin
}
drduration=18 drtimeout=28
drdebuff="DEBUFF" -- BUFF pour debug
drignore={rndroot=1,nodr=1,buff=1,aura=1,def=1,immune=1,playerbuff=1}
drt=CreateFrame("FRAME")
drt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
drt:SetScript("OnEvent",function(_,_,_,eventType,_,_,_,_,_,destGUID,_,_,_,spellID,_,_,auraType)
	local unit
	for i=1,3 do
		if destGUID==UnitGUID("arena"..i) then unit=i break end
	end
	-- if (UnitGUID("target")==destGUID) then unit=1 end -- debug
	-- if SpellDatabase[spellID] then drt:Applied(1, spellID) end -- debug
	if unit and SpellDatabase[spellID] and auraType==drdebuff and not drignore[SpellDatabase[spellID]] then
		if eventType=="SPELL_AURA_REFRESH" or eventType=="SPELL_AURA_APPLIED" then
			drt:Applied(unit,spellID)
		elseif eventType=="SPELL_AURA_REMOVED" then
			drt:Faded(unit,spellID)
		end
	end
end)
drframe={}
for i=1,3 do
	-- drframe[i]=CreateFrame("Frame",nil,_G["ArenaEnemyFrame"..i])
	drframe[i]=CreateFrame("Frame")
	drframe[i]:SetPoint("TOPLEFT",_G["ArenaEnemyFrame"..i],"TOPLEFT",db.x,db.y)
	drframe[i]:SetSize(db.iconsize,db.iconsize)
	drframe[i].t = drframe[i]:CreateTexture(nil, "BORDER")
	drframe[i].t:SetAllPoints();
	drframe[i].t:Hide();
	local texture = select(4, GetSpecializationInfo(GetSpecialization()))
	SetPortraitToTexture(drframe[i].t,texture)
	drframe[i].tracker={}
end
function drt:GetTrack(unit,cat)
	local track=drframe[unit].tracker[cat]
	if not track then
		-- track=CreateFrame("Frame",nil,drframe[unit])
		track=CreateFrame("Frame")
		drframe[unit].tracker[cat]=track
		-- track:SetPoint("CENTER",drframe[unit],"CENTER",0,0)
		track:SetPoint("CENTER",0,0)
		track:SetSize(db.iconsize,db.iconsize)
		-- track.cd=CreateFrame("Cooldown",nil,track)
		track.cd=CreateFrame("Cooldown",nil)
		track.cd:SetAllPoints(track)
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
				drt:Layout(unit)
			end
		end)
	end
	return track
end
function drt:Applied(unit,spellID)
	local cat=SpellDatabase[spellID]
	local track=drt:GetTrack(unit,cat)
	track.t:SetTexture(GetSpellTexture(spellID))
	track.active=track.active+1
	track.endtime=GetTime()+drtimeout
	if track.active==1 then track.txt:SetText("\194\189") track.txt:SetTextColor(0,1,0) end
	if track.active==2 then track.txt:SetText("\194\188") track.txt:SetTextColor(1,0.5,0) end
	if track.active==3 then track.txt:SetText("0") track.txt:SetTextColor(1,0,0) end
	track.cd:Hide()
	track:Show()
	drt:Layout(unit)
end
function drt:Faded(unit,spellID)
	local cat=SpellDatabase[spellID]
	local track=drt:GetTrack(unit,cat)
	track.cd:SetCooldown(GetTime(),drduration)
	if track.active==0 then track.active=1 end
	track.endtime=GetTime()+drduration
	track:Show()
	drt:Layout(unit)
end
function drt:Layout(unit)
	local x=0
	for cat,track in pairs(drframe[unit].tracker) do
		track:ClearAllPoints()
		if track.active>0 then
			track:SetPoint("CENTER",drframe[unit],"CENTER",x,0)
			x=x+db.iconsize
		end
	end
end

end
function DRTracker:OnDisable()
end

function DRTracker:ApplySettings()
	for i=1,3 do
		drframe[i]:SetSize(db.iconsize,db.iconsize)
		drframe[i].t:Show()
		drframe[i]:SetPoint("TOPLEFT",_G["ArenaEnemyFrame"..i],"TOPLEFT",db.x,db.y)
	end
end

-- OPTIONS

local function ShowPos()
	for i=1,3 do
		drframe[i].t:Show()
	end
end

local function HidePos()
	for i=1,3 do
		drframe[i].t:Hide()
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
				order=1,
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
			iconsize={
				type="range",
				name="Icon Size",
				min=-500,max=500,step=1,bigStep=5,
				order=12
			},
			showposition={
				type="execute",
				name="Show Position",
				func=ShowPos,
				order=13
			},
			hideposition={
				type="execute",
				name="Hide Position",
				func=HidePos,
				order=14
			},
			drt={
				type="header",
				name="DR Tracker",
				order=10,
			},
		}
	}
end
