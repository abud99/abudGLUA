FIGHT_CONFIG =
{
	["CONFIG"] = "Test",
	["Author"] = "abudzie",
	["Description"] = "Type fight then a players name"
}

// map name, Vector1 pos, Vector2 pos,
FIGHT_COORDINATES =
{
	["gm_flatgrass"] =  {Vector(8, 904, -12735), Vector(-3, -966, -12735)},
	["gm_construct"] =  {Vector(8, 904, -12735), Vector(-3, -966, -12735)},
}

FIGHT_WEAPON = 
{

}


FIGHT_ONLY_ADMIN = false


FIGHT_DUEL_TYPE =
{

}

function mapCheck(key)
    return FIGHT_COORDINATES[key]!=nil
end


local p = FindMetaTable("Player")
function p:IsDuel()
		return self:GetNWBool("duelState")
	end

function p:setDuel(b)
	self:SetNWBool("duelState", b)
end
