$modelname		"props_lcz_v1\flag_anchor.mdl"
$bodygroup		main
{
	studio		"flag_anchor.smd"
	blank
}
$surfaceprop	metal
$cdmaterials	"models\props_lcz_v1\"

$collisionmodel	"flag_anchor_cm.smd"
{
	$mass		34
	$drag		0
	$damping	1
	$rotdamping	10
}

$keyvalues
{
	prop_data
	{
		base	Metal.Medium
		health	0
	}
}

$sequence	idle	"flag_anchor.smd"