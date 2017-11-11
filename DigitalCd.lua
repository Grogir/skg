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
	--										text						nextupdate								size color
    if secs>=86400 then return				floor(secs/86400+0.5).."d",	mod(secs,43200),						15,{1,1,1}
    elseif secs>=3600 then return			floor(secs/3600+0.5).."h",	mod(secs,1800),							15,{1,1,1}
    elseif secs>=60 then return				floor(secs/60+0.5).."m",	mod(secs,30),							15,{1,1,1}
    elseif secs>=9.5 then return 			floor(secs+0.5).."",		secs+0.5-floor(secs+0.5),				18,{1,1,0}
    elseif detail and secs>=0 then return 	format(" %.1f ",secs),		secs-0.1*floor(10*secs),				18,{1,0,0}
    elseif secs>pand then return			floor(secs+0.5).."",		min(secs+.5-floor(secs+.5),secs-pand),	24,{1,0,0}
    elseif secs>=0.5 then return 			floor(secs+0.5).."",		secs+0.5-floor(secs+0.5),				24,{0,1,0}
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

function DigitalCd:OnEnable()
	if not DigitalCd.init then
		DigitalCd:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN","UpdateActions")
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
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
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
				order=1,
			},
			dcd={
				type="header",
				name="Digital Cooldown",
				order=10,
			},
		}
	}
end
