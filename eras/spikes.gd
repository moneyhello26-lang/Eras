extends Area2D

# Настройка урона в инспекторе. 
# Если хотите, чтобы шипы убивали мгновенно, можно поставить 999.
@export var damage: int = 1

func _ready() -> void:
	# Подключаем сигнал, который срабатывает, когда в шипы кто-то наступает
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Проверяем, что в шипы попал именно игрок
	if body.is_in_group("player") or body.is_in_group("Player"):
		print("Игрок наступил на шипы!")
		
		# Вариант А: Если у игрока есть функция получения урона (например, take_damage)
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
		# Вариант Б: Если функций урона еще нет, можно просто мгновенно убить/перезапустить уровень:
		else:
			_restart_level()

func _restart_level() -> void:
	# Перезапускает текущую сцену (middle_ages.tscn) сначала
	get_tree().reload_current_scene()
