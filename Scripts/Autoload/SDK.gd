extends Node

var web_sdk: IWebSDK

func _ready() -> void:
	#web_sdk = DummySDK.new()
	web_sdk = PlaygamaSDK.new()
	add_child(web_sdk)
	web_sdk.initialize_sdk()
