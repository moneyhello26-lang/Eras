extends Area2D

signal generator_destroyed

var is_broken = false

func _ready():
	# Подключаем сигнал игрока (например, если игрок нажал "E" рядом)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player") and not is_broken:
		destroy_generator()

func destroy_generator():
	is_broken = true
	$GPUParticles2D.emitting = false
	emit_signal("generator_destroyed")
	# Отключаем коллизию, чтобы больше не взаимодействовать
	monitoring = false
