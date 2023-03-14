set seed=ELDENRING
set dsluserfolder=C:\Users\diono\AppData\Roaming\Godot\app_userdata\Diablo Style Loot for Elden Ring
set ergamepath=F:\SteamLibrary\steamapps\common\ELDEN RING\Game
set dslme2folder=F:\SteamLibrary\steamapps\common\ELDEN RING\Game\ModEngine2\mod

DSMSPortable "%dslme2folder%\regulation.bin" -G ER -P "%ergamepath%" -C "%dsluserfolder%\output\%seed%\SpEffectParam.csv" "%dsluserfolder%\output\%seed%\ReinforceParamWeapon.csv" "%dsluserfolder%\output\%seed%\ItemLotParam_map.csv" "%dsluserfolder%\output\%seed%\ItemLotParam_enemy.csv" "%dsluserfolder%\output\%seed%\EquipParamWeapon.csv" "%dsluserfolder%\output\%seed%\EquipParamProtector.csv" "%dsluserfolder%\output\%seed%\EquipParamAccessory.csv"

DSMSPortable --fmgmerge "%dslme2folder%\msg\engus\item.msgbnd.dcx" "%dsluserfolder%\output\%seed%\SummaryRings.fmg.json" "%dsluserfolder%\output\%seed%\DescriptionArmor.fmg.json" "%dsluserfolder%\output\%seed%\DescriptionRings.fmg.json" "%dsluserfolder%\output\%seed%\DescriptionWeapons.fmg.json" "%dsluserfolder%\output\%seed%\TitleArmor.fmg.json" "%dsluserfolder%\output\%seed%\TitleRings.fmg.json" "%dsluserfolder%\output\%seed%\TitleWeapons.fmg.json" 

DSMSPortable "%dslme2folder%\regulation.bin" -G ER -P "%ergamepath%" -M "%dsluserfolder%\output\%seed%\DSL_MakeEffectsStack.massedit"

pause