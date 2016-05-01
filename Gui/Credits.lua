---------------------------------------------
-- Variables
---------------------------------------------

Credits = { }
Credits.Visible = false

---------------------------------------------
-- Credits Functions
---------------------------------------------

function Credits.DrawCredits()
	if Credits.Visible then
		_, Credits.Visible = ImGui.Begin("Credits", Credits.Visible, ImVec2(400, 160), -1.0)

		ImGui.Columns(1)
		if ImGui.Button("Homepage", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
			os.execute("start http://tinyurl.com/j95a3ey")
		end
		ImGui.SameLine()
		if ImGui.Button("Changelog", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			os.execute("start http://tinyurl.com/jmdxco3")
		end

		ImGui.Spacing()

		if ImGui.CollapsingHeader("Thanks to...", "id_gui_credits_thanks", true, true) then
			ImGui.Text("...MrUnreal for Player Radar")
			ImGui.Text("...Ghostyweasel for Selective Fishing")
			ImGui.Text("...pat for helping me found and fix a lot of bugs")
			ImGui.Text("...cheebah420 for the support and the very good gold spot")
			ImGui.Text("...MrUnreal and borek24 for make the repair works")
			ImGui.Text("...all donors and supporters!!!")
		end

		ImGui.End()
	end
end

function Credits.OnDrawGuiCallback()
	Credits.DrawCredits()
end