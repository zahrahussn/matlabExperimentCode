% this function mimics Matlab rng function in octave 

function rng(seed)
  
switch(seed)
  case "shuffle"
    rand ("state",time());
    
  otherwise
    error("(rng) This function is not implemented for this seed input");
end