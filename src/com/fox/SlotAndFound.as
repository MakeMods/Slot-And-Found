/*
* ...
* @author SecretFox
*/
import GUIFramework.SFClipLoader;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.InventoryItem;
import com.Utils.Archive;
import com.Utils.ID32;
import flash.geom.Point;
import com.Utils.LDBFormat;

class com.fox.SlotAndFound 
{
	public var DValLoad:DistributedValue;
	public var DValSave:DistributedValue;
	public var DValStorage:DistributedValue;
	static var QuestBoxName:String = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI",  "QuestInventoryWindowTitle"));
	
	
	public static function main(swfRoot:MovieClip):Void
	{
		var s_app = new SlotAndFound();
		swfRoot.onLoad = function(){s_app.Load()};
		swfRoot.onUnload = function(){s_app.Unload()};
		swfRoot.OnModuleActivated = function(cfg){s_app.Activate(cfg)};
		swfRoot.OnModuleDeactivated = function(){return s_app.Deactivate()};
	}

	public function SlotAndFound() {
		DValLoad = DistributedValue.Create("SlotAndFound_Load")
		DValSave = DistributedValue.Create("SlotAndFound_Save")
		DValStorage = DistributedValue.Create("Storage_SlotAndFound")
	}
	
	public function Load()
	{
		if (DValSave.GetValue()) SaveInventory();
		if (DValLoad.GetValue()) LoadInventory();
		
		DValSave.SetValue(false);
		DValLoad.SetValue(false);
		SFClipLoader.UnloadClip("slotandfound\\slotandfound");
	}
	
	public function Unload()
	{
	}
	
	public function AddToList(items:Array, item:InventoryItem, column:Number, row:Number, boxName:String )
	{
		var id = String(item.m_ACGItem.m_TemplateID0);
		for (var i in items)
		{
			var compId = items[i][0].split(":")[0];
			var compItem:InventoryItem = items[i][3];
			if (compId == id)
			{
				// There is other item with same ID, store glyph/signet info
				if (item.m_ACGItem.m_TemplateID1 || item.m_ACGItem.m_TemplateID2)
				{
					id += ":" + item.m_ACGItem.m_TemplateID1 +":" + item.m_ACGItem.m_TemplateID2;
				}
				
				// Also update the comparison data to contain glyph/signet info
				if (item.m_ACGItem.m_TemplateID1 || item.m_ACGItem.m_TemplateID2)
				{
					items[i][0] = compItem.m_ACGItem.m_TemplateID0 + ":" + compItem.m_ACGItem.m_TemplateID1 + ":" + compItem.m_ACGItem.m_TemplateID2;
				}
				break;
			}
		}
		items.push(
		[
			id,
			column,
			row,
			item, // Cache item data, in case it will become necessary to store glyph/signet info
			boxName // Store inventory box name for writing configs
		]);
	}
	
	public function SaveInventory()
	{
		var arch:Archive = new Archive();
		var inventory = _root.backpack2;
		var boxes:Array = inventory.m_IconBoxes;
		if (!inventory.m_ModuleActivated) return;
		
		var optionValue = DValSave.GetValue();
		var saveName = optionValue;
		if (saveName == true || saveName == 1) saveName = Character.GetClientCharacter().GetName();
		
		// Get all items and their positions
		var items: Array = [];
		for (var i in boxes)
		{
			var box = boxes[i];
			var boxName = box.GetName();
			if ( boxName == QuestBoxName) continue;
			for (var c = 0; c < box["m_ItemSlots"].length; c++ )
			{
				for (var r = 0; r < box["m_ItemSlots"][c].length; r++ )
				{
					var slot = box["m_ItemSlots"][c][r];
					var item:InventoryItem = slot["m_ItemData"];
					if (!item) continue;
					AddToList(items, item, c, r, boxName);
				}
			}
		}
		// Store by inventory box in the Archive
		var inventoryboxes:Object = {};
		for (var i = 0; i < items.length; i++)
		{
			var item:Array = items[i];
			var inventoryName = item[4];
			if ( inventoryboxes[inventoryName] == undefined)
			{
				inventoryboxes[inventoryName] = [];
			}
			item = item.slice(0, 3); //remove temp entries
			inventoryboxes[inventoryName].push(item.join("+"));
		}
		for (var i in inventoryboxes)
		{
			arch.ReplaceEntry(i, inventoryboxes[i].join("@"));
		}
		
		var existing:Archive = DValStorage.GetValue();
		if (!existing)
		{
			existing = new Archive();
		}

		existing.ReplaceEntry(saveName, arch);
		DValStorage.SetValue(existing);
	}
	
	public function CreateMissingBoxes(config:Archive, inventoryBoxes:Object)
	{
		var inventory = _root.backpack2;
		
		var toCreate:Object = {};
		var entries = config["m_Dictionary"];
		for (var boxName in entries)
		{
			// Check if inventory box already exists
			if (!inventoryBoxes[boxName])
			{
				toCreate[boxName] = [0, 0];
			}
			
			// Get the minimum box size for storing the items
			var items = config.FindEntry(boxName).split("@");
			for (var y = 0; y < items.length; y++)
			{
				var item_data = items[y].split("+");
				
				var column = Number(item_data[1])
				var row = Number(item_data[2])
				if (column > toCreate[boxName][0]) toCreate[boxName][0] = column;
				if (row > toCreate[boxName][1]) toCreate[boxName][1] = row;
			}
		}
		
		// Create missing inventory boxes
		var x = 50;
		for (var i in toCreate)
		{
			var box = inventory.CreateBox(toCreate[i][1] + 1, toCreate[i][0] + 1, false, false, false);
			box.SetName(i);
			box.SetPos(x, 50);
			x += box.m_BoxWidth + 25;
			inventory.m_IconBoxes[box.GetBoxID()] = box;
			inventoryBoxes[i] = box;
		}
	}
	
	public function CheckForMatch(id:Array, comparison:InventoryItem)
	{
		var main_id = Number(id[0]);
		var glyph_id = Number(id[1]);
		var signet_id = Number(id[2]);
		
		if (!glyph_id && !signet_id)
		{
			if (main_id == comparison.m_ACGItem.m_TemplateID0) return true;
			return false;
		}
		if (
			main_id == comparison.m_ACGItem.m_TemplateID0 &&
			glyph_id == comparison.m_ACGItem.m_TemplateID1 &&
			signet_id == comparison.m_ACGItem.m_TemplateID2
		) return true;
		return false;
	}
	
	public function LoadInventory()
	{
		var storage:Archive = DValStorage.GetValue();
		var inventory = _root.backpack2;
		if (!inventory.m_ModuleActivated) return;
		var inventoryID:ID32 = inventory.m_Inventory.GetInventoryID();
		var boxes:Array = inventory.m_IconBoxes;
		var optionValue = DValLoad.GetValue();
		var loadName = optionValue;
		if (loadName == true || loadName == 1) loadName = Character.GetClientCharacter().GetName();

		var config:Archive = storage.FindEntry(loadName, undefined);
		if (!config) return;
		
		var tempBox;
		var inventoryBoxes:Object = {};
		
		// Create temp box
		for (var i in boxes)
		{
			var box = boxes[i];
			var boxName = box.GetName();
			if (boxName == "Slot&Found") tempBox = box;
			inventoryBoxes[boxName] = box;
		}
		if (!tempBox)
		{
			tempBox = inventory.CreateBox(10, 10, false, false, false);
			tempBox.SetName("Slot&Found");
			inventory.m_IconBoxes[tempBox.GetBoxID()] = tempBox;
		}
		CreateMissingBoxes(config, inventoryBoxes);
		
		// Move all to temp box
		for (var i in boxes)
		{
			var box = boxes[i];
			var boxName = box.GetName();
			if ( boxName == QuestBoxName) continue;
			for (var c = 0; c < box["m_ItemSlots"].length; c++ )
			{
				for (var r = 0; r < box["m_ItemSlots"][c].length; r++ )
				{
					var slot = box["m_ItemSlots"][c][r];
					var item:InventoryItem = slot["m_ItemData"];
					inventory.MoveItemToFirstFreeSlot(box, tempBox, slot.GetSlotID());
				}
			}
		}
		
		// Move to saved positions
		for (var i in inventoryBoxes)
		{
			var entries:String = config.FindEntry(i, undefined);
			if (!entries) continue;
			var items = entries.split("@");
			var spent:Object = {};
			for (var y = 0; y < items.length; y++)
			{
				var item_data:Array = items[y].split("+");
				var id_data:Array = item_data[0].split(":");
				var column = Number(item_data[1])
				var row = Number(item_data[2])
				if (isNaN(column) || isNaN(row)) continue;
				
				// find the saved item
				for (var c = 0; c < tempBox["m_ItemSlots"].length; c++ )
				{
					for (var r = 0; r < tempBox["m_ItemSlots"][c].length; r++ )
					{
						var slot = tempBox["m_ItemSlots"][c][r];
						var item:InventoryItem = slot["m_ItemData"];
						var coord:Point = new Point(column, row);
						if (!item || spent[coord]) continue;
						var result = CheckForMatch(id_data, item);
						if (result)
						{
							if ( tempBox.RemoveItem(slot.GetSlotID()))
							{
								inventoryBoxes[i].AddItemAtGridPosition(slot.GetSlotID(), item, coord);
								spent[coord] = true;
							}
						}
					}
				}
			}
		}
		//just merge rest to main inventory
		inventory.SlotDeleteBox(_global.Enums.StandardButtonID.e_ButtonIDYes, tempBox.GetBoxID());
		
	}
}