/*sampledrv.c -- sample a discrete random variableMATLAB usage:  mat = sampledrv( invcdf, dim )18/05/98 -- created (RFM)*/#include <stdlib.h>#include <math.h>#include "mex.h"#include "matdef.h"mxArray *sampledrv(const mxArray *pInvCDF,const mxArray *pDim);/* gateway function */void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {	plhs[0]=sampledrv(prhs[0],prhs[1]);	}/* main routine */mxArray *sampledrv(const mxArray *pInvCDF,const mxArray *pDim) {	int i,j,k,M,N;	double u,s;	Mat2D rInvCDF,rDim,rSample;	mxArray *pSample;	char szStr[81];	WRAP2D( rInvCDF, pInvCDF );	WRAP2D( rDim, pDim );	M=GET2D( rDim, 0, 0 );	N=GET2D( rDim, 0, 1 );	pSample=mxCreateDoubleMatrix(M,N,mxREAL);	WRAP2D( rSample, pSample );	for(i=0;i<M;i++)		for(j=0;j<N;j++) {			u=(double)rand()/(double)RAND_MAX;			for(k=0;k<rInvCDF.m;k++)				if(u<=GET2D(rInvCDF,k,0)) {					s=GET2D(rInvCDF,k,1);					break;				}			SET2D( rSample, i, j, s );		}	return( pSample );}