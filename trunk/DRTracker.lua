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
}}

function DRTracker:OnInitialize()
	self.db=SKG.db:RegisterNamespace("DRTracker",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("DRTracker",self.options,"L DRTracker")
	self:RegisterEvent("PLAYER_LOGIN")
end
function DRTracker:PLAYER_LOGIN()
	self:Enable()
end

-- DR TRACKER

function DRTracker:ApplySettings()
end

function DRTracker:Enable()

SpellDatabase={--[127538]="stun",[768]="stun",[774]="fear",[5217]="stun",[17]="stun",-- debug
[2637]="disorient",[3355]="disorient",[19386]="disorient",[118]="disorient",[28272]="disorient",[28271]="disorient",[61305]="disorient",[61025]="disorient",[61721]="disorient",[61780]="disorient",[82691]="disorient",[115078]="disorient",[20066]="disorient",[9484]="disorient",[1776]="disorient",[6770]="disorient",[51514]="disorient",[107079]="disorient",[30217]="disorient",[67769]="disorient",[30216]="disorient",
[47476]="silence",[78675]="silence",[34490]="silence",[55021]="silence",[102051]="silence",[116709]="silence",[31935]="silence",[15487]="silence",[1330]="silence",[24259]="silence",[115782]="silence",[18498]="silence",[25046]="silence",[28730]="silence",[50613]="silence",[69179]="silence",[80483]="silence",[129597]="silence",[114238]="silence",[137460]="silence",
[91644]="disarm",[50541]="disarm",[117368]="disarm",[126458]="disarm",[64058]="disarm",[51722]="disarm",[118093]="disarm",[676]="disarm",[137461]="disarm",
[1513]="fear",[10326]="fear",[8122]="fear",[113792]="fear",[2094]="fear",[118699]="fear",[5484]="fear",[6358]="fear",[115268]="fear",[104045]="fear",[5246]="fear",[20511]="fear",[105421]="fear",[113004]="fear",[113056]="fear",[130616]="fear",[145067]="fear",
[108194]="stun",[91800]="stun",[91797]="stun",[22570]="stun",[9005]="stun",[102546]="stun",[5211]="stun",[102795]="stun",[127361]="stun",[113801]="stun",[24394]="stun",[90337]="stun",[50519]="stun",[117526]="stun",[44572]="stun",[118271]="stun",[119392]="stun",[119381]="stun",[122242]="stun",[126451]="stun",[120086]="stun",[853]="stun",[119072]="stun",[105593]="stun",[1833]="stun",[408]="stun",[118905]="stun",[30283]="stun",[89766]="stun",[132168]="stun",[20549]="stun",[107570]="stun",[46968]="stun",[115001]="stun",[47481]="stun",[110698]="stun",[132169]="stun",[126246]="stun",[105771]="stun",[126423]="stun",[126355]="stun",[96201]="stun",[115752]="stun",[118345]="stun",
[96294]="root",[339]="root",[19975]="root",[102359]="root",[50245]="root",[4167]="root",[54706]="root",[90327]="root",[128405]="root",[122]="root",[33395]="root",[116706]="root",[114404]="root",[63685]="root",[107566]="root",[113275]="root",[110693]="root",[136634]="root",[53148]="root",[113770]="root",[87194]="root",[115197]="root",
[22703]="rndstun",[113953]="rndstun",[77505]="rndstun",[7922]="rndstun",[118895]="rndstun",[64044]="horror",[6789]="horror",[87204]="horror",[137143]="horror",[33786]="cyclone",[113506]="cyclone",[99]="scatter",[19503]="scatter",[31661]="scatter",[123393]="scatter",[605]="mc",[76780]="banish",[710]="banish",[45334]="rndroot",[64803]="rndroot",[111340]="rndroot",[64695]="rndroot",[91807]="rndroot",[115757]="rndroot",[123407]="rndroot",[31117]="nodr",[56626]="nodr",[88625]="nodr",[81261]="nodr",[133901]="nodr",
[29166]="buff",[54428]="buff",[22812]="buff",[113075]="buff",[102342]="buff",[114029]="buff",[3411]="buff",[122292]="buff",[8178]="buff",[89523]="buff",[88611]="buff",[106922]="buff",[113072]="buff",[120954]="buff",[126456]="buff",[5277]="buff",[110791]="buff",[113613]="buff",[62606]="buff",[122286]="buff",[118038]="buff",[108271]="buff",[108359]="buff",[108416]="buff",[23920]="buff",[114028]="buff",[113002]="buff",[122783]="buff",[115760]="buff",[49039]="buff",[49016]="buff",[31821]="aura",[96267]="aura",[131558]="aura",[124488]="aura",
[30823]="def",[1022]="def",[498]="def",[33206]="def",[115018]="def",[61336]="def",[113306]="def",[871]="def",[48707]="def",[110570]="def",[31224]="def",[110788]="def",[19263]="def",[148467]="def",[110617]="def",[74001]="def",[48792]="def",[110575]="def",[47585]="def",[110715]="def",[104773]="def",[122291]="def",[110913]="def",[131523]="def",[125174]="def",
[45438]="immune",[110696]="immune",[642]="immune",[110700]="immune"}
driconsize=25 drduration=19 drtimeout=28
drdebuff="DEBUFF" -- BUFF pour debug
drignore={rndroot=1,nodr=1,buff=1,aura=1,def=1,immune=1,playerbuff=1}
drt=CreateFrame("FRAME")
drt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
drt:SetScript("OnEvent",function(_,_,_,eventType,_,_,_,_,_,destGUID,_,_,_,spellID,_,_,auraType)
	local unit
	for i=1,5 do
		if destGUID==UnitGUID("arena"..i) then unit=i break end
	end
	-- if (UnitGUID("target")==destGUID) then unit=1 end -- debug
	if unit and SpellDatabase[spellID] and auraType==drdebuff and not drignore[SpellDatabase[spellID]] then
		if eventType=="SPELL_AURA_REFRESH" or eventType=="SPELL_AURA_APPLIED" then
			drt:Applied(unit,spellID)
		elseif eventType=="SPELL_AURA_REMOVED" then
			drt:Faded(unit,spellID)
		end
	end
end)
drframe={}
for i=1,5 do
	drframe[i]=CreateFrame("Frame",nil,_G["ArenaEnemyFrame"..i])
	drframe[i]:SetPoint("TOPLEFT",_G["ArenaEnemyFrame"..i],"TOPRIGHT",75,0)
	drframe[i]:SetSize(driconsize,driconsize)
	drframe[i].tracker={}
end
function drt:GetTrack(unit,cat)
	local track=drframe[unit].tracker[cat]
	if not track then
		track=CreateFrame("Frame",nil,drframe[unit])
		drframe[unit].tracker[cat]=track
		track:SetPoint("CENTER",drframe[unit],"CENTER",0,0)
		track:SetSize(driconsize,driconsize)
		track.cd=CreateFrame("Cooldown",nil,track)
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
			x=x+driconsize
		end
	end
end

end

-- OPTIONS

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
			drt={
				type="header",
				name="DR Tracker",
				order=10,
			},
		}
	}
end
