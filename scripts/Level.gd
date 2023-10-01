extends Resource
class_name Level

enum FurnitureType {BED, TABLE, SIT, STORAGE}
static var FurnitureTypeName = {
	FurnitureType.BED: "bed",
	FurnitureType.TABLE: "table",
	FurnitureType.SIT: "place to sit",
	FurnitureType.STORAGE: "storage"
}

static var FurnitureTypeNamePlural = {
	FurnitureType.BED: "beds",
	FurnitureType.TABLE: "tables",
	FurnitureType.SIT: "places to sit",
	FurnitureType.STORAGE: "storages"
}

@export var available_furnitures: Array[PackedScene]
@export var needed_furnitures: Array[FurnitureType]
@export_file var map
