EquipFishingRodState = {}
EquipFishingRodState.__index = EquipFishingRodState
EquipFishingRodState.Name = "Equip fishing rod"

setmetatable(EquipFishingRodState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function EquipFishingRodState.new()
	local self = setmetatable({}, EquipFishingRodState)
	self.LastEquipTickCount = 0
	self.ItemToEquip = nil
	self.state = 0
	self.EquippedState = 0
	return self
end

function EquipFishingRodState:Reset()
	self.LastEquipTickCount = 0
	self.ItemToEquip = nil
	self.state = 0
	self.EquippedState = 0
end

function EquipFishingRodState:Exit()
	if self.state > 1 then
		self.state = 0
	end
end

function EquipFishingRodState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		local selfPlayer = GetSelfPlayer()
		local items = selfPlayer.Inventory.Items
		local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

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

		for k,v in pairs(items, function(t,a,b) return t[a].Endurance < t[b].Endurance end) do
			if v.HasEndurance and (v.Endurance <= 32767 or v.MaxEndurance <= 32767) then
				if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
					print(v.ItemEnchantStaticStatus.Name .. " which have durability")
				end
				self.state = 1
			end

			if self.state == 1 then -- 1 = item have endurance and is a know rod
				if v.Endurance > 0 then
					if v.ItemEnchantStaticStatus.IsFishingRod then
						if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
							print(v.ItemEnchantStaticStatus.Name .. " have " .. v.Endurance .. " durability left")
							print("IsFishingRod = " .. tostring(v.ItemEnchantStaticStatus.IsFishingRod) .. ", so is a know rod")
							print("Equipped: " .. v.ItemEnchantStaticStatus.Name)
						end
						self.ItemToEquip = v
						break
					else
						if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
							print(v.ItemEnchantStaticStatus.Name .. " have " .. v.Endurance .. " durability left")
							print("IsFishingRod = " .. tostring(v.ItemEnchantStaticStatus.IsFishingRod) .. ", so is a unknow rod")
						end
						self.state = 2
					end
				end
			end

			if self.state == 2 then -- 2 = this is for unknow rod
				if 	string.find(tostring(v.ItemEnchantStaticStatus.Name), "Fishing Rod") or   -- english client
					string.find(tostring(v.ItemEnchantStaticStatus.Name), "Canne à pêche") or -- french client
					string.find(tostring(v.ItemEnchantStaticStatus.Name), "Angelrute")		  -- deutsch client
				then
					if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
						print("Pyx can not recognize it, but seem to be a fishing rod")
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
			if not equippedItem.ItemEnchantStaticStatus.IsFishingRod then
				if 	not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "Fishing Rod") or   -- english client
					not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "Canne à pêche") or -- french client
					not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "Angelrute")		  -- deutsch client
				then
					return true
				end
			end
		end

		self:Exit()
		return equippedItem.Endurance == 0
	else
		return false
	end
end

function EquipFishingRodState:Run()
	self.ItemToEquip:UseItem()
	self.LastEquipTickCount = Pyx.Win32.GetTickCount()
end