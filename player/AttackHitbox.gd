extends Area2D

export var damage = 1

func _on_AttackHitbox_area_entered(area):
	area.ouch(damage)
