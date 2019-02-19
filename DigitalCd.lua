--------------------------------------------------
--
-- DigitalCd.lua
-- created 27/10/2014
-- by Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------

local AddonName,SKG=...
 DigitalCd=SKG:NewModule("DigitalCd","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
	dayssize=15,
	dayscolor={1,1,1},
	hourssize=15,
	hourscolor={1,1,1},
	minutessize=15,
	minutescolor={1,1,1},
	secondssize=18,
	secondscolor={1,1,0},
	lastsecondssize=24,
	lastsecondscolor={1,0,0},
	pandemicsize=24,
	pandemiccolor={0,0.7,0},
}}

function DigitalCd:OnInitialize()
	self.db=SKG.db:RegisterNamespace("DigitalCd",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("DigitalCd",self.options,"L DigitalCd")
end

-- DIGITAL COOLDOWNS

-- DigitalCd.frame=CreateFrame("FRAME")
DigitalCd.actions={}

function DigitalCd.OnShow(cd)
	if cd.txt then cd.txt:Show() end
	if cd.cooldownCountAction then DigitalCd.actions[cd]=true end
end
function DigitalCd.OnHide(cd)
	if cd.txt then cd.txt:Hide() end
	if cd.cooldownCountAction then DigitalCd.actions[cd]=nil end
end
function DigitalCd:AddAction(action,cd)
	if not cd.cooldownCountAction then
		cd:HookScript("OnShow",DigitalCd.OnShow)
		cd:HookScript("OnHide",DigitalCd.OnHide)
	end
	cd.cooldownCountAction=action
end
function DigitalCd:UpdateActions()
	for cd in pairs(DigitalCd.actions) do
		local start,duration,enable=GetActionCooldown(cd.cooldownCountAction)
		DigitalCd:SetCd(cd,start,duration,enable)
	end
end
function DigitalCd:SetCd(cd,start,duration,enable,charges,maxcharges)
    if start and start>0 and enable>0 and (duration>3 or cd.detailedCC) and not cd.noCooldownCount and db.enabled then
        local txt=cd.txt or DigitalCd:CreateText(cd)
        txt.start=start
        txt.duration=duration
        txt.nextupdate=0
		if cd.pandemic==true then cd.pandemic=0.3*duration end
		txt:Show()
    elseif cd.txt then
		cd.txt.text:SetText("")
		cd.txt.duration=0
		cd.txt:Hide()
    end
end
function DigitalCd:CreateText(cd)
    cd.txt=CreateFrame("Frame",nil,cd:GetParent())
    local txt=cd.txt
	txt.cd=cd
    txt:SetAllPoints(cd)
    txt:SetFrameLevel(cd:GetFrameLevel()+5)
    txt.nextupdate=0
    txt.text=txt:CreateFontString(nil,"OVERLAY")
	txt.text:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")
	txt.text:SetPoint("CENTER")
	txt:SetScript("OnUpdate",DigitalCd.CdUpdate)
    txt:Hide()
    return txt
end
function DigitalCd.CdUpdate(txt,elapsed)
	if txt.nextupdate<0 then
		if GetTime()<txt.start then return end
		local cd=txt.cd
		local text,nextupdate,size,color=DigitalCd:GetText(txt.duration-(GetTime()-txt.start),cd.detailedCC,cd.pandemic)
		local ratio=cd:GetWidth()/36 if ratio>1 then ratio=1 end
		size=ratio*size if size==0 then size=1 end
		-- if cd:GetWidth()<20 and cd:GetParent() and cd:GetParent():GetName() then
			-- local count=_G[cd:GetParent():GetName().."Count"]
			-- if count and count:IsShown() and count:GetText() then text="" end
		-- end
		local alpha=1
		if cd:GetWidth()<22 then
			alpha=0.7
			if cd:GetWidth()<20 then
				alpha=0
			end
		end
		txt.text:SetFont("Fonts\\FRIZQT__.TTF",size,"OUTLINE")
		local r,g,b=unpack(color)
		txt.text:SetTextColor(r,g,b,alpha)
		txt.text:SetText(text)
		txt.nextupdate=nextupdate
	else
		txt.nextupdate=txt.nextupdate-elapsed
	end
end
function DigitalCd:GetText(secs,detail,pand)
	pand=pand or 0.5
	--										text						nextupdate								size,color
    if secs>=86400 then return				floor(secs/86400+0.5).."d",	mod(secs,43200),						db.dayssize,db.dayscolor
    elseif secs>=3600 then return			floor(secs/3600+0.5).."h",	mod(secs,1800),							db.hourssize,db.hourscolor
    elseif secs>=60 then return				floor(secs/60+0.5).."m",	mod(secs,30),							db.minutessize,db.minutescolor
    elseif secs>=9.5 then return 			floor(secs+0.5).."",		secs+0.5-floor(secs+0.5),				db.secondssize,db.secondscolor
    elseif detail and secs>=0 then return 	format(" %.1f ",secs),		secs-0.1*floor(10*secs),				db.secondssize,db.lastsecondscolor
    elseif secs>pand then return			floor(secs+0.5).."",		min(secs+.5-floor(secs+.5),secs-pand),	db.lastsecondssize,db.lastsecondscolor
    elseif secs>=0.5 then return 			floor(secs+0.5).."",		secs+0.5-floor(secs+0.5),				db.pandemicsize,db.pandemiccolor
    end
    return "",1,15,{1,0,0}
end
function DigitalCd.Start(cd,start,duration)
	DigitalCd:SetCd(cd,start,duration,1)
	if not cd.cooldownCountAction and not cd.hook then
		cd:HookScript("OnShow",DigitalCd.OnShow)
		cd:HookScript("OnHide",DigitalCd.OnHide)
		cd.hook=true
	end
end
function DigitalCd:AddonLoaded(_,addon)
	if addon=="Blizzard_PVPUI" then
		if PVPQueueFrame and PVPQueueFrame.HonorInset and PVPQueueFrame.HonorInset.CasualPanel and PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay then
			PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.noCooldownCount=true
		end
	end
end

function DigitalCd:OnEnable()
	if not DigitalCd.init then
		DigitalCd:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN","UpdateActions")
		DigitalCd:RegisterEvent("ADDON_LOADED","AddonLoaded")
		hooksecurefunc(getmetatable(ActionButton1Cooldown).__index,"SetCooldown",DigitalCd.Start)
		hooksecurefunc("SetActionUIButton",DigitalCd.AddAction)
		for i,button in pairs(ActionBarButtonEventsFrame.frames) do
			DigitalCd:AddAction(button.action,button.cooldown)
		end
		DigitalCd.init=true
	end
end
function DigitalCd:OnDisable()
end
function DigitalCd:ApplySettings()
end

-- OPTIONS

local function getter(info)
	local value=db[info.arg or info[#info]]
	if type(value)=="table" then return unpack(value) end
	return value
end
local function setter(info,value,g,b)
	print("set",value,g,b)
	db[info.arg or info[#info]]=(g and b) and {value,g,b} or value
	DigitalCd:ApplySettings()
end
function DigitalCd:GetOptions()
	return {
		order=4,
		type="group",
		name="Digital Cd",
		desc="Displays a digital time on cooldowns",
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
				order=1
			},
			days={
				type="header",
				name="Above 1 day",
				order=10
			},
			dayscolor={
				type="color",
				name="Text Color",
				order=11
			},
			dayssize={
				type="range",
				name="Text Size",
				min=1,max=40,step=1,bigStep=1,
				order=12
			},
			hours={
				type="header",
				name="1 to 24 hours",
				order=20
			},
			hourscolor={
				type="color",
				name="Text Color",
				order=21
			},
			hourssize={
				type="range",
				name="Text Size",
				min=1,max=40,step=1,bigStep=1,
				order=22
			},
			minutes={
				type="header",
				name="1 to 60 minutes",
				order=30
			},
			minutescolor={
				type="color",
				name="Text Color",
				order=31
			},
			minutessize={
				type="range",
				name="Text Size",
				min=1,max=40,step=1,bigStep=1,
				order=32
			},
			seconds={
				type="header",
				name="10 to 60 seconds",
				order=40
			},
			secondscolor={
				type="color",
				name="Text Color",
				order=41
			},
			secondssize={
				type="range",
				name="Text Size",
				min=1,max=40,step=1,bigStep=1,
				order=42
			},
			lastseconds={
				type="header",
				name="Below 10 seconds",
				order=50
			},
			lastsecondscolor={
				type="color",
				name="Text Color",
				order=51
			},
			lastsecondssize={
				type="range",
				name="Text Size",
				min=1,max=40,step=1,bigStep=1,
				order=52
			},
			pandemic={
				type="header",
				name="Pandemic (debuff can be refreshed without loss)",
				order=60
			},
			pandemiccolor={
				type="color",
				name="Text Color",
				order=61
			},
			pandemicsize={
				type="range",
				name="Text Size",
				min=1,max=40,step=1,bigStep=1,
				order=62
			},
		}
	}
end
