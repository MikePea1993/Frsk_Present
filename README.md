# Frsk_Present

A Christmas present gifting system for RedM servers. Wrap gifts for other players with personalized tags!

## Features

- Wrap any item, weapon, or ammo as a Christmas present
- Personalized gift tags with "To" and "From" fields
- Weapons retain all components, serial numbers, and customizations
- Beautiful UI with animated present opening
- Supports both **VORP** and **RSG** frameworks

## Dependencies

- VORP Core + VORP Inventory **OR** RSG-Core + RSG-Inventory

## Installation

1. Download and extract to your resources folder
2. Add the items to your framework (see `items_vorp.md` or `items_rsg.md`)
3. Add the item images to your inventory images folder
4. Add `ensure Frsk_Present` to your server.cfg

## Items Required

| Item | Description |
|------|-------------|
| `empty_present` | Empty present box - used to create gifts |
| `christmas_present` | Wrapped present containing a gift |

## Usage

1. Give players `empty_present` items
2. Players use the empty present to open the gift wrapping UI
3. Select an item/weapon/ammo from inventory to wrap
4. Fill in the "To" and "From" fields on the gift tag
5. The wrapped `christmas_present` can be given to other players
6. Recipients use the present to see who it's from and open it

## Configuration

Edit `shared/config.lua` to customize:
- Debug mode
- Mail stamp image
- Item names
- Notification messages

## Preview

![Present UI](https://i.ibb.co/tPbf81SP/Vorp-3.png)

## License

Free to use and modify. Commercial redistribution/selling is prohibited. See LICENSE file.

## Support

For issues or suggestions, open an issue on GitHub.
