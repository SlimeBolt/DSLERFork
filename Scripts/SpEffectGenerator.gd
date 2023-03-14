extends Node
class_name SpEffectGenerator

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var SpEfLoadIndicatorPath
onready var SpEfLoadIndicator :Label = get_node(SpEfLoadIndicatorPath)
export (NodePath) var SpEfReloadButtonPath
onready var SpEfReloadButton : Button = get_node(SpEfReloadButtonPath)

var weapgendatabase : GDDatabase = load("res://Databases/WeaponGenerationInfo.tres")

var SpEffectParameters : Dictionary = {}

#MAKE SURE 
var MagicToolSpEffectIDs : Dictionary = {
	1:[],
	2:[]
}

const SpEffectIDStart : int = 8000000

const SpEffect : Dictionary = {
	"headers":["ID","Name","iconId","conditionHp","effectEndurance","motionInterval","maxHpRate","maxMpRate","maxStaminaRate","slashDamageCutRate","blowDamageCutRate","thrustDamageCutRate","neutralDamageCutRate","magicDamageCutRate","fireDamageCutRate","thunderDamageCutRate","physicsAttackRate","magicAttackRate","fireAttackRate","thunderAttackRate","physicsAttackPowerRate","magicAttackPowerRate","fireAttackPowerRate","thunderAttackPowerRate","physicsAttackPower","magicAttackPower","fireAttackPower","thunderAttackPower","physicsDiffenceRate","magicDiffenceRate","fireDiffenceRate","thunderDiffenceRate","physicsDiffence","magicDiffence","fireDiffence","thunderDiffence","NoGuardDamageRate","vitalSpotChangeRate","normalSpotChangeRate","lookAtTargetPosOffset","behaviorId","changeHpRate","changeHpPoint","changeMpRate","changeMpPoint","mpRecoverChangeSpeed","changeStaminaRate","changeStaminaPoint","staminaRecoverChangeSpeed","magicEffectTimeChange","insideDurability","maxDurability","staminaAttackRate","poizonAttackPower","diseaseAttackPower","bloodAttackPower","curseAttackPower","fallDamageRate","soulRate","equipWeightChangeRate","allItemWeightChangeRate","soul","animIdOffset","haveSoulRate","targetPriority","sightSearchEnemyRate","hearingSearchEnemyRate","grabityRate","registPoizonChangeRate","registDiseaseChangeRate","registBloodChangeRate","registCurseChangeRate","soulStealRate","lifeReductionRate","hpRecoverRate","replaceSpEffectId","cycleOccurrenceSpEffectId","atkOccurrenceSpEffectId","guardDefFlickPowerRate","guardStaminaCutRate","rayCastPassedTime","magicSubCategoryChange1","magicSubCategoryChange2","bowDistRate","spCategory","categoryPriority","saveCategory","changeMagicSlot","changeMiracleSlot","heroPointDamage","defFlickPower","flickDamageCutRate","bloodDamageRate","dmgLv_None","dmgLv_S","dmgLv_M","dmgLv_L","dmgLv_BlowM","dmgLv_Push","dmgLv_Strike","dmgLv_BlowS","dmgLv_Min","dmgLv_Uppercut","dmgLv_BlowLL","dmgLv_Breath","atkAttribute","spAttribute","stateInfo","wepParamChange","moveType","lifeReductionType","throwCondition","addBehaviorJudgeId_condition","freezeDamageRate","effectTargetSelf","effectTargetFriend","effectTargetEnemy","effectTargetPlayer","effectTargetAI","effectTargetLive","effectTargetGhost","disableSleep","disableMadness","effectTargetAttacker","dispIconNonactive","regainGaugeDamage","bAdjustMagicAblity","bAdjustFaithAblity","bGameClearBonus","magParamChange","miracleParamChange","clearSoul","requestSOS","requestBlackSOS","requestForceJoinBlackSOS","requestKickSession","requestLeaveSession","requestNpcInveda","noDead","bCurrHPIndependeMaxHP","corrosionIgnore","sightSearchCutIgnore","hearingSearchCutIgnore","antiMagicIgnore","fakeTargetIgnore","fakeTargetIgnoreUndead","fakeTargetIgnoreAnimal","grabityIgnore","disablePoison","disableDisease","disableBlood","disableCurse","enableCharm","enableLifeTime","bAdjustStrengthAblity","bAdjustAgilityAblity","eraseOnBonfireRecover","throwAttackParamChange","requestLeaveColiseumSession","isExtendSpEffectLife","hasTarget","replanningOnFire","vowType0","vowType1","vowType2","vowType3","vowType4","vowType5","vowType6","vowType7","vowType8","vowType9","vowType10","vowType11","vowType12","vowType13","vowType14","vowType15","repAtkDmgLv","sightSearchRate","effectTargetOpposeTarget","effectTargetFriendlyTarget","effectTargetSelfTarget","effectTargetPcHorse","effectTargetPcDeceased","isContractSpEffectLife","isWaitModeDelete","isIgnoreNoDamage","changeTeamType","dmypolyId","vfxId","accumuOverFireId","accumuOverVal","accumuUnderFireId","accumuUnderVal","accumuVal","eye_angX","eye_angY","addDeceasedLv","vfxId1","vfxId2","vfxId3","vfxId4","vfxId5","vfxId6","vfxId7","freezeAttackPower","AppearAiSoundId","addFootEffectSfxId","dexterityCancelSystemOnlyAddDexterity","teamOffenseEffectivity","toughnessDamageCutRate","weakDmgRateA","weakDmgRateB","weakDmgRateC","weakDmgRateD","weakDmgRateE","weakDmgRateF","darkDamageCutRate","darkDiffenceRate","darkDiffence","darkAttackRate","darkAttackPowerRate","darkAttackPower","antiDarkSightRadius","antiDarkSightDmypolyId","conditionHpRate","consumeStaminaRate","itemDropRate","changePoisonResistPoint","changeDiseaseResistPoint","changeBloodResistPoint","changeCurseResistPoint","changeFreezeResistPoint","slashAttackRate","blowAttackRate","thrustAttackRate","neutralAttackRate","slashAttackPowerRate","blowAttackPowerRate","thrustAttackPowerRate","neutralAttackPowerRate","slashAttackPower","blowAttackPower","thrustAttackPower","neutralAttackPower","changeStrengthPoint","changeAgilityPoint","changeMagicPoint","changeFaithPoint","changeLuckPoint","recoverArtsPoint_Str","recoverArtsPoint_Dex","recoverArtsPoint_Magic","recoverArtsPoint_Miracle","madnessDamageRate","isUseStatusAilmentAtkPowerCorrect","isUseAtkParamAtkPowerCorrect","dontDeleteOnDead","disableFreeze","isDisableNetSync","shamanParamChange","isStopSearchedNotify","isCheckAboveShadowTest","addBehaviorJudgeId_add","saReceiveDamageRate","defPlayerDmgCorrectRate_Physics","defPlayerDmgCorrectRate_Magic","defPlayerDmgCorrectRate_Fire","defPlayerDmgCorrectRate_Thunder","defPlayerDmgCorrectRate_Dark","defEnemyDmgCorrectRate_Physics","defEnemyDmgCorrectRate_Magic","defEnemyDmgCorrectRate_Fire","defEnemyDmgCorrectRate_Thunder","defEnemyDmgCorrectRate_Dark","defObjDmgCorrectRate","atkPlayerDmgCorrectRate_Physics","atkPlayerDmgCorrectRate_Magic","atkPlayerDmgCorrectRate_Fire","atkPlayerDmgCorrectRate_Thunder","atkPlayerDmgCorrectRate_Dark","atkEnemyDmgCorrectRate_Physics","atkEnemyDmgCorrectRate_Magic","atkEnemyDmgCorrectRate_Fire","atkEnemyDmgCorrectRate_Thunder","atkEnemyDmgCorrectRate_Dark","registFreezeChangeRate","invocationConditionsStateChange1","invocationConditionsStateChange2","invocationConditionsStateChange3","hearingAiSoundLevel","chrProxyHeightRate","addAwarePointCorrectValue_forMe","addAwarePointCorrectValue_forTarget","sightSearchEnemyAdd","sightSearchAdd","hearingSearchAdd","hearingSearchRate","hearingSearchEnemyAdd","value_Magnification","artsConsumptionRate","magicConsumptionRate","shamanConsumptionRate","miracleConsumptionRate","changeHpEstusFlaskRate","changeHpEstusFlaskPoint","changeMpEstusFlaskRate","changeMpEstusFlaskPoint","changeHpEstusFlaskCorrectRate","changeMpEstusFlaskCorrectRate","applyIdOnGetSoul","extendLifeRate","contractLifeRate","defObjectAttackPowerRate","effectEndDeleteDecalGroupId","addLifeForceStatus","addWillpowerStatus","addEndureStatus","addVitalityStatus","addStrengthStatus","addDexterityStatus","addMagicStatus","addFaithStatus","addLuckStatus","deleteCriteriaDamage","magicSubCategoryChange3","spAttributeVariationValue","atkFlickPower","wetConditionDepth","changeSaRecoveryVelocity","regainRate","saAttackPowerRate","sleepAttackPower","madnessAttackPower","registSleepChangeRate","registMadnessChangeRate","changeSleepResistPoint","changeMadnessResistPoint","sleepDamageRate","applyPartsGroup","clearTarget","fakeTargetIgnoreAjin","fakeTargetIgnoreMirageArts","requestForceJoinBlackSOS_B","unk353_4","pad2","changeSuperArmorPoint","changeSaPoint","hugeEnemyPickupHeightOverwrite","poisonDefDamageRate","diseaseDefDamageRate","bloodDefDamageRate","curseDefDamageRate","freezeDefDamageRate","sleepDefDamageRate","madnessDefDamageRate","overwrite_maxBackhomeDist","overwrite_backhomeDist","overwrite_backhomeBattleDist","overwrite_BackHome_LookTargetDist","goodsConsumptionRate","unk2","unk3"],
	"default":{
		0:["0","Affect Self SpEffect","-1","-1","-1","0","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","0","0","0","0","1","1","1","1","0","0","0","0","1","-1","-1","0","-1","0","0","0","0","0","0","0","0","0","0","0","1","0","0","0","0","1","1","1","1","0","-1","1","0","1","1","1","1","1","1","1","1","1","1","-1","-1","-1","1","1","-1","0","0","0","0","0","-1","0","0","0","0","0","100","0","0","0","0","0","0","0","0","0","0","0","0","254","254","0","0","0","0","0","-1","100","1","1","0","1","1","1","1","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","1","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","0","1","0","0","1","0","0","0","0","0","-1","-1","-1","-1","-1","-1","-1","0","0","0","0","-1","-1","-1","-1","-1","-1","-1","0","0","-1","0","-1","1","1","1","1","1","1","1","1","1","0","1","1","0","0","-1","-1","1","0","0","0","0","0","0","1","1","1","1","1","1","1","1","0","0","0","0","0","0","0","0","0","0","0","0","0","100","0","0","0","0","0","0","0","0","0","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","0","0","0","-1","1","0","0","0","0","0","1","0","1","1","1","1","1","0","0","0","0","1","1","0","1","1","1","-1","0","0","0","0","0","0","0","0","0","0","0","0","0","0","1","1","1","0","0","1","1","0","0","100","0","0","0","0","0","0","0","0","0","0","1","1","1","1","1","1","1","0","0","0","0","1","1","[0|0|0|0]"],
		1:["350300","ApplyOnEnemyDeath","20290","-1","-1","0","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","0","0","0","0","1","1","1","1","0","0","0","0","1","-1","-1","0","-1","0","0","0","0","0","0","0","0","0","0","0","1","0","0","0","0","1","1","1","1","0","-1","1","0","1","1","1","1","1","1","1","1","1","1","-1","-1","-1","1","1","-1","0","0","0","20","0","-1","0","0","0","0","0","100","0","0","0","0","0","0","0","0","0","0","0","0","254","254","199","0","0","0","0","-1","100","1","1","0","1","1","1","1","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","1","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","0","1","0","0","1","0","0","0","0","0","-1","-1","-1","-1","-1","-1","-1","0","0","0","0","-1","-1","-1","-1","-1","-1","-1","0","0","-1","0","-1","1","1","1","1","1","1","1","1","1","0","1","1","0","0","-1","-1","1","0","0","0","0","0","0","1","1","1","1","1","1","1","1","0","0","0","0","0","0","0","0","0","0","0","0","0","100","0","0","0","0","0","0","0","0","0","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","1","0","0","0","-1","1","0","0","0","0","0","1","0","1","1","1","1","1","0","0","0","0","1","1","{NEXTSPEFFECTID}","1","1","1","-1","0","0","0","0","0","0","0","0","0","0","0","0","0","0","1","1","1","0","0","1","1","0","0","100","0","0","0","0","0","0","0","0","0","0","1","1","1","1","1","1","1","0","0","0","0","1","1","[0|0|0|0]"]
		},
	"specialsuffix":{
		0:"",
		1:" on Kill"
	}
}

const SpEffectLootBankEntry : Dictionary = {
	"speffectid":0,
	"description":"SpEffect Here",
	"prefix":"",
	"suffix":"",
	"interfix":"",
	"isbehaviourspeffect":0,
	"magictoolid":0,
	"rarityname":"",
	"talismaniconid":18000,
	"talismansortid":400000,
	"talismanname":""
}

const SpEffectCustomSetupDictionary : Dictionary = {
	"name":"DefaultTalisman",
	"duration":[-1.0,-1.0],
	"triggerinterval":[0.0,0.0],
	"affectparam":[["addLifeForceStatus","addWillpowerStatus","addEndureStatus","addStrengthStatus","addDexterityStatus","addMagicStatus","addFaithStatus","addLuckStatus"],["addLifeForceStatus","addWillpowerStatus","addEndureStatus","addStrengthStatus","addDexterityStatus","addMagicStatus","addFaithStatus","addLuckStatus"]],
	"affectparamrealdesc":[["VIG","MND","END","STR","DEX","INT","FTH","ARC"],["VIG","MND","END","STR","DEX","INT","FTH","ARC"]],
	"paramtype0int1float":[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
	"affectparamminmax":[[1,4],[1,4]],
	"stateinfo":0,
	"negativevalue":[0,0],
	"showpercentsymbol":[0,0],
	"displaynumbermultiplier":[1.0,1.0],
	"showminusnotplus":[0,0],
	"effectchance":[1.0,0.4],
	"maxmultiplier":3.0,
	"errmultiplier":1.0,
	"errmultiplierparamnametrigger":["addEndureStatus"],
	"rarityaffectmultiplier":1.0,
	"speffecttype":0,
	"suffpreinterfixes":["Emboldening","of Emboldening","Emboldened"],
	"talismaniconid":[18000],
	"talismansortid":400000,
	"talismanname":""
}

const SpEffectsBasePath : String = "user://speffects"
const DefSpEffectsName : String = "#Default_SpEffectParameter.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	create_speffects_directory()
	create_default_speffect_parameters()
	load_speffect_parameters()
	
func _on_generation_start():
	add_database_speffects()

	
func create_speffects_directory():
	var spef_dir = Directory.new()
	if !spef_dir.dir_exists(SpEffectsBasePath):
		spef_dir.make_dir_recursive(SpEffectsBasePath)
		
func create_default_speffect_parameters():
	var defspef : File = File.new()
	var fulldefspefpath:String = SpEffectsBasePath+"/"+DefSpEffectsName
	if !defspef.file_exists(fulldefspefpath):
		if defspef.open(fulldefspefpath,File.WRITE) == OK:
			defspef.store_string(JSON.print(SpEffectCustomSetupDictionary))
			defspef.close()
		
func add_database_speffects():
	var armoreffectstable = weapgendatabase.get_table("ArmorEffects")
	for x in armoreffectstable.get_row_count():
		var newspeffectdict: Dictionary = {}
		var newrow : Dictionary = armoreffectstable.get_row_by_index(x)
		for y in SpEffectLootBankEntry.keys().size():
			var newkey : String = SpEffectLootBankEntry.keys()[y]
			if newrow.has(newkey):
				newspeffectdict[newkey] = newrow[newkey]
			else:
				newspeffectdict[newkey] = SpEffectLootBankEntry[newkey]
				#print(str(newrow[newkey])+" "+str(newspeffectdict[newkey]))
		var lootbanktoaddto : int = 3+newrow["isbehaviourspeffect"]
		#print(newspeffectdict)
		##MANUALLY ADD TO LOOT BANK
		#LOOT
		get_parent().LootBanks[lootbanktoaddto].LootBank_Loot[newspeffectdict["speffectid"]] = newspeffectdict
		get_parent().LootBanks[lootbanktoaddto].LootBank_IDs.append(newspeffectdict["speffectid"])
		get_parent().LootBanks[lootbanktoaddto].LootBank_AvailableIDs.append(newspeffectdict["speffectid"])
		
		## IF magictoolid IS 1 OR 2 ADD IT TO THE RESPECTIVE ARRAY IN MAGICTOOLIDS
		if newrow["magictoolid"] > 0:
			MagicToolSpEffectIDs[newrow["magictoolid"]].append(newrow["speffectid"])
			#print_debug(str(newrow["speffectid"])+" added to MTSEI row "+str(newrow["magictoolid"]))
				
		
		#print_debug(get_parent().LootBanks[lootbanktoaddto].LootBank_Loot)
		#print("Added "+str(newrow["speffectid"])+" from WeapGenDatabase to SpEffect LootBank "+str(lootbanktoaddto))
		#print(get_parent().LootBanks[lootbanktoaddto].LootBank_Loot.keys())

func load_speffect_parameters():
	var spef_dir = Directory.new()
	var finalloadedspeftext : String = ""
	if spef_dir.open(SpEffectsBasePath) == OK:
		#ITERATE THROUGH EVERY FILE IN THE SPEFFECTFOLDER, EXCLUDING
		spef_dir.list_dir_begin(true)
		var new_spef_file = spef_dir.get_next()
		while new_spef_file != "":
			if !"#" in new_spef_file and ".json" in new_spef_file:
				print(new_spef_file)
				var newfilefullpath : String = SpEffectsBasePath+"/"+new_spef_file
				var newspefjson : File = File.new()
				if newspefjson.open(newfilefullpath,File.READ)==OK:
					var newjsonparse = JSON.parse(newspefjson.get_line())
					print(newjsonparse.result)
					var newjsonparseresult : Dictionary = newjsonparse.result
					if newjsonparseresult.keys() == SpEffectCustomSetupDictionary.keys():
						SpEffectParameters[newjsonparseresult["name"]] = newjsonparseresult
						finalloadedspeftext += newjsonparseresult["name"]+" "+str(newjsonparseresult["affectparam"][0])+"\n"
					else:
						OS.alert("Custom SpEffect Parameter JSON '"+str(new_spef_file)+"' has the incorrect set of keys.\n\nIt has: "+str(newjsonparseresult.keys())+"\n\nIt should have: "+str(SpEffectCustomSetupDictionary.keys()))
				else:
					print_debug("Couldn't open "+str(newfilefullpath))
			new_spef_file = spef_dir.get_next()
	#APPLY FINALLOADEDSPEFTEXT TO INDICATOR
	if SpEffectParameters.keys().size() > 0:
		SpEfLoadIndicator.text = finalloadedspeftext
	else:
		SpEfLoadIndicator.text = "[NONE]"
	#print(str(SpEffectParameters))
	

func generate_speffect(outputlootbank:int=3,behspeffectlootbank:int=4,behspeffect:bool=false,forcespeffectparamname:String="",minmaxmultiplier:float=1.0,rarityname:String="Common",whoaskedforthis:String="")->Dictionary:
	
	#GET THE CURRENT CUMULATIVE ID AND MULTIPLY IT BY 10 TO KEEP THE FINAL 0 OF THE ID FREE IF WE NEED IT
	var newid : int = SpEffectIDStart+((get_parent().cumulativeids[3])*10)
	var triggerspeffectid : int = newid+1
	
	#CREATE VARIABLE TO SET IF WE'RE MAKING A SPECIAL KIND OF SPEFFECT - E.G. ACTIVATE ON KILL A LA TAKER'S CAMEO (1)
	var specialid = 0
	
	#INITIALISE SPEFFECTPARAM NAME
	var NewSpEffectName : String = ""
	
	#INITIALISE SPEFFECTPARAM DESCRIPTION
	var NewSpEffectDesc : String = ""
	#INITIALISE SPECIAL PARAM TYPE SUFFIX
	var NewSpecialSpefSuffix : String = ""
	#INITIALISE DURATION PARAM TYPE Desc
	var NewDurationDesc : String = ""
	#INITIALISE TRIGGER INTERVAL DESCRIPTION
	var NewTriggerIntervalDesc : String = ""
	
	#FIRST, CHOOSE THE SPEFFECT PARAMETER WE'RE GOING TO USE 
	var NewSpEffectParam : Dictionary
	if forcespeffectparamname != "" and SpEffectParameters.has(forcespeffectparamname):
		#SET NewSpEffectParam TO THE DICTIONARY WE'VE ASKED
		NewSpEffectParam = SpEffectParameters[forcespeffectparamname]
	else:
		#IF THERE IS NO FORCEDSPEFFECTPARAMNAME OR IT'S NOT IN SPEFFECT, CHOOSE FROM THE ONES THAT *ARE* AVAILABLE USING PARENT'S RNG
		var SEPSize = SpEffectParameters.keys().size()
		var SEPSizeRNG :int = get_parent().RNG.randi_range(0,SEPSize-1)
		NewSpEffectParam = SpEffectParameters[SpEffectParameters.keys()[SEPSizeRNG]]
		
	#ASSUMING WE'RE TAKING THE MULTIPLIER FROM THE RARITY TABLES, NERF THE MULTIPLIER TO STOP THINGS GETTING TOO CRAZY
	#ALSO TAKE INTO ACCOUNT THE SPEFFECTPARAM'S RARITYAFFECTMULTIPLIER
	var basemultiplier : float = minmaxmultiplier*float(NewSpEffectParam["rarityaffectmultiplier"])
	#CLAMP MULTIPLIER TO THE SPEFFECTPARAM'S MAXMULTIPLIER VALUE
	var newspeffectmultiplier : float = clamp(basemultiplier,0.95,float(NewSpEffectParam["maxmultiplier"]))
	
	#print_debug(str(minmaxmultiplier)+" "+str(float(NewSpEffectParam["rarityaffectmultiplier"]))+" "+str(basemultiplier)+" "+str(newspeffectmultiplier))
		
	specialid = NewSpEffectParam["speffecttype"]
		
	var newspeffectdict :Dictionary = create_speffect_dictionary(specialid)
	var triggerspeffectdict :Dictionary = create_speffect_dictionary(0)
	##^^^^ CREATE TRIGGER SPEFFECT AT ID AND SET NEWSPEFFECTID TO ID+1 - GOOD FOR THINGS LIKE TAKER'S CAMEO, APPLY EFFECT ON KILL
	if specialid > 0:
		triggerspeffectdict["ID"]=str(triggerspeffectid)
		NewSpecialSpefSuffix = SpEffect["specialsuffix"][specialid]
	
	#CREATE AN ARRAY OF THE SPEFFECTS DICTIONARIES ABOVE SO WE CAN JUMP BETWEEN THEM EASILY
	# FIRST ONE IS CREATED WITH THE SPECIALID, IF WE'RE DOING ANYTHING OTHER THAN A NORMAL SPEFFECT
	#OFFSET WHICH ONE WE'RE EDITING BY 1
	var newspeffects : Array = [newspeffectdict,triggerspeffectdict]
	
	#IF WE'RE CREATING ANYTHING THAT ISN'T TYPE 0, OFFSET THE NEWSPEFFECT DICT TO EDIT BY 1
	var speffecttoedit : int = 0 if specialid == 0 else 1

	
	#START CHOOSING AND SETTING THE ACTUAL PARAMETERS
	#ITERATE ACROSS THE NUMBER OF AFFECTPARAM ARRAYS WITHIN NewSpEffectParam["affectparam"]
	for x in NewSpEffectParam["affectparam"].size():
		#ONLY APPLY PARAM IF WE PASS A PERCENTAGE CHANCE, FORCE IT IF IT'S THE FIRST PARAM
		var shouldapplyparam :bool = get_parent().get_bool_chance(NewSpEffectParam["effectchance"][x])
		if shouldapplyparam or x == 0:
			#CHOOSE WHICH PARAMS TO AFFECT
			#CHOOSE FROM THE PARAMS AVAILABLE IN THE CURRENT ARRAY
			#print_debug(NewSpEffectParam["affectparam"][x])
			var numberofpossibleparams : int = NewSpEffectParam["affectparam"][x].size()-1
			var paramoffsetresult : int = get_parent().RNG.randi_range(0,numberofpossibleparams)
			var paramtoset :String = NewSpEffectParam["affectparam"][x][paramoffsetresult]
			var paramrealnametoset : String = NewSpEffectParam["affectparamrealdesc"][x][paramoffsetresult]
			
			#ADD PARAMTOSET TO THE OVERALL NAME
			NewSpEffectName += paramtoset+" "
			
			#SETUP ERR MULTIPLIER - APPLY IF PARAMTOSET IS IN ERRMULTIPLIERPARAMNAMETRIGGER, OTHERWISE LEAVE IT AT 1.0
			#THIS LETS US SCALE UP THINGS LIKE MANA REGEN WHILE KEEPING 
			var errmultiplier : float = 1.0
			if NewSpEffectParam["errmultiplierparamnametrigger"].has(str(paramtoset)):
				errmultiplier = NewSpEffectParam["errmultiplier"]
			
			#CHOOSE WHETHER OR NOT IT'S AN INT OR A FLOAT, AND THEN USE THE MAX/MIN VALUE TO GENERATE OUR NEW BOOST/NERF
			var paramminmaxarray : Array = NewSpEffectParam["affectparamminmax"][x]
			var valuetoset : float = get_parent().RNG.randf_range(paramminmaxarray[0]*newspeffectmultiplier,paramminmaxarray[1]*newspeffectmultiplier)
			##CLAMP TO 
			match int(NewSpEffectParam["paramtype0int1float"][x][paramoffsetresult]):
				1:
					valuetoset = float((round((valuetoset*errmultiplier)*100))*0.01)
					#CLAMP TO AVOID 0 VALUES
					valuetoset = clamp(valuetoset,0.01,2000.0)
				_:
					valuetoset = int(valuetoset*errmultiplier)
					valuetoset = clamp(valuetoset,1,2000)
					
			##MAKE VALUES NEGATIVE BASED ON "NEGATIVE" PARAM SETTING
			var negativemultiplier = 1.0 if NewSpEffectParam["negativevalue"][x] == 0 else -1.0
			valuetoset = valuetoset * negativemultiplier
			
			var displayvaluetoset = valuetoset*NewSpEffectParam["displaynumbermultiplier"][x]

			#INITIALISE PLUS OR MINUS PREFIX BASED ON SPEFFECT DEFINITION
			var NewSpEfPlusMinus : String = "-" if NewSpEffectParam["showminusnotplus"][x] == 1 else "+"
			
			#INITIALISE PERCENT SUFFIX BASED ON SPEFFECT DEFINITION
			var NewSpEfPercent : String = "%" if NewSpEffectParam["showpercentsymbol"][x] == 1 else ""
			
			#NOW WE'VE GOT THE PARAM AND THE VALUE, SET THEM BOTH IN THE DICTIONARY
			newspeffects[speffecttoedit][paramtoset] = valuetoset
			#ADD THE VALUE TO THE SPEFFECT'S NAME
			NewSpEffectName += NewSpEfPlusMinus+str(abs(displayvaluetoset))+NewSpEfPercent+" "

			#ADD TO DESCRIPTION
			NewSpEffectDesc += NewSpEfPlusMinus+str(abs(displayvaluetoset))+NewSpEfPercent+" "+paramrealnametoset+"\\n"

			#IF WE'RE SETTING THE FIRST PARAM, SET THE ICON ID TO THE paramoffsetresult INDEX OF THE
			#TALISMANICONID ARRAY IF IT EXISTS, OTHERWISE DEFAULT TO 0
			if x==0:
				#print_debug(NewSpEffectParam["talismaniconid"])
				var chosenicon : int = 0
				if NewSpEffectParam["talismaniconid"].size() > paramoffsetresult:
					chosenicon = paramoffsetresult
					#print_debug(NewSpEffectParam["talismaniconid"][paramoffsetresult])
				newspeffects[speffecttoedit]["talismaniconid"] = NewSpEffectParam["talismaniconid"][chosenicon]
	
	##SET ID VALUES
	var triggerspeffect = 0 if specialid > 0 else 1
	var triggeredspeffect = 1 if specialid > 0 else 0
	newspeffects[triggeredspeffect]["ID"] = newid
	newspeffects[triggerspeffect]["ID"] = triggerspeffectid

	#MAKE OUR EFFECT STACKABLE
	newspeffects[speffecttoedit]["spCategory"] = 10
		
	#SET EFFECT DURATION AND TRIGGER INTERVAL - ARRAYS PROVIDE MIN, THEN MAX
	var durationtoset : float = get_parent().RNG.randf_range(NewSpEffectParam["duration"][0],NewSpEffectParam["duration"][1])
	
	newspeffects[speffecttoedit]["effectEndurance"] = round(durationtoset*100)*0.01
	
	var triggerintervaltoset : float = get_parent().RNG.randf_range(NewSpEffectParam["triggerinterval"][0],NewSpEffectParam["triggerinterval"][1])
	#MULTIPLY BY 100, ROUND, MULTIPLY BY 0.01
	newspeffects[speffecttoedit]["motionInterval"] = round(triggerintervaltoset*100)*0.01
	#print_debug("Trigger Interval: "+str(triggerintervaltoset))
	
	#NOW WE HAVE THESE TWO, WE CAN SET OUR TRIGGER AND DURATION DESCRIPTIONS IF NECESSARY
	if durationtoset > 0 and triggerintervaltoset > 0:
		var BaseDesc : String = "Triggers once every {TRIG} seconds for {DUR} seconds."
		NewSpEffectDesc += BaseDesc.format({"TRIG":str(newspeffects[speffecttoedit]["motionInterval"]),"DUR":str(newspeffects[speffecttoedit]["effectEndurance"])})+"\n"
	elif triggerintervaltoset > 0:
		NewSpEffectDesc += "Triggers every "+str(newspeffects[speffecttoedit]["motionInterval"])+" seconds."
	elif durationtoset > 0:
		NewSpEffectDesc += "Lasts "+str(str(newspeffects[speffecttoedit]["effectEndurance"])+" seconds once triggered.")
		
	#print_debug(str(newspeffects[triggeredspeffect]["ID"])+" "+NewSpEffectDesc)
	
	#MAKE SURE WE'VE SET OUR NEW SPEFFECT'S NAME
	newspeffects[speffecttoedit]["Name"] = "DSL "+NewSpEffectName
	
	#MAKE SURE OUR NEW SPEFFECT IS SET TO STACK
	newspeffects[speffecttoedit]["spCategory"] = 10
	
	#SET THE STATEINFO
	newspeffects[speffecttoedit]["stateInfo"] = int(NewSpEffectParam["stateinfo"])
	
	#IF SPECIALID IS MORE THAN 1, SET INITIAL SPEFFECT DICTIONARY (WHICH WILL BE CONVERTED TO A TRIGGER IF THIS IS THE CASE)'S CHAIN SPEFFECT
	#VALUE TO newspeffects[1]'s ID
	if specialid > 0:
		newspeffects[0]["applyIdOnGetSoul"]=newspeffectdict[1]["ID"]
		var newnamebase :String = newspeffects[0]["Name"]
		newnamebase += newspeffects[1]["Name"]
		newspeffects[0]["Name"]=newnamebase+SpEffect["specialsuffix"][specialid]
		
	
	#COMPILE FINAL SPEFFECTPARAM ENTRY
	var finalspeffectparam : String = get_parent().compile_dictionary_values_line_from_headers(newspeffects[0],SpEffect["headers"])
	get_parent().add_to_finalstring("SpEffectParam",finalspeffectparam)
	if specialid > 0:
		var triggereffectparam : String = get_parent().compile_dictionary_values_line_from_headers(newspeffects[1],SpEffect["headers"])
		get_parent().add_to_finalstring("SpEffectParam",finalspeffectparam)
		
	
	#ADVANCE SPEFFECT CUMULATIVE ID
	get_parent().affect_cumulative_id_value(3)
	
	#ADD SPEFFECTBANKENTRY TO RELEVANT SPEFFECT LOOT BANK
	var banktoaddto :int = behspeffectlootbank if behspeffect else outputlootbank
	#print_debug(str(newspeffects[0]["ID"])+" "+str(newspeffects[0]["Name"])+" "+str(newspeffects[0]["effectEndurance"])+" "+str(newspeffects[0]["motionInterval"]))
	#DON'T FORGET, THIS FUNCTION ALSO EXPORTS THE NEW DICTIONARY TO THE SPEFFECT LOOT BANK AUTOMATICALLY
	var finallootbankentry = create_speffectlootbank_dictionary(int(newspeffects[0]["ID"]),NewSpEffectParam["suffpreinterfixes"][0],NewSpEffectParam["suffpreinterfixes"][1],NewSpEffectParam["suffpreinterfixes"][2],NewSpEffectDesc,banktoaddto,newspeffects[speffecttoedit]["talismaniconid"])#FINISH THIS
	
	#print_debug(str(whoaskedforthis)+" "+str(newspeffects[speffecttoedit]["ID"]))
	
	#RETURN THE DICTIONARY OF THE NEWLY CREATED LOOT BANK ENTRY SO WE CAN USE IT IMMEDIATELY
	return finallootbankentry
	
func create_speffectlootbank_dictionary(spefid:int,prefix:String="",suffix:String="",interfix:String="",description:String="",lootbankid:int=3, talismaniconid:int=18000,alsoexport:bool=false)->Dictionary:
	var newspeflootbankdict : Dictionary = SpEffectLootBankEntry
	
	#ASSIGN ID
	newspeflootbankdict["speffectid"]=spefid
	
	#ASSIGN xFIXES
	newspeflootbankdict["prefix"]=prefix
	newspeflootbankdict["suffix"]=suffix
	newspeflootbankdict["interfix"]=interfix
	newspeflootbankdict["talismaniconid"]=talismaniconid
	
	#ASSIGN DESCRIPTION
	newspeflootbankdict["description"]=description
	
	#EXPORT SPEFFECTLOOTBANK TO DICTIONARY
	#lootarrayid:int,lootdicttoadd:Dictionary,lootidarrayint:int,availableidarrayint:int
	if alsoexport:
		get_parent().export_values_to_loot_bank(lootbankid,newspeflootbankdict,spefid,spefid)
	
	return newspeflootbankdict
	
func create_speffect_dictionary(specialid:int=0)->Dictionary:
	var headersarray = SpEffect["headers"]
	var defaultarray = SpEffect["default"][specialid]
	var speffectdictionary : Dictionary = {}
	
	for x in headersarray.size():
		speffectdictionary[headersarray[x]] = defaultarray[x]
		
	return speffectdictionary
		
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
