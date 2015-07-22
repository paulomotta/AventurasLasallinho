-- para encontrar objetos, colisoes e o jogador no map
local customLayer = {
  _VERSION     = 'customLayer v0.1',
  _URL         = 'https://github.com/paulomotta/customLayer.lua',
  _DESCRIPTION = 'A layer processing library for Lua',
  _LICENSE     = [[
    still to define
  ]]
}

local CustomLayer = {}
CustomLayer.__index = CustomLayer
--definicao dos atributos
CustomLayer.layer = nil

setmetatable(CustomLayer, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function CustomLayer.new(layerobj)
    local self = setmetatable({}, CustomLayer)
    self.layer = layerobj
    return self
end

function CustomLayer:setLayer(layerobj)
    self.layer = layerobj
end

function CustomLayer:getLayer()
    return self.layer
end

--To use customLayers we have to pass in the object that has the draw function for the
--object that is being substituted, since we are using the actor library, we need the
--actor to be passed in because it has many attributes that are referenced inside the
--draw function

function CustomLayer:createConvertObjectFunction()
    --print("setting "..name)
    --print(graphicalObj)
    self.convertFunction = function(old)
                                local player = {x = old.x, y = old.y, name = old.name}
                                --print(name)
                                --print(graphicalObj)
                                --player.name = name
                                --player.draw = function() graphicalObjTable[player.name]:draw() end
                                return player
                           end
    self:setCustomLayerConvert()
    --self:setDraw()
end

function CustomLayer:setCustomLayerConvert()
    self.layer:toCustomLayer(self.convertFunction)
end

function CustomLayer:setDraw()
    function self.layer:draw()
        for k,obj in pairs(self.objects) do
            obj:draw()
        end
    end
end

-- Find the player object

function CustomLayer:findObject(name)
    local obj = nil
    for i  = 1, #self.layer.objects do
        if self.layer.objects[i].name == name then
            obj = self.layer.objects[i]
            --print("encontrado "..name)
        end
    end 
    return obj
end

function CustomLayer:findObjectsByType(objtype)
    local objs = {}
    local id = 1
    for i  = 1, #self.layer.objects do
        if self.layer.objects[i].type == objtype then
            objs[id] = self.layer.objects[i]
            --print("encontrado "..objtype.." "..id)
            id = id + 1
        end
    end 
    return objs
end

customLayer.new = function(layerobj)
    return CustomLayer(layerobj)
end

return customLayer