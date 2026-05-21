extends Node2D

func _ready() -> void:
	# Пробегаемся по всем слоям параллакса внутри этой сцены
	for child in get_children():
		if child is Parallax2D:
			# Намертво обнуляем вертикальный масштаб прокрутки
			child.scroll_scale.y = 0.0
			
			# Сбрасываем вертикальное смещение, чтобы фон не улетал
			child.scroll_offset.y = 0.0

func _process(_delta: float) -> void:
	# Жесткая подстраховка: принудительно удерживаем Y глобальной позиции в нуле,
	# даже если родительский узел попытается куда-то сместиться.
	global_position.y = 0.0
