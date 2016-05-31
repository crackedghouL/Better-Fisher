EquipFishingRodState = {}
EquipFishingRodState.__index = EquipFishingRodState
EquipFishingRodState.Name = "Equip fishing rod"

setmetatable(EquipFishingRodState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function EquipFishingRodState.new()
	local self = setmetatable({}, EquipFishingRodState)
	self.LastEquipTickCount = 0
	self.ItemToEquip = nil
	self.EquipState = 0
	self.EquippedState = 0
	return self
end

function EquipFishingRodState:Reset()
	self.LastEquipTickCount = 0
	self.ItemToEquip = nil
	self.EquipState = 0
	self.EquippedState = 0
end

function EquipFishingRodState:NeedToRun()
	self.ItemToEquip = nil
	self.EquipState = 0 -- 0 = nothing
	self.EquippedState = 0 -- 0 = nothing

	local selfPlayer = GetSelfPlayer()
	local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	if Pyx.Win32.GetTickCount() - self.LastEquipTickCount < 4000 then
		return false
	end

	if selfPlayer.CurrentActionName ~= "WAIT" then
		return false
	end

	if ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe > Bot.Settings.FishingSpotRadius then
		return false
	end

	for k,v in pairs(selfPlayer.Inventory.Items, function(t,a,b) return t[a].Endurance < t[b].Endurance end) do
		if v.HasEndurance then
			if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
				print(v.ItemEnchantStaticStatus.Name .. " which have durability found")
			end
			self.EquipState = 1
		end

		if self.EquipState == 1 then -- 1 = item have endurance
			if v.Endurance > 0 then
				if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
					print(v.ItemEnchantStaticStatus.Name .. " have more than 0 durability left")
				end
				self.EquipState = 2
			end
		end

		if self.EquipState == 2 then -- 2 = normal rod
			if v.ItemEnchantStaticStatus.IsFishingRod then
				if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
					print("IsFishingRod = " .. tostring(v.ItemEnchantStaticStatus.IsFishingRod) .. ", so is a normal rod")
					print("Equipped: " .. v.ItemEnchantStaticStatus.Name)
				end
				self.ItemToEquip = v
				break
			else
				if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
					print("Maybe " .. v.ItemEnchantStaticStatus.Name .. " is a enhanced rod?")
				end
				self.EquipState = 3
			end
		end

		if self.EquipState == 3 then -- 3 = this is for enhanced rod
			if string.find(tostring(v.ItemEnchantStaticStatus.Name), "Fishing Rod") then
				if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
					print("The item have in the a '+' in the name, so is a enhanced rod")
					print("Equipped: " .. v.ItemEnchantStaticStatus.Name)
				end
				self.ItemToEquip = v
				break
			else
				if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
					print("Maybe " .. v.ItemEnchantStaticStatus.Name .. " is a know rod?")
				end
				self.EquipState = 4
			end
		end

		if self.EquipState == 4 then -- fallback for know rods using ids, just in case all the step don't work
			if  v.ItemEnchantStaticStatus.ItemId == 16147 or  -- Thick Rod
				v.ItemEnchantStaticStatus.ItemId == 16151 or  -- Steel Rod
				v.ItemEnchantStaticStatus.ItemId == 16152 or  -- Gold Rod
				v.ItemEnchantStaticStatus.ItemId == 16153 or  -- Triple Float Rod
				v.ItemEnchantStaticStatus.ItemId == 16162 or  -- Balenos Rod
				v.ItemEnchantStaticStatus.ItemId == 16163 or  -- Epheria Rod
				v.ItemEnchantStaticStatus.ItemId == 16164 or  -- Calpheon Rod
				v.ItemEnchantStaticStatus.ItemId == 16165 or  -- Mediah Rod

										-- Rod +1
				v.ItemEnchantStaticStatus.ItemId == 81698 or  -- Balenos Rod
				v.ItemEnchantStaticStatus.ItemId == 81699 or  -- Epheria Rod
				v.ItemEnchantStaticStatus.ItemId == 81700 or  -- Calpheon Rod
				v.ItemEnchantStaticStatus.ItemId == 81701 or  -- Mediah Rod

										-- Rod +2
				v.ItemEnchantStaticStatus.ItemId == 147234 or -- Balenos Rod
				v.ItemEnchantStaticStatus.ItemId == 147235 or -- Epheria Rod
				v.ItemEnchantStaticStatus.ItemId == 147236 or -- Calpheon Rod
				v.ItemEnchantStaticStatus.ItemId == 147237 or -- Mediah Rod

										-- Rod +3
				v.ItemEnchantStaticStatus.ItemId == 212770 or -- Balenos Rod
				v.ItemEnchantStaticStatus.ItemId == 212771 or -- Epheria Rod
				v.ItemEnchantStaticStatus.ItemId == 212772 or -- Calpheon Rod
				v.ItemEnchantStaticStatus.ItemId == 212773 or -- Mediah Rod

										-- Rod +4
				v.ItemEnchantStaticStatus.ItemId == 278306 or -- Balenos Rod
				v.ItemEnchantStaticStatus.ItemId == 278307 or -- Epheria Rod
				v.ItemEnchantStaticStatus.ItemId == 278308 or -- Calpheon Rod
				v.ItemEnchantStaticStatus.ItemId == 278309 or -- Mediah Rod

										-- Rod +5
				v.ItemEnchantStaticStatus.ItemId == 343842 or -- Balenos Rod
				v.ItemEnchantStaticStatus.ItemId == 343843 or -- Epheria Rod
				v.ItemEnchantStaticStatus.ItemId == 343844 or -- Calpheon Rod
				v.ItemEnchantStaticStatus.ItemId == 343845 or -- Mediah Rod

										-- Rod +6
				v.ItemEnchantStaticStatus.ItemId == 409378 or -- Balenos Rod
				v.ItemEnchantStaticStatus.ItemId == 409379 or -- Epheria Rod
				v.ItemEnchantStaticStatus.ItemId == 409380 or -- Calpheon Rod
				v.ItemEnchantStaticStatus.ItemId == 409381 or -- Mediah Rod

										-- Rod +7
															  -- Balenos Rod
															  -- Epheria Rod
															  -- Calpheon Rod
															  -- Mediah Rod

										-- Rod +8
				v.ItemEnchantStaticStatus.ItemId == 540450 or -- Balenos Rod
				v.ItemEnchantStaticStatus.ItemId == 540451 or -- Epheria Rod
				v.ItemEnchantStaticStatus.ItemId == 540452 or -- Calpheon Rod
				v.ItemEnchantStaticStatus.ItemId == 540453	  -- Mediah Rod
			then
				if Bot.EnableDebug and Bot.EnableDebugEquipFishignRodState then
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
		self.EquippedState = 1
	end

	if self.EquippedState == 1 then -- 1 = normal rod
		if not equippedItem.ItemEnchantStaticStatus.IsFishingRod then
			self.EquippedState = 2
		end
	end

	if self.EquippedState == 2 then -- 2 = search for 'Fishing Rod' string
		if not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "Fishing Rod") then
			self.EquippedState = 3
		end
	end

	if self.EquippedState == 3 then -- 3 fallback to know rod using ids
		if 	not equippedItem.ItemEnchantStaticStatus.ItemId == 16147 or  -- Thick Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16151 or  -- Steel Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16152 or  -- Gold Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16153 or  -- Triple Float Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16162 or  -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16163 or  -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16164 or  -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16165 or  -- Mediah Rod

									-- Rod +1
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81698 or  -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81699 or  -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81700 or  -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81701 or  -- Mediah Rod

									-- Rod +2
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147234 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147235 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147236 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147237 or -- Mediah Rod

									-- Rod +3
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212770 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212771 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212772 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212773 or -- Mediah Rod

									-- Rod +4
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278306 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278307 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278308 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278309 or -- Mediah Rod

									-- Rod +5
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343842 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343843 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343844 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343845 or -- Mediah Rod

									-- Rod +6
			not equippedItem.ItemEnchantStaticStatus.ItemId == 409378 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 409379 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 409380 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 409381 or -- Mediah Rod

									-- Rod +7
																		 -- Balenos Rod
																		 -- Epheria Rod
																		 -- Calpheon Rod
																		 -- Mediah Rod

									-- Rod +8
			not equippedItem.ItemEnchantStaticStatus.ItemId == 540450 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 540451 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 540452 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 540453	 -- Mediah Rod
		then
			return false
		else
			return true
		end
	end

	return equippedItem.Endurance == 0
end

function EquipFishingRodState:Run()
	local selfPlayer = GetSelfPlayer()
	self.ItemToEquip:UseItem()
	self.LastEquipTickCount = Pyx.Win32.GetTickCount()
end