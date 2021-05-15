extends PopupPanel

signal buy_drugs(name, amount, drug_price)

onready var drug_name_label = $VBoxContainer/DrugNameLabel
onready var drug_slider = $VBoxContainer/DrugAmountSlider
onready var current_amount = $VBoxContainer/CurrentDrugAmount
var price = 0
var mode = "buy"
var drug_name = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_drug(name, drug_price):
	self.set_drug_name(name)
	self.price = int(drug_price)

func set_drug_name(name):
	drug_name = name
	var name_str
	if mode == "buy":
		name_str = "Drug to Buy: " + name
	elif mode == "sell":
		name_str = "Drug to Sell: " + name
	drug_name_label.text = name_str

func set_drug_amount_slider_range(min_val, max_val):
	drug_slider.min_value = min_val
	drug_slider.max_value = max_val


func set_mode(mode_name):
	if mode_name == "buy":
		pass
	elif mode_name == "sell":
		pass

func _on_DrugAmountSlider_value_changed(value):
	var total = price * value
	current_amount.text = "$" + str(int(total))

func _on_CloseButton_pressed():
	self.hide()


func _on_BuyDrugButton_pressed():
	print(self.drug_name, self.drug_slider.value, self.price)
	emit_signal("buy_drugs", drug_name, drug_slider.value, self.price)


func _on_SellDrugButton_pressed():
	pass # Replace with function body.
