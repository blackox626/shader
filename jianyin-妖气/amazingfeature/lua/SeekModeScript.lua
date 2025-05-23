--@input float curTime = 0.0{"widget":"slider","min":0,"max":3.0}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.width = 0
    self.height = 0
    self.mEntities = {}
    self.renderTargets = {}
    self.count = 0
    return self
end

function SeekModeScript:constructor()

end

function SeekModeScript:onUpdate(comp, detalTime)
    self:seekToTime(comp, self.curTime - self.startTime)
end

function SeekModeScript:onStart(comp)
    -- self.animSeqCom = comp.entity:getComponent("AnimSeqComponent")
    self.pass0Material = comp.entity:getComponent("MeshRenderer").material
    self.pass1Material = comp.entity.scene:findEntityBy("Pass1"):getComponent("MeshRenderer").material
    self.pass2Material = comp.entity.scene:findEntityBy("Pass2"):getComponent("MeshRenderer").material
    for i=1,6 do
        local ii = i+2
        self.mEntities[i] = comp.entity.scene:findEntityBy("CameraPass"..ii)
        self.renderTargets[i] = self.mEntities[i]:getComponent("Camera").renderTexture
    end
end

function SeekModeScript:seekToTime(comp, time)
        for i=1,#self.mEntities do
            self.mEntities[i].visible = false
        end
        local id = (self.count+1)%2
        for i=1,3 do
            local j = i*2-id
            self.mEntities[j].visible = true
            self.renderTargets[(self.count%2)+1+(i-1)*2] = self.mEntities[j]:getComponent("Camera").renderTexture
        end

        self.pass0Material:setTex("inputImageTextureLast",self.renderTargets[(self.count+1)%2+5])
        self.pass1Material:setTex("sourceTex1",self.renderTargets[(self.count+1)%2+1])
        self.pass1Material:setTex("solverTex",self.renderTargets[(self.count+1)%2+3])
        self.count = self.count+1

    local w = Amaz.BuiltinObject:getInputTextureWidth()*0.5
    local h = Amaz.BuiltinObject:getInputTextureHeight()*0.5
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
        self.pass1Material:setInt("imageWidth", self.width)
        self.pass1Material:setInt("imageHeight", self.height)
        for i=1,4 do
            self.renderTargets[i].width = w
            self.renderTargets[i].height = h
        end
    end
    self.pass1Material:setFloat("uTime", time)
end

function SeekModeScript:onEvent(sys, event)
    if "effects_adjust_intensity" == event.args:get(0) then
        local intensity = event.args:get(1)
        self.pass1Material:setFloat("range", 7*intensity)
    end
end


exports.SeekModeScript = SeekModeScript
return exports
