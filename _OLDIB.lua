	local Index = 1
	for ClassIndex, ClassList in ipairs(Database.list) do
		for SpellIndex, Spell in ipairs(ClassList[2]) do
			self:CreateFrame(Index, Spell[2],
				Database.x+(Database.size+1)*math.ceil((Index-1)%Database.line),
				Database.y-(Database.size+1)*math.ceil(Index/Database.line))
			self:UpdateFrame(self.framelist[Index],Spell[2],Spell[3])
			Index = Index + 1
		end
	end

	function InterruptBar:Launch()
			local Index = 1
			for ClassIndex, ClassList in ipairs(self.list) do
		    for SpellIndex, Spell in ipairs(ClassList[2]) do
		        local Frame=self.framelist[Index]
		        if(Database.fl==0)then
		            Frame:Show() Frame.CD:Show()
		        else
		            Frame:Hide() Frame.CD:Hide()
		        end
						Index = Index + 1
		    end
			end
	end

				line={
					type="range",
					name="Icons per line",
					min=1,max=50,step=1,bigStep=1,
					order=14
				},

1302-068FA782
0 3767 1159 18643 78215 020202DC42E

506c617965722d313330322d3036384641373832
5065742d302d333




function InterruptBar:DEBUGGetList()
	for ClassIndex, ClassList in ipairs(self.list) do
		for SpellIndex, Spell in ipairs(ClassList[2]) do
			print(ClassList[1] .. " : " .. Spell[2] .. "," .. Spell[3])
		end
	end
end

function InterruptBar:DEBUGGetListForSpecifiedSpec(SpecID)
	local _,SpecName,_,_,_,_,ClassName =  GetSpecializationInfoByID(SpecID)
	for ClassIndex, ClassList in ipairs(self.list) do
		if (ClassList[1] == ClassName) then
			for SpellIndex, Spell in ipairs(ClassList[2]) do
				if(self:IsSpecFoundForSpell(SpecID, Spell[1])) then
					local SpellName = GetSpellInfo(Spell[2])
					print(ClassName .. SpellName .. "(" .. Spell[2] .. ")" .. ", " .. Spell[3])
				end
			end
		end
	end
end

function InterruptBar:IsAlreadyInSourceNameList(TestSourceName)
	for Index=1, getn(self.sourcenamelist) do
		local SourceName = self.sourcenamelist[Index]
		if(TestSourceName == SourceName) then
			return true
		end
	end
	return false
end

function InterruptBar:FindNewSources()
	self.mainframe:SetScript("OnEvent", function(_,_,_,Event,_,SourceGUID,SourceName,SourceFlags,_,_,_,_,_,ID)
		if bit.band(SourceFlags,0x40)==0x40 then
			local AlreadyInList = self:IsAlreadyInSourceNameList(SourceGUID)
			if(not AlreadyInList) then
				print(SourceGUID)
				if(ClassName ~= nil) then
					for ClassIndex, ClassList in ipairs(self.list) do
						if(ClassName == ClassList[1]) then
							for SpellIndex, Spell in ipairs(ClassList[2]) do
								local SpecID = GetInspectSpecialization()
								-- if(self:IsSpecFoundForSpell(SpecID, Spell[1])) then -- TODO(find away to get the spec)
									if(Event=="SPELL_CAST_SUCCESS"and ID==Spell[2])then
										print("add " .. SourceGUID)
										table.insert(self.sourcenamelist, SourceGUID)
										self:AddClass(ClassName, SourceGUID, Spell[2])
									end
								-- end
							end
						end
					end
				end
			end
		end
	end)
	self.mainframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "FindNewSources")
end
