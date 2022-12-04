--[[
Internationalization tool
@author ikubicki
]]
class 'i18n'

function i18n:new(langCode)
    if phrases[langCode] == nil then
        langCode = 'en'
    end
    self.phrases = phrases[langCode]
    return self
end

function i18n:get(key)
    if self.phrases[key] then
        return self.phrases[key]
    end
    return key
end

phrases = {
    pl = {
        ['name'] = 'Velux Active: Roleta zewnętrzna - %s',
        ['search-devices'] = 'Szukaj urządzeń',
        ['searching-devices'] = 'Szukam...',
        ['refresh'] = 'Odśwież dane',
        ['refreshing'] = 'Odświeżam...',
        ['device-updated'] = 'Zaktualizowano dane urządzenia',
        ['check-logs'] = 'Zakończono wyszukiwanie. Sprawdź logi tego urządzenia: %s',
        ['shutter-opened'] = 'Roleta otwarta',
        ['shutter-closed'] = 'Roleta zamknięta',
        ['shutter-half-open'] = 'Roleta częściowo uchylona (%d%%)',
        ['shutter-opening'] = 'Roleta w trakcie otwierania (-> %d%%)',
        ['shutter-closing'] = 'Roleta w trakcie zamykania (-> %d%%)',
        ['stop'] = 'Zatrzymaj ruch',
        ['position-set'] = 'Pozycja: %d%%',

        ['search-row-home'] = '__ DOM %s (# %s)',
        ['search-row-home-gateways'] = '__ Wykryto %d bramek',
        ['search-row-gateway'] = '____ BRAMKA %s (# %s)',
        ['search-row-gateway-shutters'] = '____ Wykryto %d rolet',
        ['search-row-shutter'] = '______ ROLETA # %s',
        ['search-row-shutter-position'] = '______ Pozycja: %d%%',
    },
    en = {
        ['name'] = 'Velux Active: Roof window shutter - %s',
        ['search-devices'] = 'Search devices',
        ['searching-devices'] = 'Searching...',
        ['refresh'] = 'Refresh data',
        ['refreshing'] = 'Refreshing...',
        ['device-updated'] = 'Device updated',
        ['check-logs'] = 'Check device logs (%s) for search results',
        ['shutter-opened'] = 'Rollershutter opened',
        ['shutter-closed'] = 'Rollershutter closed',
        ['shutter-half-open'] = 'Rollershutter partially opened (%d%%)',
        ['shutter-opening'] = 'Rollershutter is opening (-> %d%%)',
        ['shutter-closing'] = 'Rollershutter is closing (-> %d%%)',
        ['stop'] = 'Stop movement',
        ['position-set'] = 'Position: %d%%',

        ['search-row-home'] = '__ HOME %s (# %s)',
        ['search-row-home-gateways'] = '__ %d gateways found',
        ['search-row-gateway'] = '____ GATEWAY %s (# %s)',
        ['search-row-gateway-shutters'] = '____ %d shutters found',
        ['search-row-shutter'] = '______ ROLLERSHUTTER # %s',
        ['search-row-shutter-position'] = '______ Position: %d%%',
    },
    de = {
        ['name'] = 'Velux Active: Rollladen - %s',
        ['search-devices'] = 'Geräte suchen',
        ['searching-devices'] = 'Suchen...',
        ['refresh'] = 'Aktualisieren',
        ['refreshing'] = 'Aktualisieren...',
        ['device-updated'] = 'Gerät aktualisiert',
        ['check-logs'] = 'Überprüfen Sie die Geräteprotokolle (%s) auf Suchergebnisse',
        ['shutter-opened'] = 'Rollladen geöffnet',
        ['shutter-closed'] = 'Rollladen geschlossen',
        ['shutter-half-open'] = 'Rollladen teilweise geöffnet (%d%%)',
        ['shutter-opening'] = 'Rollladen öffnet (-> %d%%)',
        ['shutter-closing'] = 'Rollladen schließt (-> %d%%)',
        ['stop'] = 'Bewegung stoppen',
        ['position-set'] = 'Position: %d%%',

        ['search-row-home'] = '__ HAUS %s (# %s)',
        ['search-row-home-gateways'] = '__ %d einfahrten gefunden',
        ['search-row-gateway'] = '____ EINFAHRT %s (# %s)',
        ['search-row-gateway-shutters'] = '____ %d rollläden gefunden',
        ['search-row-shutter'] = '______ ROLLLADEN # %s',
        ['search-row-shutter-position'] = '______ Position: %d%%',
    }
}