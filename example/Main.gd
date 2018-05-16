extends Control

# load the SIMPLE library
onready var ruby = preload("res://bin/ruby.gdns").new()

func _on_Button_pressed():
	var val = ruby.eval("123")
	$Label.text = "evaluated: " + str(val)
