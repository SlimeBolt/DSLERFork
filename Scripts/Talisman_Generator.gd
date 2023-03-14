extends Node
class_name Talisman_Generator

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var SpEffectGenPath
onready var SpEffectGenNode = get_node(SpEffectGenPath)


const TalismanCompatibilityOffset : int = 9000

const DefaultTalismanDefinition : Dictionary = {
	"name":"Talisman",
	"iconid":18000,
	"sortid":400000
}

const TalismanIDStart : int = 8000

const TalismanEffectsSet : Array = ["refId","residentSpEffectId1","residentSpEffectId2","residentSpEffectId3"]


var talismancumulativeid : int = 0


const EquipParamAccessory : Dictionary = {
	"headers":["ID","Name","disableParam_NT","disableParamReserve1","disableParamReserve2","refId","sfxVariationId","weight","behaviorId","basicPrice","sellValue","sortId","qwcId","equipModelId","iconId","shopLv","trophySGradeId","trophySeqId","equipModelCategory","equipModelGender","accessoryCategory","refCategory","spEffectCategory","sortGroupId","vagrantItemLotId","vagrantBonusEneDropItemLotId","vagrantItemEneDropItemLotId","isDeposit","isEquipOutBrake","disableMultiDropShare","isDiscard","isDrop","showLogCondType","showDialogCondType","rarity","pad2","saleValue","accessoryGroup","pad3","compTrophySedId","residentSpEffectId1","residentSpEffectId2","residentSpEffectId3","residentSpEffectId4","pad1"],
	"default":["1000","Talisman","0","0","[0|0|0]","310000","-1","0.3","0","0","100","400000","0","0","18000","-1","-1","-1","0","0","0","2","0","10","-1","-1","-1","1","0","0","1","1","1","2","2","[0|0]","0","1000","0","-1","0","0","0","0","[0|0|0|0]"]
}

func talisman_create_talisman(explootbankid:int=2,minrarity:int=-1,maxrarity:int=-1):
	#GRAB OUR BASE TALISMAN
	
	var newtalisman : Dictionary = talisman_create_default_dictionary()
	
	#SET OUR NEW TALISMAN'S ID
	
	var talismanid : int = TalismanIDStart+get_parent().cumulativeids[2]
	newtalisman["ID"] = talismanid
	
	#GET OUR RARITY
	var rarityvalues : Dictionary = get_parent().weapon_choose_rarity(minrarity,maxrarity)
	
	var rarityname : String = rarityvalues["name"]
	var raritymultiplier : float = rarityvalues["extraeffect0chance"]
	var qualitymultiplier : float = rarityvalues["mindmgmultiplier"]
	
	#FIRST, CREATE ALL OUR EFFECT CHANCES SO WE DON'T UNNECESSARILY CREATE CUSTOM SPEFFECTS
	var multieffectchances : Array = [1,raritymultiplier*0.5,raritymultiplier*0.2,raritymultiplier*0.02]
	#print(multieffectchances)
	var multieffectresults : Array = [false,false,false,false]
	
	#CREATE ARRAY OF THE VARIOUS xFIXES - ARRANGED BY SUFFIX,PREFIX,INTERFIX,SUFFIX (UNUSED, JUST MEANS LESS CODE)
	var finalfixes : Array = ["","","","",""]
	var fixtoget : Array = ["suffix","prefix","interfix","suffix","suffix"]
	
	#TRY ALL THREE MULTIEFFECT CHANCES
	
	for x in multieffectresults.size():
		multieffectresults[x] = get_parent().get_bool_chance(multieffectchances[x])
	
	#generatedeffectvaluemultiplier:float=1.0,rarityname:String="",allowcustom:bool=false)
	
	
	#GUARANTEE FIRST ASSIGNED EFFECT, THEN CHOOSE THE OTHERS WE MAY OR MAY NOT USE,
	#FORCING A CUSTOM EFFECT IF MULTIEFFECTRESULTS RETURNS TRUE - BETA 0.5 - FINAL BOOL FORCES A CUSTOM EFFECT 
	var EffectsToAssign : Array = [{},{},{},{}]
	var EffectIDs : Array = []
	var EffectDescriptions : Array = []
	
	#ASSIGN ICON AND SORTID BASED ON MAIN EFFECT,
	#ADD TO SORTID BASED ON CUMULATIVE ASSIGN ID FOR TALISMANS (2)
	var sortidadditon = get_parent().cumulativeassignids[2]
	
	#ITERATE OVER MULTIEFFECT CHANCES TO DETERMINE WHICH EFFECTS THIS TALISMAN WILL HAVE - ADD ALL OF THEM HERE
	#AND USE THE MULTIEFFECT CHANCE VALUE TO STOP IT CREATING UNNECESSARY SPEFFECTS
	var counter = 0;
	for x in multieffectchances.size():
		var neweffect = get_parent().choose_armor_effect(qualitymultiplier*1.5,rarityname,multieffectchances[x],0,0,multieffectchances[x],"Talisman "+str(x+1))
		EffectIDs.append(neweffect["speffectid"])
		EffectDescriptions.append(neweffect["description"])
		if multieffectresults[x]:
			#SET THE APPROPRIATE FINALFIX WHILE WE'RE AT IT IF MULTIEFFECTRESULT SUCCEEDS
			finalfixes[x] = neweffect[fixtoget[x]]
		#IF X IS 0, I.E. THE MANDATORY EFFECT, GRAB THE TALISMAN ICON AND SORT ID AT THIS POINT
		if counter == 0:
			newtalisman["iconId"] = neweffect["talismaniconid"]
			newtalisman["sortId"] = neweffect["talismansortid"]+sortidadditon
		counter = counter + 1
	
	#SET EACH EFFECT BASED ON MULTIEFFECTRESULTS - refId SHOULD BE GUARANTEED
	for x in multieffectresults.size():
		if multieffectresults[x]:
			newtalisman[TalismanEffectsSet[x]] = EffectIDs[x]
		
	
	#WeaponGenerator.export_values_to_loot_bank(explootbankid)
	
	#SET TALISMAN'S RARITY VFX TO rarityvalue
	newtalisman["rarity"] = rarityvalues["rarityvalue"]
	
	#ASSIGN COMPATIBILITY VALUE BASED ON CUMULATIVE TALISMAN ID AND TALISMANCOMPATIBILITY OFFSET
	#THIS SHOULD LET YOU USE MULTIPLE GENERATED TALISMANS TOGETHER
	newtalisman["accessoryGroup"] = TalismanCompatibilityOffset+sortidadditon
	
	#ADVANCE CUMULATIVE ID
	get_parent().affect_cumulative_id_value(2)
	
	#SET NEW TALISMAN NAME
	var finaltalismanname :String = talisman_create_name("",finalfixes[1],finalfixes[0],finalfixes[2],rarityname)
	newtalisman["Name"] = "DSL "+finaltalismanname
	
	#CREATE TEXT ENTRIES
	#TALISMAN TITLE
	var newtalisman_titletext : String = ""
	newtalisman_titletext = get_parent().create_text_entry(str(newtalisman["ID"]),finaltalismanname)
	get_parent().add_to_finalstring("TitleRings.fmg.json",newtalisman_titletext)
	
	#TALISMAN DESCRIPTION
	var newtalisman_description : String = ""
	var newtalismanlore = get_parent().get_node("LoreGenerator").generate_lore_description(finaltalismanname,"Armor",get_parent().RNG.seed)
	var newtalisman_effects : String = ""
	
	#ITERATE OVER EACH ENTRY OF EFFECTSTOASSIGN TO ADD DESCRIPTION
	#for x in EffectsToAssign.size():
	for x in multieffectresults.size():
		if multieffectresults[x]:
			newtalisman_effects += EffectDescriptions[x]+"\\n"

	newtalisman_description = newtalisman_effects+"\\n"+newtalismanlore
	
	#TALISMAN SUMMARY
	var newtalisman_summary : String = ""

	#ITERATE OVER THE REST OF THE EFFECTS TO ASSIGN, IF THEY ARE TO BE APPLIED, ADD THEIR DESCRIPTION TO
	#THE FINAL TALISMAN SUMMARY STRING
	for x in multieffectresults.size():
		if multieffectresults[x] && x == 0:
			newtalisman_summary += EffectDescriptions[x]
		elif multieffectresults[x]:
			newtalisman_summary += ", "+EffectDescriptions[x]
			
	newtalisman_summary = newtalisman_summary.replace("\\n","  ")
	#newtalisman_summary = newtalisman_summary.replace(".","")
		
	var finaldescription : String = ""
	finaldescription = get_parent().create_text_entry(str(newtalisman["ID"]),newtalisman_description)
	get_parent().add_to_finalstring("DescriptionRings.fmg.json",finaldescription)
	
	##CREATE SUMMARY FOR TALISMAN
	var finalsummary : String = ""
	finalsummary = get_parent().create_text_entry(str(newtalisman["ID"]),newtalisman_summary)
	get_parent().add_to_finalstring("SummaryRings.fmg.json",finalsummary)

	#FINALLY, COMPILE THE FINALSTRING FOR OUR NEW TALISMAN AND EXPORT IT
	var compiledtalisman : String = get_parent().compile_dictionary_values_line_from_headers(newtalisman,EquipParamAccessory["headers"])
	get_parent().add_to_finalstring("EquipParamAccessory",compiledtalisman)
	get_parent().export_values_to_loot_bank(explootbankid,newtalisman,newtalisman["ID"],newtalisman["ID"])

func talisman_create_default_dictionary() -> Dictionary:
	var dicttoreturn = {}
	for x in EquipParamAccessory["headers"].size():
		dicttoreturn[EquipParamAccessory["headers"][x]] = EquipParamAccessory["default"][x]
	return dicttoreturn

func talisman_create_name(talismanname:String="",prefix:String="",suffix:String="",interfix:String="",rarityname:String="")->String:
	#DETERMINE WHETHER WE NEED A SPACE BETWEEN EACH PART OF OUR NEW NAME
	var needsspacearray : Array = [prefix,suffix,interfix,rarityname]
	#print_debug(needsspacearray)
	for x in needsspacearray.size():
		#IF ANY PART OF THE ARRAY IS NOT BLANK REPLACE IT WITH A SPACE, OTHERWISE LEAVE IT BLANK
		if needsspacearray[x] != "":
			needsspacearray[x] = " "
	
	## IF TALISMAN NAME IS BLANK REPLACE IT WITH A DEFAULT, "TALISMAN"
	
	var finaltalismanname : String = talismanname if talismanname != "" else "Talisman"
	
	var stringtoreturn : String = rarityname+needsspacearray[3]+prefix+needsspacearray[0]+interfix+needsspacearray[2]+finaltalismanname+needsspacearray[1]+suffix
	
	return stringtoreturn
