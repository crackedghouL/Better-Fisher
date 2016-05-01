HookFishHandleGameState = { }
HookFishHandleGameState.__index = HookFishHandleGameState
HookFishHandleGameState.Name = "Hook game"

setmetatable(HookFishHandleGameState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function HookFishHandleGameState.new()
	local self = setmetatable({}, HookFishHandleGameState)
	self.Settings = { NoDelay = false, AlwaysPerfect = false, UseOldAnimations = false }
	self.LastGameTick = 0
	self.RandomWaitTime = 0
	return self
end

function HookFishHandleGameState:Reset()
	self.LastGameTick = 0
	self.RandomWaitTime = 0
end

function HookFishHandleGameState:NeedToRun()
	local selfPlayer = GetSelfPlayer()

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	return selfPlayer.CurrentActionName == "FISHING_HOOK_START" or selfPlayer.CurrentActionName == "FISHING_HOOK_ING_HARDER"
end

function HookFishHandleGameState:Run()
	local selfPlayer = GetSelfPlayer()

	if self.Settings.UseOldAnimations == true then
		if selfPlayer.CurrentActionName == "FISHING_HOOK_START" then
			selfPlayer:DoAction("FISHING_HOOK_PERFECT")
			selfPlayer:DoAction("FISHING_HOOK_ING")
			BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(3)")
			selfPlayer:DoAction("FISHING_HOOK_ING_HARDER")
			self.LastGameTick = Pyx.System.TickCount

			if self.Settings.NoDelay == true then
				self.RandomWaitTime = 0
			else
				self.RandomWaitTime = math.random(2800,3900)
			end
		elseif selfPlayer.CurrentActionName == "FISHING_HOOK_ING_HARDER" then
			if not selfPlayer.CurrentActionName == "FISHING_HOOK_ING_HARDER" then
				return
			else
				if Pyx.System.TickCount - self.LastGameTick > self.RandomWaitTime then
					BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(2)")
					BDOLua.Execute("MiniGame_Command_OnSuccess()")
				end
			end
		end
	else
		local fishResult = "FISHING_HOOK_PERFECT"
		if self.Settings.AlwaysPerfect == false then
			if math.random(10) > 1 then
				fishResult = "FISHING_HOOK_GOOD"
			end
		end

		if selfPlayer.CurrentActionName == "FISHING_HOOK_START" then
			if self.Settings.NoDelay == true then
				selfPlayer:DoAction(fishResult)
			else
				self.LastGameTick = Pyx.System.TickCount
				self.RandomWaitTime = math.random(3000,6000)
				selfPlayer:DoAction(fishResult)
			end
		elseif selfPlayer.CurrentActionName == "FISHING_HOOK_ING_HARDER" then
			if not selfPlayer.CurrentActionName == "FISHING_HOOK_ING_HARDER" then
				return
			else
				if Pyx.System.TickCount - self.LastGameTick > self.RandomWaitTime then
					selfPlayer:DoAction("FISHING_HOOK_SUCCESS")
				end
			end
		end
	end
end