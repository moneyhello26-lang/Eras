extends Node2D

@onready var generator_1: Node2D = $Generator_tscn
@onready var generator_2: Node2D = $Generator_tscn2

# Переменная для подсчета сломанных генераторов
var deactivated_generators_count: int = 0
# Сколько нужно сломать для победы (в нашем случае оба)
const TARGET_COUNT: int = 2

func _ready() -> void:
	# Проверяем, что генераторы на месте, и подписываемся на их сигналы
	if generator_1:
		generator_1.activated.connect(_on_generator_activated)
	if generator_2:
		generator_2.activated.connect(_on_generator_activated)

func _on_generator_activated() -> void:
	deactivated_generators_count += 1
	print("Генераторов отключено: ", deactivated_generators_count, "/", TARGET_COUNT)
	
	# Если оба генератора отключены — завершаем уровень
	if deactivated_generators_count >= TARGET_COUNT:
		finish_level()

func finish_level() -> void:
	print("Все генераторы уничтожены! Силовое поле Жанны пало.")
	
	# Делаем небольшую паузу в 1.5 секунды, чтобы игрок успел увидеть взрыв последнего генератора
	await get_tree().create_timer(1.5).timeout
	
	# Меняем сцену на кат-сцену с твистом или экран завершения уровня
	# Замените путь на ваш актуальный файл сцены
	get_tree().change_scene_to_file("res://scenes/joan_twist_cutscene.tscn")
