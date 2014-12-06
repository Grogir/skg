--------------------------------------------------
--
-- DigitalCd.lua
-- created 27/10/2014
-- by Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------
-- pandemic non exact sur la réapplication du dot...

local AddonName,SKG=...
local DigitalCd=SKG:NewModule("DigitalCd","AceEvent-3.0")
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
	self:RegisterEvent("PLAYER_LOGIN")
end
function DigitalCd:PLAYER_LOGIN()
	self:Enable()
end

-- DIGITAL COOLDOWNS

function DigitalCd:ApplySettings()
end

function DigitalCd:Enable()

dcd=CreateFrame("FRAME")
actions={}
function dcd.OnShow(self)
	if self.txt then self.txt:Show() end
	if self.cooldownCountAction then actions[self]=true end
end
function dcd.OnHide(self)
	if self.txt then self.txt:Hide() end
	if self.cooldownCountAction then actions[self]=nil end
end
function dcd:AddAction(action,cd)
	if not cd.cooldownCountAction then
		cd:HookScript("OnShow",dcd.OnShow)
		cd:HookScript("OnHide",dcd.OnHide)
	end
	cd.cooldownCountAction=action
end
function dcd:UpdateActions()
	for cd in pairs(actions) do
		local start,duration,enable=GetActionCooldown(cd.cooldownCountAction)
		dcd:SetCd(cd,start,duration,enable)
	end
end
function dcd:SetCd(cd,start,duration,enable,charges,maxcharges)
    if start and start>0 and enable>0 and (duration>3 or cd.detailedCC) and not cd.noCooldownCount then
        local txt=cd.txt or dcd:CreateText(cd,start,duration)
        txt.start=start
        txt.duration=duration
        txt.nextupdate=0
		if cd.pandemic then cd.pandemic=0.3*duration end
		txt:Show()
    elseif cd.txt then
		cd.txt.text:SetText("")
		cd.txt.duration=0
		cd.txt:Hide()
    end
end
function dcd:CreateText(cd,start,duration)
    cd.txt=CreateFrame("Frame",nil,cd:GetParent())
    local txt=cd.txt
    txt:SetAllPoints(cd)
    txt:SetFrameLevel(cd:GetFrameLevel()+5)
    txt.nextupdate=0
    txt.text=txt:CreateFontString(nil,"OVERLAY")
	txt.text:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")
	txt.text:SetPoint("CENTER")
	txt:SetScript("OnUpdate",function(self,elapsed)
		if txt.nextupdate<0 then
			if GetTime()<txt.start then return end
			local text,nextupdate,size,color=dcd:GetText(txt.duration-(GetTime()-txt.start),cd.detailedCC,cd.pandemic)
			local ratio=cd:GetWidth()/36 if ratio>1 then ratio=1 end
			size=ratio*size if size==0 then size=1 end
			if cd:GetWidth()<20 and cd:GetParent() and cd:GetParent():GetName() then
				local count=_G[cd:GetParent():GetName().."Count"]
				if count and count:IsShown() and count:GetText() then text="" end
			end
			txt.text:SetFont("Fonts\\FRIZQT__.TTF",size,"OUTLINE")
			txt.text:SetTextColor(unpack(color))
			txt.text:SetText(text)
			txt.nextupdate=nextupdate
		else
			txt.nextupdate=txt.nextupdate-elapsed
		end
	end)
    txt:Hide()
    return txt
end
function dcd:GetText(secs,detail,pand)
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
function dcd:Start(start,duration)
	dcd:SetCd(self,start,duration,1)
	if not self.cooldownCountAction and not self.hook then
		self:HookScript("OnShow",dcd.OnShow)
		self:HookScript("OnHide",dcd.OnHide)
		self.hook=true
	end
end
dcd:SetScript("OnEvent",function() dcd:UpdateActions() end)
dcd:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
hooksecurefunc(getmetatable(ActionButton1Cooldown).__index,"SetCooldown",dcd.Start)
hooksecurefunc("SetActionUIButton",dcd.AddAction)
for i,button in pairs(ActionBarButtonEventsFrame.frames) do
	dcd:AddAction(button.action,button.cooldown)
end

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
