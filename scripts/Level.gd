extends Resource
class_name Level

enum FurnitureType {BED, TABLE, SIT, STORAGE, DESK, LIGHT, TV}
static var FurnitureTypeName = {
	FurnitureType.BED: "bed",
	FurnitureType.TABLE: "table",
	FurnitureType.SIT: "place to sit",
	FurnitureType.STORAGE: "storage",
	FurnitureType.DESK: "desk",
	FurnitureType.LIGHT: "light",
	FurnitureType.TV: "TV cabinet"
}

static var FurnitureTypeNamePlural = {
	FurnitureType.BED: "beds",
	FurnitureType.TABLE: "tables",
	FurnitureType.SIT: "places to sit",
	FurnitureType.STORAGE: "storages",
	FurnitureType.DESK: "desks",
	FurnitureType.LIGHT: "light",
	FurnitureType.TV: "TV cabinets"
}

@export var level_index = 0
@export var available_furnitures: Array[PackedScene]
@export var needed_furnitures: Array[FurnitureType]
@export_file var map
