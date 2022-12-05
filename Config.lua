--[[
Configuration handler
@author ikubicki
]]
class 'Config'

function Config:new(app)
    self.app = app
    self:init()
    return self
end

function Config:getUsername()
    if self.username and self.username:len() > 3 then
        return self.username
    end
    return nil
end

function Config:getPassword()
    return self.password
end

function Config:getHomeID()
    return self.home_id
end

function Config:setHomeID(home_id)
    self.home_id = home_id
    Globals:set('velux_home_id', self.home_id)
end

function Config:getGatewayID()
    return self.gateway_id
end

function Config:setGatewayID(gateway_id)
    self.gateway_id = gateway_id
    Globals:set('velux_gateway_id', self.gateway_id)
end

function Config:getModuleID()
    return self.module_id
end

function Config:setModuleID(module_id)
    self.module_id = module_id
end

function Config:getInterval()
    return 1800 * 1000
end

--[[
This function takes variables and sets as global variables if those are not set already.
This way, adding other devices might be optional and leaves option for users, 
what they want to add into HC3 virtual devices.
]]
function Config:init()
    self.username = self.app:getVariable('Username')
    self.password = self.app:getVariable('Password')
    self.home_id = self.app:getVariable('HomeID')
    self.gateway_id = self.app:getVariable('GatewayID')
    self.module_id = self.app:getVariable('ModuleID')

    local storedUsername = Globals:get('velux_username', '')
    local storedPassword = Globals:get('velux_password', '')
    local storedHomeID = Globals:get('velux_home_id', '')
    local storedGatewayID = Globals:get('velux_gateway_id', '')

    -- handling username
    if string.len(self.username) < 4 and string.len(storedUsername) > 3 then
        self.app:setVariable("Username", storedUsername)
        self.username = storedUsername
    elseif (storedUsername == '' and self.username) then
        Globals:set('velux_username', self.username)
    end
    -- handling password
    if string.len(self.password) < 4 and string.len(storedPassword) > 3 then
        self.app:setVariable("Password", storedPassword)
        self.password = storedPassword
    elseif (storedPassword == '' and self.password) then
        Globals:set('velux_password', self.password)
    end
    -- handling Home ID
    if string.len(self.home_id) < 4 and string.len(storedHomeID) > 3 then
        self.app:setVariable("HomeID", storedHomeID)
        self.home_id = storedHomeID
    elseif (storedHomeID == '' and self.home_id) then
        Globals:set('velux_home_id', self.home_id)
    end
    -- handling Gateway ID
    if string.len(self.gateway_id) < 4 and string.len(storedGatewayID) > 3 then
        self.app:setVariable("GatewayID", storedGatewayID)
        self.gateway_id = storedGatewayID
    elseif (storedGatewayID == '' and self.home_id) then
        Globals:set('velux_gateway_id', self.gateway_id)
    end
end