--------------------------------------------------
--
-- SKG.lua
-- created 20/02/2013
-- by Pierre-Yves "Grogir" DUTREUILH & Florian "Khujara" FALAVEL
--
--------------------------------------------------

local AddonName,SKG=...
local db
_G.SKG=SKG
SKG=LibStub("AceAddon-3.0"):NewAddon(SKG,AddonName,"AceConsole-3.0")

local defaults={
	global={
	}
}

function SKG:OnInitialize()
	self.db=LibStub("AceDB-3.0"):New("SKGDB",defaults,true)
	self:SetupOptions()
	db=self.db
	LoadAddOn("Blizzard_ArenaUI")
end

function SKG:SetupOptions()
	self.options={
		type="group",
		name=AddonName,
		plugins={},
		args={}
	}
	-- self.options.plugins.profiles={profiles=LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)}
	LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName,self.options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize(AddonName,760,600)
	local status=LibStub("AceConfigDialog-3.0"):GetStatusTable(AddonName)
	status.groups={treewidth=120}
	self:RegisterChatCommand("sg","ChatCommand")
	self:RegisterChatCommand("sk","ChatCommand")
	self:RegisterChatCommand("skg","ChatCommand")
end

function SKG:ChatCommand(input)
	if not input or input:trim()=="" then
		if not InCombatLockdown() then LibStub("AceConfigDialog-3.0"):Open(AddonName) end
	else
		LibStub("AceConfigCmd-3.0").HandleCommand(self,"skg",AddonName,input)
	end
end

function SKG:ResetOptions(args,db,def)
	for a,b in pairs(args) do
		if db[a]~=nil and db[a]~=def[a] then
			db[a]=def[a]
		end
		if b.type=="group" and b.args then
			self:ResetOptions(b.args,db,def)
		end
	end
end

function SKG:RegisterModuleOptions(key,table)
	if self.options then
		self.options.plugins[key]={[key]=table}
	end
end





