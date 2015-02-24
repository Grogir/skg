--------------------------------------------------
--
-- AuraTracker.lua
-- created 27/10/2014
-- by Pierre-Yves "Grogir" DUTREUILH
--
--------------------------------------------------
--icone
--nom si nom frame
--custom loadstring
--cond autre chose que aura?

local AddonName,SKG=...
local AuraTracker=SKG:NewModule("AuraTracker","AceEvent-3.0")
-- _G.SGA=AuraTracker
local db

local defaults={global={
	enabled=true,
	iconsize=36,
	margin=2,
	minalpha=0.0,
	midalpha=0.2,
	maxalpha=1.0,
	cdalpha=0.7,
	x=0,
	y=-220,
	spellanchor="CENTER",--TOPLEFT
	listanchor="CENTER",
	parent="UIParent",
	paranchor="CENTER",
	
	auras={},
	lists={},
}}
local showactiveonly=true

function AuraTracker:OnInitialize()
	self.db=SKG.db:RegisterNamespace("AuraTracker",defaults,true)
	db=self.db.global
	self:SetEnabledState(db.enabled)
	self.options=self:GetOptions()
	self:LoadAuras()
	SKG:RegisterModuleOptions("AuraTracker",self.options,"L AuraTracker")
	-- self:RegisterEvent("PLAYER_LOGIN","Reload")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED","SpecChange")
	-- self:Temp()
end
function AuraTracker:SpecChange(e,u)
	if u and u=="player" then
		self:OnDisable()
		self:OnEnable()
	end
end

-- AURA TRACKER

function AuraTracker:ApplySettings()
	self:OnDisable()
	self:OnEnable()
end

AuraTracker.auras={}
AuraTracker.lists={}
AuraTracker.conds={}
AuraTracker.cache={}
AuraTracker.frame=CreateFrame("Frame")
AuraTracker.frame:SetScript("OnUpdate",function()
	if AuraTracker.update then
		AuraTracker:CheckAuras()
		AuraTracker.update=nil
	end
end)
function AuraTracker:OnEnable()
	local _,_,class=UnitClass("player")
	local spec=GetSpecialization()
	if spec then spec=GetSpecializationInfo(spec) end
	self:RegisterEvent("UNIT_AURA","OnAura")
	self:RegisterEvent("PLAYER_TARGET_CHANGED","OnAura")
	local auralist=AuraTracker.options.args.auragroup.args
	for i,auradb in pairs(db.auras) do
		if (not auradb.class or auradb.class and auradb.class==class) and 
		(not auradb.spec or auradb.spec and auradb.spec==spec) then
			local aura=CreateFrame("FRAME",auradb.name,_G[db.parent])
			table.insert(self.auras,aura)
			aura.db=auradb
			aura.tex=aura:CreateTexture()
			aura.tex:SetAllPoints()
			local icon=auradb.icon
			aura.cd=CreateFrame("Cooldown",nil,aura,"CooldownFrameTemplate")
			aura.cd:SetAllPoints()
			aura.cd:SetDrawEdge(false)
			aura.cd:SetDrawBling(false)
			aura.cd:SetReverse(true)
			aura.cd:SetSwipeColor(0,0,0,db.cdalpha*db.maxalpha)
			aura.cd.pandemic=auradb.pandemic
			aura:Show()
			if not auradb.size or auradb.sizetype and string.sub(auradb.sizetype,3)=="default" then
				aura:SetSize(db.iconsize,db.iconsize)
			else
				aura:SetSize(auradb.size,auradb.size)
			end
			aura.alpha=auradb.alpha or db.midalpha
			if auradb.alphatype and db[string.sub(auradb.alphatype,3)] then
				aura.alpha=db[string.sub(auradb.alphatype,3)]
			end
			aura:SetAlpha(aura.alpha)
			if auradb.conds then 
				aura.conds={}
				for j,conddb in pairs(auradb.conds) do
					local cond={
						db=conddb,
						aura=aura,
					}
					if conddb.inverse then cond.cache={} end
					table.insert(self.conds,cond)
					table.insert(aura.conds,cond)
					if not icon then icon=conddb.id end
				end
			end
			aura.tex:SetTexture(GetSpellTexture(icon))
			if auradb.snapshot and snapshot and snapshot.cache[icon] then
				aura.tcvalue=aura:CreateFontString(nil,"OVERLAY")
				aura.tcvalue:SetPoint("BOTTOMRIGHT",aura,"TOPRIGHT",0,0)
				aura.tcvalue:SetFont("Fonts\\FRIZQT__.TTF",aura:GetWidth()/4,"OUTLINE")
				
				aura.tctarget=(aura.cd.txt or aura.cd or aura):CreateFontString(nil,"OVERLAY")
				aura.tctarget:SetPoint("TOPRIGHT",aura,"TOPRIGHT",0,1)
				aura.tctarget:SetFont("Fonts\\FRIZQT__.TTF",aura:GetWidth()/4,"OUTLINE")
				
				local cache=snapshot.cache[icon]
				aura:SetScript("OnUpdate",function()
					local val=cache.valueget or cache.value
					aura.tcvalue:SetText(floor(100*val+.5))
					local tar=cache[UnitGUID("target")]
					if tar then
						if tar>=val then
							aura.tctarget:SetText(format("|cFF00FF00%d|r",100*tar+.5))
						else
							aura.tctarget:SetText(format("|cFFFF0000%d|r",100*tar+.5))
						end
					else
						aura.tctarget:SetText()
					end
				end)
				-- table.insert(tc.observers,function(value) aura.snapshot:SetText(format("%dk",value/1000+0.5)) end)
				-- spell.tcvalue.f=#tc.observers
			end
			auralist[i].hidden=nil
		else
			auralist[i].hidden=showactiveonly
		end
	end
	for i,aura in pairs(self.auras) do
		local auradb=aura.db
		if _G[auradb.parent] then
			aura:SetParent(_G[auradb.parent])
		end
		aura:SetPoint(auradb.anchor or db.spellanchor,auradb.parent or db.parent,auradb.paranchor or db.paranchor,auradb.x or db.x,auradb.y or db.y)
	end
	for i,list in pairs(db.lists) do
		list.frame=CreateFrame("FRAME",list.name,_G[list.parent] or _G[db.parent])
		list.frame:SetPoint(list.anchor or db.listanchor,list.parent or db.parent,list.paranchor or db.paranchor,list.x or db.x,list.y or db.y)
		list.frame:SetSize(#list*(db.iconsize+db.margin)-db.margin,1)
		for j=1,#list do
			self.auras[list[j]].frame:SetParent(list.frame)
		end
	end
	self.update={player=1,target=1}
	-- self:Layout()
end
function AuraTracker:OnDisable()
	for i,aura in pairs(self.auras) do
		aura:Hide()
		if aura:GetName() then _G[aura:GetName()]=nil end
	end
	for i,list in pairs(self.lists) do
		if list.frame then
			list.frame:Hide()
			if list.frame:GetName() then _G[list.frame:GetName()]=nil end
		end
	end
	self.auras={}
	self.lists={}
	self.conds={}
	self.cache={}
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
end
function AuraTracker:OnAura(event,unit)
	unit=unit or "target"
	self.cache[unit]=nil
	self.update=self.update or {}
	self.update[unit]=1
end
function AuraTracker:Cache(unit)
	self.cache[unit]={}
	local cache=self.cache[unit]
	local i,id,count,dur,expi,auth,_=0,0
	while id do
		i=i+1
		_,_,_,count,_,dur,expi,auth,_,_,id=UnitBuff(unit,i)
		if id and not cache[id] then cache[id]={count=count,dur=dur,expi=expi,auth=auth,type="buff"} end
	end
	i,id,count,dur,expi,auth=0,0
	while id do
		i=i+1
		_,_,_,count,_,dur,expi,auth,_,_,id=UnitDebuff(unit,i)
		if id and not cache[id] then cache[id]={count=count,dur=dur,expi=expi,auth=auth,type="debuff"} end
	end
end
local function CompareTables(a,b)
	if a==b then return true end
	if not a or not b then return false end
	for k,v in pairs(a) do
		if b[k]~=v then return false end
	end
	return true
end
local function ConditionN(n,c)
	n=n or #c
	for i=1,#c do
		if c[i] then n=n-1 end
	end
	if n>0 then return false end
	return true
end
function AuraTracker:CheckAuras()
	-- loop conditions
	for i,cond in pairs(self.conds) do
		local conddb=cond.db
		if self.update[conddb.unit] then
			if not self.cache[conddb.unit] then
				-- print("cache...")
				self:Cache(conddb.unit)
			end
			-- print("cond...")
			local aura=self.cache[conddb.unit][conddb.id]
			if not CompareTables(cond.cache,aura) then
				cond.aura.update=1
				cond.cache=aura
				if aura and (conddb.author==nil or conddb.author==aura.auth) and (conddb.type==nil or conddb.type==aura.type) then
					cond.value=not conddb.inverse
				else
					cond.value=not not conddb.inverse
				end
			end
		end
	end
	-- loop auras
	local changes=nil
	for i,aura in pairs(self.auras) do
		if aura.update then
			-- print("aura...")
			aura.update=nil
			local result,cache,draw={},{}
			for j,cond in pairs(aura.conds) do
				table.insert(result,cond.value)
				if cond.value and not draw then
					cache=cond.cache or cache
					draw=cond.db.id
				end
			end
			local condfunc=ConditionN
			if condfunc(aura.db.conditionn or 1,result) then
				aura:SetAlpha(db.maxalpha)
				if not aura.db.icon then
					aura.tex:SetTexture(GetSpellTexture(draw))
				end
				if cache.expi and cache.dur then
					aura.cd:SetCooldown(cache.expi-cache.dur,cache.dur)
				else
					aura.cd:SetCooldown(0,0)
				end
				if cache.count and cache.count>0 then
					if not aura.stack then
						aura.stack=aura:CreateFontString(nil,"OVERLAY")
						aura.stack:SetPoint("BOTTOMRIGHT",aura,1,0)
						aura.stack:SetFont("Fonts\\FRIZQT__.TTF",aura:GetWidth()/3,"OUTLINE")
					end
					aura.stack:Show()
					aura.stack:SetText(format("%d",cache.count))
				end
			else
				aura:SetAlpha(aura.alpha)
				aura.cd:SetCooldown(0,0)
				if aura.stack then aura.stack:Hide() end
			end
			local children={aura:GetChildren()} for _,f in pairs(children) do if f.cd then if draw then f.cd:SetSwipeColor(0,0,0,db.cdalpha*db.maxalpha) else f.cd:SetSwipeColor(0,0,0,0) end end end --debug cd
			changes=1
		end
	end
	if changes then
		self:Layout()
	end
end
function AuraTracker:Layout()
	for l,list in pairs(self.lists) do
		table.sort(list,function(a,b) return self.auras[a].expi<self.auras[b].expi or self.auras[a].expi==self.auras[b].expi and a<b end)
		for i=1,#list do
			self.auras[list[i]].frame:SetPoint("TOPLEFT",(i-1)*(db.iconsize+db.margin),0)
		end
	end
end

-- OPTIONS

local function getter(info)
	return db[info.arg or info[#info]]
end
local function setter(info,value)
	db[info.arg or info[#info]]=value
	AuraTracker:ApplySettings()
end
local function Rename(oldname,value,...)
	local name=GetSpellInfo(value)
	-- print(oldname,value,name)
	if name and name~=oldname:match("[^%d]+"):trim() then
		local auralist=AuraTracker.options.args.auragroup.args
		if auralist[name] then
			local i=2
			while auralist[name.." "..i] do i=i+1 end
			name=name.." "..i
		end
		auralist[name]=auralist[oldname]
		auralist[name].name=name
		auralist[oldname]=nil
		db.auras[name]=db.auras[oldname]
		db.auras[oldname]=nil
		LibStub("AceConfigDialog-3.0"):SelectGroup(AddonName,"AuraTracker","auragroup",name,...)
	end
end
local function GetAura(info)
	-- print(info[#info])
	local value
	local name=info[3]
	db.auras[name]=db.auras[name] or {}
	if #info==4 then
		value=db.auras[name][info[4]]
	else
		local cname=info[4]
		db.auras[name].conds=db.auras[name].conds or {}
		db.auras[name].conds[cname]=db.auras[name].conds[cname] or {}
		value=db.auras[name].conds[cname][info[5]]
	end
	if value and info.arg=="number" then value=tostring(value) end
	return value
end
local function SetAura(info,value)
	if value=="" then value=nil end
	if info.arg=="number" then value=tonumber(value) end
	local name=info[3]
	db.auras[name]=db.auras[name] or {}
	if #info==4 then
		db.auras[name][info[4]]=value
	else
		local cname=info[4]
		db.auras[name].conds=db.auras[name].conds or {}
		db.auras[name].conds[cname]=db.auras[name].conds[cname] or {}
		db.auras[name].conds[cname][info[5]]=value
	end
	if info[#info]=="icon" then Rename(info[#info-1],value) end
	if info[#info]=="id" and info[#info-1]=="Condition 1" then Rename(info[#info-2],value,info[#info-1]) end
	AuraTracker:ApplySettings()
end
local function DeleteElement(info)
	local auralist=AuraTracker.options.args.auragroup.args
	local name=info[3]
	if #info==4 then
		auralist[name]=nil
		db.auras[name]=nil
	else
		local cname=info[4]
		auralist[name].args[cname]=nil
		db.auras[name].conds[cname]=nil
	end
	AuraTracker:ApplySettings()
end
local function NewCond(name,cname)
	local auralist=AuraTracker.options.args.auragroup.args
	if type(name)~="string" then
		name=name[#name-1]
		cname=nil
	end
	if not cname then
		local i=1
		while auralist[name].args["Condition "..i] do i=i+1 end
		cname="Condition "..i
	end
	local new={
		type="group",
		name=cname,
		order=20,
		args={
			delete={
				type="execute",
				name="Delete Condition",
				func=DeleteElement,
				order=0
			},
			mandatory={
				type="description",
				name="\nMandatory settings",
				order=1
			},
			id={
				type="input",
				name="Spell id",
				desc="The spell id",
				arg="number",
				order=2
			},
			unit={
				type="input",
				name="Unit",
				desc='The unit on wich the aura must be\nEx: "target"',
				order=3
			},
			optional={
				type="description",
				name="\nOptional settings",
				order=10
			},
			author={
				type="input",
				name="Author unit",
				desc='The unit that casted the aura\nEx: "player"',
				order=11
			},
			type={
				type="input",
				name="Buff type",
				desc='"buff" or "debuff"',
				order=12
			},
			inverse={
				type="toggle",
				name="Inverse condition",
				desc="Condition will be true if aura is missing (instead of present)",
				order=13
			},
		},
	}
	auralist[name].args[cname]=new
end
local function NewAura(name)
	local auralist=AuraTracker.options.args.auragroup.args
	local cond
	if type(name)~="string" then
		local i=1
		while auralist["Aura "..i] do i=i+1 end
		name="Aura "..i
		cond=true
	end
	local new={
		type="group",
		name=name,
		order=-1,
		args={
			delete={
				type="execute",
				name="Delete Aura",
				func=DeleteElement,
				order=1
			},
			new={
				type="execute",
				name="New Condition",
				func=NewCond,
				order=2
			},
			optional={
				type="description",
				name="\nOptional settings",
				order=10
			},
			icon={
				type="input",
				name="Icon",
				desc="Icon to draw\nLeave blank to use the condition id",
				arg="number",
				order=11
			},
			conditionn={
				type="input",
				name="Conditions needed",
				desc='How many conditions need to be true to activate the aura\nLeaving blank means 1',
				arg="number",
				order=12
			},
			nl0={
				type="description",
				name="",
				order=15
			},
			x={
				type="range",
				name="X",
				softMin=-400,softMax=400,step=1,bigStep=20,--10
				order=16
			},
			y={
				type="range",
				name="Y",
				softMin=-400,softMax=400,step=1,bigStep=20,--10
				order=17
			},
			nl1={
				type="description",
				name="",
				order=20
			},
			size={
				type="range",
				name="Custom Size",
				min=0,max=500,step=1,bigStep=2,softMax=100,
				order=21
			},
			-- resetsize={
				-- type="execute",
				-- name="Reset",
				-- desc="Set to default size",
				-- func=function(i) db.auras[i[#i-1]].size=nil AuraTracker:ApplySettings() end,
				-- width="half",
				-- order=22
			-- },
			sizetype={
				type="select",
				name="Size",
				values={["1 default"]="Default",["2 custom"]="Custom"},
				width="half",
				order=22
			},
			nl2={
				type="description",
				name="",
				order=23
			},
			alpha={
				type="range",
				name="Custom Alpha",
				min=0,max=1,step=0.01,bigStep=0.1,
				order=24
			},
			-- resetalpha={
				-- type="execute",
				-- name="Reset",
				-- desc="Set to default alpha",
				-- func=function(i) db.auras[i[#i-1]].alpha=nil AuraTracker:ApplySettings() end,
				-- width="half",
				-- order=25
			-- },
			alphatype={
				type="select",
				name="Alpha",
				values={["1 minalpha"]="Min",["2 midalpha"]="Mid",["3 maxalpha"]="Max",["4 custom"]="Custom"},
				width="half",
				order=25
			},
			nl3={
				type="description",
				name="",
				order=26
			},
			snapshot={
				type="toggle",
				name="Track snapshot",
				desc="Displays modifier values if the spell is holded by the TC module",
				order=27
			},
			pandemic={
				type="toggle",
				name="Pandemic",
				desc="Colors the cooldown when it can be refreshed without loss",
				order=28
			},
			class={
				type="select",
				name="Class",
				values={[0]="Any","Warrior","Paladin","Hunter","Rogue","Priest","DeathKnight","Shaman","Mage","Warlock","Monk","Druid"},
				desc="Aura will be active only for this class",
				-- arg="number",
				order=40
			},
			spec={
				type="input",
				name="Spec",
				desc="Aura will be active only for this spec",
				arg="number",
				order=41
			},
			name={
				type="input",
				name="Frame Name",
				order=50
			},
			parent={
				type="input",
				name="Frame Parent",
				order=51
			},
			anchor={
				type="input",
				name="Anchor",
				order=52
			},
			paranchor={
				type="input",
				name="Parent Anchor",
				order=53
			},
		},
	}
	auralist[name]=new
	if cond then
		NewCond(name)
		LibStub("AceConfigDialog-3.0"):SelectGroup(AddonName,"AuraTracker","auragroup",name)
	end
	-- table.insert(AuraTracker.options.args.auragroup.args,new)
	-- LibStub("AceConfigRegistry-3.0"):NotifyChange(AddonName)
	
end
function AuraTracker:LoadAuras()
	for a,b in pairs(db.auras) do
		NewAura(a)
		b.conds=b.conds or {}
		for c,d in pairs(b.conds) do
			NewCond(a,c)
		end
	end
end
function AuraTracker:GetOptions()
	return {
		order=8,
		type="group",
		name="Aura Tracker",
		desc="Aura Tracker",
		childGroups="tab",
		get=getter,
		set=setter,
		args={
			-- enabled={
				-- type="toggle",
				-- name="Enable",
				-- desc="Enable the module",
				-- order=1,
			-- },
			-- auratrk={
				-- type="header",
				-- name="Aura Tracker",
				-- order=2,
			-- },
			defaultsgroup={
				type="group",
				name="Default Settings",
				-- childGroups="tree",
				order=20,
				args={
					enabled={
						type="toggle",
						name="Enable",
						desc="Enable the module",
						order=0,
					},
					nl0={type="description",name=" ",order=0.1},
					iconsize={
						type="range",
						name="Icon Size",
						min=0,max=500,step=1,bigStep=2,softMax=100,
						order=1
					},
					margin={
						type="range",
						name="List Margin",
						min=0,max=20,step=1,bigStep=1,
						order=2
					},
					nl1={type="description",name="",order=3},
					minalpha={
						type="range",
						name="Min Alpha",
						min=0,max=1,step=0.01,bigStep=0.1,
						order=10
					},
					midalpha={
						type="range",
						name="Mid Alpha",
						min=0,max=1,step=0.01,bigStep=0.1,
						order=11
					},
					maxalpha={
						type="range",
						name="Max Alpha",
						min=0,max=1,step=0.01,bigStep=0.1,
						order=12
					},
					cdalpha={
						type="range",
						name="Cooldown Alpha",
						min=0,max=1,step=0.01,bigStep=0.1,
						order=13
					},
					nl2={type="description",name="",order=14},
					x={
						type="range",
						name="Default X",
						min=-1000,max=1000,step=1,bigStep=10,
						order=20
					},
					y={
						type="range",
						name="Default Y",
						min=-600,max=600,step=1,bigStep=10,
						order=21
					},
					nl3={type="description",name="",order=22},
					spellanchor={
						type="input",
						name="Aura Anchor",
						order=30
					},
					listanchor={
						type="input",
						name="List Anchor",
						order=31
					},
					parent={
						type="input",
						name="Parent",
						order=32
					},
					paranchor={
						type="input",
						name="Parent Anchor",
						order=33
					},
				},
			},
			auragroup={
				type="group",
				name="Auras",
				childGroups="tree",
				get=GetAura,
				set=SetAura,
				order=10,
				args={
					new={
						type="execute",
						name="New Aura",
						func=NewAura,
						order=1
					},
					fold={
						type="execute",
						name="Fold All",
						func=function() LibStub("AceConfigDialog-3.0"):GetStatusTable(AddonName,{"AuraTracker","auragroup"}).groups.groups={} LibStub("AceConfigRegistry-3.0"):NotifyChange(AddonName) end,
						width="half",
						order=2
					},
					showactiveonly={
						type="toggle",
						name="Show Active Only",
						get=function() return showactiveonly end,
						set=function(i,v) showactiveonly=v AuraTracker:ApplySettings() end,
						order=3
					},
				},
			},
		}
	}
end
