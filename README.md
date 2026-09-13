# Slot&Found
Secret World Legends mod for saving/loading inventory layout

### Download
Downloads are at the [releases page](https://github.com/MakeMods/Slot-And-Found/releases)  
Download the SlotAndFound-v.x.y-z.zip files, not the source code

### About
Saving/Loading is completely manual, and is done by using the commands listed below.

Inventory layout is saved using item id's, instead of item "positions" like in vanilla game.  
This should make the backups survive even if the items are moved between containers or upgraded.  

Saved layouts are stored in `%localappdata/Funcom/SWL/Prefs_3.xml`,  
Prefs_3 is system wide, meaning they are accessible by all accounts on the computer.  
Prefs_3 is also fairly portable, in case you need to move settings between computers.

The mod is very lightweight and only gets loaded whenever you run one of the commands,  
after executing the command the mod unloads itself again.  
It should be safe to even uninstall the mod without losing the saved layouts.  

### Commands  
Use `/option SlotAndFound_Save true` to save current layout  
Use `/option SlotAndFound_Load true` to load saved layout  
Use `/option SlotAndFound_List true` to list all saved layouts    
Use `/option SlotAndFound_Delete true` to delete last saved layout    
By default all commands use your characters name as the save key, but you can also override it by supplying a string
e.g
`/option SlotAndFound_Save "backup"` -- Save current inventory layout to "backup"
`/option SlotAndFound_Load "AltAccount"` -- Load inventory layout that was saved as "AltAccount"
`/option SlotAndFound_Save "backup2"` -- Save the just loaded layout to "backup2"
`/option SlotAndFound_Load "backup"` -- Load the original layout
`/option SlotAndFound_Delete "backup"` -- Delete "backup" layout

 
### Install
Extract to `Secret World Legends\Data\Gui\Custom\Flash`
