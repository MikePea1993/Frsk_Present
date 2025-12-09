# VORP Framework Items Setup

Run these SQL queries in your database to add the present items:

```sql
-- Empty Present (used to create gifts)
INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
VALUES ('empty_present', 'Empty Present', 10, 1, 'item_standard', 1, 'An empty present box ready to be filled with a gift');

-- Christmas Present (contains the wrapped gift)
INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
VALUES ('christmas_present', 'Christmas Present', 10, 1, 'item_standard', 1, 'A wrapped Christmas present');
```

## Item Images

Place the following images in your `vorp_inventory/html/img/items/` folder:

- `empty_present.png`
- `christmas_present.png`

## Notes

- `limit` controls max stack size (10 recommended)
- `can_remove` = 1 allows the item to be dropped/traded
- `type` = 'item_standard' is the standard item type
- `usable` = 1 makes the item usable (triggers the registerUsableItem callback)
- Metadata is automatically stored per-item for the christmas_present
