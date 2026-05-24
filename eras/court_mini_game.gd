extends Control

@onready var dialogue_text: Label = $DialoguePanel/DialogueText
@onready var speaker_name: Label = $DialoguePanel/SpeakerName
@onready var evidence_list: ItemList = $EvidencePanel/EvidenceList
@onready var evidence_desc: Label = $EvidencePanel/EvidenceDescription

# Улики в вашем КПК (Факты, очищающие имя Жанны от технологий будущего)
var evidence_database = {
	"human_heart": {
		"name": "📊 Данные био-сканера",
		"desc": "Сканирование КПК доказало: под оплавленной броней бьется обычное человеческое сердце. Никаких микросхем или плазмы. Она смертна."
	},
	"faith_letter": {
		"name": "📜 Письмо из Домреми",
		"desc": "Свидетельства крестьян. Жанна покинула дом не из-за приказов из будущего, а потому что искренне верила, что слышит голоса святых."
	},
	"orlean_tactic": {
		"name": "🏹 Хроника Орлеана",
		"desc": "Записи штурма. Тактическая победа была достигнута благодаря внезапному удару в уязвимое место англичан, а не орбитальной бомбардировке."
	}
}

# Три этапа суда, где инквизиция приписывает Жанне технологии
var court_phases = [
	{
		"speaker": "Инквизитор Кошон",
		"text": "Эта девица — механический монстр, созданный в подземных лабораториях дьявола! Её неуязвимость — это колдовской металл, а не человеческая плоть!",
		"correct_evidence": "human_heart",
		"explanation": "Герой: Возражаю! Мой прибор зафиксировал повышенный пульс и страх. Она чувствует боль, её тело абсолютно человечно. В ней нет механизмов!",
		"hint": "Докажи, что под доспехами скрывается обычный живой человек."
	},
	{
		"speaker": "Судья Руана",
		"text": "Но как обычная крестьянка могла одолеть армию Англии под Орлеаном за 9 дней? Тут явно замешано лазерное оружие и чертежи будущего!",
		"correct_evidence": "orlean_tactic",
		"explanation": "Герой: Возражаю! Военные отчеты показывают, что англичане просто не ожидали дерзкой лобовой атаки. Это была чистая человеческая стратегия и храбрость!",
		"hint": "Вспомни, как именно был освобожден Орлеан в реальной истории."
	},
	{
		"speaker": "Инквизитор Кошон",
		"text": "Даже если её тело из плоти, её разум осквернен! Голоса в её голове — это радиопередачи шпионов из будущего, помыкающих Францией!",
		"correct_evidence": "faith_letter",
		"explanation": "Герой: Нет! Она вела людей за собой, потому что её вера была чиста. Жанна шла на смерть ради своей родины, ведомая своим сердцем, а не радиотехникой!",
		"hint": "Покажи документ, объясняющий истинные мотивы её похода."
	}
]

var current_phase: int = 0

func _ready() -> void:
	# Включаем автоматический перенос текста по словам
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Разрешаем тексту занимать всю доступную ширину родительской панели
	dialogue_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Остальная часть вашей функции _ready()...
	evidence_list.item_selected.connect(_on_evidence_selected)
	$EvidencePanel/PresentButton.pressed.connect(_on_present_pressed)
	_load_phase(0)
	_fill_evidence_ui()

func _load_phase(index: int) -> void:
	if index >= court_phases.size():
		_trigger_tragic_final()
		return
		
	current_phase = index
	speaker_name.text = court_phases[current_phase]["speaker"]
	dialogue_text.text = court_phases[current_phase]["text"]

func _fill_evidence_ui() -> void:
	evidence_list.clear()

	for id in GlobalInventory.collected_evidence:
		# Если ID из инвентаря существует в нашей базе данных суда, выводим его
		if evidence_database.has(id):
			var item_name = evidence_database[id]["name"]
			evidence_list.add_item(item_name)
			
			# Привязываем ID к элементу интерфейса
			var last_idx = evidence_list.get_item_count() - 1
			evidence_list.set_item_metadata(last_idx, id)
			
	# На случай, если хардкорный игрок пришел в суд вообще без улик:
	if evidence_list.get_item_count() == 0:
		evidence_desc.text = "⚠️ В КПК нет исторических данных. Вы не нашли ни одной улики на уровне! Опровергнуть ложь инквизитора будет невозможно..."

func _on_evidence_selected(index: int) -> void:
	var id = evidence_list.get_item_metadata(index)
	evidence_desc.text = evidence_database[id]["desc"]

func _on_present_pressed() -> void:
	var selected = evidence_list.get_selected_items()
	if selected.size() == 0: return
	
	var selected_id = evidence_list.get_item_metadata(selected[0])
	var active_phase = court_phases[current_phase]
	
	if selected_id == active_phase["correct_evidence"]:
		_success_objection(active_phase["explanation"])
	else:
		_fail_objection(active_phase["hint"])

func _success_objection(explanation: String) -> void:
	dialogue_text.text = "🔥 ВОЗРАЖАЮ! (OBJECTION!)\n\n" + explanation
	$DialoguePanel.modulate = Color.GREEN
	await get_tree().create_timer(4.5).timeout
	$DialoguePanel.modulate = Color.WHITE
	_load_phase(current_phase + 1)

func _fail_objection(hint: String) -> void:
	dialogue_text.text = "❌ Судья: Ваши слова не могут смыть с неё подозрения в использовании магии будущего!\n\n(Подсказка: " + hint + ")"
	$DialoguePanel.modulate = Color.RED
	await get_tree().create_timer(3.0).timeout
	$DialoguePanel.modulate = Color.WHITE
	_load_phase(current_phase)

# ФИНАЛ: Драматическая развязка
func _trigger_tragic_final() -> void:
	$EvidencePanel.hide() # Прячем интерфейс КПК
	$NavPanel.hide()
	
	speaker_name.text = "Инквизитор Кошон"
	dialogue_text.text = "Обвинитель: ...Вы правы. В этой девушке нет механизмов будущего или запретных машин. Она — лишь человек. Но закон церкви непреклонен. За ересь и ношение мужской одежды суд приговаривает Жанну к сожжению на костре."
	
	await get_tree().create_timer(6.0).timeout
	
	speaker_name.text = "Жанна д’Арк"
	dialogue_text.text = "Жанна (смотрит на вас сквозь решетку): Спасибо тебе, путешественник... Ты не спас мою жизнь, но ты спас нечто большее — мою душу и мою правду. Теперь история запомнит меня как защитницу Франции, а не чудовище. Я готова встретить огонь."
	
	await get_tree().create_timer(7.0).timeout
	
	speaker_name.text = "КПК Системы"
	dialogue_text.text = "🚨 Внимание: Временная линия восстановлена на 100%. Жанна д’Арк вошла в историю как великая мученица. Парадокс ликвидирован. Возвращение в хаб..."
	
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")
