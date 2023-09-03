extends Control

@onready var chat_log = $CanvasLayer/VBoxContainer/RichTextLabel
@onready var input_field = get_node("CanvasLayer/VBoxContainer/HBoxContainer/LineEdit")
@onready var button = $CanvasLayer/VBoxContainer/HBoxContainer/Button

signal message_sent(message)

func _ready():
	input_field.text_submitted.connect(text_entered)
	button.connect("pressed", Callable(self, "button_pressed"))
	

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ENTER:
				#input_field.grab_focus()
				pass
			KEY_ESCAPE:
				#input_field.release_focus()
				pass
				
func add_message(username: String, text: String):
	
	if username != "Server":
		chat_log.text += username + ' says: "' + text + '"\n'
	else:
		# Server message
		chat_log.text += "[color=yellow]" + text + "[/color]\n" 
	
func text_entered(text: String):
	if len(text) > 0:
		input_field.text = ""
		
		emit_signal("message_sent", text)
		
func button_pressed():
	text_entered(input_field.text)
