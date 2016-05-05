Settings = { }
Settings.__index = Settings

Settings.SETTINGS_ON_NORMAL_FISHING = 0
Settings.SETTINGS_ON_BOAT_FISHING = 1

Settings.SETTINGS_ON_USE_REALLIFE_METERS = 0
Settings.SETTINGS_ON_USE_INGAME_YARDS = 1

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
	self.RadarMeasure = Settings.SETTINGS_ON_USE_REALLIFE_METERS
	self.HealthPercent = 80
	self.AutoEscape = false
	self.PlayerRun = false
	self.DeleteUsedRods = true
	self.OnBoat = false
	self.EnableTrader = true
	self.EnableWarehouse = true
	self.EnableVendor = true
	self.EnableRepair = true
	return self
end