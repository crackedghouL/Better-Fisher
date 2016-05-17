Settings = { }
Settings.__index = Settings

setmetatable(Settings, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function Settings.new()
	local self = setmetatable({}, Settings)
	self.LastProfileName = ""
	self.HealthPercent = 80
	self.AutoEscape = false
	self.PlayerRun = false
	self.DeleteUsedRods = true
	self.InvFullStop = false
	self.StopWhenPeopleNearby = false
	self.TradeManagerSettings = {}
	self.WarehouseSettings = {}
	self.VendorSettings = {}
	self.RepairSettings = {}
	self.LibConsumablesSettings = {}
	self.InventoryDeleteSettings = {}
	self.StartFishingSettings = {}
	self.HookFishHandleGameSettings = {}
	self.LootSettings = {}
	return self
end