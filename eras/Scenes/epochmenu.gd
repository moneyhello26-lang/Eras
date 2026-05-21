extends CanvasLayer

# ──────────────────────────────────────────────
#  МЕНЮ ВЫБОРА ЭПОХИ — EpochMenu.gd
#  Повесь на CanvasLayer (это и будет сцена меню)
# ──────────────────────────────────────────────

# Список эпох: название => путь к сцене
const EPOCHS: Array[Dictionary] = [
	{"name": "Доисторическая эра",  "scene": "res://Scenes/prehistoric_era.tscn"},
	{"name": "Древний Рим",          "scene": "res://scenes/ancient_world.tscn"},
	{"name": "Средневековье",        "scene": "res://scenes/middle_ages.tscn"},
	{"name": "Индустриальная эпоха", "scene": "res://scenes/early_modern_period.tscn"},
	{"name": "Далёкое будущее",      "scene": "res://scenes/late_modern_period.tscn"},
]

@onready var buttons_container: VBoxContainer = $Panel/VBoxContainer
@onready var close_btn: Button               = $Panel/CloseButton


func _ready() -> void:
	var screen := get_viewport().get_visible_rect().size
	var panel_size := Vector2(500, 420)
	$Panel.size = panel_size
	$Panel.position = (screen - panel_size) / 2

	$Panel/VBoxContainer.add_theme_constant_override("separation", 10)
	$Panel/VBoxContainer.set_anchors_preset(Control.PRESET_FULL_RECT)
	$Panel/VBoxContainer.offset_top = 10
	$Panel/VBoxContainer.offset_left = 20
	$Panel/VBoxContainer.offset_right = -20
	$Panel/VBoxContainer.offset_bottom = -60

	$Panel/CloseButton.size = Vector2(160, 40)
	$Panel/CloseButton.position = Vector2((panel_size.x - 160) / 2, panel_size.y - 55)

	for epoch in EPOCHS:
		var btn := Button.new()
		btn.text = epoch["name"]
		btn.custom_minimum_size = Vector2(400, 55)
		btn.add_theme_font_size_override("font_size", 20)
		var scene_path: String = epoch["scene"]
		btn.pressed.connect(func(): _travel_to(scene_path))
		$Panel/VBoxContainer.add_child(btn)

	$Panel/CloseButton.pressed.connect(_close_menu)


func _travel_to(scene_path: String) -> void:
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file(scene_path)
	queue_free()


func _close_menu() -> void:
	get_tree().paused = false
	queue_free()


# Закрыть по Escape
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_close_menu()
