extends Node

var web_sdk: IWebSDK


func _ready() -> void:
	web_sdk = PlaygamaSDK.new()
	web_sdk.initialize_sdk()
