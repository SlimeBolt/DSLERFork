extends Node

const DamageTypesTable : Dictionary = {
	"eqwparamvalue": ["attackBasePhysics", "attackBaseFire", "attackBaseThunder", "attackBaseMagic", "attackBaseDark"],
	"cleanType": ["", "Fire", "Lightning", "Magic", "Sacred"],
	"buildUpType": {
		"": 			{20: "Poisoned",	21: "Rotting",			22: "Serrated",			23: "Chilled",				24: "Sedating",		25: "Maddening",			26: "Eutenising"},
		"Fire": 		{20: "Gaseous",	21: "Fire Blighted",	22: "Blood Flame",			23: "Frostbitten",			24: "Cozy",			25: "Shabriri's",			26: "Cremating"},
		"Lightning": 	{20: "Radiated",	21: "Corroding",		22: "Short Circuited",	23: "Super Conducted",	24: "Neuropathic",		25: "Overstimulating",	26: "Heart Stopping"},
		"Magic": 		{20: "Cursing",	21: "Decaying",		22: "Leeching",			23: "Cryonic",				24: "Hypnotising",		25: "Bellowing",			26: "Reaping"},
		"Sacred": 		{20: "Stagnating",	21: "Coven",			22: "Blootletting",		23: "Treacherous",			24: "Cleansing",		25: "Fanatical",			26: "Reincarnating"},
		"OmniDmg": "Prefected"
	},
	"spAttribute": [
		0,  #Phys
		10, #Magic
		11, #Fire
		12, #Thunder
		13, #Sacred
		20, #Poison
		21, #Scarlet Rot
		22, #Bleed
		23, #Frost
		24, #Sleep
		25, #Madness
		26  #Death Blight
	],
	"spEffectMsgId": [
		[6400, 6401, 6402, 6410], 	#Poison
		[6450, 6451, 6452], 			#Scarlet Rot
		[6500, 6501, 6502, 6510], 	#Bleed
		[6550, 6551, 6552], 			#Death Blight
		[6600, 6601, 6602], 			#Frost
		[6650, 6651, 6652], 			#Sleep
		[6700, 6701, 6702] 			#Madness
	],
	"behspeffect": {
		20: { "low-ad": 106000,	"low": 106050,	"med-ad": 106100,	"med": 106150,	"hi-ad": 106200,	"hi": 106250	},
		21: { "low-ad": 107000,	"low": 107050,	"med-ad": 107100,	"med": 107150,	"hi-ad": 107200,	"hi": 107250	},
		22: { "low-ad": 105000,	"low": 105050,	"med-ad": 105100,	"med": 105150,	"hi-ad": 105200,	"hi": 105250	},
		23: { "low-ad": 107500,	"low": 107550,	"med-ad": 107600,	"med": 107650,	"hi-ad": 107700,	"hi": 107750	},
		24: { "low-ad": 105500,	"low": 105550,	"med-ad": 105600,	"med": 105650,	"hi-ad": 105700,	"hi": 105750	},
		25: { "low-ad": 6750,	"low": 6751,	"med-ad": 6752,		"med": 6753,	"hi-ad": 6754,		"hi": 6755		},
		26: { "low-ad": 108000,	"low": 108050,	"med-ad": 108100,	"med": 108150,	"hi-ad": 108200,	"hi": 108250	}
	},
	"sfx": {"attackBasePhysics": 0, "attackBaseFire": 303001, "attackBaseThunder": 303011, "attackBaseMagic": 303071, "attackBaseDark": 303131, "OmniDmg": [303131, 303071]}
}

var RNG: RandomNumberGenerator

func _init(newRNG: RandomNumberGenerator):
	RNG = newRNG

func new_generate_weapon_damage(NewWeaponDict: Dictionary, RarityValues: Dictionary, WeaponIsShield: bool) -> Dictionary:
	var damageTypes = RollDamageTypes(RarityValues)
	var buildUps = RollBuildUps(RarityValues, damageTypes.size() == 5)
	
	return NewWeaponDict

func RollDamageTypes(RarityValues: Dictionary) -> Array:
	var result: Array
	
	#ROLL FOR AMOUNT OF DAMAGE TYPES
	var damageTypeAmount: int;
	#COMMON: 75% FOR SINGLE TYPE, 25% FOR DUAL
	match RarityValues["id"]:
		0:
			damageTypeAmount = weightedRoll({3: 1, 4: 2}, 4, 1)
	#UNCOMMON: 60% FOR SINGLE TYPE, 40% FOR DUAL
		1:
			damageTypeAmount = weightedRoll({3: 1, 5: 2}, 5, 1)
	#RARE: 50% FOR SINGLE, 50% FOR DUAL
		2:
			damageTypeAmount = RNG.randi_range(1,2)
	#TREASURED: 45% FOR SINGLE, 50% FOR DUAL, 5% FOR TRIPLE
		3:
			damageTypeAmount = weightedRoll({9: 1, 19: 2, 20: 3}, 20, 1)
	#ANCESTERAL: 40% FOR SIGNLE, 40% FOR DUAL, 20% FOR TRIPLE
		4:
			damageTypeAmount = weightedRoll({4: 1, 8: 2, 10: 3}, 10, 1)
	#LEGENDARY: 30% FOR SINGLE, 40% FOR DUAL, 30% FOR TRIPLE
		5:
			damageTypeAmount = weightedRoll({3: 1, 7: 2, 10: 3}, 10, 1)
	#DEMIGOD: 25% FOR SINGLE, 35% FOR DUAL, 35% FOR TRIPLE, 5% FOR QUADRUPLE
		6:
			damageTypeAmount = weightedRoll({5: 1, 12: 2, 19: 3, 20: 4}, 20, 1)
	#GODSLAYER: 21% FOR SINGLE, 31% FOR DUAL, 31% FOR TRIPLE, 16% FOR QUADRUPLE, 1% FOR ALL
		7:
			damageTypeAmount = weightedRoll({21: 1, 52: 2, 83: 3, 99: 4, 100: 5}, 100, 1)
		_:
			damageTypeAmount = 1
	
	#ROLL FOR DAMAGE TYPE, FORCE 50% CHANCE FOR PHYSICAL DAMAGE AS PRIMARY DAMAGE TYPE
	var damageTypesList: Array
	var attackTypesShuffled = DamageTypesTable["eqwparamvalue"]
	
	if damageTypeAmount < 5:
		var rolledTypeIndex = weightedRoll({4: 0, 5: 1, 6: 2, 7: 3, 8: 4}, 4, 0)
		
		damageTypesList.append(attackTypesShuffled[rolledTypeIndex])
		attackTypesShuffled.remove(rolledTypeIndex)
		attackTypesShuffled.shuffle()
	
		for n in attackTypesShuffled:	
			damageTypesList.append(attackTypesShuffled[n])
		
		return result
	else:
		attackTypesShuffled.shuffle()
		return attackTypesShuffled

func RollBuildUps(RarityValues: Dictionary, Perfected: bool) -> Dictionary:
	var output: Dictionary
	var amountOfBuildups: int = 0
	var skipLowTier: bool = false
	
	#PERFECTED ALWAYS HAS 3 BUILD-UPS
	if Perfected:
		amountOfBuildups = 3
	else:
		#50% CHANCE FOR BUILD-UP
		if RNG.randi_range(0,1) == 1:
			amountOfBuildups += 1
			match (RarityValues["id"]):
				#COMMON/UNCOMMON 2ND ROLL 50% FAIL CHANCE
				0, 1:
					amountOfBuildups += weightedRoll({1: 0, 2: 1}, 2, 0) 
				#RARE/TREASURED 2ND ROLL 25% FAIL CHANCE, 3RD 50% FAIL
				2, 3:
					amountOfBuildups += weightedRoll({50: 0, 125: 1, 200: 2}, 200, 0)
				#ANCESTRAL/LEGENDARY 2ND ROLL 100%, 3RD ROLL 25% FAIL, 4TH 50% FAIL
				#DEMIGOD/GODSLAYER HAS SAME RULES AS PREVIOUS, BUT SKIPS LOWER TIER BUILD-UP ROLLS
				4, 5, 6, 7:
					amountOfBuildups += weightedRoll({50: 1, 125: 2, 200: 3}, 200, 0)
					skipLowTier = RarityValues["id"] >= 6
	
	var rolledValues: Dictionary
	var buildUpWeights: Dictionary = {2: 20, 3: 21, 5: 22, 7: 23, 9: 25, 10: 26}
	
	for n in amountOfBuildups:
		var currentRol = weightedRoll(buildUpWeights, 10, 20)
		if rolledValues.has(currentRol):
			rolledValues[currentRol] += 1
			
			if buildUpWeights[currentRol] == 3 or (buildUpWeights[currentRol] == 2 and skipLowTier):
				buildUpWeights.erase(currentRol)
		else:
			if Perfected:
				rolledValues[currentRol] = 3
				buildUpWeights.erase(currentRol)
			else:
				rolledValues[currentRol] = 1
	
	output["spEffectBehaviorId0"] = -1
	output["spEffectBehaviorId1"] = -1
	output["spEffectBehaviorId2"] = -1
	
	var i: int = 0
	for n in rolledValues:
		var buildUpTier: String
		output[str("spEffectBehaviorId", i)] = DamageTypesTable["behspeffect"][n][str()]
	
	return output

func weightedRoll(values: Dictionary, totalWeight: int, default: int) -> int:
	var roll = RNG.randi_range(1, totalWeight)
	
	for weight in values:
		if roll <= weight:
			return values[weight]
	
	return default
