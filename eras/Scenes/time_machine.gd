extends Area2D

# ──────────────────────────────────────────────
#  МАШИНА ВРЕМЕНИ — TimeMachine.gd
#  Повесь на Area2D с CollisionShape2D
# ──────────────────────────────────────────────

# Сцена меню выбора эпохи
@export var epoch_menu_scene: PackedScene

# Подсказка (Label или любой Control над машиной)
@onready var hint_label: Label = $HintLabel

var player_nearby: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	hint_label.visible = false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and player_nearby:
			_open_menu()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		hint_label.visible = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		hint_label.visible = false


func _open_menu() -> void:
	if epoch_menu_scene == null:
		push_error("TimeMachine: epoch_menu_scene не назначена!")
		return
	# Пауза игры
	get_tree().paused = true
	var menu = epoch_menu_scene.instantiate()
	get_tree().root.add_child(menu)
