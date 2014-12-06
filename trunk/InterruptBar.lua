--------------------------------------------------
--
-- InterruptBar.lua
-- created 27/10/2014
-- by Florian "Khujara" FALAVEL
--
--------------------------------------------------

local AddonName,SKG=...
local InterruptBar=SKG:NewModule("InterruptBar","AceEvent-3.0")
local db

local defaults={global={
	enabled=true,
	fl=1,
	x=-124,
	y=-50,
	size=30,
	line=9,
}}

function InterruptBar:OnInitialize()
	self.db=SKG.db:RegisterNamespace("InterruptBar",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	SKG:RegisterModuleOptions("InterruptBar",self.options,"L InterruptBar")
	-- self:RegisterEvent("PLAYER_LOGIN")
	self:Enable()
end
-- function InterruptBar:PLAYER_LOGIN()
-- end

-- INTERRUPT BAR

function InterruptBar:ApplySettings()
end

function InterruptBar:Enable()

ib=CreateFrame("Frame")
-- ib.li={{6552,15},{102060,40},{1766,15},{47528,15},{47476,60},{96231,15},{57994,12},{2139,20},{116705,15},{80965,15},{78675,60},{34490,24},
-- {19647,24},{119910,24},{132409,24},{115781,24},{119911,24},{15487,45},{23920,25},{114028,60},{1719,180},{18499,30},{46968,40},{108194,30},
-- {5484,40},{51514,35},{8143,60},{8177,25},{19503,30},{60192,28},{1499,28},{106951,180},{99,30},{5211,50},{44572,30},{12472,180},{108978,180},
-- {113724,45},{12043,90},{119381,45},{31884,180},{853,60},{105593,30},{115750,120},{108921,45},{8122,27},{51713,60},{2094,120}}
ib.li={{6552,15},{102060,40},{1766,15},{47528,15},{47476,60},{96231,15},{57994,12},{2139,20},{116705,15},{80965,15},{78675,60},
{34490,24},{147362,24},{19647,24},{119910,24},{132409,24},{115781,24},{119911,24},{15487,45},{23920,25},{114028,60},{108194,30},
{853,60},{105593,30},{44572,30},{5484,40},{8122,27},{8143,60},{19503,30},{60192,28},{1499,28},{12043,90}}
-- fl=1 ic=30 xp=-800 yp=-50 n=12 -- ic=icon size, xp=x position, yp=y position, n=number per line
-- fl=1 ic=30 xp=-124 yp=-50 n=9 -- ic=icon size, xp=x position, yp=y position, n=number per line
function ib:cf(i,s,x,y)
    local _,_,t=GetSpellInfo(s)
    local f=CreateFrame("Frame",nil,UIParent)
    f:SetPoint("CENTER",x,y)
    f:SetSize(db.size,db.size)
    f.t=f:CreateTexture(nil,"BORDER")
    f.t:SetAllPoints(true)
    f.t:SetTexture(t)
    f.c=CreateFrame("Cooldown",nil,f)
    f.c:SetAllPoints(f)
    return f
end
function ib.update(self)
	if GetTime()>=self.start+self.duration then
        ib:deactivatebtn(self)
    end
end
function ib:activatebtn(frame,ptime,lc)
	frame:GetParent():Show()
	frame.start=ptime
	frame.duration=lc
	frame:SetCooldown(ptime,lc)
	if(db.fl==1) then
		frame:SetScript("OnUpdate",ib.update)
	end
end
function ib:deactivatebtn(frame)
	frame:GetParent():Hide()
	frame:SetScript("OnUpdate",nil)
end
function ib:ud(f,ls,lc)
    f:SetScript("OnEvent",function(_,_,_,e,_,_,_,b,_,_,_,_,_,s)
        if(e=="SPELL_CAST_SUCCESS"and s==ls)then
            if bit.band(b,0x40)==0x40 then --or bit.band(b,0x100)==0x100 then
                ib:activatebtn(f.c,GetTime(),lc)
            end
        end
    end)
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end
for i,s in ipairs(ib.li) do
    _G["ib"..i]=ib:cf(i,s[1],db.x+(db.size+1)*math.ceil((i-1)%db.line),db.y-(db.size+1)*math.ceil(i/db.line))
    ib:ud(_G["ib"..i],s[1],s[2])
end
ib:SetScript("OnEvent",function()
    for i,s in ipairs(ib.li) do
        local f=_G["ib"..i]
        if(db.fl==0)then
            f:Show() f.c:Show()
        else
            f:Hide() f.c:Hide()
        end
    end
end)
ib:RegisterEvent("PLAYER_ENTERING_WORLD")

end

-- OPTIONS

local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	InterruptBar:ApplySettings()
end
function InterruptBar:GetOptions()
	return {
		order=3,
		type="group",
		name="Interrupt Bar",
		desc="Interrupt Bar",
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
			ib={
				type="header",
				name="Interrupt Bar",
				order=10,
			},
			x={
				type="range",
				name="X",
				min=-500,max=500,step=1,bigStep=5,
				order=11
			},
			y={
				type="range",
				name="Y",
				min=-500,max=500,step=1,bigStep=5,
				order=12
			},
			size={
				type="range",
				name="Size",
				min=5,max=100,step=1,bigStep=5,
				order=13
			},
			line={
				type="range",
				name="Icons per line",
				min=1,max=50,step=1,bigStep=1,
				order=14
			},
			fl={
				type="select",
				name="Display",
				values={[0]="Always","Standard","Persistent"},
				-- min=0,max=2,step=1,bigStep=1,
				order=15
			},
		}
	}
end
