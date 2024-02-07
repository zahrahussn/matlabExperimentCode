% Symmetrical female face (left face in Fig. 2b), using the harmonic amplitudes from Fig. 2a (Wilson & Wilkinson, 2002)
makeRadialStim([1 2 3 4 5 6 7],[7 20 5 1 0.4 0.5 0.3],[0 0 180 0 180 180 180]);

% Right assymetrical female face (right face in Fig. 2b)
phiRot = -18; % 3rd, 4th and 5th harmonics are shifted by 100%, 100% and -15% of phiRot, respectively
makeRadialStim([1 2 3 4 5 6 7],[7 20 5 1 0.4 0.5 0.3],[0 0 180+phiRot 0+phiRot 180-0.15*phiRot 180 180]);
