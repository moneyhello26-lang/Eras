extends CharacterBody2D

# ──────────────────────────────────────────────
#  НАСТРОЙКИ
# ──────────────────────────────────────────────

@export_group("Movement")
@export var move_speed: float = 200.0
@export var jump_force: float = 450.0
@export var gravity: float = 1200.0

@export_group("Double Jump")
@export var can_double_jump: bool = true

@export_group("Wall Slide")
@export var wall_slide_speed: float = 80.0
@export var wall_jump_force_x: float = 250.0

# ──────────────────────────────────────────────
#  УЗЕЛ
# ──────────────────────────────────────────────

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# ──────────────────────────────────────────────
#  ПЕРЕМЕННЫЕ
# ──────────────────────────────────────────────

var is_alive:       bool = true
var is_sitting:     bool = false
var has_double_jump:bool = false
var facing_right:   bool = true
var current_anim:   String = ""

# Флаги прыжка — вместо is_playing()
var jump_anim_active: bool = false   # обычный прыжок ещё "в подъёме"
var djump_anim_active: bool = false  # двойной прыжок ещё играет

# ──────────────────────────────────────────────
#  ГОТОВНОСТЬ
# ──────────────────────────────────────────────

func _ready() -> void:
	has_double_jump = can_double_jump
	sprite.animation_finished.connect(_on_animation_finished)


# ──────────────────────────────────────────────
#  ГЛАВНЫЙ ЦИКЛ
# ──────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if not is_alive:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_apply_gravity(delta)

	if is_sitting:
		_handle_sit_input()
		move_and_slide()
		return

	_handle_movement()
	_handle_jump()
	_handle_sit()
	_handle_wall_slide()

	move_and_slide()
	_update_animation()


# ──────────────────────────────────────────────
#  ГРАВИТАЦИЯ
# ──────────────────────────────────────────────

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Приземлились — сбрасываем флаги прыжка
		jump_anim_active  = false
		djump_anim_active = false


# ──────────────────────────────────────────────
#  ДВИЖЕНИЕ
# ──────────────────────────────────────────────

func _handle_movement() -> void:
	var direction := 0.0
	if Input.is_key_pressed(KEY_D):
		direction = 1.0
	elif Input.is_key_pressed(KEY_A):
		direction = -1.0
	
	if direction != 0:
		velocity.x = direction * move_speed
		_flip(direction > 0)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)


# ──────────────────────────────────────────────
#  ПРЫЖОК
# ──────────────────────────────────────────────

func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			_do_jump(false)
			has_double_jump = can_double_jump
		elif _is_wall_sliding():
			_do_wall_jump()
		elif has_double_jump:
			_do_jump(true)
			has_double_jump = false


func _do_jump(is_double: bool) -> void:
	velocity.y = -jump_force
	if is_double:
		djump_anim_active = true
		jump_anim_active  = false
		_force_anim("Double_Jump")
	else:
		jump_anim_active  = true
		djump_anim_active = false
		_force_anim("Jump")


func _do_wall_jump() -> void:
	velocity.y = -jump_force
	velocity.x = -sign(get_wall_normal().x) * wall_jump_force_x
	jump_anim_active  = true
	djump_anim_active = false
	_force_anim("Jump")


# ──────────────────────────────────────────────
#  СИДЕНИЕ
# ──────────────────────────────────────────────dd

func _input(event: InputEvent) -> void:
	if not is_alive:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SHIFT:
			if is_sitting:
				is_sitting = false
				_force_anim("Idle")
			elif is_on_floor():
				is_sitting = true
				velocity.x = 0
				_force_anim("Sit")
		
		if event.keycode == KEY_SPACE and not is_sitting:
			if is_on_floor():
				_do_jump(false)
				has_double_jump = can_double_jump
			elif _is_wall_sliding():
				_do_wall_jump()
			elif has_double_jump:
				_do_jump(true)
				has_double_jump = false
				
func _handle_sit() -> void:
	pass

func _handle_sit_input() -> void:
	pass


# ──────────────────────────────────────────────
#  СКОЛЬЖЕНИЕ ПО СТЕНЕ
# ──────────────────────────────────────────────

func _handle_wall_slide() -> void:
	if _is_wall_sliding():
		velocity.y = min(velocity.y, wall_slide_speed)


func _is_wall_sliding() -> bool:
	return is_on_wall() and not is_on_floor() and velocity.y > 0


# ──────────────────────────────────────────────
#  ОБНОВЛЕНИЕ АНИМАЦИИ
# ──────────────────────────────────────────────

func _update_animation() -> void:
	# Двойной прыжок — ждём окончания (сигнал animation_finished)
	if djump_anim_active:
		return

	# Обычный прыжок — показываем пока летим вверх
	if jump_anim_active:
		if velocity.y >= 0:
			# Начали падать — прыжок закончился
			jump_anim_active = false
		else:
			return  # ещё летим вверх, не трогаем

	# Wall Slide
	if _is_wall_sliding():
		_play_anim("Wall_Slide")
		return

	# В воздухе
	if not is_on_floor():
		_play_anim("Fall")
		return

	# На земле
	if abs(velocity.x) > 5:
		_play_anim("Run")
	else:
		_play_anim("Idle")


# ──────────────────────────────────────────────
#  ВСПОМОГАТЕЛЬНЫЕ
# ──────────────────────────────────────────────

# Плавная смена — только если анимация другая
func _play_anim(name: String) -> void:
	if current_anim == name:
		return
	current_anim = name
	sprite.play(name)

# Принудительная смена (для прыжков/смерти/удара)
func _force_anim(name: String) -> void:
	current_anim = name
	sprite.play(name)


func _flip(right: bool) -> void:
	if facing_right == right:
		return
	facing_right   = right
	sprite.flip_h  = not right


func _on_animation_finished() -> void:
	match current_anim:
		"Double_Jump":
			djump_anim_active = false
			# Сразу переключаемся на нужную анимацию
			_update_animation()
		"Hit":
			current_anim = ""
			_update_animation()
		"Death", "Death_in_Air":
			pass   # остаёмся в последнем кадре


# ──────────────────────────────────────────────
#  УРОН И СМЕРТЬ
# ──────────────────────────────────────────────

func take_hit() -> void:
	if not is_alive:
		return
	_force_anim("Hit")


func die() -> void:
	if not is_alive:
		return
	is_alive = false
	velocity  = Vector2.ZERO
	if is_on_floor():
		_force_anim("Death")
	else:
		_force_anim("Death_in_Air")
	await sprite.animation_finished
	$CollisionShape2D.set_deferred("disabled", true)
