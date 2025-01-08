extends Node

const ITEMS = ["Apple", "Blueberry", "Broccoli", "Carrot", "Cauliflower", "Cucumber", "Egg",
	"Garlic", "Green Beans", "Green Grapes", "Hot Pepper", "Milk", "Peas", "Potato",
	"Pumpkin", "Purple Grapes", "Raddish", "Raspberry", "Red Onion", "Strawberry",
	"Sweet Potato", "Tomato", "Watermelon", "Wheat"]

const ITEM_PAIN_RELIEVER = preload("res://scripts/inventory/items/item_pain_reliever.tres")
const ITEM_ANTIBIOTIC = preload("res://scripts/inventory/items/item_antibiotic.tres")
const ITEM_IMMUNE_BOOSTER = preload("res://scripts/inventory/items/item_immune_booster.tres")
const ITEM_DIGESTIVE_AID = preload("res://scripts/inventory/items/item_digestive_aid.tres")
const ITEM_ENERGY_BOOSTER = preload("res://scripts/inventory/items/item_energy_booster.tres")
const ITEM_ANTI_INFLAMMATORY = preload("res://scripts/inventory/items/item_anti_inflammatory.tres")
const ITEM_DETOXIFIER = preload("res://scripts/inventory/items/item_detoxifier.tres")


const MEDICINES = {
	"Pain Reliever": {
		"illnesses": ["Headaches", "Migraines", "Muscle strains", "Arthritis"],
		"recipes": {
			"Herbal Salve": ["Garlic", "Potato", "Wheat"],
			"Berry Boost Drink": ["Blueberry", "Raspberry", "Strawberry", "Milk"],
			"Pain Relief Tea": ["Green Grapes", "Purple Grapes", "Pumpkin"]
		},
		"item_data": ITEM_PAIN_RELIEVER
	},
	"Antibiotic": {
		"illnesses": ["Respiratory infections", "Skin infections", "Stomach ulcers", "Sore throat"],
		"recipes": {
			"Healing Broth": ["Garlic", "Red Onion", "Cauliflower", "Carrot"],
			"Immunity Boost Juice": ["Egg", "Hot Pepper", "Green Grapes"],
			"Soothing Elixir": ["Cucumber", "Peas", "Raddish"]
		},
		"item_data": ITEM_ANTIBIOTIC
	},
	"Immune Booster": {
		"illnesses": ["Common cold", "Seasonal flu", "Fatigue", "Weak immunity"],
		"recipes": {
			"Vitamin Shot": ["Apple", "Strawberry", "Broccoli"],
			"Energizing Soup": ["Sweet Potato", "Pumpkin", "Green Beans", "Wheat"],
			"Berry Immunity Drink": ["Blueberry", "Raspberry", "Purple Grapes"]
		},
		"item_data": ITEM_IMMUNE_BOOSTER
	},
	"Digestive Aid": {
		"illnesses": ["Bloating", "Indigestion", "Constipation", "Acid reflux"],
		"recipes": {
			"Soothing Smoothie": ["Cucumber", "Milk", "Peas"],
			"Fiber-Rich Salad": ["Raddish", "Carrot", "Tomato", "Broccoli"],
			"Digestive Tea": ["Garlic", "Wheat", "Hot Pepper"]
		},
		"item_data": ITEM_DIGESTIVE_AID
	},
	"Energy Booster": {
		"illnesses": ["Chronic fatigue", "Post-illness recovery", "Low stamina", "Lack of focus"],
		"recipes": {
			"Power Blend": ["Watermelon", "Apple", "Sweet Potato", "Pumpkin"],
			"Revitalizing Tea": ["Tomato", "Garlic", "Wheat"],
			"Morning Shake": ["Milk", "Blueberry", "Green Grapes"]
		},
		"item_data": ITEM_ENERGY_BOOSTER
	},
	"Anti-inflammatory": {
		"illnesses": ["Joint pain", "Skin rashes", "Swollen glands", "Allergic reactions"],
		"recipes": {
			"Healing Smoothie": ["Carrot", "Raddish", "Purple Grapes", "Strawberry"],
			"Anti-inflammatory Soup": ["Potato", "Sweet Potato", "Broccoli", "Cauliflower"],
			"Cooling Drink": ["Cucumber", "Watermelon", "Strawberry"]
		},
		"item_data": ITEM_ANTI_INFLAMMATORY
	},
	"Detoxifier": {
		"illnesses": ["Toxin buildup", "Liver issues", "Acne", "Sleep disturbances"],
		"recipes": {
			"Green Cleanse Juice": ["Green Beans", "Green Grapes", "Cucumber"],
			"Detox Soup": ["Cauliflower", "Garlic", "Raddish", "Hot Pepper"],
			"Refreshing Salad": ["Apple", "Broccoli", "Blueberry", "Pumpkin"]
		},
		"item_data": ITEM_DETOXIFIER
	}
}

var _illness_to_category = {}
var _item_to_recipe = {}
var _recipe_to_category = {}

func _ready():
	for category in MEDICINES:
		# Make a map from illness to category as {str -> str}
		for illness in MEDICINES[category]["illnesses"]:
			_illness_to_category[illness] = category

		# Make a map from item to recipe as {str -> Array[str]}
		for recipe in MEDICINES[category]["recipes"]:
			for item in MEDICINES[category]["recipes"][recipe]:
				if _item_to_recipe.has(item):
					if not _item_to_recipe[item].has(recipe):
						_item_to_recipe[item].append(recipe)
				else:
					_item_to_recipe[item] = [recipe]

			# Make map from recipe to category as {str -> str}
			_recipe_to_category[recipe] = category
	

## Get all possible craftable recipes given items
func get_possible_recipes(items: Array):
	var ret_recipes = []

	for category_name in MEDICINES:
		for recipe_name in MEDICINES[category_name]["recipes"]:
			var recipe_items = MEDICINES[category_name]["recipes"][recipe_name]
			
			# Check if we have all items to make the recipe
			if _can_craft_recipe(recipe_items, items):
				ret_recipes.append({recipe_name = recipe_name, recipe_items = recipe_items})
	
	return ret_recipes


## Returns whether the recipe can be crafted from given items
func _can_craft_recipe(recipe: Array, _items: Array) -> bool:
	var items = _items.duplicate()

	for req_item in recipe:
		if items.has(req_item):
			items.erase(req_item)
		else:
			return false
	
	return true


## Returns an ItemData for the medicine recipe.
func get_medicine_item_from_recipie(recipe_name = "") -> ItemData:
	var medicine_category = _recipe_to_category[recipe_name]
	var item_data = MEDICINES[medicine_category]["item_data"].duplicate()
	item_data.name += " - " + recipe_name
	
	return item_data
