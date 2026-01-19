AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Server-side initialization function for the Entity
function ENT:Initialize()
    self:SetModel( "models/props_wasteland/gaspump001a.mdl" ) -- Sets the model for the Entity.
    self:PhysicsInit( SOLID_VPHYSICS ) -- Initializes physics for the Entity, making it solid and interactable.
    self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the Entity moves, using physics.
    self:SetSolid( SOLID_VPHYSICS ) -- Makes the Entity solid, allowing for collisions.
    local phys = self:GetPhysicsObject() -- Retrieves the physics object of the Entity.
    if phys:IsValid() then -- Checks if the physics object is valid.
        phys:Wake() -- Activates the physics object, making the Entity subject to physics (gravity, collisions, etc.).
    end

    local handleOffset = Vector( 0, -18, 48 )
    local angleOffset = Angle( 0, 270, 0 )

    self.Handle = ents.Create( "ramsay_gaspump_handle" )
    self.Handle:SetPos( self:LocalToWorld( handleOffset ) )
    self.Handle:SetAngles( self:GetAngles() + angleOffset )
    self.Handle:SetParent( self )
    self.Handle:Spawn()
    self.Handle.Pump = self

    self:DeleteOnRemove( self.Handle )


    -- after BOTH entities are spawned
    constraint.Rope(
        self,               -- Entity 1 (pump)
        self.Handle,        -- Entity 2 (handle)
        0,                  -- Bone on entity 1 (0 = root)
        0,                  -- Bone on entity 2
        Vector(0, -18, 57), -- Local offset on pump
        Vector(9, 0, -6),    -- Local offset on handle
        60,                 -- Rope length
        200,                  -- Add length
        0,                  -- Force limit (0 = unbreakable)
        1.5,                  -- Width
        "cable/cable2",     -- Material
        false               -- Rigid
    )
end
