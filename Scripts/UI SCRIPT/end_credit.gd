extends Control

@onready var credits_container = $CreditsContainer
@onready var dialogue_label = $DialogueLabel
@onready var fade_rect = $FadeReact

var credits_speed = 40.0
var phase = 0

func _ready():
	fade_rect.modulate.a = 1.0
	dialogue_label.text = ""
	credits_container.visible = false
	await fade_in()
	await outro_dialogue()
	credits_container.visible = true
	phase = 1

func _process(delta):
	if phase == 1:
		credits_container.position.y -= credits_speed * delta

func fade_in():
	while fade_rect.modulate.a > 0.0:
		fade_rect.modulate.a -= 0.02
		await get_tree().process_frame

func outro_dialogue():
	dialogue_label.text = "Scientist A: Wala na. Nadugmok na gyud."
	await wait(1)
	dialogue_label.text = "Scientist B: Sayanga... Pwede pa to ma-repair?"
	await wait(1)
	dialogue_label.text = "Scientist A: Dili na. Klaro kaayo sa data..."
	await wait(1)
	dialogue_label.text = "Scientist A: Not even once did it try to survive."
	await wait(1)
	dialogue_label.text = "Scientist B: Defective. Scrap the project. Humanity is safe."
	await wait(1)
	dialogue_label.text = ""

func wait(t):
	await get_tree().create_timer(t).timeout
