--old.

local yakuza_movement = {}

local rs = game:GetService("ReplicatedStorage")
local cm = rs:WaitForChild("CommonModules")

local vector = require(cm:WaitForChild("Vector"))
local collision = require(cm:WaitForChild("Collision"))
local global_ref = require(cm:WaitForChild("GlobalReference"))

local collision_ref = global_ref:New(workspace, "Level/Map/Collision")

-- Movement interface
function yakuza_movement.Move(self)
    -- Get collision whitelist
    local wl = {workspace.Terrain, collision_ref:Get()}
    
    -- Get global speed
    self.gspd = self:ToGlobal(self.spd) 
    
    -- Get slope factor
    local slope_factor
    
    local gspd_mag = (self.gspd.X * self.gspd.X) + (self.gspd.Z * self.gspd.Z)
    if gspd_mag > 0.001 then
        local mag = math.sqrt(gspd_mag) -- Get XZ magnitude (for division)
        local dot = (self.gspd.X * self.floor_normal.X) + (self.gspd.Z * self.floor_normal.Z) -- Get Y factor
        local dotd = dot / mag
        slope_factor = self.floor_normal.Y / math.sqrt((self.floor_normal.Y * self.floor_normal.Y) + (dotd * dotd)) -- Convert Y factor to XZ factor
    else
        slope_factor = 1
    end
    
    -- Move
    self.pos += self.gspd * Vector3.new(slope_factor, 1, slope_factor)
    
    -- Floor collision
    local hit, pos, nor = collision.Raycast(wl, self.pos + Vector3.new(0, self.p.height, 0), Vector3.new(0, -(self.p.height + (self.flag.grounded and 0.8 or 0)), 0))
    
    if hit then
        self.pos = pos
        self.spd = Vector3.new(self.spd.X, 0, self.spd.Z)
        self.floor_normal = nor
        self.flag.grounded = true
    else
        self.flag.grounded = false
    end
    
    -- Wall collision
    local wall_hit, wall_pos, wall_nor = collision.Raycast(wl, self.pos, self.spd)
    
    if wall_hit then
        self.pos = wall_pos
        self.spd = Vector3.new(0, self.spd.Y, 0)
    end
end

return yakuza_movement
