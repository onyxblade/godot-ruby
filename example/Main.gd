extends Control

func _on_Button_pressed():
	var bunny = $Node.vector()
	#print(get_children())
	print(bunny.texture)
	add_child(bunny)
	#$Label.text = 'zcvzxv'
	#print($Node.is_class("Node"))
	#print(HTTPClient.new().is_class("Reference"))

