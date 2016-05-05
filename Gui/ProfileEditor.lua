-----------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

ProfileEditor = { }
ProfileEditor.Visible = false
ProfileEditor.CurrentProfile = Profile()
ProfileEditor.AvailablesProfilesSelectedIndex = 0
ProfileEditor.AvailablesProfiles = { }
ProfileEditor.CurrentProfileSaveName = "Unamed"

-----------------------------------------------------------------------------
-- ProfileEditor Functions
-----------------------------------------------------------------------------

function ProfileEditor.DrawProfileEditor()
	if ProfileEditor.Visible then
		_, ProfileEditor.Visible = ImGui.Begin("Profile editor", ProfileEditor.Visible, ImVec2(300, 400), -1.0, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoResize)

		_, ProfileEditor.CurrentProfileSaveName = ImGui.InputText("##id_guid_profile_save_name", ProfileEditor.CurrentProfileSaveName)
		ImGui.SameLine()
		if ImGui.Button("Save") then
			ProfileEditor.SaveProfile(ProfileEditor.CurrentProfileSaveName)
		end

		_, ProfileEditor.AvailablesProfilesSelectedIndex = ImGui.Combo("##id_guid_profile_load_combo", ProfileEditor.AvailablesProfilesSelectedIndex, ProfileEditor.AvailablesProfiles)
		ImGui.SameLine()
		if ImGui.Button("Load") then
			ProfileEditor.LoadProfile(ProfileEditor.AvailablesProfiles[ProfileEditor.AvailablesProfilesSelectedIndex])
		end

		if ImGui.Button("Clear profile##id_guid_profile_clear", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Navigation.ClearMesh()
			ProfileEditor.CurrentProfile = Profile()
			ProfileEditor.CurrentProfileSaveName = "Unamed"
		end

		if ImGui.CollapsingHeader("Mesher", "id_gui_profile_editor_mesh", true, true) then
			_,Navigation.MesherEnabled = ImGui.Checkbox("Enable mesher##id_guid_profile_enable_mesher", Navigation.MesherEnabled)
			ImGui.SameLine();
			_,Navigation.RenderMesh = ImGui.Checkbox("Draw geometry##id_guid_profile_draw_mesher", Navigation.RenderMesh)
			if ImGui.Button("Build navigation##id_guid_profile_editor_build_navigation", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				Navigation.BuildNavigation()
			end
		end

		if ImGui.CollapsingHeader("Fishing spot", "id_gui_profile_editor_fishing_spot", true, false) then
			if ProfileEditor.CurrentProfile:HasFishSpot() then
				ImGui.Text("Distance: " .. math.floor(ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe) / 100)
			else
				ImGui.Text("Distance: Not set")
			end
			if ImGui.Button("Set##id_guid_profile_set_fishing_spot" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2.08, 20)) then
				local selfPlayer = GetSelfPlayer()
				if selfPlayer then
					ProfileEditor.CurrentProfile.FishSpotPosition.X = selfPlayer.Position.X
					ProfileEditor.CurrentProfile.FishSpotPosition.Y = selfPlayer.Position.Y
					ProfileEditor.CurrentProfile.FishSpotPosition.Z = selfPlayer.Position.Z
					ProfileEditor.CurrentProfile.FishSpotRotation = selfPlayer.Rotation
				end
			end
			ImGui.SameLine()
			if ImGui.Button("Clear##id_guid_profile_clear_fishing_spot", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				ProfileEditor.CurrentProfile.FishSpotPosition.X = 0
				ProfileEditor.CurrentProfile.FishSpotPosition.Y = 0
				ProfileEditor.CurrentProfile.FishSpotPosition.Z = 0
				ProfileEditor.CurrentProfile.FishSpotRotation = 0
			end
		end

		if ImGui.CollapsingHeader("Trade Manager NPC", "id_gui_profile_editor_trademanager", true, false) then
			if string.len(ProfileEditor.CurrentProfile.TradeManagerNpcName) > 0 then
				ImGui.Text("Name: " .. ProfileEditor.CurrentProfile.TradeManagerNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetTradeManagerPosition().Distance3DFromMe / 100) .. " y)")
			else
				ImGui.Text("Name: Not set")
			end
			if ImGui.Button("Set##id_guid_profile_set_trademanager" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2.08, 20)) then
				local npcs = GetNpcs()
				if table.length(npcs) > 0 then
					local TradeManagerNpc = npcs[1]
					ProfileEditor.CurrentProfile.TradeManagerNpcName = TradeManagerNpc.Name
					ProfileEditor.CurrentProfile.TradeManagerNpcPosition.X = TradeManagerNpc.Position.X
					ProfileEditor.CurrentProfile.TradeManagerNpcPosition.Y = TradeManagerNpc.Position.Y
					ProfileEditor.CurrentProfile.TradeManagerNpcPosition.Z = TradeManagerNpc.Position.Z
				end
			end
			ImGui.SameLine()
			if ImGui.Button("Clear##id_guid_profile_clear_trademanager", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				ProfileEditor.CurrentProfile.TradeManagerNpcName = ""
				ProfileEditor.CurrentProfile.TradeManagerNpcPosition.X = 0
				ProfileEditor.CurrentProfile.TradeManagerNpcPosition.Y = 0
				ProfileEditor.CurrentProfile.TradeManagerNpcPosition.Z = 0
			end
		end

		if ImGui.CollapsingHeader("Vendor NPC", "id_guid_profile_editor_vendor", true, false) then
			if string.len(ProfileEditor.CurrentProfile.VendorNpcName) > 0 then
				ImGui.Text("Name: " .. ProfileEditor.CurrentProfile.VendorNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetVendorPosition().Distance3DFromMe / 100) .. "y)")
			else
				ImGui.Text("Name: Not set")
			end

			if ImGui.Button("Set##id_guid_profile_set_vendor" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2.08, 20)) then
				local npcs = GetNpcs()
				if table.length(npcs) > 0 then
					local VendorNpc = npcs[1]
					ProfileEditor.CurrentProfile.VendorNpcName = VendorNpc.Name
					ProfileEditor.CurrentProfile.VendorNpcPosition.X = VendorNpc.Position.X
					ProfileEditor.CurrentProfile.VendorNpcPosition.Y = VendorNpc.Position.Y
					ProfileEditor.CurrentProfile.VendorNpcPosition.Z = VendorNpc.Position.Z
				end
			end
			ImGui.SameLine()
			if ImGui.Button("Clear##id_guid_profile_clear_vendor", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				ProfileEditor.CurrentProfile.VendorNpcName = ""
				ProfileEditor.CurrentProfile.VendorNpcPosition.X = 0
				ProfileEditor.CurrentProfile.VendorNpcPosition.Y = 0
				ProfileEditor.CurrentProfile.VendorNpcPosition.Z = 0
			end
		end

		if ImGui.CollapsingHeader("Repair NPC", "id_gui_profile_editor_repair", true, false) then
		    if string.len(ProfileEditor.CurrentProfile.RepairNpcName) > 0 then
		        ImGui.Text("Name: " .. ProfileEditor.CurrentProfile.RepairNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetRepairPosition().Distance3DFromMe / 100) .. "y)")
		    else
		        ImGui.Text("Name: Not set")
		    end

		    if ImGui.Button("Set##id_guid_profile_set_repair" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
		        local npcs = GetNpcs()
		        if table.length(npcs) > 0 then
		            local RepairNpc = npcs[1]
		            ProfileEditor.CurrentProfile.RepairNpcName = RepairNpc.Name
		            ProfileEditor.CurrentProfile.RepairNpcPosition.X = RepairNpc.Position.X
		            ProfileEditor.CurrentProfile.RepairNpcPosition.Y = RepairNpc.Position.Y
		            ProfileEditor.CurrentProfile.RepairNpcPosition.Z = RepairNpc.Position.Z
		        end
		    end

		    ImGui.SameLine()
		    if ImGui.Button("Clear##id_guid_profile_clear_repair", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
		        ProfileEditor.CurrentProfile.RepairNpcName = ""
		        ProfileEditor.CurrentProfile.RepairNpcPosition.X = 0
		        ProfileEditor.CurrentProfile.RepairNpcPosition.Y = 0
		        ProfileEditor.CurrentProfile.RepairNpcPosition.Z = 0
		    end
		end

		if ImGui.CollapsingHeader("Warehouse NPC", "id_guid_profile_editor_warehouse", true, false) then
			if string.len(ProfileEditor.CurrentProfile.WarehouseNpcName) > 0 then
				ImGui.Text("Name: " .. ProfileEditor.CurrentProfile.WarehouseNpcName .. " (" .. math.floor(ProfileEditor.CurrentProfile:GetWarehousePosition().Distance3DFromMe / 100) .. " y)")
			else
				ImGui.Text("Warehouse: Not set")
			end

			if ImGui.Button("Set##id_guid_profile_set_warehouse" , ImVec2(ImGui.GetContentRegionAvailWidth() / 2.08, 20)) then
				local npcs = GetNpcs()
				if table.length(npcs) > 0 then
					local WarehouseNpc = npcs[1]
					ProfileEditor.CurrentProfile.WarehouseNpcName = WarehouseNpc.Name
					ProfileEditor.CurrentProfile.WarehouseNpcPosition.X = WarehouseNpc.Position.X
					ProfileEditor.CurrentProfile.WarehouseNpcPosition.Y = WarehouseNpc.Position.Y
					ProfileEditor.CurrentProfile.WarehouseNpcPosition.Z = WarehouseNpc.Position.Z
				end
			end
			ImGui.SameLine()

			if ImGui.Button("Clear##id_guid_profile_clear_warehouse", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				ProfileEditor.CurrentProfile.WarehouseNpcName = ""
				ProfileEditor.CurrentProfile.WarehouseNpcPosition.X = 0
				ProfileEditor.CurrentProfile.WarehouseNpcPosition.Y = 0
				ProfileEditor.CurrentProfile.WarehouseNpcPosition.Z = 0
			end
		end

		ImGui.End()
	end
end

function ProfileEditor.RefreshAvailableProfiles()
	ProfileEditor.AvailablesProfiles = { }
	for k,v in pairs(Pyx.FileSystem.GetFiles("Profiles\\*.json")) do
		v = string.gsub(v, ".json", "")
		table.insert(ProfileEditor.AvailablesProfiles, v)
	end
end

function ProfileEditor.SaveProfile(name)
	local profileFilename = "\\Profiles\\" .. name .. ".json"
	local meshFilename = "\\Profiles\\" .. name .. ".mesh"
	local objFilename = "\\Profiles\\" .. name .. ".obj"

	--Navigation.ExportWavefrontObject(objFilename)

	print("[" .. os.date(Bot.UsedTimezone) .. "] Save mesh : " .. meshFilename)
	if not Navigation.SaveMesh(meshFilename) then
		print("[" .. os.date(Bot.UsedTimezone) .. "] Unable to save .mesh !")
		return
	end

	Bot.Settings.LastProfileName = name

	local json = JSON:new()
	Pyx.FileSystem.WriteFile(profileFilename, json:encode_pretty(ProfileEditor.CurrentProfile))
	ProfileEditor.RefreshAvailableProfiles()
end

function ProfileEditor.LoadProfile(name)
	local profileFilename = "\\Profiles\\" .. name .. ".json"
	local meshFilename = "\\Profiles\\" .. name .. ".mesh"

	print("[" .. os.date(Bot.UsedTimezone) .. "] Load mesh : " .. meshFilename)
	if not Navigation.LoadMesh(meshFilename) then
		print("[" .. os.date(Bot.UsedTimezone) .. "] Unable to load .mesh !")
		return
	end

	Bot.Settings.LastProfileName = name
	ProfileEditor.CurrentProfileSaveName = name

	ProfileEditor.AttackableMonstersSelectedIndex = 0
	ProfileEditor.AttackableMonstersComboSelectedIndex = 0

	local json = JSON:new()
	ProfileEditor.CurrentProfile = Profile()
	table.merge(ProfileEditor.CurrentProfile, json:decode(Pyx.FileSystem.ReadFile(profileFilename)))
end

function ProfileEditor.OnDrawGuiCallback()
	ProfileEditor.DrawProfileEditor()
end

function ProfileEditor.OnRender3D()
	if Navigation.RenderMesh then
		local selfPlayer = GetSelfPlayer()
		if ProfileEditor.CurrentProfile:HasFishSpot() then
			Renderer.Draw3DTrianglesList(GetInvertedTriangleList(ProfileEditor.CurrentProfile.FishSpotPosition.X, ProfileEditor.CurrentProfile.FishSpotPosition.Y + 100, ProfileEditor.CurrentProfile.FishSpotPosition.Z, 20, 50, 0xAAFF0000, 0xAAFF00FF))
		end
	end
end

ProfileEditor.RefreshAvailableProfiles()

if table.length(ProfileEditor.AvailablesProfiles) > 0 then
	ProfileEditor.AvailablesProfilesSelectedIndex = 1
end