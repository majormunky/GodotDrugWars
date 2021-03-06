extends Panel

onready var inventory_list = $VBoxContainer/InventoryList
onready var money_label = $VBoxContainer/MoneyLabel
onready var current_city_title = $VBoxContainer/CurrentCityTitle
onready var city_drug_list = $VBoxContainer/CityDrugList
onready var message_box = $VBoxContainer/MessageBox
onready var day_label = $VBoxContainer/HBoxContainer4/DayLabel
onready var buy_button = $VBoxContainer/HBoxContainer3/BuyDrugDialogButton
onready var BuySellDialog = preload("res://scenes/BuySellDrugDialog.tscn")
onready var CityChooser = preload("res://scenes/CityChooser.tscn")

var player_money = 1500
var drugs = [
	{"name": "Marijuana", "min_price": 10, "max_price": 40},
	{"name": "Cocaine", "min_price": 350, "max_price": 1000},
	{"name": "Meth", "min_price": 10, "max_price": 45},
	{"name": "Heroin", "min_price": 50, "max_price": 100},
	{"name": "Speed", "min_price": 25, "max_price": 45},
	{"name": "Acid", "min_price": 40, "max_price": 250},
]

var current_day = 1
var max_days = 30
var player_drugs = []
var current_city_drugs = []
var drug_prices = {}
var selected_drug = null
var buy_sell_dialog = null
var city_chooser = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	buy_sell_dialog = BuySellDialog.instance()
	add_child(buy_sell_dialog)
	
	city_chooser = CityChooser.instance()
	add_child(city_chooser)
	
	city_chooser.update_city_list()
	current_city_title.text = "Current City: " + city_chooser.get_current_city_name()
	money_label.text = "Money: $" + str(player_money)
	inventory_list.clear()
	setup_drugs_for_city()
	
	city_chooser.connect("go_to_city", self, "_on_new_city_selected")
	buy_sell_dialog.connect("buy_drugs", self, "_on_BuySellDrugDialog_buy_drugs")
	city_drug_list.connect("item_selected", self, "_on_drug_item_selected")
	

func _on_drug_item_selected(_index):
	buy_button.disabled = false

func _on_new_city_selected(new_city):
	update_current_city_label(new_city)
	setup_drugs_for_city()
	current_day += 1
	update_day_label()
	city_chooser.hide()
 

func update_day_label():
	day_label.text = "Day: " + str(current_day)
	

func generate_random_drugs():
	var result = []
	for i in drugs:
		var drug_price = rand_range(i.min_price, i.max_price)
		result.append([i.name, drug_price])
	return result

func update_current_city_label(city_name):
	current_city_title.text = "Current City: " + city_name


func setup_drugs_for_city():
	current_city_drugs = generate_random_drugs()
	city_drug_list.clear()
	for drug in current_city_drugs:
		var drug_str = drug[0] + " - $" + str(int(drug[1]))
		city_drug_list.add_item(drug_str)
		drug_prices[drug[0]] = int(drug[1])


func get_price_for_drug(name):
	return drug_prices[name]
			

func update_player_money_label():
	money_label.text = "$" + str(player_money)


func draw_player_drugs():
	for drug in player_drugs:
		inventory_list.add_item(str(drug[1]) + ": " + drug[0])


func _on_ChangeCityButton_pressed():
	city_chooser.show()


func _on_BuyDrugDialogButton_pressed():
	if not city_drug_list.is_anything_selected():
		return
	
	var selected_drug_index = city_drug_list.get_selected_items()[0]
	var selected_drug_text = city_drug_list.get_item_text(selected_drug_index)
	var parts = selected_drug_text.split(" - $")
	
	selected_drug = parts[0]
	buy_sell_dialog.set_drug(parts[0], parts[1])
	buy_sell_dialog.set_mode("buy")
	buy_sell_dialog.set_drug_amount_slider_range(1, player_money / int(parts[1]))
	buy_sell_dialog.show()


func _on_BuyDrugButton_pressed():
	var amount = int(buy_sell_dialog.find_node("DrugAmountSlider").value)
	var total = int(buy_sell_dialog.find_node("CurrentDrugAmount").text.replace("$", ""))
	
	player_drugs.append([selected_drug, amount])
	player_money -= total
	update_player_money_label()
	draw_player_drugs()
	selected_drug = null
	buy_sell_dialog.hide()


func _on_SellDrugButton_pressed():
	if not inventory_list.is_anything_selected():
		return
	
	var selected_drug_index = inventory_list.get_selected_items()[0]
	var selected_drug_text = inventory_list.get_item_text(selected_drug_index)
	var parts = selected_drug_text.split(": ")
	
	var current_drug_price = get_price_for_drug(parts[1])
	var sell_amount = int(parts[0]) * current_drug_price
	
	inventory_list.remove_item(selected_drug_index)
	player_money += sell_amount
	update_player_money_label()
	message_box.clear()
	message_box.add_text("You sold " + parts[1] + " for " + String(sell_amount))
	buy_sell_dialog.find_node("DrugAmountSlider").set_value(1)
	yield(get_tree().create_timer(2.5), "timeout")
	message_box.clear()


func _on_CloseCityChooserButton_pressed():
	city_chooser.hide()


func _on_BuySellDrugDialog_buy_drugs(name, amount, drug_price):
	var total = drug_price * amount
	player_money -= total
	player_drugs.append([name, amount])
	draw_player_drugs()
	update_player_money_label()
	message_box.add_text("You bought " + str(amount) + " unit(s) of " + name + " for $" + str(total))
	yield(get_tree().create_timer(2.5), "timeout")
	message_box.clear()
