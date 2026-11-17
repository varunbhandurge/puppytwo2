extends Node

## Master Automated Headless QA Test Runner for Two Puppies: The Great Adventure

const TestCharacterMovementScript = preload("res://tests/test_character_movement.gd")
const TestSplitScreenScript = preload("res://tests/test_split_screen.gd")
const TestPuzzlesScript = preload("res://tests/test_puzzles.gd")
const TestBossScript = preload("res://tests/test_boss.gd")
const TestSaveSystemScript = preload("res://tests/test_save_system.gd")
const TestChapter1BackyardScript = preload("res://tests/test_chapter_1_backyard.gd")
const TestFullCampaignScript = preload("res://tests/test_full_campaign.gd")
const TestNarrativeAudioScript = preload("res://tests/test_narrative_audio.gd")
const TestVisualOptimizationScript = preload("res://tests/test_visual_optimization.gd")
const TestFullGameQACertificationScript = preload("res://tests/test_full_game_qa_certification.gd")
const TestPCReleasePackagingScript = preload("res://tests/test_pc_release_packaging.gd")
const TestOnlineCoopScript = preload("res://tests/test_online_coop.gd")

func _ready() -> void:
	print("\n" + "=".repeat(75))
	print("   TWO PUPPIES: THE GREAT ADVENTURE — AUTOMATED QA TEST RUNNER")
	print("=".repeat(75) + "\n")
	
	var all_suites: Array[Dictionary] = []
	all_suites.append(TestCharacterMovementScript.run_all_tests())
	all_suites.append(TestSplitScreenScript.run_all_tests())
	all_suites.append(TestPuzzlesScript.run_all_tests())
	all_suites.append(TestBossScript.run_all_tests())
	all_suites.append(TestSaveSystemScript.run_all_tests())
	all_suites.append(TestChapter1BackyardScript.run_all_tests())
	all_suites.append(TestFullCampaignScript.run_all_tests())
	all_suites.append(TestNarrativeAudioScript.run_all_tests())
	all_suites.append(TestVisualOptimizationScript.run_all_tests())
	all_suites.append(TestFullGameQACertificationScript.run_all_tests())
	all_suites.append(TestPCReleasePackagingScript.run_all_tests())
	all_suites.append(TestOnlineCoopScript.run_all_tests())
	
	var total_passed: int = 0
	var total_failed: int = 0
	
	for suite in all_suites:
		print(">>> SUITE: %s" % suite["suite_name"])
		for t in suite["tests"]:
			var status = "[ PASS ]" if t["passed"] else "[ FAIL ]"
			print("  %s %-12s : %-42s (%s)" % [status, t["id"], t["name"], t["message"]])
			if t["passed"]:
				total_passed += 1
			else:
				total_failed += 1
		print("-".repeat(75))
	
	print("\n" + "=".repeat(75))
	print("QA TEST EXECUTION SUMMARY:")
	print("  TOTAL TESTS EXECUTED : %d" % (total_passed + total_failed))
	print("  PASSED               : %d" % total_passed)
	print("  FAILED               : %d" % total_failed)
	print("=".repeat(75) + "\n")
	
	if total_failed == 0:
		print(">>> ALL QA TESTS PASSED SUCCESSFULLY! FULL 8-CHAPTER CAMPAIGN VALIDATED. <<<\n")
		get_tree().quit(0)
	else:
		printerr(">>> QA TEST FAILURES DETECTED! <<<\n")
		get_tree().quit(1)
