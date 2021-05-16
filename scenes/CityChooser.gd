extends PopupPanel


onready var city_list = $MarginContainer/VBoxContainer/CityList

signal go_to_city(city_name)

var cities = ["Seattle", "Portland", "San Diego", "Los Angeles", "San Francisco"]
var current_city = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_city_list():
	city_list.clear()
	var index = 0
	for city in cities:
		var city_title
		if index == current_city:
			city_title = "-> " + city
		else:
			city_title = city
		city_list.add_item(city_title)
		index += 1


func _on_SelectCityButton_pressed():
	if city_list.is_anything_selected():
		var city_name = city_list.get_item_text(city_list.get_selected_items()[0])
		self.hide()
		emit_signal("go_to_city", city_name)


func _on_CloseCityChooserButton_pressed():
	pass # Replace with function body.