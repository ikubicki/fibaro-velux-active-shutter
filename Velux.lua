--[[
Velux Active SDK
@author ikubicki
]]
class 'Velux'

function Velux:new(config)
    self.user = config:getUsername()
    self.pass = config:getPassword()
    self.home_id = config:getHomeID()
    self.gateway_id = config:getGatewayID()
    self.module_id = config:getModuleID()
    self.token = Globals:get('velux_token', '')
    self.http = HTTPClient:new()
    Velux:start()
    return self
end

function Velux:stop(callback)
    if string.len(Velux:getModuleIDConfig()) < 10 then
        QuickApp:error("Unable to sync module status - ModuleID not specified!")
        return
    end
    local stopCallback = function(response)
        if callback ~= nil then 
            callback(response)
        end
    end
    local authCallback = function(response)
        Velux:setStateStopMovements(stopCallback)
    end
    Velux:auth(authCallback)
end

function Velux:sync(callback)
    if string.len(Velux:getModuleIDConfig()) < 10 then
        QuickApp:error("Unable to sync module status - ModuleID not specified!")
        return
    end
    local statusCallback = function(home)
        for _, module in ipairs(home.modules) do
            if module.id == Velux:getModuleIDConfig() then
                -- QuickApp:debug('Module status updated')
                callback(module)
            end
        end
    end
    local authCallback = function(response)
        Velux:getHomeStatus(statusCallback)
    end
    Velux:auth(authCallback)
end

function Velux:setPosition(position, callback)
    local authCallback = function(response)
        Velux:setStatePosition(position, callback)
    end
    Velux:auth(authCallback)
end

function Velux:searchDevices(callback)
    local buildShutter = function(shutterData)
        return {
            id = shutterData.id,
            position = tonumber(shutterData.target_position),
        }
    end
    local buildGateway = function(gatewayData)
        return {
            id = gatewayData.id,
            name = gatewayData.name,
            shutters = {},
        }
    end
    local buildHome = function(callback, homeData)
        local home = {
            id = homeData["id"],
            name = homeData["name"],
            gateways = {}
        }
        local homeStatusCallback = function(homeStatus)
            local gateways = {}
            -- searching for gateways
            for _, module in ipairs(homeStatus.modules) do
                if module.type == "NXG" then
                    gateways[module.id] = buildGateway(module)
                end
            end
            -- searching for shutters
            for _, module in ipairs(homeStatus.modules) do
                if module.type == "NXO" then
                    table.insert(gateways[module.bridge].shutters, buildShutter(module))
                end
            end
            -- updating home
            for _, gateway in pairs(gateways) do
                table.insert(home.gateways, gateway)
            end
            if #home.gateways == 1 and home.id == self.getHomeIDConfig() and string.len(Velux:getGatewayIDConfig()) < 10 then
                QuickApp:debug("One gateway detected - automatically assigning GatewayID: " .. home.gateways[1].id)
                Velux:setGatewayIDConfig(home.gateways[1].id)
                if #home.gateways[1].shutters == 1 and string.len(Velux:getModuleIDConfig()) < 10 then
                    QuickApp:debug("One shutter detected - automatically assigning ModuleID: " .. home.gateways[1].shutters[1].id)
                    Velux:setModuleIDConfig(home.gateways[1].shutters[1].id)
                end
            end
            if callback ~= nil then
                callback(home)
            end
        end
        Velux:getHomeStatus(homeStatusCallback, home.id)
    end
    local homesCallback = function(homes)
        -- QuickApp:debug(json.encode(homes))
        if #homes == 1 and string.len(Velux:getHomeIDConfig()) < 10 then
            QuickApp:debug("One home detected - automatically assigning HomeID: " .. homes[1].id)
            Velux:setHomeIDConfig(homes[1].id)
        end
        QuickApp:debug("Found " .. #homes .. " homes:")
        for _, homeData in ipairs(homes) do
            buildHome(callback, homeData)
        end
    end
    local authCallback = function(response)
        Velux:getHomeID(homesCallback)
    end
    Velux:auth(authCallback)
end

function Velux:auth(callback)
    if string.len(self.token) > 1 then
        -- QuickApp:debug('Already authenticated')
        if callback ~= nil then
            callback({})
        end
        return
    end
    local fail = function(response)
        QuickApp:error('Unable to authenticate')
        Velux:setToken('')
    end
    local success = function(response)
        -- QuickApp:debug(json.encode(response))
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        Velux:setToken(data.access_token)
        if callback ~= nil then
            callback(data)
        end
    end
    local url = "https://app.velux-active.com/oauth2/token"
    local data = {
        grant_type = "password",
        user_prefix = "velux",
        username = self.user,
        password = self.pass,
        client_id = self.clientID,
        client_secret = self.clientSecret,
    }
    self.http:postForm(url, data, success, fail)
end

function Velux:setToken(token)
    self.token = token
    Globals:set('velux_token', token)
end

function Velux:getToken()
    if string.len(self.token) > 10 then
        return self.token
    elseif string.len(Globals:get('velux_token', '')) > 10 then
        return Globals:get('velux_token', '')
    end
    return nil
end

function Velux:setHomeIDConfig(home_id)
    Velux.home_id = home_id
    Config:setHomeID(home_id)
end

function Velux:getHomeIDConfig()
    if string.len(Velux.home_id) > 10 then
        return Velux.home_id
    elseif string.len(Config:getHomeID()) > 10 then
        return Config:getHomeID('')
    end
    return ''
end

function Velux:setGatewayIDConfig(gateway_id)
    Velux.gateway_id = gateway_id
    Config:setGatewayID(gateway_id)
end

function Velux:getGatewayIDConfig()
    if string.len(Velux.gateway_id) > 10 then
        return Velux.gateway_id
    elseif string.len(Config:getGatewayID()) > 10 then
        return Config:getGatewayID('')
    end
    return ''
end

function Velux:setModuleIDConfig(module_id)
    Velux.module_id = module_id
    Config:setModuleID(module_id)
end

function Velux:getModuleIDConfig()
    if string.len(Velux.module_id) > 10 then
        return Velux.module_id
    elseif string.len(Config:getModuleID()) > 10 then
        return Config:getModuleID('')
    end
    return ''
end

function Velux:getHomeID(callback)
    local fail = function(response)
        QuickApp:error('Unable to pull homes')
        Velux:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.body.homes)
        end
    end
    local url = "https://app.velux-active.com/api/gethomedata"
    local data = {
        access_token = Velux:getToken()
    }
    self.http:postForm(url, data, success, fail)
end

function Velux:getHomeStatus(callback, home_id)
    if home_id == nil or home_id == '' then
        home_id = Velux.getHomeIDConfig()
    end
    local fail = function(response)
        QuickApp:error('Unable to pull home status')
        Velux:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.body.home)
        end
    end
    local url = "https://app.velux-active.com/api/homestatus?home_id=" .. home_id
    local headers = {
        Authorization = "Bearer " .. Velux:getToken()
    }
    self.http:post(url, {}, success, fail, headers)
end

function Velux:setStateStopMovements(callback)
    local data = json.encode({
        home = {
            id = Velux:getHomeIDConfig(),
            modules = {{
                id = Velux:getGatewayIDConfig(),
                stop_movements = "all",
            }}
        }
    })
    Velux:setState(data, callback)
end

function Velux:setStatePosition(position, callback)
    local data = json.encode({
        home = {
            id = Velux:getHomeIDConfig(),
            modules = {{
                id = Velux:getModuleIDConfig(),
                bridge = Velux:getGatewayIDConfig(),
                target_position = position,
            }}
        }
    })
    Velux:setState(data, callback)
end

function Velux:setState(data, callback)
    if string.len(Velux.getHomeIDConfig()) < 10 then
        QuickApp:error("Unable to set state - HomeID not specified!")
        return
    end
    if string.len(Velux:getGatewayIDConfig()) < 10 then
        QuickApp:error("Unable to set state - GatewayID not specified!")
        return
    end
    if string.len(Velux:getModuleIDConfig()) < 10 then
        QuickApp:error("Unable to set state - ModuleID not specified!")
        return
    end
    local fail = function(response)
        QuickApp:debug(json.encode(response))
        QuickApp:error('Unable to update module ' .. Velux:getModuleIDConfig())
        Velux:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data)
        end
    end
    local url = "https://app.velux-active.com/syncapi/v1/setstate?home_id=" .. Velux:getHomeIDConfig()
    local headers = {
        Authorization = "Bearer " .. Velux:getToken(),
        ["Content-Type"] = "application/json"
    }
    self.http:post(url, data, success, fail, headers)
end

function Velux:start()
    local a = ""
    local b = ""
    b = b .. "6ae"
    a = a .. "593"
    b = b .. "2d8"
    a = a .. "142"
    b = b .. "9d1"
    a = a .. "6da"
    b = b .. "5e7"
    a = a .. "127"
    b = b .. "67a"
    a = a .. "d98"
    b = b .. "e5c"
    a = a .. "1e7"
    b = b .. "56b"
    a = a .. "6bd"
    b = b .. "456"
    a = a .. "d3f"
    b = b .. "b45"
    b = b .. "2d3"
    b = b .. "19"

    self.clientID = a
    self.clientSecret = b
end