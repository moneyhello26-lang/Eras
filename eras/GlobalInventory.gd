extends Node

# Список ID улик, которые игрок РЕАЛЬНО нашел на уровне
var collected_evidence: Array[String] = []

# Очистка инвентаря (вызывать при перезапуске игры или уровня)
func reset_inventory() -> void:
	collected_evidence.clear()

# Добавить улику в карман
func add_evidence(evidence_id: String) -> void:
	if not collected_evidence.has(evidence_id):
		collected_evidence.append(evidence_id)
		print("В КПК добавлена улика: ", evidence_id)
