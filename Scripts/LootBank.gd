extends Node
class_name Loot_Bank

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (int) var LootBankID = 0

var LootBank_Loot : Dictionary
var LootBank_IDs : Array
var LootBank_AvailableIDs : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_lootbank()
	pass # Replace with function body.

func setup_lootbank():
	get_parent().LootBanks[LootBankID] = self
	
func add_to_lootbank_loot(id:int,finallootdict:Dictionary):
	LootBank_Loot[id] = finallootdict

func add_to_lootbank_ids(id:int):
	LootBank_IDs.append(id)

func add_to_lootbank_available_ids(id:int):
	LootBank_AvailableIDs.append(id)
	
func remove_available_id(id:int):
	LootBank_AvailableIDs.erase(id)
	make_parent_emit_idremoved_signal()
	#print("Loot Bank ID "+str(LootBankID)+" removed id "+str(id))
	
func remove_available_index(index:int):
	LootBank_AvailableIDs.remove(index)
	make_parent_emit_idremoved_signal()
	#print("Loot Bank ID "+str(LootBankID)+" removed index "+str(index))
	
func get_lootbank_loot_dictionary(id:int=0) -> Dictionary:
	var dictionarytoreturn : Dictionary = LootBank_Loot[id]
	return dictionarytoreturn

func get_first_available_id(alsoremove:bool=true) -> int:
	var idtoreturn = LootBank_AvailableIDs[0]
	print(idtoreturn)
	if alsoremove:
		LootBank_AvailableIDs.remove(0)
	make_parent_emit_idremoved_signal()
	return idtoreturn

func get_lootbank_id_from_index(index:int=0) -> int:
	var indextocheck :int = index
	if indextocheck > LootBank_AvailableIDs.size()-1:
		indextocheck = LootBank_AvailableIDs.size()-1
	var idtoreturn :int = LootBank_AvailableIDs[indextocheck]
	return idtoreturn
	
func get_lootbank_available_id_array_size() -> int:
	var availablearraysize = LootBank_AvailableIDs.size()
	return availablearraysize
	
func print_lootbank_available_ids():
	print(str(LootBank_AvailableIDs))
	
func make_parent_emit_idremoved_signal():
	get_parent().emit_signal("idremoved")

func clear_lootbank():
	LootBank_Loot = {}
	LootBank_IDs.clear()
	LootBank_AvailableIDs.clear()
	#print("Loot Bank ID "+str(LootBankID)+" cleared!")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
