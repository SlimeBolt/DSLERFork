extends Node
class_name Weapon_Generator

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var weapgendatabase : GDDatabase = load("res://Databases/WeaponGenerationInfo.tres")

var RNG = RandomNumberGenerator.new()

export (NodePath) var SeedTextPath
onready var SeedText : TextEdit = get_node(SeedTextPath)
export (NodePath) var GenerateButtonPath
onready var GenerateButton : Button = get_node(GenerateButtonPath)
export (NodePath) var LoadItemLotsButtonPath
onready var LoadItemLotsButton : Button = get_node(LoadItemLotsButtonPath)
export (NodePath) var LoadedItemLotsIndicatorPath
onready var LoadedItemLotsIndicator : Label = get_node(LoadedItemLotsIndicatorPath)
export (NodePath) var OpenUserDirButtonPath
onready var OpenUserDirButton : Button = get_node(OpenUserDirButtonPath)
export (NodePath) var IndicatorLabelPath
onready var IndicatorLabel = get_node(IndicatorLabelPath)

export (NodePath) var LimitItemLotsPath
onready var LimitItemLots = get_node(LimitItemLotsPath)

export (NodePath) var WeaponBankPath
onready var WeaponBank = get_node(WeaponBankPath)
export (NodePath) var ArmorBankPath
onready var ArmorBank = get_node(ArmorBankPath)

const outputpathstart:String = "output/{SEEDTEXT}/"


##SLIDER NODES

export (NodePath) var MaxEarlyGameRaritySliderPath

#FORMAT IS [CREATEDLOOT,LOOTIDS,AVAILABLELOOTIDS]
var LootBanks : Dictionary = {}

##CUSTOM ITEMLOT JSON VARIABLES
const customitemlotsdir : String = "user://itemlotjsons/"

const LoadedItemlotsIndicatorString = "{ID}: {PATTERN}\nGuaranteed Drops: {GUARANTEED},\nOne Time Pickups: {ONETIME},\nDrop Chance Mult: {DROPCHANCEMULT},\nStat Req Mult:{STATREQMULT},\nStarting ID: {STARTID}\nEnding ID: {ENDID}\n\n"

var itemlotjsontemplate : Dictionary = {
	"customitemlotsetname":"Default",
	"guaranteeddrops":0,
	"onetimepickup":0,
	"loottypecreationpatterns":["00","11"],
	"itemlotidsarray":[250000301,227100503],
	"dropchancevaluemultiplier":1.0,
	"minweaponrarity":-1,
	"maxweaponrarity":-1,
	"weaponstatreqmultiplier":1.0,
	"outputparam":"ItemLotParam_enemy"
}

var CustomItemlotJsons : Array = []

const weaponscalingoptions : Array = ["correctStrength","correctAgility","correctMagic","correctFaith","correctLuck"]
const weapondamagevalues : Array = ["attackBasePhysics","attackBaseMagic","attackBaseFire","attackBaseThunder","attackBaseDark"]
const armordefencevalues : Array = ["neutralDamageCutRate","slashDamageCutRate","blowDamageCutRate","thrustDamageCutRate","magicDamageCutRate","fireDamageCutRate","thunderDamageCutRate","darkDamageCutRate"]

const ParamTypes : Dictionary = {
	0:"EquipParamWeapon",
	1:"ReinforceWeaponParam",
	2:"ItemLotParam_enemy",
	3:"ItemLotParam_map",
	4:"EquipParamProtector"
}

var FinalStrings : Dictionary ={
	"EquipParamWeapon":"",
	"ReinforceWeaponParam":"",
	"ItemLotParam_enemy":"",
	"ItemLotParam_map":"",
	"EquipParamAccessory":"",
	"SpEffectParam":"",
	"DescriptionWeapons.fmg.json":"",
	"TitleWeapons.fmg.json":"",
	"EquipParamProtector":"",
	"DescriptionArmor.fmg.json":"",
	"DescriptionRings.fmg.json":"",
	"SummaryRings.fmg.json":"",
	"TitleRings.fmg.json":"",
	"TitleArmor.fmg.json":"",
	"MassEditEnemyDrops":""
}

const ItemLotAssignments : Array = ["lotItemId0", "lotItemCategory0", "lotItemBasePoint0", "getItemFlagId0"]
const statreqkeys : Array = ["properStrength","properAgility","properMagic","properFaith","properLuck"]

#ITEM ACQUISITION - THERE'S THREE DIGITS BEYOND THIS, ONCE 999 IS REACHED, LOOP BACK, BUT KEEP THAT LAST ZERO HERE BECAUSE
#THAT MIGHT MAKE IT SAVE???
const ItemAcquisitionStart : int = 102426
const EquipParamWeaponStart : int = 10000
const EquipMtrlParamSetStart : int = 20000
const ArmorItemAcquisitionStart : int = 90000


const OptionalLimitedLootPerItemlot :int = 4


const UseExistingEffectChance : float = 0.3
const GeneratedSpEffectMultiplierDivisionThreshold : float = 1.6

var cumulativeids : Dictionary = {
	0:0,
	1:0,
	2:0,
	3:0,
	-1:0
}

var cumulativeassignids : Dictionary = {
	0:0,
	1:0,
	2:0,
	3:0
}

var ItemAcquisitionOffset : int = 0
var ItemAcquisitionFlagOffset : int = 0
var ItemAcquisitionFlagSequence : Array = [0,4,7,8,9]

# Called when the node enters the scene tree for the first time.
func _ready():
	create_itemlot_json_directory()
	GenerateButton.connect("pressed",self,"start_generation")
	LoadItemLotsButton.connect("pressed",self,"load_itemlot_jsons")
	OpenUserDirButton.connect("pressed",self,"open_user_data_folder")
	pass # Replace with function body.

#ITEMLOT HANDLER

func get_next_acquisition_id() -> int:
	#MULTIPLY BASENUMBER (102426) BY 10000 TO GET 1024260000
	var basenumber :int = (ItemAcquisitionStart+ItemAcquisitionOffset)*10000
	#NOW ADD THE CURRENT FLAG SEQUENCE[ITEMACQUISITIONFLAGOFFSET]*1000
	var newitemflagsequenceno : int = ItemAcquisitionFlagSequence[ItemAcquisitionFlagOffset]*1000
	basenumber += newitemflagsequenceno
	var numbertoreturn : int = basenumber+cumulativeids[-1]
	affect_cumulative_id_value(-1)
	return numbertoreturn


## WEAPON GENERATION FUNCTIONS

func start_generation():
	#MAKE SURE WE HAVE SOME WEAPONS LOADED
	if WeaponBank.WeaponBank.keys().size() > 0:
		#MAKE SURE WE HAVE SOME ITEMLOTS LOADED
		if CustomItemlotJsons.size() > 0:
			GenerateButton.disabled = true
			LoadItemLotsButton.disabled = true
			
			IndicatorLabel.text = "-WORKING-"
			yield(get_tree().create_timer(0.1),"timeout")
			call_deferred("generate_loot")
		else:
			IndicatorLabel.text = "-NO ITEMLOT SETS LOADED!-"
	else:
		IndicatorLabel.text = "-NO WEAPONS LOADED!-"


func generate_loot():
	clear_all_generated_weapons()
	clear_finalstring(true)
	$SpEffectGenerator._on_generation_start()
	affect_cumulative_id_value(0,1,true)
	affect_cumulative_assign_id_value(0,1,true)
	RNG.seed = hash(SeedText.text)
	#print_debug(hash(SeedText.text))
	
	##FILL THE ITEMLOT SETS ITEMLOTS IF THERE ARE ANY
	if CustomItemlotJsons.size() > 0:
		IndicatorLabel.text = "-FILLING ITEMLOT SETS-"
		yield(get_tree().create_timer(0.1),"timeout")
		for c in CustomItemlotJsons.size():
			fill_custom_itemlot_set(CustomItemlotJsons[c])
	
	##GENERATE THE SPEFFECT MASSEDIT FILE FOR THE NEW SEED FOLDER
	#FOR CONVENIENCE
	
	speffect_create_massedit_entries()

	IndicatorLabel.text = "-EXPORTING CSVS AND FMG.JSONS-"
	yield(get_tree().create_timer(0.1),"timeout")
	export_csvs_and_txts()
	create_default_reinforceparamweapon()
	
	#REACTIVATE GENERATE AND LOAD ITEMLOTS BUTTONS
	GenerateButton.disabled = false
	LoadItemLotsButton.disabled = false
	
	IndicatorLabel.text = "-COMPLETE!-"
	#for x in LootBanks.keys().size():
	#	LootBanks[LootBanks.keys()[x]].print_lootbank_available_ids()

func create_output_path_from_default() -> String:
	var newoutputpath :String = outputpathstart.format({"SEEDTEXT":str(SeedText.text)})
	#print(newoutputpath)
	var newoutputdir = Directory.new()
	if !newoutputdir.dir_exists("user://"+str(newoutputpath)):
		newoutputdir.make_dir_recursive("user://"+str(newoutputpath))
	newoutputpath = "user://"+str(newoutputpath)
	return newoutputpath
	
func export_csvs_and_txts():
	var ready:bool =false
	write_json_from_template(FinalStrings["TitleWeapons.fmg.json"],"TitleWeapons.fmg.json")
	write_json_from_template(FinalStrings["DescriptionWeapons.fmg.json"],"DescriptionWeapons.fmg.json")
	write_json_from_template(FinalStrings["TitleArmor.fmg.json"],"TitleArmor.fmg.json")
	write_json_from_template(FinalStrings["DescriptionArmor.fmg.json"],"DescriptionArmor.fmg.json")
	write_json_from_template(FinalStrings["TitleRings.fmg.json"],"TitleRings.fmg.json")
	write_json_from_template(FinalStrings["DescriptionRings.fmg.json"],"DescriptionRings.fmg.json")
	write_json_from_template(FinalStrings["SummaryRings.fmg.json"],"SummaryRings.fmg.json")
	write_csv(FinalStrings["EquipParamWeapon"],"EquipParamWeapon")
	write_csv(FinalStrings["ItemLotParam_enemy"],"ItemLotParam_enemy")
	write_csv(FinalStrings["ItemLotParam_map"],"ItemLotParam_map")
	write_csv(FinalStrings["SpEffectParam"],"SpEffectParam")
	write_csv(FinalStrings["EquipParamProtector"],"EquipParamProtector")
	write_csv(FinalStrings["EquipParamAccessory"],"EquipParamAccessory")

func clear_all_generated_weapons():
	for x in LootBanks.keys().size():
		LootBanks[LootBanks.keys()[x]].clear_lootbank()
		
	$SpEffectGenerator.MagicToolSpEffectIDs[1] = []
	$SpEffectGenerator.MagicToolSpEffectIDs[2] = []

func create_number_of_weapons(number:int=1):
	for x in number:
		create_weapon(x)

func create_weapon(minrarity:int=-1,maxrarity:int=-1,outputarraysid:int=0,statreqmultiplier:float=1.0,customname:String = "",forceid:int=-1):
	var newweapondict : Dictionary = {}
	newweapondict = weapon_create_dictionary_from_loaded_weapons(forceid)
	var newweaponname : String = ""
	newweaponname = newweapondict["Name"]
	var RarityValues :Dictionary = weapon_choose_rarity(minrarity,maxrarity)
	var effectstable = weapgendatabase.get_table("ArmorEffects")
	
	#QUICKLY GET CANCASTSORCERY/INCANTATIONS VALUE FROM DICT TO LET US RESTRICT STAFFS/SEALS TO RELEVANT EFFECTS ONLY
	var cancastarray : Array = [int(newweapondict["enableMagic"]),int(newweapondict["enableMiracle"])]
	
	var choseneffect = choose_armor_effect(RarityValues["mindmgmultiplier"],RarityValues["name"],false,cancastarray[0],cancastarray[1],false,"Weapon 1 ")
	#print(str(choseneffect["speffectid"])+" "+str(choseneffect["suffix"]))
	
	#STORE ORIGINAL ID FOR CATCHING LORE OVERRIDES
	var originalid = int(newweapondict["ID"])
	
	#GET BASE WEAPON WEPMOTIONCATEGORY AS INT
	var motioncategory = int(newweapondict["wepmotionCategory"])
	
	#DETERMINE IF WEAPON IS A SHIELD
	
	var weaponisshield : bool = weapon_is_weapon_shield(motioncategory)
	
	#FOR SOME REASON SOMETIMES THE GENERATOR STARTS PULLING EXISTING GENERATED NAMES, CAUSING WEIRD NAMES LIKE
	#"RARE RARE UNCOMMON [weaponname]" - NO IDEA WHAT'S CAUSING THIS BUT RESETTING THE NAME
	#AND PULLING A FRESH NAME FROM DEFAULTWEAPONNAMES SEEMS TO WORK AROUND THIS BUG
	#if "DSL" in newweaponname:
	#	newweaponname = ""
	#	#print_debug([])
	#	newweaponname = get_node("/root/WeaponGenDefaultArrays").DefaultWeaponNames[defaultweaponidsselection]
		
	#RANDOMISE WEAPON'S WEIGHT
	var newweaponweight : float = weapon_choose_weight(newweapondict["weight"])
	set_dictionary_value(newweapondict,"weight",str(newweaponweight))
	
	#BETA 0.4 - I'M DUMMYING THIS NEXT PART OUT, IT SEEMS TO HAVE SOME PROBLEMS WITH MAKING CERTAIN ATTACKS DO LESS DAMAGE THAN THEY SHOULD
	#IF WE HAVE AN ARRAY FOR THE WEAPON'S WEPMOTIONCATEGORY, CHOOSE A RANDOM BEHAVIOUR VARIATION, OTHERWISE LEAVE IT ALONE
	#if get_node("/root/WeaponGenDefaultArrays").wepmotionCategory.has(int(newweapondict["wepmotionCategory"])):
		#var newbehvar :int = weapon_choose_moveset(int(newweapondict["wepmotionCategory"]))
		#var printresult : bool = get_bool_chance(0.5)
		#if printresult:
		#	print_debug("Set "+str(newweaponname)+"'s BehVar to "+str(newbehvar)+", it was "+str(newweapondict["behaviorVariationId"]))
	#	set_dictionary_value(newweapondict,"behaviorVariationId",str(newbehvar))
	
	#SET ELEMENT CORRECT ID TO ALLOW PROPER DAMAGE SCALING FROM ALL SOURCES
	set_dictionary_value(newweapondict,"attackElementCorrectId","42300")

	#ASSIGN A RANDOM ASH OF WAR
	var newashofwar = choose_swordartsparam(newweapondict["wepmotionCategory"])
	if newashofwar > 0:
		set_dictionary_value(newweapondict,"swordArtsParamId",str(newashofwar))
	else:
		print("AoW choice for "+str(newweaponname)+" returned -1, skipping...")
	#if rand_range(0.0,100.0) > 80.0:
	#	print(str(newweaponname)+" swordArtsParamId: "+str(newweapondict["swordArtsParamId"]))
	
	#DISALLOW CHOOSING ASH OF WAR TO STOP WEAPONS BEING BOTH AMAZING STAT-WISE *AND* CUSTOMIZABLE
	set_dictionary_value(newweapondict,"disableGemAttr","0")
	set_dictionary_value(newweapondict,"gemMountType","2")
	
	#ADD AN EXTRA VALUE THAT DETERMINES THE WEAPON'S ITEMLOT DROP CHANCE
	newweapondict["itemlotdropchance"] = RarityValues["DropChance"]

	#GET BASE WEAPONS DAMAGE VALUES, FIND THE LARGEST ONE, AND CHOOSE NEW DAMAGE TYPE
	var originaldamagevalues : Array = weapon_get_current_weapon_damage_values(newweapondict)

	##RESET ALL BASE DAMAGE BEFORE GENERATING NEW VALUES
	set_dictionary_value(newweapondict,"attackBasePhysics","0")
	set_dictionary_value(newweapondict,"attackBaseMagic","0")
	set_dictionary_value(newweapondict,"attackBaseFire","0")
	set_dictionary_value(newweapondict,"attackBaseThunder","0")
	set_dictionary_value(newweapondict,"attackBaseDark","0")

	var basedamage :int = originaldamagevalues.max()
	## CHOOSE NEW DAMAGE TYPE
	var chosendamagetype = weapon_choose_damage_type()

	#REDUCE FINAL DAMAGE IF WEAPON IS A SHIELD WITH THIS MULTIPLIER
	var weaponisshieldmultiplier = 0.45 if weaponisshield else 1.0 
	##SET DAMAGE VALUES BASED ON RARITY - ARRAY COMPRISED OF [CHOSEN DAMAGE TYPE,AMOUNT]
	var finalprimarydamage = int(((basedamage) * RNG.randf_range(RarityValues["mindmgmultiplier"],RarityValues["maxdmgmultiplier"]))*weaponisshieldmultiplier)

	#print(newweapondict["Name"]+" "+str(basedamage)+" "+str(finalprimarydamage))
	#print(str(basedamage)+" "+str(finalprimarydamage))
	#SET PRIMARY DAMAGE
	set_dictionary_value(newweapondict,chosendamagetype["eqwparamvalue"],str(finalprimarydamage))
	if chosendamagetype["spAttribute"] > 0:
		set_dictionary_value(newweapondict,"spAttribute",str(chosendamagetype["spAttribute"]))
	
	##SET RESIDENTSFX PARAMETERS BASED ON CHOSEN DAMAGE TYPE
	if chosendamagetype["residentSfxId"] > 0:
		set_dictionary_value(newweapondict,"residentSfxId_1",str(chosendamagetype["residentSfxId"]))
		set_dictionary_value(newweapondict,"residentSfxId_2",str(chosendamagetype["residentSfxId"]))
		set_dictionary_value(newweapondict,"residentSfx_DmyId_1","300")
		set_dictionary_value(newweapondict,"residentSfx_DmyId_2","301")
		
	##RESET ALL SPEFFECTS ON BASE WEAPON AND SET MANDATORY BEHSPEFFECTS AND SPEFFECTMSGS IF PRESENT
	set_dictionary_value(newweapondict,"spEffectBehaviorId0","-1")
	set_dictionary_value(newweapondict,"spEffectBehaviorId1","-1")
	set_dictionary_value(newweapondict,"spEffectBehaviorId2","-1")
	set_dictionary_value(newweapondict,"spEffectMsgId0","-1")
	set_dictionary_value(newweapondict,"spEffectMsgId1","-1")
	set_dictionary_value(newweapondict,"spEffectMsgId2","-1")
	if chosendamagetype["mandatorybehspeffect"] > 0:
		set_dictionary_value(newweapondict,"spEffectBehaviorId0",str(chosendamagetype["mandatorybehspeffect"]))
		set_dictionary_value(newweapondict,"spEffectMsgId0",str(chosendamagetype["spEffectMsgId0"]))
		if (RarityValues["rarityvalue"] > 2 && chosendamagetype["mandatorybehspeffect"] > 4):
			var secondaryChosenDamageType = weapon_choose_damage_type()
			set_dictionary_value(newweapondict,"spEffectBehaviorId1",str(secondaryChosenDamageType["mandatorybehspeffect"]))
			set_dictionary_value(newweapondict,"spEffectMsgId1",str(secondaryChosenDamageType["spEffectMsgId0"]))
	
	#ROLL FOR SECONDARY DAMAGE BASED ON WEAPON RARITY AND APPLY
	var applysecondarydamage : bool = get_bool_chance(RarityValues["multidamagetypechance"])
	var secondarydamagedict : Dictionary = weapon_choose_secondary_damage(RarityValues)
	if applysecondarydamage:
		#GET THE BASE SECONDARY DAMAGE PARAM NAME - e.g. attackBasePhysics - SO WE CAN ADD TO IT IF NECESSARY
		var currentsecdamagevalue : int = int(newweapondict[secondarydamagedict["damagename"]])
		set_dictionary_value(newweapondict,secondarydamagedict["damagename"],str(currentsecdamagevalue+secondarydamagedict["damageamount"]))

	#NOW THE NEW DAMAGE VALUES HAVE BEEN SET, ADJUST THE WEAPON'S STAT REQUIREMENTS TO COMPENSATE
	var rarityrequirementsmultiplier : float = RarityValues["extraeffect0chance"]*0.9
	var newhighestweapondamage : int = weapon_get_damage_values_array_max(newweapondict)
	var statrequirementsmultiplier : float = weapon_choose_weaponstats_multiplier(newhighestweapondamage,160,statreqmultiplier,3.0,rarityrequirementsmultiplier)
	var finalweaponstatrequirements : Dictionary = weapon_choose_stat_requirements(newweapondict,0.99,1.01,statrequirementsmultiplier)
	#NOW WE HAVE THE FINAL WEAPON STAT REQUIREMENTS, APPLY THEM
	for x in finalweaponstatrequirements.keys().size():
		var newkey : String = str(finalweaponstatrequirements.keys()[x])
		newweapondict[newkey] = finalweaponstatrequirements[newkey]
		#print_debug(newweapondict["Name"]+" "+str(newkey)+" "+str(newweapondict[newkey]))

	#MAKE WEAPONS USE NEW REINFORCEPARAM
	set_dictionary_value(newweapondict,"reinforceTypeId",str(RarityValues["reinforceid"]))
	#print(str(newweapondict["Name"]+" "+str(newweapondict["reinforceTypeId"])))
	
	#SET WEAPON CRITICAL DAMAGE
	#MULTIPLY BY 2.5 IF WEAPON IS A DAGGER
	var daggermultiplier :float = 3.0 if int(newweapondict["wepmotionCategory"]) == 20 else 1.0
	var criticaldamagetoassign : int = int(weapon_choose_critical_damage(30)*daggermultiplier)
	set_dictionary_value(newweapondict,"throwAtkRate",str(criticaldamagetoassign))
	
	##SET WEAPON SELL PRICE
	set_dictionary_value(newweapondict,"sellValue",str(RarityValues["sellamount"]))

	#APPLY EFFECT IF RARITY SPEFFECT0 CHANCE IS CLEARED
	#CLEAR SPEFFECTID VALUES BEFORE DECIDING TO GIVE A RANDOM ONE
	set_dictionary_value(newweapondict,"residentSpEffectId","-1")
	set_dictionary_value(newweapondict,"residentSpEffectId1","-1")
	set_dictionary_value(newweapondict,"residentSpEffectId2","-1")
	
	#GREATLY INCREASE EFFECT CHANCE IF WE'RE MAKING A STAFF OR A SEAL
	var extrasealeffectchance : float = 0.0
	if cancastarray[0] == 1 or cancastarray[1] == 1:
		extrasealeffectchance = 0.3
	
	var addeffectchance = get_bool_chance(RarityValues["extraeffect0chance"]+extrasealeffectchance)
	
	if addeffectchance:
		set_dictionary_value(newweapondict,"residentSpEffectId",str(choseneffect["speffectid"]))
		
	#CHOOSE BEHAVIOUR SPEFFECT AND REPLACE 
	var beheffectchance : bool = get_bool_chance(RarityValues["extraeffect1chance"])
	var behspeffecttitle : String = ""
	if $Loot_BankBehSpEffects.LootBank_Loot.keys().size() > 0 and beheffectchance:
		var behspeffectdict : Dictionary = $Loot_BankBehSpEffects.LootBank_Loot[$Loot_BankBehSpEffects.LootBank_Loot.keys()[RNG.randi_range(0,$Loot_BankBehSpEffects.LootBank_Loot.keys().size()-1)]]
		set_dictionary_value(newweapondict,"spEffectBehaviorId2",str(behspeffectdict["speffectid"]))
		behspeffecttitle = " "+str(behspeffectdict["prefix"])
	
	#SET WEAPON DROP'S RARITY BASED ON rarityvalue
	
	newweapondict["rarity"] = RarityValues["rarityvalue"]

	#GENERATE NEW WEAPON NAME
	var effectsuffix : String = (" "+choseneffect["suffix"]) if addeffectchance else ""
	var raritytitle = RarityValues["name"]
	var damagetypeprefix = " " if chosendamagetype["type"] == "" else " "+str(chosendamagetype["type"])+" "
	var secondarydamagetypeprefix = "" if !applysecondarydamage else " "+secondarydamagedict["damagerealname"]
	var finalname :String = raritytitle+behspeffecttitle+secondarydamagetypeprefix+damagetypeprefix+newweaponname+effectsuffix

	##ADD A SMALL PART OF THE ITEMLOT SET NAME SO WE KNOW WHICH ITEMLOT SET THIS WEAPON CAME FROM
	var itemlotsetname = create_short_custom_name(customname)

	set_dictionary_value(newweapondict,"Name","DSL"+itemlotsetname+" "+finalname)

	#SET NEW GENERATED WEAPON'S ID BY ADDING id TO THE EquipParamWeaponStart CONST VALUE
	affect_cumulative_id_value(0)
	set_dictionary_value(newweapondict,"ID",str((EquipParamWeaponStart+cumulativeids[0])*10000))

	#REPLACE ORIGINAL ORIGINEQUIPWEP VALUES WITH NEW ID
	weapon_assign_origin_weapons(newweapondict)
	
	#SET WEAPON'S BLOCKING 

	var newweaponblockingvalues = weapon_choose_blocking_values(weaponisshield,motioncategory,chosendamagetype["eqwparamvalue"],secondarydamagedict["damagename"],RarityValues["mindmgmultiplier"])
	for x in newweaponblockingvalues.keys().size():
		newweapondict[newweaponblockingvalues.keys()[x]] = newweaponblockingvalues[newweaponblockingvalues.keys()[x]]
		#print(newweapondict[newweaponblockingvalues.keys()[x]])
	
	##SET WEAPON'S SCALING VALUES
	
	var newweaponscalingdict : Dictionary = weapon_choose_scaling(chosendamagetype["eqwparamvalue"],int(newweapondict["enableMagic"]),int(newweapondict["enableMiracle"]))
	for x in weaponscalingoptions.size():
		set_dictionary_value(newweapondict,weaponscalingoptions[x],str(newweaponscalingdict[weaponscalingoptions[x]]))

	#CREATE WEAPON DESCRIPTION
	var newweapondescription : String
	var newweaponlore : String = $LoreGenerator.generate_lore_description(finalname,"Weapon",RNG.seed,originalid)
	
	#ADD PRIMARY DAMAGE
	var primarydamagedescription = chosendamagetype["type"]
	if primarydamagedescription == "":
		primarydamagedescription = "Physical"
	##CREATE SECONDARY DAMAGE DESCRIPTION EVEN IF WE DIDN'T APPLY IT
	var secondarydamagedescription = ""
	#IF WE DID APPLY IT SET UP THE STRING BY APPLYING THE SECONDARY DAMAGE'S DESCRIPTION NAME
	if applysecondarydamage:
		secondarydamagedescription += " and "+secondarydamagedict["damagedescription"]
	
	newweapondescription += "Deals "+primarydamagedescription+secondarydamagedescription+" damage.\\n"
	#ADD DESCRIPTION OF SPECIAL EFFECT IF PRESENT
	if addeffectchance:
		newweapondescription += choseneffect["description"]+"\\n\\n"
	else:
		#ADD A GAP BETWEEN THE DAMAGE DESCRIPTION AND THE RANDOM LORE
		newweapondescription += "\\n"
	
	#SET materialSetId TO 0 TO TRY AND CURB FREE UPGRADES - BETA 0.4
	set_dictionary_value(newweapondict,"materialSetId","0")
	
	#ADD RANDOMLY GENERATED LORE
	newweapondescription += newweaponlore
	
	var finaldescriptiontextentry = create_text_entry(newweapondict["ID"],newweapondescription)
	add_to_finalstring("DescriptionWeapons.fmg.json",finaldescriptiontextentry)

	#CREATE WEAPONTITLE.FMG.JSON ENTRY FOR NEW WEAPON
	var newweapontitleentry: String = create_text_entry(newweapondict["ID"],finalname)
	add_to_finalstring("TitleWeapons.fmg.json",newweapontitleentry)

	#CREATE DICTIONARY STRING AND ADD IT TO RELEVANT FINAL STRINGS
	var finalweaponstring : String = compile_dictionary_values_line_from_headers(newweapondict,get_node("/root/WeaponGenDefaultArrays").ParamHeaders["EquipParamWeapon"])
	add_to_finalstring("EquipParamWeapon",finalweaponstring)

	#EXPORT TO CHOSEN LOOT ARRAY
	export_values_to_loot_bank(0,newweapondict,int(newweapondict["ID"]),int(newweapondict["ID"]))

func weapon_get_damage_values_array_max(weapondictionary:Dictionary)->int:
	var damagearray : Array = []
	for x in weapondamagevalues.size():
		damagearray.append(int(weapondictionary[weapondamagevalues[x]]))
	var highestdamagevalue : int = damagearray.max()
	#print_debug(str(weapondictionary["Name"])+"'s highest damage value: "+str(highestdamagevalue)+" "+str(damagearray))
	return highestdamagevalue
		
func weapon_choose_weaponstats_multiplier(highestdamagevalue:int=100,threshold:int=150,minimummultiplier:float=1.0,maximummultiplier:float=2.5,raritybonusmultiplier:float=0.0)->float:
	var multipliertoreturn : float = 1.0
	multipliertoreturn = highestdamagevalue / threshold
	multipliertoreturn = clamp(multipliertoreturn,minimummultiplier,maximummultiplier)
	
	#FINALLY, ADD THE RARITY BONUS MULTIPLIER
	multipliertoreturn += raritybonusmultiplier
	
	return multipliertoreturn

func weapon_create_dictionary_from_loaded_weapons(forcedid:int=-1):
	var shieldchance : bool = get_bool_chance(0.05)
	var weaponbanktoquery : String = "weapons"
	if shieldchance:
		#print_debug("Making a shield!")
		weaponbanktoquery = "shields"
	
	#print(WeaponBank.WeaponBank[weaponbanktoquery])
	
	if WeaponBank.WeaponBank[weaponbanktoquery].keys().size() > 0:
		var weaponheaders : Array = get_node("/root/WeaponGenDefaultArrays").ParamHeaders["EquipParamWeapon"]
		
		#CHOOSE A WEAPON, THEN IF FORCEDID IS MORE THAN 0 AND OUR OTHER CONDITIONS ARE MET REPLACE IT WITH THE FORCED ONE
		var chosenweapon : Array = WeaponBank.WeaponBank[weaponbanktoquery][WeaponBank.WeaponBank[weaponbanktoquery].keys()[RNG.randi_range(0,WeaponBank.WeaponBank[weaponbanktoquery].keys().size()-1)]]
		
		if forcedid > 0 and WeaponBank.WeaponBank[weaponbanktoquery].has(forcedid):
			#print("WeaponBank has forced ID "+str(forcedid)+", choosing indicated weapon from WeaponBank!")
			chosenweapon = WeaponBank.WeaponBank[weaponbanktoquery][forcedid]
		
		var dicttoreturn : Dictionary = {}
		
		#SPECIFY WHICH EQUIPPARAMWEAPON HEADERS NEED TO BE WHICH VARIABLE
		var weaponheaders_ints : Array = ["ID","properStrength","properAgility","properMagic","properFaith","properLuck","wepmotionCategory"]
		var weaponheaders_floats : Array = ["correctStrength","correctAgility","correctMagic","correctFaith","correctLuck","weight"]
		
		for x in weaponheaders.size():
			##CATCH SOME SPECIAL CASES TO MAKE SURE WE GET THE RIGHT VARIABLE TYPE OUT OF THEM
			if weaponheaders_ints.has(weaponheaders[x]):
				dicttoreturn[weaponheaders[x]] = int(chosenweapon[x])
			elif weaponheaders_floats.has(weaponheaders[x]):
				dicttoreturn[weaponheaders[x]] = float(chosenweapon[x])
			else:
				dicttoreturn[weaponheaders[x]] = chosenweapon[x]
		return dicttoreturn

func weapon_get_current_weapon_damage_values(weapon:Dictionary)->Array:
	var arraytoreturn : Array = [0,0,0,0,0]
	for x in weapondamagevalues.size():
		arraytoreturn[x] = int(weapon[weapondamagevalues[x]])
	if rand_range(0,1) > 0.7:
		#print(str(weapon["Name"])+" "+str(arraytoreturn))
		pass
	return arraytoreturn
	

func weapon_choose_stat_requirements(weapon:Dictionary,minvariance:float=0.9,maxvariance:float=1.15,multiplier:float=1.0)->Dictionary:
	var statreqarray :Array = []
	#print(statreqarray)
	#ITERATE ON THE WEAPON DICTIONARY TO GET THE VALUES FOR EACH STATREQKEY
	for x in statreqkeys.size():
		statreqarray.append(weapon[statreqkeys[x]])
	
	var finalstatreqdict : Dictionary = {}
	for x in statreqkeys.size():
		finalstatreqdict[statreqkeys[x]] = int((statreqarray[x]*RNG.randf_range(minvariance,maxvariance)*multiplier))
		#CLAMP VALUES TO STOP THEM GETTING TOO RIDICULOUSLY HIGH
		finalstatreqdict[statreqkeys[x]] = clamp(finalstatreqdict[statreqkeys[x]],0,60)
	return finalstatreqdict

func weapon_choose_scaling(primarydamagetype:String="attackBasePhysics",enableMagic:int=0,enableMiracle:int=0)->Dictionary:
	#SETUP OUR SCALING OPTION VALUES BASED ON SCALINGOPTIONS CONST
	var newweaponscalingdict:Dictionary = {}
	for x in weaponscalingoptions.size():
		newweaponscalingdict[weaponscalingoptions[x]]=0
	
	#NOW ASSIGN A RANDOM BASELINE FOR EACH STAT
	for x in weaponscalingoptions.size():
		newweaponscalingdict[weaponscalingoptions[x]]=RNG.randi_range(8,15)
	
	#CHOOSE TWO SCALING OPTIONS TO MULTIPLY TO GET OUR PRIMARY AND SECONDARY SCALING ATTRIBUTES
	var primaryscalingmultiplier = RNG.randf_range(7,10)
	var secondaryscalingmultiplier = RNG.randf_range(4,8)
	var primaryscalingparamid : int = RNG.randi_range(0,weaponscalingoptions.size()-1)
	var secondaryscalingparamid : int = RNG.randi_range(0,weaponscalingoptions.size()-1)
	
	#OVERRIDE THIS RANDOMLY CHOSEN PARAM FOR OUR PRIMARY SCALING STAT BASED ON THE KIND OF DAMAGE OUR WEAPON DOES
	#"attackBaseMagic","attackBaseFire","attackBaseThunder","attackBaseDark"
	match primarydamagetype:
		"attackBaseThunder":
			primaryscalingparamid = 3
			secondaryscalingparamid = RNG.randi_range(0,1)
		"attackBaseFire":
			primaryscalingparamid = 2
			secondaryscalingparamid = RNG.randi_range(0,1)
		"attackBaseMagic":
			primaryscalingparamid = 2
		"attackBaseDark":
			primaryscalingparamid = 3
		_:
			primaryscalingparamid = RNG.randi_range(0,1)
			#CHANCE TO MAKE NORMAL WEAPONS SCALE WITH SOMETHING OTHER THAN DEX OR STR
			var scalewithall : bool = get_bool_chance(0.4)
			#IF WE FAIL THE SCALE WITH ALL CHECK, CHOOSE EITHER STR OR DEX, OTHERWISE DON'T TOUCH THE ORIGINAL
			#SECONDARYSCALINGPARAMID RESULT
			if !scalewithall:
				secondaryscalingparamid = RNG.randi_range(0,1)
			
	##CATCH IF WE'RE MAKING A SEAL OR STAFF AND OVERWRITE ABOVE BY CHECKING enableMiracle AND enableMagic
	if enableMagic == 1:
		primaryscalingparamid = 2
		#print_debug("Making a Staff!")
	elif enableMiracle == 1:
		primaryscalingparamid = 3
		#print_debug("Making a Seal!")
	
	var finalprimaryscaling : int = newweaponscalingdict[weaponscalingoptions[primaryscalingparamid]]*primaryscalingmultiplier
	var finalsecondaryscaling : int = newweaponscalingdict[weaponscalingoptions[secondaryscalingparamid]]*secondaryscalingmultiplier
	newweaponscalingdict[weaponscalingoptions[primaryscalingparamid]] = finalprimaryscaling
	#CATCH THE SECONDARY SCALING PARAM BEING THE SAME AS THE FIRST AND OVERWRITING IT BY JUST GIVING THE PRIMARY
	#SCALING PARAM VALUE A 30% BONUS
	if secondaryscalingparamid == primaryscalingparamid:
		newweaponscalingdict[weaponscalingoptions[primaryscalingparamid]] += 20.0
	else:
		newweaponscalingdict[weaponscalingoptions[secondaryscalingparamid]] = finalsecondaryscaling
	
	#CLAMP EVERY SCALE TO 150, WHICH IS AN A
	for x in weaponscalingoptions.size():
		newweaponscalingdict[weaponscalingoptions[x]]=clamp(newweaponscalingdict[weaponscalingoptions[x]],0.0,150.0)
	
	#RETURN DICTIONARY
	return newweaponscalingdict
	
func weapon_choose_scaling_old(primarydamagetype:String="attackBasePhysics")->Dictionary:
	#SETUP OUR SCALING OPTION VALUES BASED ON SCALINGOPTIONS CONST
	var newweaponscalingdict:Dictionary = {}
	for x in weaponscalingoptions.size():
		newweaponscalingdict[weaponscalingoptions[x]]=0
		
	var primaryscalingstat : int = 0
	var primaryscalingvalue : float = round(RNG.randf_range(40.0,100.0))
	var secondaryscalingstat : int = 1
	var secondaryscalingvalue : float = 0.0
	#CREATE A BOOL TO DECIDE IF WE WANT TO FORCE A SECONDARY SCALING VALUE
	var forcedsecondaryscalingvalue : bool = false
	#weaponscalingoptions : Array = ["correctStrength","correctAgility","correctMagic","correctFaith","correctLuck"]
	match primarydamagetype:
		"attackBaseMagic":
			#GREATLY SCALES WITH MAGIC
			primaryscalingstat = RNG.randi_range(0,2)
			secondaryscalingstat = 2
			forcedsecondaryscalingvalue = true
		"attackBaseFire":
			#SCALES WITH BOTH FAITH AND MAGIC
			primaryscalingstat = RNG.randi_range(0,2)
			secondaryscalingstat = 3
			forcedsecondaryscalingvalue = true
		"attackBaseThunder":
			#SCALES WITH EITHER STR OR DEX AS WELL AS FAITH
			primaryscalingstat = RNG.randi_range(0,1)
			secondaryscalingstat = 3 
			forcedsecondaryscalingvalue = true
		"attackBaseDark":
			#GREATLY SCALES WITH FAITH
			primaryscalingstat = 3
			secondaryscalingstat = 3
			forcedsecondaryscalingvalue = true
		_:
			primaryscalingstat = RNG.randi_range(0,1)
			secondaryscalingstat = RNG.randi_range(0,1)
	##SMALL CHANCE TO MAKE THE PRIMARY SCALING LUCK-BASED
	var useluck = get_bool_chance(0.1)
	primaryscalingstat = 4 if useluck else primaryscalingstat
	newweaponscalingdict[weaponscalingoptions[primaryscalingstat]] = primaryscalingvalue
	
	#SET SECONDARY SCALING IF WE PASS A CHANCE CHECK OR FORCEDSECONDARYSCALINGVALUE IS TRUE
	var usesecondaryscaling = get_bool_chance(0.7)
	if usesecondaryscaling or forcedsecondaryscalingvalue:
		secondaryscalingvalue = round((RNG.randf_range(20.0,100.0))*0.8)
	
	#IF SECONDARY SCALING STAT IS THE SAME AS PRIMARY AND WE'RE USING SECONDARY SCALING, ADD SECONDARY TO IT MINIMUM 20% AND CLAMP TO 99
	if secondaryscalingstat == primaryscalingstat and (usesecondaryscaling or forcedsecondaryscalingvalue):
		var secondaryscalingtoadd = 20.0 if secondaryscalingvalue < 20.0 else secondaryscalingvalue
		newweaponscalingdict[weaponscalingoptions[primaryscalingstat]] = primaryscalingvalue + 20.0
		#print_debug("Sec Scaling same as Pri Scaling! "+str(primaryscalingvalue)+" "+str(primaryscalingvalue + 25.0))
		if newweaponscalingdict[weaponscalingoptions[primaryscalingstat]] > 99.0:
			newweaponscalingdict[weaponscalingoptions[primaryscalingstat]] = 99.0
	newweaponscalingdict[weaponscalingoptions[secondaryscalingstat]] = secondaryscalingvalue
	
	return newweaponscalingdict

func weapon_assign_origin_weapons(newweapondict:Dictionary):
	var weaponid : String = str(newweapondict["ID"])
	set_dictionary_value(newweapondict,"originEquipWep",weaponid)
	for x in 25:
		match x:
			0,1:
				set_dictionary_value(newweapondict,"originEquipWep"+str(x+1),weaponid)
			_:
				set_dictionary_value(newweapondict,"originEquipWep"+str(x+1),"-1")

func weapon_choose_critical_damage(maximum:int=0) -> int:
	var critdamagetoreturn: int = RNG.randi_range(0,maximum)
	return critdamagetoreturn

func weapon_choose_moveset(weaponmotioncategory:int=20) -> int:
	var inttoreturn = 100
	if get_node("/root/WeaponGenDefaultArrays").wepmotionCategory.has(weaponmotioncategory):
		#GET THE ARRAY OF WHICH BEHAVIOUR VARIATIONS CORRESPOND TO WHICH WEPMOTIONCATEGORY VALUE AND USE ITS SIZE TO DETERMINE HOW MANY
		#BEHVARIATIONS WE HAVE TO CHOOSE FROM, THEN PICK A RANDOM NUMBER BETWEEN 0 AND THAT SIZE
		var intresult = RNG.randi_range(0,get_node("/root/WeaponGenDefaultArrays").wepmotionCategory[weaponmotioncategory].size()-1)
		var movesetoptions :Array = get_node("/root/WeaponGenDefaultArrays").wepmotionCategory.keys()
		inttoreturn = get_node("/root/WeaponGenDefaultArrays").wepmotionCategory[weaponmotioncategory][intresult]
	#print_debug("WMotionCategory: "+str(weaponmotioncategory)+" ChosenBehVariation: "+str(inttoreturn))
	return inttoreturn

func weapon_choose_secondary_damage(rarityvalues:Dictionary) -> Dictionary:
	var minmaxsecdmg : Array = [rarityvalues["minmultitypedamage"],rarityvalues["maxmultitypedamage"]]
	var damagenames : Array = ["attackBasePhysics","attackBaseFire","attackBaseMagic","attackBaseThunder","attackBaseDark"]
	var secondaryvfxids : Array = [-1,303001,303071,303011,303131]
	var damagerealnames : Array = ["Tempered","Burning","Glintstone","Bolt-charged","Holy"]
	var damagedescnames : Array = ["Physical","Fire","Magic","Lightning","Holy"]
	var chosendamagename : int = RNG.randi_range(0,damagenames.size()-1)
	var dictionarytoreturn = {
		"damagename":damagenames[chosendamagename],
		"damagerealname":damagerealnames[chosendamagename],
		"damagedescription":damagedescnames[chosendamagename],
		"damageamount":RNG.randi_range(minmaxsecdmg[0],minmaxsecdmg[1]),
		"secondaryvfx":secondaryvfxids[chosendamagename]
	}
	return dictionarytoreturn

func weapon_choose_blocking_values(isdefensiveweapon:bool=false,wepmotioncategory:int=20,primarydamage:String ="attackBasePhysics",secondarydamage:String="attackBasePhysics",raritymultiplier:float=1.0) -> Dictionary:
	var blockingvalues : Dictionary = {
		"physGuardCutRate":0,
		"magGuardCutRate":0,
		"fireGuardCutRate":0,
		"thunGuardCutRate":0,
		"darkGuardCutRate":0
	}
	
	var attacktoblockingtranslation : Dictionary = {
		"attackBasePhysics":"physGuardCutRate",
		"attackBaseMagic":"magGuardCutRate",
		"attackBaseFire":"fireGuardCutRate",
		"attackBaseThunder":"thunGuardCutRate",
		"attackBaseDark":"darkGuardCutRate"
	}

	#print("Blocking Multiplier: "+str(blockingmultiplier))

	var cutrates : Array = blockingvalues.keys()
	var blockingmultiplier = RNG.randf_range(0.65,0.75)
	var finalraritymultiplier :float = 0.0
	
	#IF WEAPON IS A SHIELD, INCREASE THE BLOCKING MULTIPLIER AND SET FINAL RARITY MULTIPLIER FROM 0
	if isdefensiveweapon:
		blockingmultiplier += 0.2
		finalraritymultiplier = raritymultiplier
		finalraritymultiplier = clamp(finalraritymultiplier,0.9,6.0)
	#IF WEAPON HAS A GREATSHIELD WEPMOTIONCATEGORY, INCREASE THE BLOCKING MULTIPLIER EVEN FURTHER
	if wepmotioncategory == 47:
		blockingmultiplier += 0.2
		
	#HANDLE AN ADDITIONAL BLOCKING AMOUNT CONTROLLED BY A SHIELD'S RARITY MULTIPLIER
	var shieldrarityaddition = 0.1 * finalraritymultiplier
	#STOP THIS FROM GETTING OUT OF HAND
	shieldrarityaddition = clamp(shieldrarityaddition,0.0,0.4)
		
	##ALLOW POSSIBILITY OF 100% BLOCK IF OUR WEAPON IS A SHIELD, OTHERWISE HAVE IT BE 70
	var maxblockrate : int = 100 if isdefensiveweapon else 70
	
	for x in cutrates.size():
		blockingvalues[cutrates[x]] = int((RNG.randi_range(10,maxblockrate)*blockingmultiplier)+shieldrarityaddition)
	
		
	#IF OUR WEAPON IS A SHIELD, GET OUR PRIMARY AND SECONDARY DAMAGE TYPE, CONVERT IT TO A CUTRATE TYPE AND GIVE A 30% BONUS TO IT, CAPPING AT 99
	if isdefensiveweapon:
		var bestdefenseparam : String = "physGuardCutRate"
		var secondbestdefenseparam : String = "physGuardCutRate"
		if attacktoblockingtranslation.has(primarydamage):
			bestdefenseparam = attacktoblockingtranslation[primarydamage]
		if attacktoblockingtranslation.has(secondarydamage):
			secondbestdefenseparam = attacktoblockingtranslation[secondarydamage]
		var newbestblockingvalue : int = blockingvalues[bestdefenseparam] + 30
		var newsecondbestblockingvalue : int = blockingvalues[secondbestdefenseparam] + 20
		#IF WEAPON IS A GREATSHIELD, FORCE THE PRIMARY BLOCKING VALUE TO 100%
		if wepmotioncategory == 47:
			newbestblockingvalue = 100
		blockingvalues[bestdefenseparam] = newbestblockingvalue
		blockingvalues[secondbestdefenseparam] = newsecondbestblockingvalue
	
	# JUST BEFORE WE RETURN THE VALUE, CLAMP EACH VALUE IN BLOCKINGVALUES TO 100
	for x in blockingvalues.size():
		blockingvalues[cutrates[x]] = int(clamp(blockingvalues[cutrates[x]],0,100))
	
	#print_debug(blockingvalues)

	return blockingvalues

func weapon_choose_weight(basevalue:float=1.5) -> float:
	var weighttoreturn = (round(RNG.randf_range(basevalue*0.85,basevalue*1.15)*100)) * 0.01
	#print(str(basevalue)+" "+str(weighttoreturn))
	return weighttoreturn

func weapon_choose_damage_type() -> Dictionary:
	var damagetable = weapgendatabase.get_table("DamageTypes")
	var numberofdamagetypes : int = damagetable.get_row_count()
	var chosendamagetype :int = RNG.randi_range(0,numberofdamagetypes-1)
	var physdamageonly : bool = get_bool_chance(0.5)
	if physdamageonly:
		chosendamagetype = 0
	var damagetypedict : Dictionary = damagetable.get_row_by_index(chosendamagetype)
	return damagetypedict

func weapon_choose_rarity(minrarityid:int=-1,maxrarityid:int=-1) -> Dictionary:
	
	#FIRST, SETUP VARIABLES FOR A CHOSEN RARITY INT AND A BOOL THAT
	#WILL STOP THAT RARITY BEING CHANGED AFTER IT'S ALREADY BEEN SET
	var chosenrarity : int = 0
	var rarityselected : bool = false
	var raritytable = weapgendatabase.get_table("Rarities")
	var raritydict : Dictionary = {}
	
	var raritychoicedict : Dictionary = {}
	
	##HANDLE OUR MIN AND MAX VALUES - START BY HAVING THE MAX AS THE TOTAL ROW COUNT -1
	#TO ACCOUNT FOR A "FOR" LOOP STARTING AT 0, NOT 1
	var maxrarityindex = raritytable.get_row_count()
	var minrarityindex = 0
	
	#CATCH MAXRARITYID BEING SET TO MORE THAN MAXRARITYINDEX
	
	if maxrarityid > maxrarityindex:
		maxrarityid = maxrarityindex
	
	#FIRST, IF MINRARITYID AND MAXRARITYID ARE THE SAME AND ABOVE -1, JUST GRAB THE ROW THEY'RE INDICATING AND RETURN IT
	#ALSO CATCH IF MINRARITYID IS SET ABOVE THE TOTAL NUMBER OF RARITIES AVAILABLE
	if minrarityid > -1 and minrarityid == maxrarityid:
		raritydict = raritytable.get_row_by_index(minrarityid)
		#print_debug("Rarities are the same, returning indicated MinRarityId - "+str(raritydict["name"]))
		return raritydict
	elif minrarityid >= raritytable.get_row_count():
		raritydict = raritytable.get_row_by_index(raritytable.get_row_count()-1)
		#print_debug("Min Rarity set above total number of rarities available and no Max Rarity set - returning last available rarity, "+str(raritydict["name"]))
		return raritydict
	else:	
		#OTHERWISE...
		#IF MAXRARITYID IS 0+ AND MORE THAN MINRARITY LET IT BE SET
		if maxrarityid > minrarityid and maxrarityid > -1:
			maxrarityindex = maxrarityid
		#IF MINRARITYID IS 0+ AND LESS THAN OR EQUAL TO MAXRARITY INDEX LET IT BE SET 
		if (minrarityid < maxrarityid and minrarityid > -1) or (minrarityid > -1 and maxrarityid == -1):
			minrarityindex = minrarityid
		#print_debug(str([minrarityindex,maxrarityindex,maxrarityindex-minrarityindex]))
		
		#TO COMPILE A WEIGHTED RANDOM CHANCE, WE START WITH A TOTAL CHANCE INT AT 0
		#AND AN ARRAY TO STORE OUR THRESHOLDS
		var totalweightedchance : int = 0
		var raritychancethresholds : Array = []
		for x in maxrarityindex - minrarityindex:
			#OFFSET OUR INDEX TO GRAB RARITYTABLE ROWS FROM BY MINRARITYINDEX
			var indextocheck = x+minrarityindex
			var newrarityrow = raritytable.get_row_by_index(indextocheck)
			#ADD THIS RARITY'S SELECTION CHANCE VALUE TO TOTALWEIGHTED CHANCE...
			totalweightedchance += newrarityrow["selectionchance"]
			#... AND ADD THE CURRENT SUM OF TOTALWEIGHTED CHANCE, THE INDEX INT THAT WILL BE
			#SET IF THE RANDOM NUMBER WE'RE ABOUT TO MAKE IS LESS OR EQUAL TO IT, AND THE NAME OF
			#THE RARITY FOR READABILITY
			raritychancethresholds.append([totalweightedchance,indextocheck,newrarityrow["name"]])
		#print_debug(raritychancethresholds)
		
		#NOW WE HAVE OUR THRESHOLDS AND THE INDEX THAT WILL BE USED IF THE RANDOM
		#NUMBER WE'RE ABOUT TO GENERATE IS LESS THAN OR EQUAL TO IT, WE GENERATE
		#THAT NUMBER AND ITERATE OVER EVERY ENTRY IN RARITYCHANCE THRESHOLDS
		
		var randomresult : int = RNG.randi_range(0,totalweightedchance)
		
		for x in raritychancethresholds.size():
			if randomresult <= raritychancethresholds[x][0]:
				if rarityselected == false:
					rarityselected = true
					chosenrarity = raritychancethresholds[x][1]
					#print_debug("Chosen Rarity Index: "+str(chosenrarity)+", random result was "+str(randomresult))
				else:
					if rarityselected == false:
						print_debug("Rarity already chosen!")
					
		raritydict = raritytable.get_row_by_index(chosenrarity)
		
		return raritydict

func create_weapon_name(weapontype:String="Dagger",rarity:String="Common",specialdamage:String="") -> String:
	var spdamagespace = "" if specialdamage == "" else " "
	var stringtoreturn = rarity+spdamagespace+specialdamage+" "+weapontype
	return stringtoreturn

func weapon_is_weapon_shield(wepmotioncategory:int=20) -> bool:
	var booltoreturn = false
	#SETUP THE WEPMOTIONIDS TO IDENTIFY IF THIS NEW WEAPON IS A SHIELD
	var shieldwepmotioncategories : Array = [47,49,48]
	
	if shieldwepmotioncategories.has(wepmotioncategory):
		booltoreturn = true
	return booltoreturn
	
func choose_swordartsparam(wepmotionid:int=-1) -> int:
	var selection : int = 10
	#CHECK IN SwordArtsParam.gd's wepmotionrestrictedsap VARIABLE TO SEE IF THE CURRENT WEPMOTION ID IS THERE, IF THE SAME SCRIPT'S
	#SWORDARTSPARAM VARIABLE HAS AN ARRAY FOR THAT SAME WEPMOTIONID, CHOOSE A NUMBER FROM THAT
	if get_node("/root/SwordArtsParam").wepmotionrestrictedsap.has(wepmotionid) and get_node("/root/SwordArtsParam").SwordArtsParam.has(wepmotionid):
		selection = get_node("/root/SwordArtsParam").SwordArtsParam[wepmotionid][RNG.randi_range(0,get_node("/root/SwordArtsParam").SwordArtsParam[wepmotionid].size()-1)]
	#OTHERWISE WE GRAB ONE OF THE GENERIC USER APPLICABLE SWORD/UNIQUE AOWS FROM SWORDARTSPARAM[-1]
	elif !get_node("/root/SwordArtsParam").wepmotionrestrictedsap.has(wepmotionid):
		selection = get_node("/root/SwordArtsParam").SwordArtsParam[-1][RNG.randi_range(0,get_node("/root/SwordArtsParam").SwordArtsParam[-1].size()-1)]
	return selection

func get_bool_chance(chancetarget:float=0.9) -> bool:
	var booltoreturn = false
	var randomchance = RNG.randf_range(0.0,1.0)
	if randomchance > 1.0-chancetarget:
		booltoreturn = true
	return booltoreturn

## TALISMAN GENERATION FUNCTIONS

func choose_talisman_type() -> Dictionary:
	var talismantable = weapgendatabase.get_table("TalismanInfo")

	var talismantypedict : Dictionary

	return talismantypedict

func choose_talisman_tier(talismantableid:int=0) -> Dictionary:
	var talismantable = weapgendatabase.get_table("TalismanInfo")
	var chosentalismanrow = talismantable.get_row(talismantableid)
	var tiercolumnids : Array = ["effectid_lesser","effectid","effectid_greater","effectid_ultimate"]
	var tiertoget = RNG.randi_range(0,tiercolumnids.size()-1)

	var talismantierdict :Dictionary = {}
	talismantierdict["tier"] = tiercolumnids[tiertoget]
	talismantierdict["tierint"] = tiertoget
	return talismantierdict

## ARMOR GENERATION FUNCTIONS

func get_armor_dictionary_from_id(armorid:int=40000) -> Dictionary:
	var armorvaluesarray :Array = get_node("/root/WeaponGenDefaultArrays").ArmorDefaults[armorid]
	var armorheadersarray :Array = get_node("/root/WeaponGenDefaultArrays").ParamHeaders["EquipParamProtector"]
	var armordict :Dictionary = {}
	for x in armorheadersarray.size()-1:
		armordict[armorheadersarray[x]] = armorvaluesarray[x]
	#print(armordict)
	return armordict

func choose_armor_effect(generatedeffectvaluemultiplier:float=1.0,
		rarityname:String="",
		allowcustom:bool=false,
		cancastsorceries:int=0,
		cancastincantations:int=0,
		forcecustomeffect:bool=false,
		whoaskedforthis:String="") -> Dictionary:
	#print(LootBanks[3].LootBank_Loot.keys())
	var numberofeffects = LootBanks[3].LootBank_Loot.keys().size()-1
	var randomeffecttochoose = RNG.randi_range(0,numberofeffects)
	var chosenarmoreffect : int = LootBanks[3].LootBank_Loot.keys()[randomeffecttochoose]
	#print("Chosen Armor Effect ID: "+str(chosenarmoreffect))
	#print(LootBanks[3].LootBank_Loot)
	var effectdict :Dictionary = LootBanks[3].LootBank_Loot[chosenarmoreffect]
	
	#CATCH IF WE'RE MAKING A STAFF OR A SEAL AND OVERRIDE TO A SORCERY/INCANTATION BOOSTING EFFECT
	if cancastsorceries == 1:
		var chosensorceryeffect : int = $SpEffectGenerator.MagicToolSpEffectIDs[1][RNG.randi_range(0,$SpEffectGenerator.MagicToolSpEffectIDs[1].size()-1)]
		effectdict = LootBanks[3].LootBank_Loot[chosensorceryeffect]
	elif cancastincantations == 1:
		var chosenincantationeffect : int = $SpEffectGenerator.MagicToolSpEffectIDs[2][RNG.randi_range(0,$SpEffectGenerator.MagicToolSpEffectIDs[2].size()-1)]
		effectdict = LootBanks[3].LootBank_Loot[chosenincantationeffect]
	
	var finalvaluemultiplier = generatedeffectvaluemultiplier / GeneratedSpEffectMultiplierDivisionThreshold
	#print_debug(finalvaluemultiplier)
	
	#CREATE OUR OWN EFFECT INSTEAD IF WE CLEAR A "USE EXISTING SPEFFECT" CHECK
	var numberofspeffectconfigs : int = $SpEffectGenerator.SpEffectParameters.keys().size()
	var createeffectinstead : bool = get_bool_chance(UseExistingEffectChance)
	if numberofspeffectconfigs > 0:
		if forcecustomeffect:
			var forcedeffect = $SpEffectGenerator.generate_speffect(3,4,false,"",finalvaluemultiplier,rarityname,"Forced Custom "+str(whoaskedforthis))
			effectdict = forcedeffect
		elif createeffectinstead and allowcustom:
			var allowedeffect = $SpEffectGenerator.generate_speffect(3,4,false,"",finalvaluemultiplier,rarityname,"Allowed Custom "+str(whoaskedforthis))
			effectdict = allowedeffect
		#print_debug(str(whoaskedforthis)+" "+str(effectdict["speffectid"]))
	return effectdict

func create_number_of_armors(number:int=1):
	for x in number:
		create_armor(x)

func armor_choose_random_dictionary_from_armorbank(forcedid:int=-1)->Dictionary:
	var armorheaders :Array = get_node("/root/WeaponGenDefaultArrays").ParamHeaders["EquipParamProtector"]
	var armoridtochoose : int = RNG.randi_range(0,ArmorBank.ArmorBank.keys().size()-1)
	var chosenarmorarray : Array = ArmorBank.ArmorBank[ArmorBank.ArmorBank.keys()[armoridtochoose]]
	
	#CHECK IF FORCEDID IS MORE THAN 1 AND IT'S IN THE ARMORBANK, AND SELECT IT IF SO
	if forcedid > 0 and ArmorBank.ArmorBank.has(forcedid):
		#print("ArmorBank has forced ID "+str(forcedid)+", selecting...")
		chosenarmorarray = ArmorBank.ArmorBank[forcedid]
	
	var dicttoreturn :Dictionary = {}
	
	for x in armorheaders.size():
		dicttoreturn[armorheaders[x]] = chosenarmorarray[x]
	#print(dicttoreturn["Name"])
	return dicttoreturn
#id:int=0,lootbankid:int=1,customname:String="",forcedid:int=-1,minrarity:int=-1,maxrarity:int=-1

func create_armor(argumentsarray:Array=[0,1,"",-1,-1,-1]):
	var chosenarmor : Dictionary = armor_choose_random_dictionary_from_armorbank(argumentsarray[3])
	
	var originalarmorid : int = int(chosenarmor["ID"])
	
	var armorrarity = weapon_choose_rarity(argumentsarray[4],argumentsarray[5])
	var effect1chancetarget = float(armorrarity["extraeffect0chance"])
	var effect2chancetarget = float(armorrarity["extraeffect0chance"]*0.2)
	
	#RESET ALL SPEFFECTS AND CHOOSE NEW ONES

	set_dictionary_value(chosenarmor,"residentSpEffectId","-1")
	set_dictionary_value(chosenarmor,"residentSpEffectId2","-1")
	set_dictionary_value(chosenarmor,"residentSpEffectId3","-1")
	#ESTABLISH THE CHANCE OF GETTING OUR SECOND AND THIRD EFFECTS FIRST SO
	#WE DON'T UNNECESSARILY CREATE A WASTED CUSTOM SPEFFECT
	var effect1chance :bool = get_bool_chance(effect1chancetarget)
	var effect2chance :bool = get_bool_chance(effect2chancetarget)
	var effectidarray : Array = []
	var effectdescriptionarray : Array = []
	var effectfixarray : Array = []
	var effectfixtoadd : Array = ["prefix","suffix","interfix","interfix","interfix"]
	
	#TO AVOID THE LAST ASSIGNED EFFECTS OVERWRITING THE OTHER TWO, WE ASSIGN EACH EFFECT'S SPEFFECT, DESCRIPTION AND xFIX TO A SEPARATE ARRAY
	#BEFORE THE NEXT ONE IS INTRODUCED
	var effect0 = choose_armor_effect(armorrarity["mindmgmultiplier"],armorrarity["name"],true,0,0,false,"Armor 1 ")
	#FIRST APPEND THE xFIX BEFORE WE MAKE THE EFFECTID ARRAY SIZE ANY BIGGER
	effectfixarray.append(effect0[effectfixtoadd[effectidarray.size()]])
	effectidarray.append(effect0["speffectid"])
	effectdescriptionarray.append(effect0["description"])
	#REPEAT THIS FOR EFFECT 1
	var effect1 = choose_armor_effect(armorrarity["mindmgmultiplier"],armorrarity["name"],effect1chance,0,0,false,"Armor 2 ")
	effectfixarray.append(effect1[effectfixtoadd[effectidarray.size()]])
	effectidarray.append(effect1["speffectid"])
	effectdescriptionarray.append(effect1["description"])
	#AND EFFECT 2
	var effect2 = choose_armor_effect(armorrarity["mindmgmultiplier"],armorrarity["name"],effect2chance,0,0,false,"Armor 3 ")
	effectfixarray.append(effect2[effectfixtoadd[effectidarray.size()]])
	effectidarray.append(effect2["speffectid"])
	effectdescriptionarray.append(effect2["description"])
	set_dictionary_value(chosenarmor,"residentSpEffectId",str(effectidarray[0]))
	
	if effect2chance:
		set_dictionary_value(chosenarmor,"residentSpEffectId3",str(effectidarray[2]))
	if effect1chance:
		set_dictionary_value(chosenarmor,"residentSpEffectId2",str(effectidarray[1]))
		
	#if effect2chance:
	#	set_dictionary_value(chosenarmor,"residentSpEffectId3",str(effect2["speffectid"]))
	#elif effect2chance and !effect1chance:
	#	set_dictionary_value(chosenarmor,"residentSpEffectId3",str(effect2["speffectid"]))
	#	#print_debug("Effect 2 true and Effect 1 false, forcing Effect 1 to true!")
	#	effect1chance = true
	#if effect1chance:
	#	set_dictionary_value(chosenarmor,"residentSpEffectId2",str(effect1["speffectid"]))
	
	##ARMOR NAME ELEMENTS - CHOSEN ARMOR'S NAME, MANDATORY EFFECT'S PREFIX, OPTIONAL EFFECT 1's SUFFIX
	var armornameelements :Array = [chosenarmor["Name"],effectfixarray[0],effectfixarray[1],effectfixarray[2]]
	var newarmorname = create_armor_name(armornameelements,effect1chance,effect2chance,armorrarity["name"])
	var newarmordescription = create_armor_description(effectdescriptionarray,effect1chance,effect2chance)
	
	#CREATE ARRAY OF ALL OF OUR ARMOR DEFENCE VALUES
	var armordefencearray : Array
	for x in armordefencevalues.size():
		armordefencearray.append(float(chosenarmor[armordefencevalues[x]]))
	#print_debug(armordefencearray)
	#NOW WE HAVE THAT ARRAY, LET'S RANDOMISE THOSE ELEMENTS
	for x in armordefencearray.size():
		##RANDOMISE ARMOR ABSORPTION BASED ON RARITY
		#SET A SMALL RANDOM AMOUNT TO MULTIPLY ON TO OUR ARMOR VALUE TO CREATE SOME VARIANCE BETWEEN PIECES
		var maxarmorabsvariance : float = 0.04
		var currentarmorvariance : float = RNG.randf_range(-maxarmorabsvariance,maxarmorabsvariance)
		var armorabsmultiplier : float = 1.0 - ((armorrarity["mindmgmultiplier"]*0.05) + currentarmorvariance)
		#LIMIT THE MULTIPLIER EITHER WAY TO STOP THINGS GETTING TOO CRAZY
		armorabsmultiplier = clamp(armorabsmultiplier,0.9,1.02)
		armordefencearray[x] = armordefencearray[x]*armorabsmultiplier
	
	#NOW WE'VE RANDOMISED THEM, APPLY THEM IN THE DICTIONARY
	for x in armordefencearray.size():
		chosenarmor[armordefencevalues[x]] = armordefencearray[x]
	
	## HANDLE ARMOR SELL VALUE
	var armorsellprice :int = 200
	if effect1chance:
		armorsellprice += 400
	if effect2chance:
		armorsellprice += 800
		
	#MULTIPLY SELL VALUE BY RARITY MINDMGMULTIPLIER
	armorsellprice = int(armorsellprice * float(armorrarity["mindmgmultiplier"]))

	set_dictionary_value(chosenarmor,"sellValue",str(armorsellprice))
	
	#SET ARMOR'S RARITY DROP FX BASED ON rarityvalue
	
	set_dictionary_value(chosenarmor,"rarity",str(armorrarity["rarityvalue"]))
	
	#I HAVE NO IDEA WHY THIS ISN'T NOTICED BUT LET'S SET IT
	chosenarmor["pad404"] = "[0|0|0|0|0|0|0|0|0|0|0|0|0|0]"
	
	#CREATE A SHORT VERSION OF THE ITEMLOT SET THAT SPAWNED THIS ARMOR'S NAME SO WE KNOW WHERE IT CAME FROM
	var itemlotsetname : String = create_short_custom_name(argumentsarray[2])
	
	#ASSIGN NEW ARMOR'S EDITOR NAME
	set_dictionary_value(chosenarmor,"Name","DSL"+itemlotsetname+" "+str(newarmorname))
	affect_cumulative_id_value(1)
	set_dictionary_value(chosenarmor,"ID",str(EquipParamWeaponStart+cumulativeids[1])+str("000"))
	var finalarmorid : int = int(chosenarmor["ID"])

	if effect2chance and chosenarmor["residentSpEffectId3"]=="-1":
		print_debug(str(chosenarmor["Name"])+" has residentSpEffectId3 but it's -1! Should have been "+str(effect2["speffectid"]))
		breakpoint
	
	#print_debug(str(finalarmorid)+" "+str(effectidarray))
	
	#GENERATE ARMOR LORE
	
	var newarmorlore : String = $LoreGenerator.generate_lore_description(newarmorname,"Armor",RNG.seed,originalarmorid)
	newarmordescription += "\\n"+newarmorlore

	#CREATE FINAL CSV STRING FOR ARMOR AND ADD IT TO RELEVANT FINALSTRINGS
	var armorfinalstring = compile_dictionary_values_line_from_headers(chosenarmor,get_node("/root/WeaponGenDefaultArrays").ParamHeaders["EquipParamProtector"])
	add_to_finalstring("EquipParamProtector",armorfinalstring)

	var armortextstrings : Array = [create_text_entry(chosenarmor["ID"],newarmorname),create_text_entry(chosenarmor["ID"],newarmordescription)]
	add_to_finalstring("TitleArmor.fmg.json",armortextstrings[0])
	add_to_finalstring("DescriptionArmor.fmg.json",armortextstrings[1])

	#ADD CREATED ARMOR TO DICTIONARY OF CREATED ARMORS, THEN LIST ITS ID IN CREATEDARMORSID AND AVAILABLEARMORSID FOR EASY ACCESS AND ASSIGNMENT
	export_values_to_loot_bank(argumentsarray[1],chosenarmor,finalarmorid,finalarmorid)

func create_armor_name(armornameelementsarray:Array=["Test","Yes","No","Why"],effect1active:bool=false,effect2active:bool=false,rarityname:String="") -> String:
	var nametoreturn :String = ""
	var rarityindicator : String = rarityname+" " if rarityname != "" else ""
	var effect1full = " "+str(armornameelementsarray[2]) if effect1active else ""
	var effect2full = " "+str(armornameelementsarray[3])+" " if effect2active else " "
	nametoreturn = rarityindicator+str(armornameelementsarray[1])+effect2full+str(armornameelementsarray[0])+effect1full
	return nametoreturn

func create_armor_description(armordescriptionelementsarray:Array=["effect0","effect1","effect2"],effect1active:bool=false,effect2active:bool=false,weaponname:String="")->String:
	var effect1desc = armordescriptionelementsarray[1]+"\\n" if effect1active else ""
	var effect2desc = armordescriptionelementsarray[2]+"\\n" if effect2active else ""
	var descriptiontoreturn :String = str(armordescriptionelementsarray[0])+"\\n"+effect1desc+effect2desc
	return descriptiontoreturn


## ITEMLOT GENERATION FUNCTIONS

# NEW ITEMLOT GENERATION FUNCTIONS

func fill_itemlot_set(creationpatterns:Array=["00","01"],itemlotarray:Array=[0],outputfinalstring:String="ItemLotParam_enemy",guaranteeddrop:bool=false,onetimepickup:bool=false,chancemultiplier:float=1.0,minrarity:int=-1,maxrarity:int=-1,wepstatreqmult:float=1.0,customname:String=""):
	
	#SET LIMITED ITEMLOT SLOT CHECKBOX VALUE
	var limititemlots : bool = bool(LimitItemLots.pressed)
	var maxitemsperitemlot : int = OptionalLimitedLootPerItemlot
	#print(limititemlots)
	
	#IF WE'RE MAKING A GUARANTEED DROP, WE WANT TO START FROM lotItemId01, OTHERWISE lotItemId02
	var lotitemidoffset = 1 if guaranteeddrop else 2
	
	
	## FOR EVERY ITEMLOT IN ITEMLOTARRAY...
	for x in itemlotarray.size():
		#FIRST, WE CHOOSE ONE OF THE RANDOM CREATIONPATTERNS VALUES TO ACT AS OUR BASE
		var creationpattern : String = creationpatterns[RNG.randi_range(0,creationpatterns.size()-1)]
		
		#GET HOW MANY LOOT ITEMS TO GENERATE FROM THE LENGTH OF CREATIONPATTERN
		var lootnum : int = creationpattern.length()
		if limititemlots and (creationpattern.length() > maxitemsperitemlot):
			lootnum = 0
			for z in maxitemsperitemlot:
				lootnum += 1
		
		#WE CREATE A NEW ITEMLOT DICTIONARY TO ADD TO THE FINAL ITEMLOTPARAM STRING
		var newitemlot : Dictionary = create_dictionary_from_paramtype("ItemLotParam_enemy")
		
		##CHECK OUR CURRENT ID AGAINST ANY ENEMY SPECIFIC LOOT BANK ENTRIES TO RESTRICT OURSELVES TO CERTAIN WEAPONS AND ARMOR IF NECESSARY
		var lootchoices : Dictionary = choose_random_armor_and_weapon_id_from_restricted_set(itemlotarray[x])
		
		#DISABLE ITEMLOT RARITY TO RESTRICT IT TO THE ITEMS THEMSELVES
		newitemlot["lotItem_Rarity"] = -1
		
		#CATCH WHETHER OUR NEW ITEMLOT IS IN A MAX RARITY OVERRIDE LIST AND SET OUR FINAL MAX RARITY APPROPRIATELY
		var finalmaxrarity = maxrarity
		if $Max_Rarity_Override_Handler.MaxRarityOverride.has(int(itemlotarray[x])):
			finalmaxrarity = $Max_Rarity_Override_Handler.MaxRarityOverride[int(itemlotarray[x])]
			#print_debug("ItemLot ID "+str(itemlotarray[x])+" has an override! Setting to "+str($Max_Rarity_Override_Handler.MaxRarityOverride[int(itemlotarray[x])]))
		
		##SETUP TOTAL CHANCE, EVERY NEW BIT OF LOOT WILL SUBTRACT FROM THIS
		var totalchance : int = 1000
		
		#NOW, WE CREATE ALL THE LOOT WE NEED. FIRST, WE CREATE AN ARRAY THAT WILL HOLD EACH GENERATED
		#LOOT DICTIONARY
		var lootarray : Array = []
		for l in lootnum:
			#SET UP OUR LOOT DETAILS ARRAY
			var lootdetailsdict:Dictionary = {
				"id":0,
				"type":2,
				"dropchance":60
			}
			#SET WHICH TYPE OF LOOT TO MAKE BY MAKING AN INT
			#OUT OF THE CURRENT NUMBER IN CREATIONPATTERN WE'RE ON
			var loottypetomake : int = int(creationpattern[l])
			
			#NOW WE HAVE THIS, WE CHECK IF WE HAVE A FUNCTION FOR CREATING THE RELEVANT
			#LOOT TYPE AND RUN IT, QUICKLY SETTING THE TYPE VALUE WHILE WE'RE AT IT
			match loottypetomake:
				1:
					create_armor([cumulativeids[1],1,customname,lootchoices[1],minrarity,finalmaxrarity])
					lootdetailsdict["type"] = 3
				2:
					$Talisman_Generator.talisman_create_talisman(2,minrarity,finalmaxrarity)
					lootdetailsdict["type"] = 4
				_:
					create_weapon(minrarity,finalmaxrarity,0,wepstatreqmult,customname,lootchoices[0])
			
			##NEXT UP WE SORT OUT OUR DROP CHANCE - IF THE LOOT IS A WEAPON, THIS
			#IS DETERMINED BY THEIR "DROP CHANCE" DICT VALUE ASSIGNED DURING CREATION
			var finaldropchance : int = int(30*chancemultiplier)
			match loottypetomake:
				1:
					#IF IT'S ARMOR, WE START WITH THE BASE OF 30, 3%, THEN SUBTRACT 10 IF THE ARMOR HAS A SECONDARY EFFECT
					if int(LootBanks[1].LootBank_Loot[LootBanks[1].LootBank_IDs[cumulativeassignids[1]]]["residentSpEffectId2"]) > 0:
						finaldropchance -= int(10*chancemultiplier)
					#AND 10 MORE IF IT HAS A TERTIARY EFFECT - 1% CHANCE TO DROP TOP TIER ARMOR
					if int(LootBanks[1].LootBank_Loot[LootBanks[1].LootBank_IDs[cumulativeassignids[1]]]["residentSpEffectId3"]) > 0:
						finaldropchance -= int(10*chancemultiplier)
				2:
					#IF IT'S A TALISMAN, WE START WITH THE BASE OF 30, 3%, THEN SUBTRACT 10 IF THE ARMOR HAS A SECONDARY EFFECT
					if int(LootBanks[2].LootBank_Loot[LootBanks[2].LootBank_IDs[cumulativeassignids[2]]]["residentSpEffectId1"]) > 0:
						finaldropchance -= int(10*chancemultiplier)
					#AND 10 MORE IF IT HAS A TERTIARY EFFECT - 1% CHANCE TO DROP TOP TIER ARMOR
					if int(LootBanks[2].LootBank_Loot[LootBanks[2].LootBank_IDs[cumulativeassignids[2]]]["residentSpEffectId2"]) > 0:
						finaldropchance -= int(10*chancemultiplier)
					if int(LootBanks[2].LootBank_Loot[LootBanks[2].LootBank_IDs[cumulativeassignids[2]]]["residentSpEffectId3"]) > 0:
						finaldropchance -= int(6*chancemultiplier)
				_:
					#IF IT'S A WEAPON, ID 0
					#WE SEARCH THE LOOTBANK_LOOT DICTIONARY BASED ON THE CURRENT CUMULATIVE ID TO SEARCH THROUGH
					#TO FIND THE "itemlotdropchance" VALUE TO SET ITS DROPCHANCE
					finaldropchance = int((LootBanks[0].LootBank_Loot[LootBanks[0].LootBank_IDs[cumulativeassignids[0]]]["itemlotdropchance"])*chancemultiplier)
			#CLAMP FINAL DROPCHANCE TO BE AT LEAST 1 - 0.1%
			if finaldropchance < 1:
				finaldropchance = 1
			
			#NOW THAT'S DONE, APPLY OUR NEW FINAL DROP CHANCE TO THE LOOT DICTIONARY'S DROPCHANCE VALUE
			lootdetailsdict["dropchance"] = finaldropchance
					
			#NOW THAT'S DONE, WE CAN QUERY THE MATCHING LOOT BANK FOR
			#THE NEXT ID TO SUBMIT AND ADD IT
			lootdetailsdict["id"] = LootBanks[loottypetomake].LootBank_IDs[cumulativeassignids[loottypetomake]]
			affect_cumulative_assign_id_value(loottypetomake)
			
			#FINALLY, ADD OUR DICTIONARY TO LOOTARRAY
			lootarray.append(lootdetailsdict)
		
		#NOW OUR LOOT IS CREATED, WE PROCESS THE ITEMLOTID ENTRIES FOR EACH ITEM IN LOOTARRAY
		#BUT FIRST, WE CREATE A STRING VARIABLE TO CREATE AN INDICATIVE NAME
		var customnamespace = " " if customname != "" else ""
		var itemlotname : String = "DSL "+lootchoices["name"]+customname+customnamespace
		for i in lootarray.size():
			##FIRST, WE SET THE ID BY GRABBING THE CURRENT LOOTARRAY DICTIONARY'S id
			var itemid = i+lotitemidoffset
			set_dictionary_value(newitemlot,"lotItemId0"+str(itemid),str(lootarray[i]["id"]))
			##NOW WE ADD THE NEW TYPE TO THE ITEMLOTNAME TO HELP INDICATE WHICH ARRAY WAS CHOSEN
			itemlotname += str(lootarray[i]["type"])+" "
			
			#NEXT, THE TYPE
			set_dictionary_value(newitemlot,"lotItemCategory0"+str(itemid),str(lootarray[i]["type"]))
			
			#MAKE THE DROPS BE AFFECTED BY LUCK
			set_dictionary_value(newitemlot,"enableLuck0"+str(itemid),"1")
			
			#MAKE SURE QUANTITY IS SET TO 1
			set_dictionary_value(newitemlot,"lotItemNum0"+str(itemid),"1")
						
			
			#BETA 0.42 - SET EVERY ITEM'S LOTITEMBASEPOINT, IF WE'RE NOT MAKING A GUARANTEED DROP
			#ALSO SUBTRACT FROM TOTAL CHANCE - THIS SHOULD ALLOW GUARANTEED DROPS TO BE BASED SOLELY
			#ON THE INDIVIDUAL ITEMS' DROPRATES AND STOP THE FIRST ITEM BEING MUCH MORE LIKELY THAN THE
			#OTHERS
			set_dictionary_value(newitemlot,"lotItemBasePoint0"+str(itemid),str(lootarray[i]["dropchance"]))
			if !guaranteeddrop:
				totalchance -= int(lootarray[i]["dropchance"])
		
		#WITH ALL THAT DONE, SET THE FIRST LOTITEMBASEPOINT TO WHATEVER'S LEFT OF TOTALCHANCE - BETA 0.42 - *IF* WE
		#AREN'T MAKING A GUARANTEED DROP
		if !guaranteeddrop:
			set_dictionary_value(newitemlot,"lotItemBasePoint01",str(totalchance))

		#BACKUP - GOING TO TRY AND ADJUST THE ABOVE SO THAT IF WE'RE MAKING A GUARANTEED DROP, WE DON'T BOTHER WITH
		#TOTAL CHANCE AT ALL, AND JUST GENERATE EACH ITEMLOT BASE POINT IN THE SAME WAY, THAT WAY WE DON'T HAVE ONE
		#ITEM THAT'S SIGNIFICANTLY MORE LIKELY THAN THE OTHERS
		#	if (guaranteeddrop and i != 0) or !guaranteeddrop:
		#		#OTHERWISE, SET THE DROP CHANCE AND SUBTRACT IT FROM TOTALDROPCHANCE FOR LATER
		#		set_dictionary_value(newitemlot,"lotItemBasePoint0"+str(itemid),str(lootarray[i]["dropchance"]))
		#		totalchance -= int(lootarray[i]["dropchance"])
		#
		#WITH ALL THAT DONE, SET THE FIRST LOTITEMBASEPOINT TO WHATEVER'S LEFT OF TOTALCHANCE
		#set_dictionary_value(newitemlot,"lotItemBasePoint01",str(totalchance))

		
		#WE SET THE NEW ITEMLOT'S ID AND NAME
		set_dictionary_value(newitemlot,"ID",str(itemlotarray[x]))
		
		#SET NAME TO COLLATED LOOT NAME
		set_dictionary_value(newitemlot,"Name",itemlotname)
		
		##FINALLY, IF WE'RE MAKING A ONE-TIME-ONLY DROP, ASSIGN A getItemFlagId BY ADDING CUMULATIVE ID -1 AND ADDING TO IT
		if onetimepickup:
			set_dictionary_value(newitemlot,"getItemFlagId",str(get_next_acquisition_id()))
			#NO LONGER NEEDED AS GET NEXT ACQ FLAG AFFECTS THE CUMULATIVE ID VALUE
			#affect_cumulative_id_value(-1)
		
		#THEN, AT LONG, LONG LAST, WE COMPILE THE FINAL ITEMLOT STRING AND SEND IT TO FINALSTRINGS
		var newitemlotstring :String = compile_dictionary_values_line_from_headers(newitemlot,get_node("/root/WeaponGenDefaultArrays").ParamHeaders["ItemLotParam_enemy"])
		add_to_finalstring(outputfinalstring,newitemlotstring)
		
func fill_custom_itemlot_set(customitemlotdict:Dictionary):
#fill_itemlot_set(creationpatterns:Array=["00","01"],itemlotarray:Array=[0],
#outputfinalstring:String="ItemLotParam_enemy",guaranteeddrop:bool=false,chancemultiplier:float=1.0,
#minrarity:int=-1,maxrarity:int=-1, CUSTOMNAME):

	## WRITE A WAY TO PASS THE EXACT ITEMLOT ID NUMBER 
	fill_itemlot_set(customitemlotdict["loottypecreationpatterns"],
	customitemlotdict["itemlotidsarray"],customitemlotdict["outputparam"],
	bool(customitemlotdict["guaranteeddrops"]),bool(customitemlotdict["onetimepickup"]),customitemlotdict["dropchancevaluemultiplier"],
	customitemlotdict["minweaponrarity"],customitemlotdict["maxweaponrarity"],customitemlotdict["weaponstatreqmultiplier"],customitemlotdict["customitemlotsetname"])

func choose_random_armor_and_weapon_id_from_restricted_set(itemlotid:int=0)->Dictionary:
	var selectionsdict : Dictionary = {
		0:-1,
		1:-1,
		2:-1,
		"name":""
	}
	
	#CHECK IF CURRENT ITEMLOT ID IS REGISTERED TO A ENEMY SPECIFIC LOOT BANK
	if $EnemySpecificLootBank.ItemLotsToESL.has(itemlotid):
		#print("ItemLots to ESL has "+str(itemlotid)+"! Choosing from Arrays...")
		var ESLBToQuery = $EnemySpecificLootBank.ItemLotsToESL[itemlotid]
		
		var ESLBLootSizes : Array = [$EnemySpecificLootBank.EnemySpecificLoot[ESLBToQuery][0].size(),$EnemySpecificLootBank.EnemySpecificLoot[ESLBToQuery][1].size()]
		#print(ESLBLootSizes)
		#FIRST CHOOSE A WEAPON MODEL
		if ESLBLootSizes[0] > 0:
			selectionsdict[0] = $EnemySpecificLootBank.EnemySpecificLoot[ESLBToQuery][0][RNG.randi_range(0,ESLBLootSizes[0]-1)]
		#NOW AN ARMOR MODEL
		if ESLBLootSizes[1] > 0:
			selectionsdict[1] = $EnemySpecificLootBank.EnemySpecificLoot[ESLBToQuery][1][RNG.randi_range(0,ESLBLootSizes[1]-1)]
		selectionsdict["name"] = " "+ESLBToQuery+" "
		
	return selectionsdict

func affect_cumulative_id_value(whichone:int=0,amount:int=1,reset:bool=false):
	if reset:
		ItemAcquisitionOffset = 0
		ItemAcquisitionFlagOffset = 0
		for x in cumulativeids.keys().size():
			cumulativeids[cumulativeids.keys()[x]]=0
	else:
		var valuetoaddto : int = cumulativeids[whichone]
		cumulativeids[whichone] = valuetoaddto + amount
		#HANDLE ITEMACQUISITIONIDS - IF MORE THAN 999, RESET AND INCREASE ITEMACQUISITIONFLAGOFFSET BY 1
		if whichone == -1 and cumulativeids[whichone] > 999:
			cumulativeids[whichone] = 0
			ItemAcquisitionFlagOffset += 1
			#IF IAFO IS MORE THAN THE SIZE OF THE VALID IAFO ARRAY, ADD 10 TO IAO AS WE'VE REACHED THE END OF THE SAVEABLE FLAG RANGES AND ALSO 
			#RESET IAFO
			if ItemAcquisitionFlagOffset >= ItemAcquisitionFlagSequence.size():
				ItemAcquisitionFlagOffset = 0
				ItemAcquisitionOffset += 10

func affect_cumulative_assign_id_value(whichone:int=0,amount:int=1,reset:bool=false):
	#IF RESET IS TRUE, SET ALL CUMULATIVE IDS TO 0
	if reset:
		for x in cumulativeassignids.keys().size():
			cumulativeassignids[cumulativeassignids.keys()[x]]=0
	else:
		var valuetoaddto : int = cumulativeassignids[whichone]
		cumulativeassignids[whichone] = valuetoaddto + amount



## DATA CREATION FUNCTIONS

func create_short_custom_name(original:String="",maxcharacters:int=8):
	var stringtoreturn = ""
	if original.length() > maxcharacters:
		stringtoreturn += " "
		for x in maxcharacters:
			stringtoreturn += original[x]
	else:
		stringtoreturn = original
	return stringtoreturn

func create_dictionary_from_paramtype(whichparamtype:String="EquipParamWeapon") -> Dictionary:
	var dictionarytoreturn:Dictionary
	var headersarray : Array = get_header_array_from_paramid(whichparamtype)
	var valuesarray : Array = get_default_array_from_paramid(whichparamtype)
	for x in headersarray.size():
		dictionarytoreturn[headersarray[x]] = valuesarray[x]
	return dictionarytoreturn
	
func create_default_reinforceparamweapon():
	var outputpath : String = create_output_path_from_default()
	var baserpwpath = "res://Databases/ReinforceParamWeapon.tres"
	var baserpw = Directory.new()
	baserpw.copy(baserpwpath,outputpath+"/ReinforceParamWeapon.csv")
	

func set_dictionary_value(dictionary:Dictionary,whichid:String="Name",value:String="Test"):
	if dictionary.has(whichid):
		dictionary[whichid] = value
		#print_debug("Set "+str(whichid)+" to "+str(value))
	else:
		print_debug("Dictionary does not have "+str(whichid)+"!")

func compile_dictionary_values_line_from_headers(dictionary:Dictionary,headers:Array=[]) -> String:
	var finalstring : String = ""
	for x in headers.size():
		var finalpart = ","
		if x == headers.size()-1:
			finalpart = "\n"
		finalstring += str(dictionary[headers[x]])+finalpart
	#print_debug(finalstring)
	return finalstring

## TEXT CREATION FUNCTIONS

func create_text_entry(id:String="0",text:String="Test")->String:
	var stringtoadd :String= "{\"ID\":"+str(id)+",\"Text\":\""+str(text)+"\"},\n"
	return stringtoadd

# DATA COLLECTION FUNCTIONS

## IMPORT ITEMLOTS TO GENERATE

func create_itemlot_json_directory():
	var itemlotdir = Directory.new()
	if !itemlotdir.dir_exists(customitemlotsdir):
		itemlotdir.make_dir(customitemlotsdir)
	else:
		load_itemlot_jsons()
	create_default_itemlot_json()
		
#CREATE A TEMPLATE JSON FOR THE ITEMLOTS

func create_default_itemlot_json():
	var outputjsonfile = File.new()
	var outputjsonfilepath = customitemlotsdir+"/#DEFAULT_CustomItemLot.json"
	if !outputjsonfile.file_exists(outputjsonfilepath):
		var outputjson :String = JSON.print(itemlotjsontemplate)
		outputjsonfile.open(outputjsonfilepath,File.WRITE)
		outputjsonfile.store_string(outputjson)
		outputjsonfile.close()

## LOAD ANY CUSTOM ITEMLOT SETS CREATED BASED ON THE DEFAULT

func load_itemlot_jsons():
	IndicatorLabel.text = "-LOADING CUSTOM ITEMLOTS-"
	yield(get_tree().create_timer(0.1),"timeout")
	
	CustomItemlotJsons = []
	var finalloadeditemstext : String = ""
	
	## FIRST, LOOK INTO THE CUSTOM ITEMLOTS DIRECTORY AND GET A LIST OF WHAT'S INSIDE
	var customitemlotdirectory = Directory.new()
	if customitemlotdirectory.open(customitemlotsdir) == OK:
		customitemlotdirectory.list_dir_begin(true)
		var newitemlotfile = customitemlotdirectory.get_next()
		while newitemlotfile != "":
			#print(newitemlotfile)
			##CHECK IF FILE IS A DIRECTORY
			if !"#" in newitemlotfile and ".json" in newitemlotfile:
				var newitemlotjson = File.new()
				if newitemlotjson.open(str(customitemlotsdir+newitemlotfile),File.READ) == OK:
					while !newitemlotjson.eof_reached():
						var parseditemlotjson : JSONParseResult = JSON.parse(newitemlotjson.get_line())
						var newitemlotdict : Dictionary = parseditemlotjson.result
						#IF THIS NEW JSON LINE SHARES THE SAME KEYS AS OUR CURRENT TEMPLATE, ADD IT TO THE
						#ITEMLOTJSON ARRAY, ELSE LET THE USER KNOW WHAT'S WRONG
						if newitemlotdict.keys() == itemlotjsontemplate.keys():
							#print_debug("Custom Itemlot "+newitemlotdict["customitemlotsetname"]+" has the correct keys! Adding...")
							CustomItemlotJsons.append(newitemlotdict)
							#"{ID}: {PATTERN}\nGuaranteed Drops: {GUARANTEED}, Drop Chance Mult: {DROPCHANCEMULT}, STARTING ID: {STARTID}\n\n"
							var texttoadd : String = LoadedItemlotsIndicatorString.format({"ID":str(newitemlotdict["customitemlotsetname"]),
							"PATTERN":str(newitemlotdict["loottypecreationpatterns"]),
							"DROPCHANCEMULT":str(newitemlotdict["dropchancevaluemultiplier"]),
							"STARTID":str(newitemlotdict["itemlotidsarray"][0]),
							"ENDID":str(newitemlotdict["itemlotidsarray"][newitemlotdict["itemlotidsarray"].size()-1]),
							"GUARANTEED":str(bool(newitemlotdict["guaranteeddrops"])),"ONETIME":str(bool(newitemlotdict["onetimepickup"])),
							"STATREQMULT":str(newitemlotdict["weaponstatreqmultiplier"])})
							finalloadeditemstext += texttoadd
						else:
							OS.alert("Custom Itemlot "+newitemlotfile+" has the wrong set of keys!\nIt has:\n"+str(newitemlotdict.keys())+"\n\nIt should have:\n"+str(itemlotjsontemplate.keys()))
					newitemlotjson.close()
				else:
					print_debug("Failed to open "+newitemlotfile)
				newitemlotfile = customitemlotdirectory.get_next()
			else:
				newitemlotfile = customitemlotdirectory.get_next()
		customitemlotdirectory.list_dir_end()
		if finalloadeditemstext != "":
			LoadedItemLotsIndicator.text = finalloadeditemstext
			IndicatorLabel.text = "-ITEMLOT SETS LOADED-"
		else:
			IndicatorLabel.text = "-NO ITEMLOT SETS FOUND-"

func export_values_to_loot_bank(lootarrayid:int,lootdicttoadd:Dictionary,lootidarrayint:int,availableidarrayint:int):
	#GRAB THE RELEVANT LOOTBANK ID, AND ASSIGN THE VALUES TO IT
	LootBanks[lootarrayid].add_to_lootbank_loot(lootidarrayint,lootdicttoadd)
	LootBanks[lootarrayid].add_to_lootbank_ids(lootidarrayint)
	LootBanks[lootarrayid].add_to_lootbank_available_ids(availableidarrayint)

func get_weapon_dictionary_by_id(id:int=1000000):
	var dictionarytoreturn : Dictionary
	dictionarytoreturn = get_node("/root/WeaponGenDefaultArrays").DefaultWeapons[id]
	return dictionarytoreturn

func get_weapontype_name(weapontypeid:int=0) -> String:
	var stringtoreturn = "Dagger"
	var weapontypedict = weapgendatabase.get_row_from("WeaponTypes",weapontypeid)
	stringtoreturn = weapontypedict["basename"]
	return stringtoreturn

func get_weapontype_dictionary(weapontypeid:int=0) -> Dictionary:
	var weapontypedict = weapgendatabase.get_row_from("WeaponTypes",weapontypeid)
	return weapontypedict

func get_header_array_from_paramid(whichparamtype:String="EquipParamWeapon") -> Array:
	var arraytoreturn = ["ERROR"]
	if get_node("/root/WeaponGenDefaultArrays").ParamHeaders.has(whichparamtype):
		arraytoreturn = get_node("/root/WeaponGenDefaultArrays").ParamHeaders[whichparamtype]
	return arraytoreturn

func create_header_array_string(whichparamarray:Array) -> String:
	var stringtoreturn = ""
	return stringtoreturn

func get_default_array_from_paramid(whichparamtype:String="EquipParamWeapon") -> Array:
	var arraytoreturn = ["ERROR"]
	if get_node("/root/WeaponGenDefaultArrays").ParamDefaults.has(whichparamtype):
		arraytoreturn = get_node("/root/WeaponGenDefaultArrays").ParamDefaults[whichparamtype]
	return arraytoreturn

#FINAL STRING FUNCTIONS

func add_to_finalstring(whichparamtype:String="EquipParamWeapon",stringtoadd:String="this"):
	FinalStrings[whichparamtype] += stringtoadd
	#print_debug(FinalStrings[whichparamtype])

func get_paramtype_string_from_id(whichparamtype:int=0) -> String:
	var stringtoreturn = ParamTypes[whichparamtype]
	return stringtoreturn

func clear_finalstring(all:bool=false,whichparamtype:String="EquipParamWeapon"):
	if all:
		var keystoclear : Array = FinalStrings.keys()
		for x in keystoclear.size():
			FinalStrings[keystoclear[x]] = ""
	else:
		if FinalStrings.has(whichparamtype):
			FinalStrings[whichparamtype] = ""

#

func open_user_data_folder():
	OS.shell_open(OS.get_user_data_dir())

func write_csv(string:String="id,name\ntest,yes",csvname:String="test"):
	var csvpathfull :String = create_output_path_from_default()+str(csvname)+".csv"
	var csvpath = csvpathfull
	var newcsv = File.new()
	newcsv.open(csvpath,File.WRITE)
	newcsv.store_string(string)
	newcsv.close()

func write_txt(string:String="Test!",txtname:String="ohyes"):
	var txtpathfull :String = create_output_path_from_default()+str(txtname)+".txt"
	var txtpath = txtpathfull
	var newtxt = File.new()
	newtxt.open(txtpath,File.WRITE)
	newtxt.store_string(string)
	newtxt.close()

func write_json_from_template(stringtoadd:String="yep",filetoload:String="TitleWeapons.fmg.json"):
	var jsonpath = "res://Databases/TextBase/"+str(filetoload)
	var jsonstring :String = ""
	var newjson = File.new()
	newjson.open(jsonpath,File.READ)
	jsonstring = newjson.get_as_text()
	newjson.close()
	jsonstring = jsonstring.format({"NEWENTRIES":str(stringtoadd)})
	var outputjsonpathoriginal :String = create_output_path_from_default()+str(filetoload)
	var outputjsonpath = outputjsonpathoriginal
	var outputjson = File.new()
	outputjson.open(outputjsonpath,File.WRITE)
	outputjson.store_string(jsonstring)
	outputjson.close()
	
#SPEFFECT FUNCTIONS

func speffect_create_massedit_entries():
	var armoreffectstable = weapgendatabase.get_table("ArmorEffects")
	var masseditstringbase : String = "param SpEffectParam: id {EFFECTID}: spCategory: = 10;"
	
	var speffectstoset : Array = []
	var masseditoutputstring : String = ""
	
	#FIRST ADD EVERY USED SPEFFECTID TO THE SPEFFECTSTOSET ARRAY
	for x in armoreffectstable.get_row_count():
		var currentarmoreffectsrow = armoreffectstable.get_row_by_index(x)
		var effectidint : int = currentarmoreffectsrow["speffectid"]
		speffectstoset.append(effectidint)
		
	#NOW CREATE A MASSEDIT LINE FOR EACH ENTRY IN SPEFFECTSTOSET AND ADD IT TO THE FINAL MASSEDIT STRING
	for y in speffectstoset.size():
		var massedittoadd = masseditstringbase.format({"EFFECTID":str(speffectstoset[y])})
		var newline = "" if y == speffectstoset.size()-1 else "\n"
		masseditoutputstring += massedittoadd+newline
		
	#FINALLY, CREATE A TXT FILE IN THE CURRENT SEED'S DIRECTORY WITH THESE MASSEDIT
	
	var massedittextdir :String = create_output_path_from_default()
	var massedittextpath :String = massedittextdir+"/DSL_MakeEffectsStack.massedit"
	var speffectmasseditfile = File.new()
	speffectmasseditfile.open(massedittextpath,File.WRITE)
	speffectmasseditfile.store_string(masseditoutputstring)
	speffectmasseditfile.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
