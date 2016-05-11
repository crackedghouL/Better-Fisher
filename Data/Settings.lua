Settings = { }
Settings.__index = Settings

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
	self.RadarMeasure = Settings.SETTINGS_ON_USE_REALLIFE_METERS
	self.HealthPercent = 80
	self.AutoEscape = false
	self.PlayerRun = false
	self.DeleteUsedRods = true
	self.InvFullStop = false
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