$modelname			"props_lcz_v1\jumppad001a.mdl"
$body				main								"jumppad001a.smd"
$surfaceprop		metal
$cdmaterials		"models\props_lcz_v1"
$staticprop

$collisionmodel			"jumppad001a_cm"
{
	$concave
	$maxconvexpieces	64
	$mass				100
}

$sequence			idle								"jumppad001a.smd"