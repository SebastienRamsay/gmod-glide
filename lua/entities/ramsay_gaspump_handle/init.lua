AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Server-side initialization function for the Entity
function ENT:Initialize()
    self:SetModel( "models/ramsay/gas-pump.mdl" ) -- Sets the model for the Entity.
    self:PhysicsInit( SOLID_VPHYSICS ) -- Initializes physics for the Entity, making it solid and interactable.
    self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the Entity moves, using physics.
    self:SetSolid( SOLID_VPHYSICS ) -- Makes the Entity solid, allowing for collisions.
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject() -- Retrieves the physics object of the Entity.
    if phys:IsValid() then -- Checks if the physics object is valid.
        phys:Wake() -- Activates the physics object, making the Entity subject to physics (gravity, collisions, etc.).
    end

    self.NextFuel = CurTime() + 0.1
end

function ENT:Use( ply )
    if not IsValid( ply ) then return end
    self:Pickup( ply )
end

function ENT:Pickup( ply )
    if IsValid( self.HeldBy ) then return end

    self:SetSolid( SOLID_NONE )
    self:SetParent( ply )
    self:FollowBone( ply, ply:LookupBone( "ValveBiped.Bip01_Head1" ) )

    -- Set local offset / rotation
    self:SetLocalPos( Vector( 15, 0, 15 ) )
    self:SetLocalAngles( Angle( 20, 180, 230 ) )

    self.HeldBy = ply
    ply.FuelHandle = self
end

function ENT:PutAway()
    if not IsValid( self.Pump ) then return end
    self:SetSolid( SOLID_VPHYSICS )
    self.HeldBy.FuelHandle = nil
    self.HeldBy = nil
    self:FollowBone( nil )
    self:SetParent( self.Pump )
    self:SetPos( Vector( 0, -18, 48 ) )
    local angleOffset = Angle( 0, 270, 0 )
    self:SetAngles( self.Pump:GetAngles() + angleOffset )
end

-- Fueling logic
function ENT:Think()
    local ply = self.HeldBy
    if not IsValid(ply) then
        self.HeldBy = nil
        return
    end

    -- Auto put away if too far from pump
    if IsValid( self.Pump ) and self:GetPos():Distance( self.Pump:GetPos() ) >= 200 then
        self:PutAway()
        return
    end

    -- Put away on right click
    if ply:KeyDown( IN_ATTACK2 ) then
        self:PutAway()
        return
    end

    -- Fueling
    if not ply:KeyDown( IN_ATTACK ) then return end
    if self.NextFuel > CurTime() then return end
    self.NextFuel = CurTime() + 0.1

    local tr = util.TraceLine({
        start  = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 50,
        filter = { self, ply }
    })

    local car = tr.Entity
    if not IsValid(car) then return end
    if car.Base ~= "base_glide_car" then return end
    if not car.GetFuel or not car.SetFuel then return end

    local fuel = car:GetFuel()
    local maxFuel = car.GetMaxFuel and car:GetMaxFuel() or 100
    if fuel < maxFuel then
        local newFuel = math.min(fuel + 1, maxFuel)
        car:SetFuel(newFuel)
        ply:ChatPrint("Fuel Added: " .. math.floor(newFuel))
    end

    self:NextThink(CurTime())
    return true
end
