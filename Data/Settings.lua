Settings = { }
Settings.__index = Settings

Settings.SETTINGS_ON_NORMAL_FISHING = 0
Settings.SETTINGS_ON_BOAT_FISHING = 1

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
	self.FishingMethod = Settings.SETTINGS_ON_NORMAL_FISHING
	self.PlayerRun = false
	self.DeleteUsedRods = true
	self.OnBoat = false
	return self
end