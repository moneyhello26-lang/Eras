extends Area2D

# Указываем ID улики прямо в инспекторе для каждого предмета на карте!
# Значения должны совпадать с ключами из базы данных суда: 
# "human_heart", "faith_letter", "orlean_tactic"
@export var evidence_id: String = "human_heart"

func _ready() -> void:
	# Подключаем сигнал касания
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Проверяем, что это игрок (у вас в группе "Player" или "player")
	if body.is_in_group("Player") or body.is_in_group("player"):
		# Кладим улику в глобальный инвентарь
		GlobalInventory.add_evidence(evidence_id)
		
		# Эффект подбора: здесь можно проиграть звук или показать всплывающий текст
		_show_pickup_effect()
		
		# Удаляем предмет с карты
		queue_free()

func _show_pickup_effect() -> void:
	print("Эффект подбора улики ", evidence_id)
	# Сюда можно добавить спавн красивых искр или надпись "УЛИКА НАЙДЕНА"
