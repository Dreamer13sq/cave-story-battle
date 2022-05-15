/// @desc

DrawText(16, 20, location);
DrawText(16, 40, speedvec);
DrawText(16, 60, characterfolder.GetTRKName(trkindex));
DrawText(16, 80, "Anim: " + animkey);
DrawText(16, 100, "Action: " + actionkey);
DrawText(16, 120, "Frame: " + string(frame) + "/" + string(trkactive.framecount));
DrawText(16, 140, StringBinary(fighterstate, 8));
DrawText(16, 160, FighterFlagGet(FL_FFlag.inmotion));




