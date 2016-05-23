---------------------------------------------
-- Variables
---------------------------------------------

ConfirmWindow = {}
ConfirmWindow.Visible = false

---------------------------------------------
-- ConfirmWindow Functions
---------------------------------------------

function ConfirmWindow.DrawConfirmWindow()
	if ConfirmWindow.Visible then
		_, ConfirmWindow.Visible = ImGui.Begin("Are you sure?", ConfirmWindow.Visible, ImVec2(350, 400), -1.0, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoTitleBar)

		ImGui.TextColored(ImVec4(1,0.2,0.2,1), "WARNING!")
		ImGui.Text("By default all \"Fishing Rods\", \"Thick Fishing Rods\"and \"Steel Fishing Rods\",\nwill be deleted on 0 durability because they can't be repaired.")
		ImGui.Spacing()
		if ImGui.Button("Continue", ImVec2(ImGui.GetContentRegionAvailWidth() / 3, 20)) then
			Bot.Start()
			ConfirmWindow.Visible = false
		end
		ImGui.SameLine()
		if ImGui.Button("Disable it", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
			Bot.Settings.DeleteUsedRods = false
			ConfirmWindow.Visible = false
		end
		ImGui.SameLine()
		if ImGui.Button("Cancel", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			ConfirmWindow.Visible = false
		end

		ImGui.End()
	end
end

function ConfirmWindow.OnDrawGuiCallback()
	ConfirmWindow.DrawConfirmWindow()
end