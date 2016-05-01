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
	self.LootSettings = {}
	self.HookFishHandleGameSettings = {}
	self.WarehouseSettings = {}
	self.VendorSettings = {}
	self.TradeManagerSettings = {}
	self.LibConsumablesSettings = {}
	self.InventoryDeleteSettings = {}
	self.StartFishingSettings = {}
	self.PlayerRun = false
	self.DeleteUsedRods = true
	self.OnBoat = false
	return self
end