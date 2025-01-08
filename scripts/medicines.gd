extends Node

var items = ["Apple", "Blueberry", "Broccoli", "Carrot", "Cauliflower", "Cucumber", "Egg",
	"Garlic", "Green Beans", "Green Grapes", "Hot Pepper", "Milk", "Peas", "Potato",
	"Pumpkin", "Purple Grapes", "Raddish", "Raspberry", "Red Onion", "Strawberry", 
	"Sweet Potato", "Tomato", "Watermelon", "Wheat"]

var medicines = {
	"Pain Relievers": {
		"illnesses": ["Headaches", "Migraines", "Muscle strains", "Arthritis"],
		"recipes": {
			"Herbal Salve": ["Garlic", "Potato", "Wheat"],
			"Berry Boost Drink": ["Blueberry", "Raspberry", "Strawberry", "Milk"],
			"Pain Relief Tea": ["Green Grapes", "Purple Grapes", "Pumpkin"]
		}
	},
	"Antibiotics": {
		"illnesses": ["Respiratory infections", "Skin infections", "Stomach ulcers", "Sore throat"],
		"recipes": {
			"Healing Broth": ["Garlic", "Red Onion", "Cauliflower", "Carrot"],
			"Immunity Boost Juice": ["Egg", "Hot Pepper", "Green Grapes"],
			"Soothing Elixir": ["Cucumber", "Peas", "Raddish"]
		}
	},
	"Immune Boosters": {
		"illnesses": ["Common cold", "Seasonal flu", "Fatigue", "Weak immunity"],
		"recipes": {
			"Vitamin Shot": ["Apple", "Strawberry", "Broccoli"],
			"Energizing Soup": ["Sweet Potato", "Pumpkin", "Green Beans", "Wheat"],
			"Berry Immunity Drink": ["Blueberry", "Raspberry", "Purple Grapes"]
		}
	},
	"Digestive Aids": {
		"illnesses": ["Bloating", "Indigestion", "Constipation", "Acid reflux"],
		"recipes": {
			"Soothing Smoothie": ["Cucumber", "Milk", "Peas"],
			"Fiber-Rich Salad": ["Raddish", "Carrot", "Tomato", "Broccoli"],
			"Digestive Tea": ["Garlic", "Wheat", "Hot Pepper"]
		}
	},
	"Energy Boosters": {
		"illnesses": ["Chronic fatigue", "Post-illness recovery", "Low stamina", "Lack of focus"],
		"recipes": {
			"Power Blend": ["Watermelon", "Apple", "Sweet Potato", "Pumpkin"],
			"Revitalizing Tea": ["Tomato", "Garlic", "Wheat"],
			"Morning Shake": ["Milk", "Blueberry", "Green Grapes"]
		}
	},
	"Anti-inflammatory": {
		"illnesses": ["Joint pain", "Skin rashes", "Swollen glands", "Allergic reactions"],
		"recipes": {
			"Healing Smoothie": ["Carrot", "Raddish", "Purple Grapes", "Strawberry"],
			"Anti-inflammatory Soup": ["Potato", "Sweet Potato", "Broccoli", "Cauliflower"],
			"Cooling Drink": ["Cucumber", "Watermelon", "Strawberry"]
		}
	},
	"Detoxifiers": {
		"illnesses": ["Toxin buildup", "Liver issues", "Acne", "Sleep disturbances"],
		"recipes": {
			"Green Cleanse Juice": ["Green Beans", "Green Grapes", "Cucumber"],
			"Detox Soup": ["Cauliflower", "Garlic", "Raddish", "Hot Pepper"],
			"Refreshing Salad": ["Apple", "Broccoli", "Blueberry", "Pumpkin"]
		}
	}
}

var medicine_categories = []
var illnesses = []


func _ready():
	for category in medicines:
		medicine_categories.append(category)

		for illness in medicines[category]["illnesses"]:
			illnesses.append(illness)
		
	
	#print("Medicine categories: ", medicine_categories)
	#print("Illnesses: ", illnesses)
