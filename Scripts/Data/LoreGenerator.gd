extends Node
class_name LoreGenerator


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const OverrideLoreDirectory : String = "user://overridelore"
const DefaultOverrideLore : Dictionary = {
	"idset":[1000000],
	"WeaponorArmor":"Weapon",
	"lore":"This dagger does not deserve a custom lore description.\n\nFor real."
}


var OverrideLore : Dictionary = {
	"Weapon":{},
	"Armor":{}
}

var LoreRNG = RandomNumberGenerator.new()

var Names : Array = ["Margit","Morgott","Malenia","Queen Marika","Iji","Ranni","Blaidd","Maliketh","Gurranq",
"Rykard","Praetor Rykard","Hyetta","the Three Fingers","The Two Fingers","Shabriri","Yura","Eleonora",
"Godwyn the Golden","the Frenzied Flame","the Greater Will","Radagon","Queen Consort Radagon","the Erdtree Burial Watchdog",
"the Fell God","the Fire Giant","a Godskin Noble","a Godskin Apostle","the Gloam-Eyed Queen","the Nox","Sir Gideon Ofnir",
"Knight Bernahl","Recusant Bernahl","Nepheli Loux","Hoarah Loux","Godfrey, First Elden Lord","Godwyn, Prince of Death",
"Iji the Blacksmith","Merchant Kale","the Great Caravan","Blaidd the Half-Wolf","a Merchant","Kenneth Haight","Fortissax",
"Gransax","a Farum Azula Beastman","Mohg","an unknown individual","every single member of the Great Caravan","every single soldier in {PlaceName}",
"a Misbegotten","every single Misbegotten","a Dominula Celebrant","Melina","Torrent","the Witch Renna","Lunar Princess Ranni",
"Miquella","a big, strangely intelligent crab","a big, oddly sapient Land Octopus", "Godrick the Grafted","Godefroy the Grafted",
"Bloodhound Knight Darriwil","Stormhawk Deenh","a Noble from a far off land","a Commoner","the serpent Eiglay","Lady Tanith","Lady Tanith's daughter Rya",
"Zorayas","Rya","a frighteningly large number of sapient Runebears","a Chrystalian","a Stone Miner","Castellan Edgar","Irina",
"a mournfully singing Harpy","a Giant Bat singing in a faraway tongue","a Giant Bat","an absolute swarm of Basilisks"]

var Places : Array = ["Limgrave","Leyndell","Stormveil Castle","the Weeping Peninsula","Castle Morne","Dominula","Farum Azula",
"Mount Gelmir","Volcano Manor","the Shaded Castle","Altus Plateau"]

var ThingTheyDid = ["forged the Elden Ring,","stole a shard of Destined Death,","shattered the Elden Ring,",
"attacked the Fire Giants,","set out to slay the Gods,","set out to devour the Gods,","slew {EnemyName},","murdered {EnemyName},",
"married {FriendName},","adopted {FriendName},","found {EnemyName} in bed with their consort {FriendName},","became the Blade of {FriendName},",
"challenged {EnemyName},","set out on their path,","left {FriendName} behind,","revealed {EnemyName}'s greatest falsehood,","looked upon {PlaceName}",
"looked upon {PlaceName} with envious eyes,","abandoned {PlaceName},","was discovered to be bedding {FriendName},","named {FriendName} as their heir,",
"joined the militia protecting {PlaceName}"]

var UsedWeapOrArmor : Dictionary = {
	"Armor":["wore","donned","presented","cloaked themselves with"],
	"Weapon":["brandished","swung","struck their enemies with","smashed their enemies with","raised high","cut down {EnemyName} with",
	"roamed the Lands Between slaughtering Those Who Live In Death with","dueled {EnemyName} with","protected {FriendName} with",
	"crossed the wastes of Caelid with","beseiged {PlaceName} with","entered a Hero's Grave with","plundered the catacombs with",
	"presented {FriendName} with","crossed {PlaceName} with","besieged {PlaceName} with"]
}

var ResultOfUseWeaporArmor : Dictionary = {
	"Armor":["to hide among the peasants fleeing {PlaceName}.","to indicate their affairs were to be kept strictly private.","to pledge their allegiance to {FriendName}'s cause.",
	"to impress {FriendName}.","as they found it suited them.","as they liked how it looked.","to boost {FriendName}'s virility.","to boost their virility.",
	", flaunting their allegiance to {FriendName}.",", to tell all of their hatred of {EnemyName}.","to show their love for {PlaceName}.",
	"for the glory of {PlaceName}.","and it is believed this inspired a great fondness in {FriendName}.","so that {EnemyName} would not recognise them.","as they knew it would enrage {EnemyName} to see them wearing it.","to sow jealously in {EnemyName}."],
	"Weapon":["in a well-meaning but failed attempt to end the Shattering.","to kill {EnemyName}.","trying to kill {EnemyName}.","to help {FriendName} defeat {EnemyName}.",
	"to defeat {EnemyName} and win the hand of {FriendName}.","to clear the way for the marriage of {FriendName} and {EnemyName}.",", as the weapon's size and girth boosted their confidence.",
	"but it was not enough to save their trusted friend, {FriendName}.","but it was not enough to save their love, {FriendName}.",", but they were disarmed, and the weapon was lost.","in a last ditch attempt to save the people of {PlaceName2}.",
	"to indimidate {EnemyName} into silence.","to force {EnemyName} to leave.","so that {EnemyName} could never return to {PlaceName}.",", but they threw it away, no longer able to stomach the bloodshed they had caused.",", but their desire to coat the weapon with {EnemyName}'s blood went unfulfiled.",
	"so that the Night of the Black Knives would never reoccur."]
}


# Called when the node enters the scene tree for the first time.
func _ready():
	create_default_lore_override()
	load_lore_overrides()
	pass # Replace with function body.
	
func generate_lore_description(weaparmorname:String="None",armoriftrue:String="Weapon",rngseed:int=0,paramid:int=-1) -> String:
	LoreRNG.randomize()
	LoreRNG.seed = rngseed
	var lorearray : Array = [LoreRNG.randi_range(0,Names.size()-1),
	LoreRNG.randi_range(0,ThingTheyDid.size()-1),
	LoreRNG.randi_range(0,UsedWeapOrArmor[armoriftrue].size()-1),
	LoreRNG.randi_range(0,ResultOfUseWeaporArmor[armoriftrue].size()-1)]
	var Name1Enemy : String = Names[LoreRNG.randi_range(0,Names.size()-1)]
	var Name2Friend : String = Names[LoreRNG.randi_range(0,Names.size()-1)]
	var PlaceName : String = Places[LoreRNG.randi_range(0,Places.size()-1)]
	var Place2Name : String = Places[LoreRNG.randi_range(0,Places.size()-1)]
	var stringtoreturn = str("When "+Names[lorearray[0]]+" "+ThingTheyDid[lorearray[1]]+" they "+UsedWeapOrArmor[armoriftrue][lorearray[2]]+" this "+weaparmorname+" "+ResultOfUseWeaporArmor[armoriftrue][lorearray[3]]).format({"EnemyName":str(Name1Enemy),"FriendName":str(Name2Friend),"PlaceName":str(PlaceName),"PlaceName2":str(Place2Name)})
	
	#CATCH LORE OVERRIDES
	if OverrideLore[armoriftrue].keys().has(paramid):
		var overridestring = str(OverrideLore[armoriftrue][paramid])
		stringtoreturn = overridestring.replace("\n","\\n")
	#print(stringtoreturn)
	return stringtoreturn
	
func create_default_lore_override():
	var overrideloredir : Directory = Directory.new()
	if !overrideloredir.dir_exists(OverrideLoreDirectory):
		overrideloredir.make_dir_recursive(OverrideLoreDirectory)
	var defoverridelorefile : File = File.new()
	var fulloverridelorepath : String = OverrideLoreDirectory+"/#DEFAULT_OverrideLore.json"
	if !defoverridelorefile.file_exists(fulloverridelorepath):
		if defoverridelorefile.open(fulloverridelorepath,File.WRITE) == OK:
			defoverridelorefile.store_string(JSON.print(DefaultOverrideLore))
			defoverridelorefile.close()
	else:
		print("Default OverrideLore already exists!")
		
func load_lore_overrides():
	OverrideLore["Weapon"].clear()
	OverrideLore["Armor"].clear()
	var loredir : Directory = Directory.new()
	if loredir.open(OverrideLoreDirectory) == OK:
		loredir.list_dir_begin(true)
		var ovrfile = loredir.get_next()
		while ovrfile != "":
			if !"#" in ovrfile and ".json" in ovrfile:
				var newovr = File.new()
				if newovr.open(OverrideLoreDirectory+"/"+ovrfile,File.READ) == OK:
					var ovrparse = JSON.parse(newovr.get_line())
					var ovrdict : Dictionary = ovrparse.result
					if ovrdict.keys() == DefaultOverrideLore.keys():
						for x in ovrdict["idset"].size():
							OverrideLore[ovrdict["WeaponorArmor"]][int(ovrdict["idset"][x])] = ovrdict["lore"]
			ovrfile = loredir.get_next()
		print_debug(str(OverrideLore))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
