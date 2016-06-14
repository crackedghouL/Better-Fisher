IdleState = {}
IdleState.__index = IdleState
IdleState.Name = "Idle"

setmetatable(IdleState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function IdleState.new()
	local self = setmetatable({}, IdleState)
	return self
end

function IdleState:NeedToRun()
	return true
end

function IdleState:Run()
	if GetSelfPlayer():CheckCurrentAction("RUN_SPRINT") or GetSelfPlayer():CheckCurrentAction("RUN")
	or GetSelfPlayer():CheckCurrentAction("RUN_ING") or GetSelfPlayer():CheckCurrentAction("RUN_STOP")
	or GetSelfPlayer():CheckCurrentAction("RIN_SPRINT_FAST") or GetSelfPlayer():CheckCurrentAction("RUN_SPRINT_FAST_ST")
	or GetSelfPlayer():CheckCurrentAction("RUN")
			then GetSelfPlayer():DoActionAtPosition("WAIT",GetSelfPlayer().CrosshairPosition, 1)
		end
end
