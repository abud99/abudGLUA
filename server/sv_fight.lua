function addNetworkStrings(tab)
	for k,v in pairs(tab) do
		util.AddNetworkString(v)
	end
end
networkStrings = {"SpawnProps", "DuelState", "DuelMenu", "CancelDuelManual", "SendCoordinates"}
addNetworkStrings(networkStrings)






hook.Add("PlayerInitialSpawn", "GiveDuelBoolean", function(ply)
	ply:SetNWBool( "duelState", false )
	ply:SetNWEntity("Dueled", nil)
end)


hook.Add("PlayerDisconnected", "removeDuelState", function(ply)
		ply:SetNWBool( "duelState", false)
		ply:SetNWEntity("Dueled", nil)
		if ply:IsDuel() then
			local opp = ply:GetNWEntity("Dueled")
			if opp:IsValid() then
				opp:setDuel(false)
			end
		end
		
	end)


hook.Add( "PlayerDeath", "CancelDuel", function( victim, inflictor, attacker )
		victim:SetNWBool( "duelState", false)
		victim:SetNWBool("Dueled", nil)
		if attacker:IsDuel() then
			attacker:setDuel(false)
			attacker:SetNWEntity("Dueled", nil)
			attacker:Spawn()
			//victim:setDuel(false)
			//local d = victim:GetNWEntity("Dueled")
			//d:setDuel(false)
		else
			print("....")
		end
		if timerNick(victim, "DuelTimer") then timer.Remove(victim:Nick() .. "DuelTimer") end
		if timerNick(attacker, "DuelTimer") then timer.Remove(attacker:Nick() .. "DuelTimer") end
end )


for k, v in pairs(player.GetAll()) do
	//print(v:Nick())
	if v:GetNWEntity("Dueled"):IsValid() then
		print( v:Nick().." His opponent " .. v:GetNWEntity("Dueled"):Nick())
	end
end


print("Server side loaded")

net.Receive("SpawnProps", function(len, main)
	ag = net.ReadInt(8)
	versus = Player(ag)
	main:SetNWEntity("Dueled", versus)
	versus:SetNWEntity("Dueled", main)
	versus:PrintMessage( HUD_PRINTTALK, "Being challenged by " .. main:Nick() )
	PrepareDuel(main, versus)
	hook.Add("PlayerDisconnected", "NetDuelState", function(ply)
		if ply == main then
			versus:SetNWBool( "duelState", false)
		end
		if ply == versus then
			main:SetNWBool( "duelState", false)
		end
		if timerNick(ply, "DuelTimer") then
			timer.Remove(ply:Nick() .. "DuelTimer")
		end
	end)


-- hook.Add( "PlayerDeath", "CancelDuelGhettoFix", 
-- 	function( victim, inflictor, attacker )
-- 		if victim == versus || victim == main then
-- 			victim:SetNWBool("duelState", false)
-- 		end
-- 	end)
end) // end of net



hook.Add("ShowSpare2", "OpenDuelMenu", 
	function(ply)
		if FIGHT_ONLY_ADMIN then
			if !ply:IsAdmin() then return end
				net.Start("DuelMenu")
				net.Send(ply)
		else
			net.Start("DuelMenu")
			net.Send(ply)
		end
	end)






-- hook.Add( "CanPlayerSuicide", "AllowOwnerSuicide", function( ply )
-- 	if ply:GetNWBool("duelState") then ply:PrintMessage( HUD_PRINTTALK, "Can't kill yourself while in a duel" ) return false end
-- end )


hook.Add("EntityTakeDamage", "Negate", function(target,  dmginfo)
	if dmginfo:IsFallDamage() then return end 
	if dmginfo:GetAttacker() != target:GetNWEntity("Dueled") then dmginfo:SetDamage(0) end
	if target:IsDuel() && dmginfo:GetAttacker():GetNWBool("duelState") == false then
		dmginfo:SetDamage(0)
	end
	
end)



hook.Add("ShowSpare2", "SendDuelMenuOpen", sendDuelState)

function timerNick(main, timerName)
	if main:IsValid() then
 		return timer.Exists(main:Nick() .. timerName )
 	end
 end


function createTimer(main, delay, rep, func)
	if main:IsValid() then
		timer.Create(main:Nick() .. "DuelTimer", delay, rep, func)
	end
end

function PrepareDuel(main, versus, weapon)
	net.Receive("SendCoordinates", function(len, ply)
		pos1 = net.ReadVector()
		pos2 = net.ReadVector()
	end)
	if pos1 == nil || pos2 == nil then print("Something went wrong") return end
		if versus:IsValid() && main:IsValid() && versus:IsPlayer() && main:IsPlayer() then
		main:SetNWBool( "duelState", true )
		versus:SetNWBool( "duelState", true )	
	end
	print(pos1)
	print(pos2)
	weapon = weapon or "weapon_357"
	main:StripWeapons()
	main:StripAmmo()
	main:Give(weapon, false)
	if main:GetActiveWeapon():IsValid() && main:Alive() then
		main:GetActiveWeapon():SetClip1(1)
	end
	versus:StripWeapons()
	versus:StripAmmo()
	versus:Give(weapon, false)
	if versus:GetActiveWeapon():IsValid() && versus:Alive() then
		versus:GetActiveWeapon():SetClip1(1)
	end
	main:SetPos(pos1)
	versus:SetPos(pos2)
	main:GodDisable()
	versus:GodDisable()
	local count = 5;
	createTimer(main, 1, 5, function() count = count - 1 print(count) end)
	hook.Add("Think", "ThinkDuel", 
		function()
			if (timerNick(main, "DuelTimer")) then
				if main:IsValid() && versus:IsValid() then
					main:Freeze(true)
					versus:Freeze(true)
				end
			else
				if main:IsValid() && versus:IsValid() then
					main:Freeze(false)
					versus:Freeze(false)
					suddenDeath(main, versus)
			end
		end
	end)
	PrintMessage(HUD_PRINTTALK, "Duel now starting between " .. main:Nick() .. " and " .. versus:Nick())

end


function suddenDeath(main, versus)
	if main:GetNWBool( "duelState" ) == true && versus:GetNWBool( "duelState" ) == true then
		if main:GetActiveWeapon():Clip1() == 0 && versus:GetActiveWeapon():Clip1() == 0 then
			main:GetActiveWeapon():SetClip1(1)
			versus:GetActiveWeapon():SetClip1(1)
		end
	end
end



-- net.Receive("CancelDuelManual", 
-- 	function(len, ply)
-- 		duel = false
-- 	end)


