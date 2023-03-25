extends HFlowContainer

@onready var AttachedPartList = $AttachedPartList
@onready var PlaceablePartsList = $PlaceablePartsList
@export var active_part_list : CustomDatatypes.PartLists

signal placeable_part_selected(part_name)
signal placeable_part_cleared()

# Called when the node enters the scene tree for the first time.
func _ready():
	print(CustomDatatypes.PartLists)
	active_part_list = CustomDatatypes.PartLists.ATTACHED_PARTS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_part_list_mode_cycle_parts_list():
	if active_part_list == CustomDatatypes.PartLists.ATTACHED_PARTS:
		active_part_list = CustomDatatypes.PartLists.PLACEABLE_PARTS
		AttachedPartList.hide()
		AttachedPartList.deselect_all()
		PlaceablePartsList.show()
	elif active_part_list == CustomDatatypes.PartLists.PLACEABLE_PARTS:
		emit_signal("placeable_part_cleared")
		active_part_list = CustomDatatypes.PartLists.ATTACHED_PARTS
		AttachedPartList.show()
		PlaceablePartsList.hide()
		PlaceablePartsList.deselect_all()


func _on_placeable_parts_list_item_selected(index):
	emit_signal("placeable_part_selected", PlaceablePartsList.get_item_text(index))
