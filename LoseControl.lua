--------------------------------------------------
--
-- LoseControl.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL & Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------

local AddonName,SKG=...
local LoseControl=SKG:NewModule("LoseControl","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
}}

function LoseControl:OnInitialize()
	self.db=SKG.db:RegisterNamespace("LoseControl",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("LoseControl",self.options,"L LoseControl")
end

-- LOSE CONTROL

-- Raid Portrait
-- for i=1,15 do
	-- local portr=CompactRaidFrameContainer:CreateTexture("RaidMember"..i.."Portrait")
	-- portr:ClearAllPoints()
	-- local y=50
	-- portr:SetSize(y,y)
	-- portr:SetPoint("TOPRIGHT",CompactRaidFrameContainer,"TOPLEFT",-1,-14-(y*(i-1)))
	-- portr:SetTexture("Interface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
-- end
function ShowRaidPortrait()
	local hideall
	-- if FlowContainer_GetUsedBounds(CompactRaidFrameContainer)>DefaultCompactUnitFrameSetupOptions.width+5 then
	if GetNumGroupMembers()>5 then
		hideall=1
	end
    for i=1,15 do
        local portr=_G["RaidMember"..i.."Portrait"]
        local _,class=UnitClass("raid"..i)
        if class and not hideall then
			local member
			if CompactRaidFrameContainer.groupMode=="flush" then
				member=CompactRaidFrameContainer_GetUnitFrame(CompactRaidFrameContainer,"raid"..i,"raid")
			else
				for j=1,8 do
					for k=1,5 do
						local frame=_G["CompactRaidGroup"..j.."Member"..k]
						if frame and frame.unit=="raid"..i then
							member=frame
						end
					end
				end
			end
			if member and member:IsShown() then
				local _,y=member:GetSize()
				portr:SetSize(y-1,y-1)
				portr:SetPoint("TOPRIGHT",member,"TOPLEFT",-1,0)

				local t=CLASS_ICON_TCOORDS[class]
				portr:SetTexture("Interface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
				portr:SetTexCoord(unpack(t))
				if portr.lc then
					portr.lc:Show()
					SetPortrait("raid"..i,portr:GetName(),portr.lc)
				else
					portr:Show()
				end
			else
				portr:Hide()
				if portr.lc then
					portr.lc:Hide()
					portr.lc.cd:Hide()
					portr.lc.tex:Hide()
				end
			end
		else
			portr:Hide()
			if portr.lc then
				portr.lc:Hide()
				portr.lc.cd:Hide()
				portr.lc.tex:Hide()
			end
		end
	end
end
function HideRaidPortrait()
    for i=1,15 do
        local portr=_G["RaidMember"..i.."Portrait"]
        portr:Hide()
    end
end
-- hooksecurefunc("CompactRaidFrameContainer_LayoutFrames",ShowRaidPortrait)

local portraitlist={PlayerPortrait="player",TargetFramePortrait="target",FocusFramePortrait="focus",PartyMemberFrame1Portrait="party1",PartyMemberFrame2Portrait="party2",PartyMemberFrame3Portrait="party3",PartyMemberFrame4Portrait="party4",ArenaEnemyFrame1ClassPortrait="arena1",ArenaEnemyFrame2ClassPortrait="arena2",ArenaEnemyFrame3ClassPortrait="arena3",ArenaEnemyFrame4ClassPortrait="arena4",ArenaEnemyFrame5ClassPortrait="arena5",RaidMember1Portrait="raid1",RaidMember2Portrait="raid2",RaidMember3Portrait="raid3",RaidMember4Portrait="raid4",RaidMember5Portrait="raid5",RaidMember6Portrait="raid6",RaidMember7Portrait="raid7",RaidMember8Portrait="raid8",RaidMember9Portrait="raid9",RaidMember10Portrait="raid10",RaidMember11Portrait="raid11",RaidMember12Portrait="raid12",RaidMember13Portrait="raid13",RaidMember14Portrait="raid14",RaidMember15Portrait="raid15"}
local aurapriority={playerbuff=1,buff=1,debuff=2,root=3,rndroot=3,nodr=4,def=5,aura=6,silence=6,stun=7,rndstun=7,disorient=7,incap=7}
local portraitsize={player=56,target=56,focus=56,party1=36,party2=36,party3=36,party4=36,arena1=36,arena2=36,arena3=36,arena4=36,arena5=36,raid1=56,raid2=56,raid3=56,raid4=56,raid5=56,raid6=56,raid7=56,raid8=56,raid9=56,raid10=56,raid11=56,raid12=56,raid13=56,raid14=56,raid15=56}
local raidportrait={RaidMember1Portrait=1,RaidMember2Portrait=1,RaidMember3Portrait=1,RaidMember4Portrait=1,RaidMember5Portrait=1,RaidMember6Portrait=1,RaidMember7Portrait=1,RaidMember8Portrait=1,RaidMember9Portrait=1,RaidMember10Portrait=1,RaidMember11Portrait=1,RaidMember12Portrait=1,RaidMember13Portrait=1,RaidMember14Portrait=1,RaidMember15Portrait=1}

function CheckAura(unit,AuraFunc,icon,prio,expi,dur)
	local i=1
	local _,newicon,_,_,newdur,newexpi,_,_,_,id=AuraFunc(unit,1)
	while id do
		if SpellDatabase[id] then
			local newprio=aurapriority[SpellDatabase[id]]
			if newprio and (newprio>prio or newprio==prio and newexpi>expi) then
				icon,prio,expi,dur=newicon,newprio,newexpi,newdur
			end
		end
		i=i+1
		_,newicon,_,_,newdur,newexpi,_,_,_,id=AuraFunc(unit,i)
	end
	return icon,prio,expi,dur
end

function AssignPortrait(portrait,icon,lc)
    if icon then
        lc.tex:Show()
        lc.cd:SetFrameLevel(portrait:GetParent():GetFrameLevel())
        lc.tex:SetAllPoints(portrait)
        portrait:Hide()
        -- lc.tex:SetTexCoord(0,1,0,1)
		if icon~=lc.tex.lasticon then
			lc.tex.lasticon=icon
			if(raidportrait[portrait:GetName()]) then
				lc.tex:SetTexture(icon)
				lc.cd:SetSize(lc.tex:GetSize())
			else
				SetPortraitToTexture(lc.tex,icon)
			end
		end
    else
        portrait:Show()
        lc.tex:Hide()
    end
end

function SetPortrait(unit,portrait,lc)
    if UnitName(unit) and lc:IsShown() then
        local prio,expi,dur,icon=0,0,0
		icon,prio,expi,dur=CheckAura(unit,UnitBuff,icon,prio,expi,dur)
		icon,prio,expi,dur=CheckAura(unit,UnitDebuff,icon,prio,expi,dur)
		if dur then
			lc.cd:SetCooldown(expi-dur,dur)
			lc.cd:Show()
		else
			lc.cd:Hide()
		end
		AssignPortrait(portrait,icon,lc)
    end
end

function LoseControl:OnEnable()
	for portraitname,unit in pairs(portraitlist) do
		local po=_G[portraitname]
		if po then
			if not po.lc then
				local lc=CreateFrame("Frame")
				po.lc=lc
				lc.cd=CreateFrame("Cooldown",nil,UIParent,"CooldownFrameTemplate")
				-- lc.cd:SetDrawEdge(false)
				lc.cd:SetParent(po:GetParent())
				lc.cd:ClearAllPoints()
				lc.cd:SetPoint("CENTER",po,"CENTER",0,0)
				lc.cd:SetSize(portraitsize[unit],portraitsize[unit])
				lc.cd:SetAlpha(0.5)
				lc.cd.detailedCC=1
				lc.tex=lc:CreateTexture(nil,"BORDER")
				lc.tex:SetParent(po:GetParent())
				lc.tex:ClearAllPoints()
				lc.tex:SetPoint("CENTER",po,"CENTER",0,0)
				lc.tex:SetSize(portraitsize[unit],portraitsize[unit])
				lc:RegisterEvent("UNIT_AURA")
				if unit=="target" then lc:RegisterEvent("PLAYER_TARGET_CHANGED") end
				if unit=="focus" then lc:RegisterEvent("PLAYER_FOCUS_CHANGED") end
			end
			po.lc:SetScript("OnEvent",function(_,e,u) if u==unit or e~="UNIT_AURA" then SetPortrait(unit,po,po.lc) end end)
			po.lc:Show()
		end
	end
end

function LoseControl:OnDisable()
	for portraitname,unit in pairs(portraitlist) do
		local po=_G[portraitname]
		if po and po.lc then
			po.lc:SetScript("OnEvent",nop)
			po.lc:Hide()
		end
	end
end

function LoseControl:ApplySettings()
	if db.enabled then
		self:OnDisable()
		self:OnEnable()
	end
end

-- OPTIONS

local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	LoseControl:ApplySettings()
end
function LoseControl:GetOptions()
	return {
		order=7,
		type="group",
		name="Lose Control",
		desc="Lose Control",
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
			lc={
				type="header",
				name="Lose Control",
				order=10,
			},
		}
	}
end
