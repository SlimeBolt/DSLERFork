extends Node
class_name EnemySpecificLootBank

var EnemySpecificLoot : Dictionary = {}
var ItemLotsToESL : Dictionary = {}

const defaultenemyspecificlootbankdict : Dictionary ={
	"enabled":1,
	"name":"EnemyLoot",
	"itemlotids":[0,1],
	"lootids":{
		0:[1000000],
		1:[40000],
		2:[]
	}
}

const enemylootpath : String = "user://enemyspecificloot"
const defaulteslname : String = "#Default_EnemySpecificLoot.json"

export (NodePath) var ReloadESLButtonPath
onready var ReloadESLButton = get_node(ReloadESLButtonPath)
export (NodePath) var ESLIndicatorPath
onready var ESLIndicator = get_node(ESLIndicatorPath)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	ReloadESLButton.connect("pressed",self,"load_enemyspecificlootbanks")
	create_enemyspecificloot_directory()
	create_default_enemyspecificlootbank()
	load_enemyspecificlootbanks()
	pass # Replace with function body.

func create_enemyspecificloot_directory():
	var esldir = Directory.new()
	if !esldir.dir_exists(enemylootpath):
		esldir.make_dir_recursive(enemylootpath)

func create_default_enemyspecificlootbank():
	var fulldefeslpath = enemylootpath+"/"+defaulteslname
	var defeslfile = File.new()
	if !defeslfile.file_exists(fulldefeslpath):
		defeslfile.open(fulldefeslpath,File.WRITE)
		defeslfile.store_string(JSON.print(defaultenemyspecificlootbankdict))
		defeslfile.close()
		
func load_enemyspecificlootbanks():
	EnemySpecificLoot.clear()
	ItemLotsToESL.clear()
	
	var ESLFinalText :String = ""
	
	#ITERATE THROUGH THE ENEMYLOOTPATH FOLDER TO FIND ALL COMPATIBLE FILES
	var eslb_dir = Directory.new()
	if eslb_dir.open(enemylootpath) == OK:
		eslb_dir.list_dir_begin(true)
		var eslb_file = eslb_dir.get_next()
		while eslb_file != "":
			if !"#" in eslb_file and ".json" in eslb_file:
				var neweslbjson = File.new()
				if neweslbjson.open(enemylootpath+"/"+eslb_file,File.READ) == OK:
					while !neweslbjson.eof_reached():
						var newelbjsonparse : JSONParseResult = JSON.parse(neweslbjson.get_line())
						#print(newelbjsonparse)
						var neweslbdict : Dictionary = newelbjsonparse.result
						if neweslbdict.keys() == defaultenemyspecificlootbankdict.keys() and neweslbdict["enabled"]==1:
							var nametoassign : String = neweslbdict["name"]
							#print_debug(nametoassign)
							#ADD EVERY LISTED ITEMLOT ID INTO ITEMLOTSTOESL, WITH THE NAME OF THE IMPORTED ENEMYLOOT PATH AS ITS VALUE
							for x in neweslbdict["itemlotids"].size():
								var newitemlotid :int = int(neweslbdict["itemlotids"][x])
								ItemLotsToESL[newitemlotid] = nametoassign
							#CREATE A NEW DICTIONARY TO STORE WHICH WEAPON AND ARMOR IDS ARE ASSIGNED TO EACH LOOT TYPE - 0=WEAPON, 1=ARMOR, 2=TALISMANS
							var compatibleidsdictionary : Dictionary = {
								0:[],
								1:[],
								2:[]
							}
							#print(neweslbdict["lootids"])
							compatibleidsdictionary[0]=neweslbdict["lootids"]["0"]
							compatibleidsdictionary[1]=neweslbdict["lootids"]["1"]
							compatibleidsdictionary[2]=neweslbdict["lootids"]["2"]
							#NOW ADD THAT DICTIONARY AS AN ENTRY IN ENEMYSPECIFICLOOT, WITH THE IMPORTED ENEMYSPECIFICLOOT SET'S NAME AS THE KEY
							EnemySpecificLoot[nametoassign]=compatibleidsdictionary
							#print_debug(str(compatibleidsdictionary))
							#FINALLY, ADD ESLB_FILE TO FINAL STRING TO SHOW IT'S BEEN LOADED
							ESLFinalText += neweslbdict["name"]+"\n"
						elif neweslbdict.keys() != defaultenemyspecificlootbankdict.keys():
							OS.alert("Enemy Specific Loot Bank '"+neweslbdict["name"]+"' has the wrong set of keys.\n\nIt has: "+str(neweslbdict.keys())+"\n\nIt should have: "+str(defaultenemyspecificlootbankdict.keys()))	
			eslb_file = eslb_dir.get_next()
		ESLIndicator.text = ESLFinalText
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
