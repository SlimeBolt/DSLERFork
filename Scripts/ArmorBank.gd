extends Node
class_name Armor_Bank

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const armorsdir :String = "user://armors"

#HOLDS MAIN armor DICTIONARIES FOR EACH FILE PROCESSED
var ArmorBank : Dictionary = {}

#INDICATOR TO UPDATE

export (NodePath) var ArmorBankIndicatorPath 
onready var ArmorBankIndicator = get_node(ArmorBankIndicatorPath)
export (NodePath) var LoadArmorButtonPath 
onready var LoadArmorButton = get_node(LoadArmorButtonPath)

# Called when the node enters the scene tree for the first time.
func _ready():
	armorBank_create_armors_directory()
	armorBank_load_armors()
	LoadArmorButton.connect("pressed",self,"armorBank_load_armors")
	pass # Replace with function body.

func armorBank_create_armors_directory():
	var newarmorsdir = Directory.new()
	if !newarmorsdir.dir_exists(armorsdir):
		newarmorsdir.make_dir_recursive(armorsdir)

func armorBank_load_armors():
	ArmorBank.clear()
	var armorsdirectory = Directory.new()
	var finalloadedarmorstext : String = ""
	if armorsdirectory.open(armorsdir) == OK:
		#OPEN THE ARMORS DIRECTORY AND ITERATE ON ITS CONTENTS
		armorsdirectory.list_dir_begin(true)
		var armorfile = armorsdirectory.get_next()
		while armorfile != "":
			print(armorfile)
			if ".txt" in armorfile and !"#" in armorfile:
				var currentfile = File.new()
				if currentfile.open(str(armorsdir+"/"+armorfile),File.READ) == OK:
					while !currentfile.eof_reached():
						var newentry = currentfile.get_csv_line()
						#MAKE SURE THE NEW ENTRY HAS THE EXACT SAME NUMBER OF VALUES AS OUR PARAM HEADERS TO
						#HELP VALIDATE IF IT'S OKAY TO BE ADDED
						if newentry.size() == get_node("/root/WeaponGenDefaultArrays").ParamHeaders["EquipParamProtector"].size():
							#print(newentry[0]+" has correct number of Param values ("+str(get_node("/root/armorGenDefaultArrays").ParamHeaders["EquipParamarmor"].size())+"), adding!")
							ArmorBank[int(newentry[0])] = newentry
						else:
							print(newentry[0]+" has wrong number of Param entries, has "+str(newentry.size())+", should have "+str(get_node("/root/armorGenDefaultArrays").ParamHeaders["EquipParamarmor"].size()))
					finalloadedarmorstext += armorfile+"\n"
					currentfile.close()
				else:
					print_debug("Could not open "+str(armorfile))
			armorfile = armorsdirectory.get_next()
	if ArmorBank.keys().size() > 0:
		ArmorBankIndicator.text = finalloadedarmorstext
	else:
		ArmorBankIndicator.text = "[NONE]"
