extends Button

@onready var selection_bar = $ColorRect_No # Récupère le trait sous le bouton

func _ready():
	selection_bar.visible = false  # Cache le trait au départ

func _on_focus_entered():
	selection_bar.visible = true  # Affiche le trait quand sélectionné

func _on_focus_exited():
	selection_bar.visible = false  # Cache le trait quand non sélectionné
