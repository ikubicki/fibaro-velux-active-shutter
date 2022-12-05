
--[[
Velux Active integration
@author ikubicki
]]

function QuickApp:onInit()
    self.config = Config:new(self)
    self.velux = Velux:new(self.config)
    self.i18n = i18n:new(api.get("/settings/info").defaultLanguage)
    self:trace('')
    self:trace(string.format(self.i18n:get('name'), self.name))
    self:updateProperty('manufacturer', 'Velux')
    self:updateProperty('model', 'Velux Active KIX 300')
    self:updateView("button1", "text", self.i18n:get('stop'))
    self:updateView("button2", "text", self.i18n:get('search-devices'))
    self:updateView("label", "text", self.i18n:get('name'))
    self:updateProperty("value", 99)
    if string.len(self.config:getModuleID()) > 10 then
        self:run()
    end
end

function QuickApp:open()
    self:setPosition(100)
end

function QuickApp:close()
    self:setPosition(0)
end

function QuickApp:stop()
    local callback = function(response)
        self:pullDataFromCloud()
    end
    self.velux:stop(callback)
end

function QuickApp:setValue(value)
    if value > 98 then
        value = 100
    end
    self:setPosition(value)
end

function QuickApp:setPositionEvent(event)
    local position = event.values[1]
    self:setValue(position)
end

function QuickApp:stopEvent(event)
    self:stop()
end

function QuickApp:refreshDataEvent(event)
    self:updateView("label", "text", self.i18n:get('refreshing'))
    self:pullDataFromCloud()
end

function QuickApp:setPosition(position)
    -- self:debug(string.format("Setting new position (%d%%) ...", position))
    if position < 1 then
        position = 0
    elseif position > 98 then
        position = 100
    end
    local callback = function(response)
        self:debug(string.format(self.i18n:get('position-set'), position))
        self:pullDataFromCloud()
    end
    self.velux:setPosition(position, callback)
end

function QuickApp:updateValues(position, newPosition)
    value = position
    self:updateView("slider", "value", tostring(position))
    if position < 1 then
        value = 0
        text = self.i18n:get('shutter-closed')
    elseif position > 98 then
        value = 99
        text = self.i18n:get('shutter-opened')
    else 
        text = string.format(self.i18n:get('shutter-half-open'), position)
    end
    local inMotion = false
    if newPosition ~= nil and newPosition > position then
        text = string.format(self.i18n:get('shutter-opening'), position)
        inMotion = true
    elseif newPosition ~= nil and newPosition < position then
        text = string.format(self.i18n:get('shutter-closing'), position)
        inMotion = true
    end
    if inMotion then
        fibaro.setTimeout(3000, function()
            self:pullDataFromCloud()
        end)
    end
    self:updateView("label", "text", text)
    self:updateProperty("value", value)
end

function QuickApp:run()
    self:pullDataFromCloud()
    local interval = self.config:getInterval()
    if (interval > 0) then
        fibaro.setTimeout(interval, function() self:run() end)
    end
end

function QuickApp:pullDataFromCloud()
    local callback = function(moduleData)
        -- QuickApp:debug(json.encode(moduleData))
        self:updateView("button3", "text", self.i18n:get('refresh'))
        self:updateValues(moduleData.current_position, moduleData.target_position)
    end
    self:updateView("button3", "text", self.i18n:get('refreshing'))
    self.velux:sync(callback)
end

function QuickApp:searchDevicesEvent()
    self:debug(self.i18n:get('searching-devices'))
    self:updateView("button2", "text", self.i18n:get('searching-devices'))
    local callback = function(homeData)
        self:updateView("button2", "text", self.i18n:get('search-devices'))
        -- printing results
        QuickApp:trace(string.format(self.i18n:get('search-row-home'), homeData.name, homeData.id))
        QuickApp:trace(string.format(self.i18n:get('search-row-home-gateways'), #homeData.gateways))
        for _, gateway in ipairs(homeData.gateways) do
            QuickApp:trace(string.format(self.i18n:get('search-row-gateway'), gateway.name, gateway.id))
            QuickApp:trace(string.format(self.i18n:get('search-row-gateway-shutters'), #gateway.shutters))
            for __, shutter in ipairs(gateway.shutters) do
                QuickApp:trace(string.format(self.i18n:get('search-row-shutter'), shutter.id))
                QuickApp:trace(string.format(self.i18n:get('search-row-shutter-position'), shutter.position))
            end
        end
        self:updateView("label", "text", string.format(self.i18n:get('check-logs'), 'QUICKAPP' .. self.id))
    end
    self.velux:searchDevices(callback)
end
