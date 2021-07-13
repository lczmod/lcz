// Created by Crowbar 0.29.0.0

$ModelName "player/custom_player/lcz_v1/plr_godmode_ct.mdl"

$BodyGroup "studio"
{
	studio "plr_godmode_ct_reference.smd"
}


$SurfaceProp "flesh"

$Contents "solid"

$EyePosition 0 0 73

$MaxEyeDeflection 90

$CDMaterials "models/props_lcz_v1/"

$Attachment "lcz_v1_weapon_bone" "ValveBiped.weapon_bone" 0 0 0 rotate 0 0 0
$Attachment "weapon_hand_L" "weapon_hand_L" 0 0 0 rotate 0 0 0
$Attachment "weapon_hand_R" "weapon_hand_R" 0 0 0 rotate 0 0 0
$Attachment "primary" "primary_jiggle_jnt" 0 0 0 rotate 0 0 0
$Attachment "pistol" "leg_upper_R" 3.8 -4.5 2.6 rotate 8 1 -10
$Attachment "knife" "leg_upper_L" 6.4 -2.1 5.5 rotate 0 150 86
$Attachment "eholster" "leg_upper_L" 0 0 5 rotate 0 0 90
$Attachment "grenade0" "spine_0" 1.3 -3 -9 rotate 90 0 0
$Attachment "grenade1" "spine_0" 1.3 -0.7 -9.9 rotate 90 0 0
$Attachment "grenade2" "spine_0" 1.3 2.1 -9.8 rotate 90 0 0
$Attachment "grenade3" "spine_0" 1.3 5.2 -9 rotate 90 0 0
$Attachment "grenade4" "spine_0" 1.3 6.9 -6.4 rotate 90 0 0
$Attachment "defusekit" "spine_0" -1.6 -6 0 rotate 0 87 95
$Attachment "c4" "spine_3" -1 -7.5 0.1 rotate -3 4 90
$Attachment "facemask" "head_0" 2.8 5.5 0.3 rotate 0 75 90
$Attachment "clip_limit" "head_0" 7 6 0 rotate 0 0 0
$Attachment "primary_smg" "primary_smg_jiggle_jnt" 0 0 0 rotate 0 0 0

$CBox 0 0 0 0 0 0

$BBox -13 -13 0 13 13 72

// $HBoxSet "cstrike"
// $HBox 1 "head_0" -0.2 0.9 0 3.6 0.1 0 0 0 0
// $HBox 1 "neck_0" -0.3 -1.3 -2.1 4.2 3.5 2.1 0 -2.1 0
// $HBox 2 "neck_0" -1.3 0.9 0 1.4 1.3 0 0 0 0
// $HBox 3 "pelvis" -2.7 1.1 -3.2 -2.7 1.1 3.2 0 0 0
// $HBox 3 "spine_0" 1.4 0.8 3.1 1.4 0.8 -3.1 0 0 0
// $HBox 2 "spine_1" 3.8 0.8 -2.4 3.8 0.4 2.4 0 0 0
// $HBox 2 "spine_2" 4.8 0.15 -4.1 4.8 0.15 4.1 0 0 0
// $HBox 2 "spine_3" 2.5 -0.6 -6 2.5 -0.6 6 0 0 0
// $HBox 6 "leg_upper_L" 1.3 0 0 16.5 0 0 0 0 0
// $HBox 7 "leg_upper_R" 1.3 0 0 16.5 0 0.7 0 0 0
// $HBox 6 "leg_lower_L" 0.1 0 0.2 17 -0.4 0.7 0 0 0
// $HBox 7 "leg_lower_R" 0.1 0 0.2 17 -0.4 0.7 0 0 0
// $HBox 6 "ankle_L" -2.5 -3.8 -2.8 10.4 -0.2 2 0 24.1 0
// $HBox 7 "ankle_R" -10.4 0.3 -2 2.6 4 2.8 0 24.5 0
// $HBox 4 "hand_L" -2 -2 -2 4.6 2 2 0 13.2 0
// $HBox 5 "hand_R" -5 -2 -2 2 2 2 180 194.600006 0
// $HBox 4 "arm_upper_L" 0 0 0 11.2 0 0 0 0 0
// $HBox 4 "arm_lower_L" 0 0 0 10 0 0 0 0 0
// $HBox 5 "arm_upper_R" 0 0 0 11.2 0 0 0 0 0
// $HBox 5 "arm_lower_R" 0 0 0 10 0 0 0 0 0
// $SkipBoneInBBox

$BoneMerge "pelvis"
$BoneMerge "spine_0"
$BoneMerge "spine_1"
$BoneMerge "spine_2"
$BoneMerge "spine_3"
$BoneMerge "neck_0"
$BoneMerge "head_0"
$BoneMerge "clavicle_L"
$BoneMerge "arm_upper_L"
$BoneMerge "arm_lower_L"
$BoneMerge "hand_L"
$BoneMerge "finger_middle_meta_L"
$BoneMerge "finger_middle_0_L"
$BoneMerge "finger_middle_1_L"
$BoneMerge "finger_middle_2_L"
$BoneMerge "finger_pinky_meta_L"
$BoneMerge "finger_pinky_0_L"
$BoneMerge "finger_pinky_1_L"
$BoneMerge "finger_pinky_2_L"
$BoneMerge "finger_index_meta_L"
$BoneMerge "finger_index_0_L"
$BoneMerge "finger_index_1_L"
$BoneMerge "finger_index_2_L"
$BoneMerge "finger_thumb_0_L"
$BoneMerge "finger_thumb_1_L"
$BoneMerge "finger_thumb_2_L"
$BoneMerge "finger_ring_meta_L"
$BoneMerge "finger_ring_0_L"
$BoneMerge "finger_ring_1_L"
$BoneMerge "finger_ring_2_L"
$BoneMerge "weapon_hand_L"
$BoneMerge "arm_lower_L_TWIST"
$BoneMerge "arm_lower_L_TWIST1"
$BoneMerge "arm_upper_L_TWIST"
$BoneMerge "arm_upper_L_TWIST1"
$BoneMerge "clavicle_R"
$BoneMerge "arm_upper_R"
$BoneMerge "arm_lower_R"
$BoneMerge "hand_R"
$BoneMerge "finger_middle_meta_R"
$BoneMerge "finger_middle_0_R"
$BoneMerge "finger_middle_1_R"
$BoneMerge "finger_middle_2_R"
$BoneMerge "finger_pinky_meta_R"
$BoneMerge "finger_pinky_0_R"
$BoneMerge "finger_pinky_1_R"
$BoneMerge "finger_pinky_2_R"
$BoneMerge "finger_index_meta_R"
$BoneMerge "finger_index_0_R"
$BoneMerge "finger_index_1_R"
$BoneMerge "finger_index_2_R"
$BoneMerge "finger_thumb_0_R"
$BoneMerge "finger_thumb_1_R"
$BoneMerge "finger_thumb_2_R"
$BoneMerge "finger_ring_meta_R"
$BoneMerge "finger_ring_0_R"
$BoneMerge "finger_ring_1_R"
$BoneMerge "finger_ring_2_R"
$BoneMerge "weapon_hand_R"
$BoneMerge "arm_lower_R_TWIST"
$BoneMerge "arm_lower_R_TWIST1"
$BoneMerge "arm_upper_R_TWIST"
$BoneMerge "arm_upper_R_TWIST1"
$BoneMerge "leg_upper_L"
$BoneMerge "leg_lower_L"
$BoneMerge "ankle_L"
$BoneMerge "ball_L"
$BoneMerge "leg_upper_L_TWIST"
$BoneMerge "leg_upper_L_TWIST1"
$BoneMerge "leg_upper_R"
$BoneMerge "leg_lower_R"
$BoneMerge "ankle_R"
$BoneMerge "ball_R"
$BoneMerge "leg_upper_R_TWIST"
$BoneMerge "leg_upper_R_TWIST1"
$BoneMerge "lh_ik_driver"
$BoneMerge "lean_root"
$BoneMerge "lfoot_lock"
$BoneMerge "rfoot_lock"

$JiggleBone "primary_jiggle_jnt"
{
	is_flexible
	{
		length 50
		tip_mass 0
		pitch_stiffness 100
		pitch_damping 15
		yaw_stiffness 700
		yaw_damping 15
		allow_length_flex
		along_stiffness 100
		along_damping 0
		angle_constraint 45.000002
	}
}
$JiggleBone "primary_smg_jiggle_jnt"
{
	is_flexible
	{
		length 50
		tip_mass 0
		pitch_stiffness 100
		pitch_damping 15
		yaw_stiffness 700
		yaw_damping 15
		allow_length_flex
		along_stiffness 100
		along_damping 0
		angle_constraint 45.000002
	}
}

$Sequence "default" {
	"plr_godmode_ct_anims\default.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$Sequence "ragdoll" {
	"plr_godmode_ct_anims\ragdoll.smd"
	activity "ACT_DIERAGDOLL" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$IncludeModel "player/custom_player/animset_ct.mdl"

$IKChain "rhand" "hand_R" knee 0 0 0
$IKChain "lhand" "hand_L" knee 0 0 0
$IKChain "rfoot" "ankle_R" knee 0 0 0
$IKChain "lfoot" "ankle_L" knee 0 0 0

$CollisionJoints "plr_godmode_ct_physics.smd"
{
	$mass 300
	$inertia 10
	$damping 0.4
	$rotdamping 20
	$rootbone "pelvis"

	$jointmassbias "pelvis" 2.6
	$jointdamping "pelvis" 1
	$jointrotdamping "pelvis" 12

	$jointmassbias "leg_upper_R" 3
	$jointrotdamping "leg_upper_R" 8
	$jointconstrain "leg_upper_R" x limit -15 15 0.4
	$jointconstrain "leg_upper_R" y limit -70 50 0.4
	$jointconstrain "leg_upper_R" z limit -15 15 0.4

	$jointmassbias "leg_lower_R" 3
	$jointrotdamping "leg_lower_R" 2
	$jointconstrain "leg_lower_R" x limit 0 0 0.4
	$jointconstrain "leg_lower_R" y limit 0 110 0.4
	$jointconstrain "leg_lower_R" z limit 0 0 0.4

	$jointmassbias "leg_upper_L" 3
	$jointrotdamping "leg_upper_L" 8
	$jointconstrain "leg_upper_L" x limit -15 15 0.4
	$jointconstrain "leg_upper_L" y limit -15 15 0.4
	$jointconstrain "leg_upper_L" z limit -70 50 0.4

	$jointmassbias "leg_lower_L" 3
	$jointrotdamping "leg_lower_L" 2
	$jointconstrain "leg_lower_L" x limit 0 0 0.4
	$jointconstrain "leg_lower_L" y limit 0 0 0.4
	$jointconstrain "leg_lower_L" z limit 0 110 0.4

	$jointconstrain "ankle_L" x limit -20 20 0.4
	$jointconstrain "ankle_L" y limit -40 40 0.4
	$jointconstrain "ankle_L" z limit -30 40 0.4

	$jointrotdamping "spine_0" 2
	$jointconstrain "spine_0" x limit -15 15 0.4
	$jointconstrain "spine_0" y limit -15 15 0.4
	$jointconstrain "spine_0" z limit -5 25 0.4

	$jointrotdamping "spine_2" 2
	$jointconstrain "spine_2" x limit -15 15 0.4
	$jointconstrain "spine_2" y limit -15 15 0.4
	$jointconstrain "spine_2" z limit -10 35 0.4

	$jointmassbias "arm_upper_R" 3
	$jointconstrain "arm_upper_R" x limit -45 45 0.4
	$jointconstrain "arm_upper_R" y limit -30 70 0.4
	$jointconstrain "arm_upper_R" z limit -70 45 0.4

	$jointmassbias "arm_lower_R" 3
	$jointconstrain "arm_lower_R" x limit -20 20 0.4
	$jointconstrain "arm_lower_R" y limit -10 90 0.4
	$jointconstrain "arm_lower_R" z limit -5 5 0.4

	$jointmassbias "arm_upper_L" 3
	$jointconstrain "arm_upper_L" x limit -45 45 0.4
	$jointconstrain "arm_upper_L" y limit -30 70 0.4
	$jointconstrain "arm_upper_L" z limit -70 45 0.4

	$jointmassbias "arm_lower_L" 3
	$jointconstrain "arm_lower_L" x limit -20 20 0.4
	$jointconstrain "arm_lower_L" y limit -5 5 0.4
	$jointconstrain "arm_lower_L" z limit -10 90 0.4

	$jointrotdamping "hand_L" 8
	$jointconstrain "hand_L" x limit -15 15 0.4
	$jointconstrain "hand_L" y limit -20 30 0.4
	$jointconstrain "hand_L" z limit -20 20 0.4

	$jointrotdamping "hand_R" 8
	$jointconstrain "hand_R" x limit -15 15 0.4
	$jointconstrain "hand_R" y limit -20 30 0.4
	$jointconstrain "hand_R" z limit -20 20 0.4

	$jointrotdamping "head_0" 2
	$jointconstrain "head_0" x limit -25 25 0.4
	$jointconstrain "head_0" y limit -20 20 0.4
	$jointconstrain "head_0" z limit -10 35 0.4

	$jointconstrain "ankle_R" x limit -20 20 0.4
	$jointconstrain "ankle_R" y limit -40 40 0.4
	$jointconstrain "ankle_R" z limit -30 40 0.4
	$jointcollide "head_0" "hand_L"
}

$KeyValues
{
	snapshot_weights_all 
	{
	}
	snapshot_weights_upperbody 
	{
		"leg_upper_L" "0.5"
		"leg_lower_L" "0"
		"ankle_L" "0"
		"ball_L" "0"
		"leg_upper_R" "0.5"
		"leg_lower_R" "0"
		"ankle_R" "0"
		"ball_R" "0"
		"leg_upper_L_TWIST" "0.5"
		"leg_upper_L_TWIST1" "0.2"
		"leg_upper_R_TWIST" "0.5"
		"leg_upper_R_TWIST1" "0.2"
	}
	qc_path 
	{
		"value" "models\player\custom_player\lcz_v1\qc\plr_godmode_ct.qc"
	}
}
