% db2contrast.m

function contrast = db2contrast(db)
    contrast = 10.^(db./20);
end
