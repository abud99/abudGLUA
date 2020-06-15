//PrintTable(FIGHT_CONFIG)

-- concommand.Add("cancelfight", cancel)
-- function cancel(ply, cmd, args)
-- 	if ply:IsValid() then
-- 		net.Start("CancelDuelManual")
-- 		net.SendToServer()
-- 	end
-- end



function getUserID(str)
	if string.len(str)  == 1 then
		return string.Right(str, 1)
	else
		return string.Right(str, 2)
	end
end


net.Receive("DuelMenu", 
	function()
		local ply = LocalPlayer()
		for k, v in pairs (player.GetAll()) do
			print(v:GetNWBool("duelState"))
		end
		if (!DuelMenu) then
			if !ply:Alive() then return end
			local DuelMenu = vgui.Create("DFrame")
			count = 0
			DuelMenu:SetTitle("Duel Menu")
			DuelMenu:SetSize(700, 400)
			DuelMenu:Center()
			DuelMenu:SetVisible(true)
			DuelMenu:MakePopup()
			DuelMenu:SetDraggable(true)
			local comboBox = vgui.Create("DComboBox", DuelMenu)
			comboBox:SetPos(500, 300)
			comboBox:SetSize(100, 20)
			local TextEntry = vgui.Create( "DTextEntry", DuelMenu ) -- create the form as a child of frame
			TextEntry:SetPos( 25, 30 )
			TextEntry:SetSize( 80, 20 )
			TextEntry:SetValue( "None selected" )
			TextEntry:SetEditable(false)
			comboBox:SetValue("Fuck my life")
			for k,v in pairs(player.GetAll()) do
				if v:UserID() == LocalPlayer():UserID() then continue end 
				comboBox:AddChoice(v:Name() .. " " .. v:UserID(),nil, false)
			end
			local b2 = vgui.Create("DButton", DuelMenu)
			b2:SetText("Set Position")
			b2:SetPos(150, 50)
			b2:SetSize(100, 30)
			b2.DoClick = function()
				if count == 0 then
					x = LocalPlayer():GetPos()
					count = count + 1
				elseif count == 1 then
					y = LocalPlayer():GetPos()
					net.Start("SendCoordinates")
					net.WriteVector(x)
					net.WriteVector(y)
					net.SendToServer()
					chat.AddText(Color(255, 0, 0), "Positions sets")
				else
					print("Something went wrong - Client side")
				end
			end

			function comboBox:OnSelect(index, text, data)
				local storec = comboBox:GetSelected()
				local userIDc = tonumber(getUserID(storec))
				print(string.len(userIDc))
				local targetc = Player(userIDc)
				if targetc:GetNWBool("duelState") then
					TextEntry:SetTextColor(Color(255, 0, 0))
					TextEntry:SetValue( tostring(targetc:GetNWBool("duelState")) )
				else
					TextEntry:SetTextColor(Color(0, 255, 0))
					TextEntry:SetValue( tostring(targetc:GetNWBool("duelState")) )
				end
			end

			local DermaButton = vgui.Create( "DButton", DuelMenu )
			DermaButton:SetText( "Duel" )					
			DermaButton:SetPos( 25, 50 )					
			DermaButton:SetSize( 100, 30 )					
			DermaButton.DoClick = function()
				if table.getn(player.GetAll()) < 2 then print ("Minimum number of players not met") return end
				if comboBox:GetSelected() == nil then return end	
					store = comboBox:GetSelected()
					userID = tonumber(getUserID(store))
					target = Player(userID)
					if target:IsDuel() then print("Target in duel") return end
					if !ply:Alive() then print ("Need to be alive") return end
					if x == nil && y == nil then print("Set coordinates first") return end
					if target:IsValid() && target:Alive() && !ply:IsDuel()  then
							net.Start("SpawnProps")
							net.WriteInt(userID, 8)
							net.SendToServer()
							x = nil
							y = nil
						else
							print("You are in a duel")
					end
													
			end
		end //button end






	end
)




-- concommand.Add("fight", streetClub)
-- function streetClub(ply, cmd, args)
-- 	if !mapCheck(game.GetMap()) then print("Not a supported map") return end
-- 	if !ply:Alive() then print ("Need to be alive") return end
-- 	if currentDuel == true then print("Duel in progress") return end
-- 	second = args[1]
-- 	if second != nil then
-- 		for k, v in pairs(player.GetAll()) do
-- 			if tonumber(second) == v:UserID() && v:IsValid() && v:Alive() then
-- 					net.Start("SpawnProps")
-- 					net.WriteInt(v:UserID(), 8)
-- 					chat.AddText( Color( 100, 100, 255 ), "You are now challenging ", v:Nick(), Color(255, 0, 0) )
-- 					net.SendToServer()
-- 					break
-- 			end
-- 		end
-- 	else
-- 		print("No args given")

-- 	end
-- end



