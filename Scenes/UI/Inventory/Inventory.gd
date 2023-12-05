extends Control
class_name Inventory

var items : Array = []

class ItemAmount:
	var amount : int = 0
	var item : ItemData = null
	
	func _init(_amount : int, _item : ItemData) -> void:
		amount = _amount
		item = _amount
	



func _add_item(item: ItemData, amount: int = 1) -> void:
	var id = _find_item_id(item)
	if id == -1 :
		items.append(ItemAmount.new(amount, item))
	else:
		items[id].amount += amount
		
#Find the position of the item (return -1 if can't find)
func _find_item_id(item : ItemData) -> int:
	for i in range(items.size()):
		var ind = items[i]
		if i.item == item:
			return i
	return -1

func _remove_item_id(item: ItemData) -> int:
	return -1
