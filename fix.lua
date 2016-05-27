if Pyx.System == nil then
    local callbackTranslations = {
        OnScriptStart = "Pyx.OnScriptStart",
        OnScriptStop = "Pyx.OnScriptStop",
        OnDrawGui = "ImGui.OnRender",
        OnPulse = "PyxBDO.OnPulse",
        OnRender3D = "PyxBDO.OnRender3D",
        OnSendPacket = "PyxBDO.OnSendPacket",
        OnReceivePacket = "PyxBDO.OnReceivePacket",
    }
    Pyx.System = {
        StopCurrentScript = function() Pyx.Scripting.CurrentScript:Stop() end,
        RegisterCallback = function(a,b) Pyx.Scripting.CurrentScript:RegisterCallback(callbackTranslations[a],b) end,
    }
    local mt = {}
    mt.__index = function(self, k)
        if k == "TickCount" then
            return Pyx.Win32.GetTickCount()
        end
        return rawget(self, k)
    end
    setmetatable(Pyx.System, mt)
end
