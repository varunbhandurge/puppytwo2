class_name SplitScreenManager extends Control

## Manages Dual SubViewports, Camera Assignments, and Dynamic Orientation

@onready var split_container: BoxContainer = $SplitContainer
@onready var viewport_container_1: SubViewportContainer = $SplitContainer/ViewportContainer1
@onready var viewport_1: SubViewport = $SplitContainer/ViewportContainer1/SubViewport1
@onready var viewport_container_2: SubViewportContainer = $SplitContainer/ViewportContainer2
@onready var viewport_2: SubViewport = $SplitContainer/ViewportContainer2/SubViewport2
@onready var divider_bar: ColorRect = $DividerBar

var camera_1: PuppyCamera = null
var camera_2: PuppyCamera = null

func _ready() -> void:
	EventBus.split_orientation_toggled.connect(set_orientation)
	_setup_viewports()
	set_orientation(GameManager.split_is_vertical)

func _setup_viewports() -> void:
	# Crucial: SubViewport 2 shares the exact 3D world of SubViewport 1
	if viewport_1 and viewport_2:
		viewport_2.world_3d = viewport_1.world_3d

func assign_targets(target_p1: Node3D, target_p2: Node3D) -> void:
	if not camera_1:
		camera_1 = PuppyCamera.new()
		camera_1.name = "PuppyCamera1"
		if viewport_1:
			viewport_1.add_child(camera_1)
	camera_1.target = target_p1
	
	if not camera_2:
		camera_2 = PuppyCamera.new()
		camera_2.name = "PuppyCamera2"
		if viewport_2:
			viewport_2.add_child(camera_2)
	camera_2.target = target_p2

func set_orientation(is_vertical: bool) -> void:
	if not split_container:
		return
		
	split_container.vertical = not is_vertical
	
	# Update size flags
	viewport_container_1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	viewport_container_1.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_container_2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	viewport_container_2.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _process(_delta: float) -> void:
	_update_divider()

func _update_divider() -> void:
	if not divider_bar or not split_container:
		return
		
	if not split_container.vertical:
		# Vertical split (Side by Side)
		divider_bar.size = Vector2(4, size.y)
		divider_bar.position = Vector2(size.x * 0.5 - 2, 0)
	else:
		# Horizontal split (Top and Bottom)
		divider_bar.size = Vector2(size.x, 4)
		divider_bar.position = Vector2(0, size.y * 0.5 - 2)
