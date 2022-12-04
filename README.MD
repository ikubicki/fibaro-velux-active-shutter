# Velux Active shutters integration

Virtual device that allow to control a single rollershutter controlled by Velux Active controller (KIX 300).

## Configuration

`Username` - Velux username

`Password` - Velux password

`HomeID` - ID of the home

`GatewayID` - ID of the gateway device (NXG)

`ModuleID` - ID of the shutter module (NXO)

### Optional values

In case of single shutter setup, `HomeID`, `GatewayID` and `ModuleID` will be automatically populated once you will click `Search devices` button.
If you own more than one shutter, `ModuleID` will need to be manually provided through QuickApp Variables section.
If you own more than one gateway or more locations (homes), `GatewayID` and `HomeID` will need to be manually provided as well,

## Installation

Follow regular installation process. After virtual device will be added to your Home Center unit, click on Variables and provide `Username` and `Password`.
Then, click on `Search devices` button which will pull all information from your Velux account that includes Homes, Gateways and detected shutters.

To access pulled information, go to logs of the device, review detected devices and use proper IDs as variables of the QuickApp.

To have more controls, you may also change role of the shutter to `Blind with positioning`.