function openfiles(wildcard)defarg('wildcard','*');[files,folders] = selectmanyfiles(wildcard);for i = 1:length(files),	currfile = [folders{i},files{i}];	edit(currfile);endreturn