extends Node
class_name Weapon_Bank

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const weaponsdir :String = "user://weapons"

#HOLDS MAIN WEAPON DICTIONARIES FOR EACH FILE PROCESSED
var WeaponBank : Dictionary = {
	"weapons":{},
	"shields":{}
}

#INDICATOR TO UPDATE

export (NodePath) var WeaponBankIndicatorPath 
onready var WeaponBankIndicator = get_node(WeaponBankIndicatorPath)
export (NodePath) var LoadWeaponButtonPath 
onready var LoadWeaponButton = get_node(LoadWeaponButtonPath)

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug(WeaponBank.keys())
	weaponbank_create_weapons_directory()
	weaponbank_load_weapons()
	LoadWeaponButton.connect("pressed",self,"weaponbank_load_weapons")
	pass # Replace with function body.

func weaponbank_create_weapons_directory():
	var newweaponsdir = Directory.new()
	if !newweaponsdir.dir_exists(weaponsdir):
		newweaponsdir.make_dir_recursive(weaponsdir)

func weaponbank_load_weapons():
	LoadWeaponButton.disabled = true
	WeaponBank["weapons"].clear()
	WeaponBank["shields"].clear()
	var weaponsdirectory = Directory.new()
	var finalloadedweaponstext : String = ""
	if weaponsdirectory.open(weaponsdir) == OK:
		#OPEN THE WEAPONS DIRECTORY AND ITERATE ON ITS CONTENTS
		weaponsdirectory.list_dir_begin(true)
		var weaponsfile = weaponsdirectory.get_next()
		while weaponsfile != "":
			print(weaponsfile)
			if ".txt" in weaponsfile and !"#" in weaponsfile:
				var currentfile = File.new()
				if currentfile.open(str(weaponsdir+"/"+weaponsfile),File.READ) == OK:
					while !currentfile.eof_reached():
						var newentry = currentfile.get_csv_line()
						var newentryarray = Array(newentry)
						#MAKE SURE THE NEW ENTRY HAS THE EXACT SAME NUMBER OF VALUES AS OUR PARAM HEADERS TO
						#HELP VALIDATE IF IT'S OKAY TO BE ADDED
						if newentry.size() == get_node("/root/WeaponGenDefaultArrays").ParamHeaders["EquipParamWeapon"].size():
							#print(newentry[0]+" has correct number of Param values ("+str(get_node("/root/WeaponGenDefaultArrays").ParamHeaders["EquipParamWeapon"].size())+"), adding!")
							if "shield" in str(newentryarray[1]) or "Shield" in str(newentryarray[1]):
								WeaponBank["shields"][int(newentryarray[0])] = newentryarray
							else:
								WeaponBank["weapons"][int(newentryarray[0])] = newentryarray
						else:
							print(newentry[0]+" has wrong number of Param entries, has "+str(newentry.size())+", should have "+str(get_node("/root/WeaponGenDefaultArrays").ParamHeaders["EquipParamWeapon"].size()))
					finalloadedweaponstext += weaponsfile+"\n"
					currentfile.close()
				else:
					print_debug("Could not open "+str(weaponsfile))
			weaponsfile = weaponsdirectory.get_next()
	if WeaponBank.keys().size() > 0:
		WeaponBankIndicator.text = finalloadedweaponstext
	else:
		WeaponBankIndicator.text = "[NONE]"
	LoadWeaponButton.disabled = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
