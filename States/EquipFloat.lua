EquipFloatState = {}
EquipFloatState.__index = EquipFloatState
EquipFloatState.Name = "Equip Float"

setmetatable(EquipFloatState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function EquipFloatState.new()
	local self = setmetatable({}, EquipFloatState)
	self.LastEquipTickCount = 0
	self.ItemToEquip = nil
	self.state = 0
	return self
end

function EquipFloatState:Reset()
	self.LastEquipTickCount = 0
	self.ItemToEquip = nil
	self.state = 0
end

function EquipFloatState:Exit()
	if self.state > 1 then
		self.state = 0
	end
end

function EquipFloatState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		local selfPlayer = GetSelfPlayer()
		local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_LEFT_HAND)

		if not selfPlayer.IsAlive then
			return false
		end

		if selfPlayer.CurrentActionName ~= "WAIT" then
			return false
		end

		if Pyx.Win32.GetTickCount() - self.LastEquipTickCount < Bot.WaitTimeForStates then
			return false
		end

		if ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe > Bot.Settings.FishingSpotRadius then
			return false
		end

		for k,v in pairs(selfPlayer.Inventory.Items, function(t,a,b) return t[a].Endurance < t[b].Endurance end) do
			if v.HasEndurance and (v.Endurance <= 32767 or v.MaxEndurance <= 32767) then
				if Bot.EnableDebug and Bot.EnableDebugEquipFloatState then
					print(v.ItemEnchantStaticStatus.Name .. " which have durability")
				end
				self.state = 1
			end

			if self.state == 1 then -- 1 = item have endurance
				if v.Endurance > 0 then
					if Bot.EnableDebug and Bot.EnableDebugEquipFloatState then
						print(v.ItemEnchantStaticStatus.Name .. " have " .. v.Endurance .. " durability left")
					end
					self.state = 2
				end
			end

			if self.state == 2 then -- 2 = fallback for know Floats using ids, just in case all the step don't work
				if 	v.ItemEnchantStaticStatus.ItemId == 16167 or  -- Ash Tree Float
					v.ItemEnchantStaticStatus.ItemId == 81703 or  -- Ash Tree Float +1
					v.ItemEnchantStaticStatus.ItemId == 147239 or -- Ash Tree Float +2
					v.ItemEnchantStaticStatus.ItemId == 212775 or -- Ash Tree Float +3
					v.ItemEnchantStaticStatus.ItemId == 278311 or -- Ash Tree Float +4
					v.ItemEnchantStaticStatus.ItemId == 343847 or -- Ash Tree Float +5
					v.ItemEnchantStaticStatus.ItemId == 16168 or  -- Maple Float
					v.ItemEnchantStaticStatus.ItemId == 81704 or  -- Maple Float +1
					v.ItemEnchantStaticStatus.ItemId == 147240 or -- Maple Float +2
					v.ItemEnchantStaticStatus.ItemId == 212776 or -- Maple Float +3
					v.ItemEnchantStaticStatus.ItemId == 278312 or -- Maple Float +4
					v.ItemEnchantStaticStatus.ItemId == 343848 or -- Maple Float +5
					v.ItemEnchantStaticStatus.ItemId == 16169 or  -- Cedar Float
																  -- Cedar Float +1
																  -- Cedar Float +2
																  -- Cedar Float +3
																  -- Cedar Float +4
																  -- Cedar Float +5
					v.ItemEnchantStaticStatus.ItemId == 16170	  -- Palm Tree Float
																  -- Palm Tree Float +1
																  -- Palm Tree Float +2
																  -- Palm Tree Float +3
																  -- Palm Tree Float +4
																  -- Palm Tree Float +5
				then
					if Bot.EnableDebug and Bot.EnableDebugEquipFloatState then
						print("Equipped: " .. v.ItemEnchantStaticStatus.Name)
					end
					self.ItemToEquip = v
					break
				end
			end
		end

		if not self.ItemToEquip then
			return false
		end

		if not equippedItem then
			return true
		else
			if 	not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "Float") or	-- english client
				not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "flottant") or -- french client
				not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "holzfloß") 	-- deutsch client
			then
				return true
			end
		end

		self:Exit()
		return equippedItem.Endurance == 0
	else
		return false
	end
end

function EquipFloatState:Run()
	self.ItemToEquip:UseItem()
	self.LastEquipTickCount = Pyx.Win32.GetTickCount()
end