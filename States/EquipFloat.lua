EquipFloatState = { }
EquipFloatState.__index = EquipFloatState
EquipFloatState.Name = "Equip Float"

setmetatable(EquipFloatState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function EquipFloatState.new()
	local self = setmetatable({}, EquipFloatState)
	self.LastEquipTickCount = 0
	self.ItemToEquip = nil
	self.EquippedState = 0
	self.EquipState = 0
	self.EquippedState = 0
	self.DebugCheck = 0
	return self
end

function EquipFloatState:Reset()
	self.LastEquipTickCount = 0
	self.ItemToEquip = nil
	self.EquippedState = 0
	self.EquipState = 0
	self.EquippedState = 0
	self.DebugCheck = 0
end

function EquipFloatState:NeedToRun()
	self.ItemToEquip = nil
	self.EquipState = 0    -- 0 = nothing
	self.EquippedState = 0 -- 0 = nothing

	local selfPlayer = GetSelfPlayer()

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	if Pyx.System.TickCount - self.LastEquipTickCount < 4000 then
		return false
	end

	if ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe > 100 then
		return false
	end

	for k,v in pairs(selfPlayer.Inventory.Items, function(t,a,b) return t[a].Endurance < t[b].Endurance end) do
		if v.HasEndurance then
			if Bot.EnableDebug == true and self.DebugCheck == 0 then
				print("[" .. os.date(Bot.UsedTimezone) .. "] " .. v.ItemEnchantStaticStatus.Name .. " which have durability found")
			end

			self.EquipState = 1
			self.DebugCheck = 1
		end

		if self.EquipState == 1 then -- 1 = item have endurance
			if v.Endurance > 0 then
				if Bot.EnableDebug == true and self.DebugCheck == 1 then
					print("[" .. os.date(Bot.UsedTimezone) .. "] " .. v.ItemEnchantStaticStatus.Name .. " have more than 0 durability left")
				end

				self.EquipState = 2
			end
			self.DebugCheck = 2
		end


		if self.EquipState == 2 then -- 2 = this is for enhanced float
			if string.find(v.ItemEnchantStaticStatus.Name, "Float") then
				if Bot.EnableDebug == true and self.DebugCheck == 2 then
					print("[" .. os.date(Bot.UsedTimezone) .. "] The item have in the a '+' in the name, so is a enhanced float")
				end

				if Bot.EnableDebug == true and self.DebugCheck == 2 then
					print("[" .. os.date(Bot.UsedTimezone) .. "] Equipped: " .. v.ItemEnchantStaticStatus.Name)
				end
				self.ItemToEquip = v
				break
			else
				if Bot.EnableDebug == true and self.DebugCheck == 2 then
					print("[" .. os.date(Bot.UsedTimezone) .. "] Maybe " .. v.ItemEnchantStaticStatus.Name .. " is a know float?")
				end

				self.EquipState = 3
			end
			self.DebugCheck = 3
		end

		if self.EquipState == 3 then -- fallback for know Float using ids, just in case all the step don't work
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
				print("[" .. os.date(Bot.UsedTimezone) .. "] Equipped: " .. v.ItemEnchantStaticStatus.Name)
				self.ItemToEquip = v
				break
			end
		end
	end

	if not self.ItemToEquip then
		return false
	end

	local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_LEFT_HAND)

	if not equippedItem then
		return true
	else
		self.EquippedState = 1
	end

	if self.EquippedState == 1 then -- 2 = search for 'Float' string
		if not string.find(equippedItem.ItemEnchantStaticStatus.Name, "Float") then
			self.EquippedState = 2
		end
	end

	if self.EquippedState == 2 then -- 2 fallback to know float using ids
		if 	not equippedItem.ItemEnchantStaticStatus.ItemId == 16167 or		-- Ash Tree Float
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81703 or		-- Ash Tree Float +1
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147239 or	-- Ash Tree Float +2
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212775 or	-- Ash Tree Float +3
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278311 or	-- Ash Tree Float +4
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343847 or	-- Ash Tree Float +5
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16168 or		-- Maple Float
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81704 or		-- Maple Float +1
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147240 or	-- Maple Float +2
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212776 or	-- Maple Float +3
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278312 or	-- Maple Float +4
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343848		-- Maple Float +5
		then
			self.EquippedState = 3
		else
			self.EquippedState = 4
		end
	end

	if self.EquippedState == 3 then
		return false
	end

	if self.EquippedState == 4 then
		return true
	end

	return equippedItem.Endurance == 0
end

function EquipFloatState:Run()
	local selfPlayer = GetSelfPlayer()
	self.ItemToEquip:UseItem()
	self.LastEquipTickCount = Pyx.System.TickCount
end