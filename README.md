# bcc-wagons

## Description

Whether you're a hardworking farmer tending to your crops, a family embarking on a scenic countryside picnic, or a successful businessman looking to make an impression, these wagons will revolutionize the way you travel.

## Features

- **Wagon Shopping**: Buy and sell wagons through the wagon shops.
- **Payment Options**: Use cash and/or gold for payments in the menu.
- **Personal Inventory**: Each owned wagon has its own inventory.
- **Wagon Calling**: Call your selected wagon using the `J` key.
- **Custom Shop Hours**: Set individual shop hours or disable them to keep the shop open.
- **Customizable Blips**: Shop blips are colored and changeable per shop location, reflecting open, closed, or job-locked status.
- **Job-Based Access**: Limit shop access by job and job grade.
- **Wagon Return**: Return your wagon at any shop location via prompt or use the menu when afield.
- **Wagon Naming**: Give your wagon a special name at purchase time or rename it using the menu.
- **Configurable Limits**: Set a max number of wagons per player and wainwrights in the main config.
- **NPC Spawns**: Distance-based NPC spawns for a more immersive experience.
- **Wagon Trading**: Trade wagons with other players using the menu.
- **Job-Specific Purchases**: Limit individual wagon purchases to specified jobs.
- **Wainwright Job**: Allows the wainwright job to sell wagons to players (more features to come!).
- **Shared Inventory Option**: Allows wagon inventories to be looted when the wagon is empty of players.
- **Wagon Condition**: Wagon condition reduces while spawned. Repair your wagon with the repair item (default: hammer, configurable). The repair item can also repair boats if using `bcc-boats`. The durability of the repair item reduces with each use.

## Commands

- `/wagonEnter`: Use this command if you have trouble getting to your wagon.
- `/wagonReturn`: Return your wagon when away from a shop (if enabled in the config).

## Dependencies

- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
- [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)

## Installation

1. Ensure dependencies are installed/updated and ensured before this script.
2. Add the `bcc-wagons` folder to your resources folder.
3. Add `ensure bcc-wagons` to your `server.cfg`.
4. Run the included database file `wagons.sql`.
5. Restart the server.

## Credits

- **lrp_stable**
- **[ByteSizd](https://github.com/AndrewR3K)**: Vue Boilerplate for RedM
- **[SavSin](https://github.com/DavFount)**: UI conversion to VueJS

## GitHub

- [bcc-wagons](https://github.com/BryceCanyonCounty/bcc-wagons)
