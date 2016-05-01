---------------------------------------------
-- Variables
---------------------------------------------

Radar = { }
Radar.Visible = false

ShowMeters = true
ShowYards = false

ShowTraceline = false
ShowPlayers = true
ShowMonsters = false
ShowVehicles = false
ShowNpcs = false

---------------------------------------------
-- Radar Functions
---------------------------------------------

function Radar.DrawRadar()
	if Radar.Visible then
		_, Radar.Visible = ImGui.Begin("Radar", Radar.Visible, ImVec2(600, 400), -1.0)

		if ImGui.CollapsingHeader("Settings", "id_gui_radar_settings", true, true) then
			_, ShowTraceline = ImGui.Checkbox("##id_guid_radar_settings_drawlines", ShowTraceline)
			ImGui.SameLine()
			ImGui.Text("Draw lines")

			ImGui.SameLine()
			_, ShowMeters = ImGui.Checkbox("##id_guid_radar_settings_usemeters", ShowMeters)
			ImGui.SameLine()
			ImGui.Text("Use meters")

			ImGui.SameLine()
			_, ShowYards = ImGui.Checkbox("##id_guid_radar_settings_useyards", ShowYards)
			ImGui.SameLine()
			ImGui.Text("Use yards")

			if ImGui.CollapsingHeader("Filters", "id_guid_radar_filters", true, false) then
				_, ShowPlayers = ImGui.Checkbox("##id_guid_radar_filters_player", ShowPlayers)
				ImGui.SameLine()
				ImGui.Text("Show Players")

				ImGui.SameLine()
				_, ShowMonsters = ImGui.Checkbox("##id_guid_guid_radar_filters_monster", ShowMonsters)
				ImGui.SameLine()
				ImGui.Text("Show Monsters")

				ImGui.SameLine()
				_, ShowVehicles = ImGui.Checkbox("##id_guid_radar_filters_vehicle", ShowVehicles)
				ImGui.SameLine()
				ImGui.Text("Show Vehicles")

				ImGui.SameLine()
				_, ShowNpcs = ImGui.Checkbox("##id_guid_radar_filters_npc", ShowNpcs)
				ImGui.SameLine()
				ImGui.Text("Show NPCs")
			end
		end

		local characters = GetActors()
		local selfPlayer = GetSelfPlayer()

		ImGui.Columns(3)
		ImGui.Separator()
		ImGui.Text("Name")
		ImGui.NextColumn()
		ImGui.Text("Distance")
		ImGui.NextColumn()
		ImGui.Text("Information")
		ImGui.NextColumn()
		ImGui.Separator()

		for k,v in pairs(characters, function(t,a,b) return t[a].Position.Distance3DFromMe < t[b].Position.Distance3DFromMe end) do  -- sort by distance
			local useMeters = tostring(math.floor(math.floor(v.Position.Distance3DFromMe) * 0.009144))
			local useYards = tostring(math.floor(v.Position.Distance3DFromMe))

			if
				(v.IsPlayer and ShowPlayers and v.Name ~= selfPlayer.Name) or
				(v.IsMonster and ShowMonsters) or
				(v.IsVehicle and ShowVehicles) or
				(v.IsNpc and ShowNpcs)
			then
				if v.IsPlayer then
					ImGui.TextColored(ImVec4(0.20,1,0.20,1), "[P]") -- green
					ImGui.SameLine()
					ImGui.Text(v.Name)
				elseif v.IsMonster then
					ImGui.TextColored(ImVec4(1,0.20,0.20,1), "[M]") -- red
					ImGui.SameLine()
					ImGui.Text(v.Name)
				elseif v.IsVehicle then
					ImGui.TextColored(ImVec4(1,1,0.20,1), "[V]") -- yellow
					ImGui.SameLine()
					ImGui.Text(v.Name)
				elseif v.IsNpc then
					ImGui.TextColored(ImVec4(0.50,0.20,0.50,1), "[N]") -- purple
					ImGui.SameLine()
					ImGui.Text(v.Name)
				else
					ImGui.SameLine()
					ImGui.Text("[?]" .. v.Name)
				end
				ImGui.NextColumn()

				if ShowMeters then
					ImGui.Text(useMeters .. " meters")
				elseif ShowYards then
					ImGui.Text(useYards .. " yards")
				end
				ImGui.NextColumn()

				if ImGui.CollapsingHeader("More info", tostring(v.Key)) then
					if Bot.EnableDebug and Bot.EnableDebugRadar then
						ImGui.Text("Pointer :")
						ImGui.SameLine();
						ImGui.Text(v.Pointer)

						ImGui.Text("Key :")
						ImGui.SameLine();
						ImGui.Text(v.Key)

						ImGui.Text("Action :")
						ImGui.SameLine();
						ImGui.Text(v.CurrentActionName)

						ImGui.Text("Health :")
						ImGui.SameLine();
						ImGui.Text(tostring(v.Health) .. " / " .. tostring(v.MaxHealth))

						ImGui.Text("CanAttack :")
						ImGui.SameLine();
						ImGui.Text(tostring(v.CanAttack))

						ImGui.Text("Interactable :")
						ImGui.SameLine();
						ImGui.Text(tostring(v.IsInteractable))

						ImGui.Text("IsLootInteraction :")
						ImGui.SameLine();
						ImGui.Text(tostring(v.IsLootInteraction))

						ImGui.Text("BodySize :")
						ImGui.SameLine();
						ImGui.Text(tostring(v.BodySize))

						ImGui.Text("BodyHeight :")
						ImGui.SameLine();
						ImGui.Text(tostring(v.BodyHeight))

						ImGui.Text("Tribe :")
						ImGui.SameLine();
						ImGui.Text(tostring(v.CharacterStaticStatus.TribeType))
					else
						ImGui.Text("Action:")
						ImGui.SameLine();
						ImGui.Text(v.CurrentActionName)

						if not v.IsVehicle then
							ImGui.Text("Health:")
							ImGui.SameLine();
							ImGui.Text(tostring(v.Health) .. "/" .. tostring(v.MaxHealth))
						end
					end
				end
				ImGui.NextColumn()
			end
		end
		ImGui.End()
	end
end

function Radar.OnRender3D()
	if ShowTraceline then
		local characters = GetActors()
		local selfPlayer = GetSelfPlayer()
		local linesList = { }
		local count = 0

		for k,v in pairs(characters, function(t,a,b) return t[a].Position.Distance3DFromMe < t[b].Position.Distance3DFromMe end) do
			local distance = v.Position.Distance3DFromMe
			local color = 0xFFFF0000

			if distance < 1000 then
				color = 0xFFFF0000 -- Red
			elseif distance < 2000 then
				color = 0xFFFFFF00 -- Yellow
			else
				color = 0xFF00FF00 -- Green
			end

			table.insert(linesList,{selfPlayer.Position.X,selfPlayer.Position.Y+150,selfPlayer.Position.Z,color})

			if v.IsPlayer and ShowPlayers then
				table.insert(linesList,{v.Position.X,v.Position.Y+150,v.Position.Z,color})
			elseif v.IsMonster and ShowMonsters then
				table.insert(linesList,{v.Position.X,v.Position.Y+150,v.Position.Z,color})
			elseif v.IsVehicle and ShowVehicles then
				table.insert(linesList,{v.Position.X,v.Position.Y+150,v.Position.Z,color})
			elseif v.IsNpc and ShowNpcs then
				table.insert(linesList,{v.Position.X,v.Position.Y+150,v.Position.Z,color})
			end

			count = count + 1
		end

		if count > 0 then
			Renderer.Draw3DLinesList(linesList)
		end
	end
end

function Radar.OnDrawGuiCallback()
	Radar.DrawRadar()
end