//
//      Name: handleExplosionObject
//      Desc: Explosion event handler for objects
//      Return: None
//

private ['_obj'];

_obj = _this select 0;

[_obj, "", 0.1, _obj, "G_40mm_HEDP"] spawn handleDamageObject;

