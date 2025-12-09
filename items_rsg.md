# RSG Framework Items Setup

Add these items to your `rsg-core/shared/items.lua` file:

```lua
-- Christmas Present Items
['empty_present'] = {
    name = 'empty_present',
    label = 'Empty Present',
    weight = 100,
    type = 'item',
    image = 'empty_present.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'An empty present box ready to be filled with a gift'
},

['christmas_present'] = {
    name = 'christmas_present',
    label = 'Christmas Present',
    weight = 500,
    type = 'item',
    image = 'christmas_present.png',
    unique = true,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'A wrapped Christmas present'
},
```

## Item Images

Place the following images in your `rsg-inventory/html/images/` folder:
- `empty_present.png`
- `christmas_present.png`

## Notes

- `unique = true` on christmas_present ensures each present has its own metadata (To/From/Gift info)
- `shouldClose = true` closes inventory when item is used
- The `weight` values can be adjusted to your server's economy
