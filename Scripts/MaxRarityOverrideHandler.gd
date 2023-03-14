extends Node
class_name Max_Rarity_Override_Handler

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var MaxRarityOverride : Dictionary = {}

const MRODefaultPath : String = "user://maxrarityoverride"

# Called when the node enters the scene tree for the first time.
func _ready():
	create_default_directory()
	create_default_mroh()
	load_mros()
	
	pass # Replace with function body.

func create_default_directory():
	var mrodir = Directory.new()
	if !mrodir.dir_exists(MRODefaultPath):
		mrodir.make_dir(MRODefaultPath)

func create_default_mroh():
	var MROExtraPath : String = "/#Default_MaxRarityOverride.txt"
	var mrofile = File.new()
	if !mrofile.file_exists(MRODefaultPath+MROExtraPath):
		if mrofile.open(MRODefaultPath+MROExtraPath,File.WRITE) == OK:
			mrofile.store_string("3\n110\n214000991")
		else:
			OS.alert("Could not access "+str(MRODefaultPath+MROExtraPath)+"!","Unable to create default MaxRarityOverride")

func load_mros():
	#MAX RARITY OVERRIDES WILL STORE A MAX RARITY VALUE FOR A SET OF ITEMLOT IDS, BASED ON THE KEY INT PROVIDED AT THE TOP OF A TEXT FILE
	var loadmrodir = Directory.new()
	if loadmrodir.open(MRODefaultPath) == OK:
		var finalloadedmros : String = ""
		loadmrodir.list_dir_begin(true)
		var mrofile = loadmrodir.get_next()
		while mrofile != "":
			if !"#" in mrofile and ".txt" in mrofile:
				#CREATE AN ARRAY TO STORE EVERY NUMBER IN THE MRO FILE - THE TOP NUMBER WILL BE [0], AND WE'LL USE THIS AS THE MAX RARITY
				#VALUE FOR THE SUBSEQUENT NUMBERS, WHICH WILL REPRESENT THE ITEMLOT IDS WHOSE MAX RARITY WILL BE SET TO LINE 0'S VALUE.
				var newmroentry : Array = []
				var newmro = File.new()
				if newmro.open(MRODefaultPath+"/"+mrofile,File.READ) == OK:
					while !newmro.eof_reached():
						var newentry :int = int(newmro.get_line())
						newmroentry.append(newentry)
					if newmroentry.size() >= 2:
						var newkey : int = 0
						for x in newmroentry.size():
							if x == 0:
								newkey = newmroentry[x]
							else:
								MaxRarityOverride[newmroentry[x]]=newkey
						finalloadedmros += mrofile+" "
						#print_debug(str(MaxRarityOverride))
			mrofile = loadmrodir.get_next()
		if MaxRarityOverride.keys().size() == 0:
			print_debug("No MROs Loaded.")
		else:
			print_debug("MROs Loaded: "+finalloadedmros)
	else:
		OS.alert("Could not open "+str(MRODefaultPath))
