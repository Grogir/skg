for i=1, 5 do
	local aframe = _G["ArenaEnemyFrame"..i]
	for j=1, 13 do
		local debuff = CreateFrame("Cooldown", "ArenaEnemyFrame" .. i .. "Debuff" .. j, aframe)
		debuff:RegisterEvent("UNIT_AURA")
		debuff:SetSize(15,15)
		debuff.use = false
		debuff:SetPoint("CENTER", aframe, "TOPLEFT", 15*(j-1), 15)
		debuff.tex = debuff:CreateTexture()
		debuff.tex:SetAllPoints(debuff)
	end
	local f = CreateFrame("Frame")
	f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	f:SetScript("OnEvent", function(_,_,_, eventtype, hideCaster, srcGUID, srcName, srcFlags, _, dstGUID, dstName, dstFlags, _, spellID, spellName, _, auraType)
		local unit = "arena" .. i
		if(dstGUID == UnitGUID(unit)) then
		--if(dstGUID == UnitGUID("player")) then
			if(eventtype == "SPELL_AURA_APPLIED") then
				if(auraType=="DEBUFF") then
					if(srcGUID == UnitGUID("player")) then
						AddDebuffIcon(aframe, spellName, unit)
					end
				end
			end
		end
	end)
end

function AddDebuffIcon(frame, spell, unit)
	local _, _, ic, _, _, dur, expi, _, _, _, spellid = UnitDebuff(unit, spell)
	for i=1, 13 do
		local debuff = _G[frame:GetName() .. "Debuff" .. i]
		if(not debuff:IsShown()) then
			debuff:SetScript("OnEvent",function(self,event,a1)
				local _, _, _, _, _, dur, expi, _, _, _, _ = UnitDebuff(unit, spell)
				if(expi) then
					debuff:SetCooldown(expi-dur, dur)
				else
					debuff:SetCooldown(0,0)
				end
			end)
			debuff:SetCooldown(GetTime(), dur)
			debuff.tex:SetTexture(ic)
			return
		end
	end
end
