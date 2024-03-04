a = 0.707 + 1i*0.707;
b = -0.707 + 1i*0.707;

c = a * conj(b);

estPhaseShift = angle(c);
estPhaseShiftDeg = rad2deg(estPhaseShift);