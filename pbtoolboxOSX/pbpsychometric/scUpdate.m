function sc=scUpdate(sc,correct)%%   9-Dec-2006  PJB     :   modified so that out-of-range values are converted to closest possible matches%sc.trialcount=sc.trialcount+1;sc.trialdata(sc.trialcount,:)=[sc.curvalue,correct];if (correct==1)	sc.correct=sc.correct+1;	sc.incorrect=0;else	sc.correct=0;	sc.incorrect=sc.incorrect+1;end;[minIndex,maxIndex]=size(sc.values);goingdown=-1;goingup=1;neutral=0;switch sc.curdirectioncase neutral	if (sc.correct>=sc.down)		sc.curdirection=goingdown;		tmp=sc.curindex-sc.curstepsize;		if (tmp<minIndex)			tmp=minIndex;		end;		if (tmp>maxIndex)			tmp=maxIndex;		end;        sc.curindex=tmp;        sc.curvalue=sc.values(tmp);		sc.correct=0;		sc.incorrect=0;	elseif (sc.incorrect>=sc.up)		sc.curdirection=goingup;		tmp=sc.curindex+sc.curstepsize;        if (tmp<minIndex)			tmp=minIndex;		end;		if (tmp>maxIndex)			tmp=maxIndex;		end;        sc.curindex=tmp;        sc.curvalue=sc.values(tmp);		sc.correct=0;		sc.incorrect=0;	end;		case goingup	if (sc.correct>=sc.down)		sc.curdirection=goingdown;		sc.reversalcount=sc.reversalcount+1; % we have a reversal!		sc.revpoints(sc.reversalcount)=sc.curvalue; % store the reversal point		sc=scCalcStepSize(sc);	% see if the stepsize is changed		tmp=sc.curindex-sc.curstepsize;		if (tmp<minIndex)			tmp=minIndex;		end;		if (tmp>maxIndex)			tmp=maxIndex;		end;        sc.curindex=tmp;        sc.curvalue=sc.values(tmp);		sc.correct=0;		sc.incorrect=0;	elseif (sc.incorrect>=sc.up)		tmp=sc.curindex+sc.curstepsize;		if (tmp<minIndex)			tmp=minIndex;		end;		if (tmp>maxIndex)			tmp=maxIndex;		end;        sc.curindex=tmp;        sc.curvalue=sc.values(tmp);	end;case goingdown	if (sc.correct>=sc.down)		tmp=sc.curindex-sc.curstepsize;		if (tmp<minIndex)			tmp=minIndex;		end;		if (tmp>maxIndex)			tmp=maxIndex;		end;        sc.curindex=tmp;        sc.curvalue=sc.values(tmp);		sc.correct=0;		sc.incorrect=0;	elseif (sc.incorrect>=sc.up)		sc.curdirection=goingup;		sc.reversalcount=sc.reversalcount+1; % we have a reversal!		sc.revpoints(sc.reversalcount)=sc.curvalue; % store the reversal point		sc=scCalcStepSize(sc);	% see if the stepsize is changed		tmp=sc.curindex+sc.curstepsize;		if (tmp<minIndex)			tmp=minIndex;		end;		if (tmp>maxIndex)			tmp=maxIndex;		end;        sc.curindex=tmp;        sc.curvalue=sc.values(tmp);	end;end;return;	