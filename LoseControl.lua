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
	
	decimals=true,
	cdalpha=0.7,
	
	player=true,
	target=true,
	focus=true,
	party=true,
	arena=true,
	raid=true,
}}

function LoseControl:OnInitialize()
	self.db=SKG.db:RegisterNamespace("LoseControl",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("LoseControl",self.options,"L LoseControl")
end

-- LOSE CONTROL

local portraitlist={PlayerPortrait="player",TargetFramePortrait="target",FocusFramePortrait="focus",PartyMemberFrame1Portrait="party1",PartyMemberFrame2Portrait="party2",PartyMemberFrame3Portrait="party3",PartyMemberFrame4Portrait="party4",ArenaEnemyFrame1ClassPortrait="arena1",ArenaEnemyFrame2ClassPortrait="arena2",ArenaEnemyFrame3ClassPortrait="arena3",ArenaEnemyFrame4ClassPortrait="arena4",ArenaEnemyFrame5ClassPortrait="arena5",RaidMember1Portrait="raid1",RaidMember2Portrait="raid2",RaidMember3Portrait="raid3",RaidMember4Portrait="raid4",RaidMember5Portrait="raid5",RaidMember6Portrait="raid6",RaidMember7Portrait="raid7",RaidMember8Portrait="raid8",RaidMember9Portrait="raid9",RaidMember10Portrait="raid10",RaidMember11Portrait="raid11",RaidMember12Portrait="raid12",RaidMember13Portrait="raid13",RaidMember14Portrait="raid14",RaidMember15Portrait="raid15"}
local aurapriority={playerbuff=1,buff=1,debuff=2,root=3,rndroot=3,nodr=4,def=5,aura=6,silence=6,stun=7,rndstun=7,disorient=7,incap=7}
local portraitsize={player=52,target=52,focus=52,party=32,arena=32,raid=50}

function LoseControl:CreateRaidPortraits()
    for i=1,15 do
		local portr=CompactRaidFrameContainer:CreateTexture("RaidMember"..i.."Portrait","BORDER")
		portr:SetTexture("Interface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
	end
end

function LoseControl:ShowRaidPortrait()
	local hideall
	-- if FlowContainer_GetUsedBounds(CompactRaidFrameContainer)>DefaultCompactUnitFrameSetupOptions.width+5 then
	if GetNumGroupMembers()>5 or not db.enabled or not db.raid then
		hideall=true
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

				portr:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
				portr.lc:Show()
				portr.lc.cd:SetSize(y-1,y-1)
				LoseControl:SetPortrait("raid"..i,portr,portr.lc)
			else
				portr:Hide()
				portr.lc:Hide()
				portr.lc.cd:Hide()
				portr.lc.tex:Hide()
			end
		else
			portr:Hide()
			portr.lc:Hide()
			portr.lc.cd:Hide()
			portr.lc.tex:Hide()
		end
	end
end

function LoseControl:CheckAura(unit,AuraFunc,icon,prio,expi,dur)
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

function LoseControl:AssignPortrait(portrait,icon,tex)
    if icon then
        tex:Show()
        portrait:Hide()
		if icon~=tex.lasticon then
			tex.lasticon=icon
			if portrait:GetName():sub(1,4)=="Raid" then
				tex:SetTexture(icon)
			else
				SetPortraitToTexture(tex,icon)
			end
		end
    else
        portrait:Show()
        tex:Hide()
    end
end

function LoseControl:SetPortrait(unit,portrait,lc)
    if UnitName(unit) and lc:IsShown() then
        local prio,expi,dur,icon=0,0,0
		icon,prio,expi,dur=self:CheckAura(unit,UnitBuff,icon,prio,expi,dur)
		icon,prio,expi,dur=self:CheckAura(unit,UnitDebuff,icon,prio,expi,dur)
		if dur then
			lc.cd:SetCooldown(expi-dur,dur)
			lc.cd:Show()
		else
			lc.cd:Hide()
		end
		self:AssignPortrait(portrait,icon,lc.tex)
    end
end

function LoseControl:OnEnable()
	if not RaidMember1Portrait then
		self:CreateRaidPortraits()
		hooksecurefunc("CompactRaidFrameContainer_LayoutFrames",self.ShowRaidPortrait)
	end
	
	for portraitname,unit in pairs(portraitlist) do
		local po=_G[portraitname]
		if po then
			if not po.lc then
				local parent=po:GetParent()
				local s=portraitsize[unit:match("%a+")]
				local lc=CreateFrame("Frame",nil,parent)
				po.lc=lc
				
				lc.tex=parent:CreateTexture(nil,"BORDER")
				lc.tex:SetAllPoints(po)
				
				lc.cd=CreateFrame("Cooldown",nil,parent,"CooldownFrameTemplate")
				lc.cd:ClearAllPoints()
				lc.cd:SetPoint("CENTER",po,"CENTER")
				lc.cd:SetSize(s,s)
				lc.cd:SetDrawEdge(false)
				lc.cd:SetReverse(true)
				lc.cd:SetFrameLevel(parent:GetFrameLevel())
				
				lc:RegisterEvent("UNIT_AURA")
				if unit=="target" then lc:RegisterEvent("PLAYER_TARGET_CHANGED") end
				if unit=="focus" then lc:RegisterEvent("PLAYER_FOCUS_CHANGED") end
				lc:SetScript("OnEvent",function(_,e,u) if u==unit or e~="UNIT_AURA" then self:SetPortrait(unit,po,po.lc) end end)
			end
		end
	end
	
	self:ApplySettings()
end

function LoseControl:OnDisable()
	self:ApplySettings()
end

function LoseControl:ApplySettings()
	for portraitname,unit in pairs(portraitlist) do
		local po=_G[portraitname]
		if po and po.lc then
			po.lc.cd:SetAlpha(db.cdalpha)
			po.lc.cd.detailedCC=db.decimals
			
			local shown=db[unit:match("%a+")] and db.enabled
			po.lc:SetShown(shown)
			if shown then
				self:SetPortrait(unit,po,po.lc)
			else
				po.lc.cd:Hide()
				po.lc.tex:Hide()
				po:Show()
			end
		end
	end
	self:ShowRaidPortrait()
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
				set=function(i,v) db.enabled=v if v then self:Enable() else self:Disable() end end,
				order=1
			},
			lc={
				type="header",
				name="Lose Control",
				order=10
			},
			cdalpha={
				type="range",
				name="Cooldown Alpha",
				min=0,max=1,step=0.01,bigStep=0.1,
				order=21
			},
			decimals={
				type="toggle",
				name="Decimals on Cooldowns",
				order=22
			},
			nl0={type="description",name="",order=30},
			player={
				type="toggle",
				name="Player",
				order=31
			},
			nl1={type="description",name="",order=31.5},
			target={
				type="toggle",
				name="Target",
				order=32
			},
			nl2={type="description",name="",order=32.5},
			focus={
				type="toggle",
				name="Focus",
				order=33
			},
			nl3={type="description",name="",order=33.5},
			party={
				type="toggle",
				name="Party",
				order=34
			},
			nl4={type="description",name="",order=34.5},
			arena={
				type="toggle",
				name="Arena",
				order=35
			},
			nl5={type="description",name="",order=35.5},
			raid={
				type="toggle",
				name="Raid",
				order=36
			},
		}
	}
end
