extends Node2D

signal activated

@onready var area_2d: Area2D = $Area2D
# Используем safe-накатывание (get_node_or_null), чтобы игра не вылетала, 
# если узлы эффектов называются чуть иначе
@onready var cpu_particles_2d = get_node_or_null("CPUParticles2D")
@onready var animated_sprite_2d = get_node_or_null("AnimatedSprite2D")

var is_active: bool = true

func _ready() -> void:
	# Безопасное подключение сигнала
	if area_2d:
		area_2d.body_entered.connect(_on_body_entered)
	else:
		push_error("Внимание: На сцене генератора не найден узел Area2D!")
		
	if animated_sprite_2d and animated_sprite_2d.has_method("play"):
		animated_sprite_2d.play("default")

func _on_body_entered(body: Node2D) -> void:
	# Проверяем группу "Player" или "player" (с маленькой буквы)
	if is_active and (body.is_in_group("Player") or body.is_in_group("player")):
		deactivate_generator()

func deactivate_generator() -> void:
	is_active = false
	print("Сигнал пошел: Генератор деактивирован!")
	
	# Выключаем эффекты, если они существуют
	if cpu_particles_2d:
		cpu_particles_2d.emitting = false
	if animated_sprite_2d:
		if animated_sprite_2d.has_method("stop"):
			animated_sprite_2d.stop()
		animated_sprite_2d.hide()
		
	# Отключаем мониторинг, чтобы событие не срабатывало дважды
	if area_2d:
		area_2d.set_deferred("monitoring", false)
	
	# Отправляем сигнал наверх (в сцену middle_ages)
	activated.emit()
