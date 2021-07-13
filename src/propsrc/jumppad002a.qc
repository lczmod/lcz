$modelname			"props_lcz_v1\jumppad002a.mdl"
$body				main								"jumppad002a.smd"
$surfaceprop		metal
$cdmaterials		"models\props_lcz_v1"
$staticprop

$collisionmodel			"jumppad002a_cm"
{
	$concave
	$maxconvexpieces	64
	$mass				100
}

$sequence			idle								"jumppad002a.smd"