Profile = { }
Profile.__index = Profile

setmetatable(Profile, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Profile.new()
  local self = setmetatable({}, Profile)
    self.FishSpotPosition = { X = 0, Y = 0, Z = 0 }
    self.FishSpotRotation = 0
    self.VendorNpcName = ""
    self.VendorNpcPosition = { X = 0, Y = 0, Z = 0 }
    self.TradeManagerNpcName = ""
    self.TradeManagerNpcPosition = { X = 0, Y = 0, Z = 0 }
    self.WarehouseNpcName = ""
    self.WarehouseNpcPosition = { X = 0, Y = 0, Z = 0 }
    self.RepairNpcName = ""
    self.RepairNpcPosition = { X = 0, Y = 0, Z = 0 }
  return self
end

function Profile:HasFishSpot()
    if self.FishSpotPosition.X ~= 0 and self.FishSpotPosition.Y ~= 0 and self.FishSpotPosition.Z ~= 0 then
        return true
    else
        return false
    end
end

function Profile:GetFishSpotPosition()
    return Vector3(self.FishSpotPosition.X, self.FishSpotPosition.Y, self.FishSpotPosition.Z)
end

function Profile:GetFishSpotRotation()
    return self.FishSpotRotation
end

function Profile:GetVendorPosition()
    return Vector3(self.VendorNpcPosition.X, self.VendorNpcPosition.Y, self.VendorNpcPosition.Z)
end

function Profile:GetRepairPosition()
    return Vector3(self.RepairNpcPosition.X, self.RepairNpcPosition.Y, self.RepairNpcPosition.Z)
end

function Profile:GetTradeManagerPosition()
    return Vector3(self.TradeManagerNpcPosition.X, self.TradeManagerNpcPosition.Y, self.TradeManagerNpcPosition.Z)
end

function Profile:GetWarehousePosition()
    return Vector3(self.WarehouseNpcPosition.X, self.WarehouseNpcPosition.Y, self.WarehouseNpcPosition.Z)
end

function Profile:GetVendorPosition()
    return Vector3(self.VendorNpcPosition.X, self.VendorNpcPosition.Y, self.VendorNpcPosition.Z)
end

function Profile:HasTradeManager()
    return string.len(self.TradeManagerNpcName) > 0
end

function Profile:HasWarehouse()
    return string.len(self.WarehouseNpcName) > 0
end

function Profile:HasVendor()
    return string.len(self.VendorNpcName) > 0
end
