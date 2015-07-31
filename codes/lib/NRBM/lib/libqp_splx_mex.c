/* -----------------------------------------------------------------------
libqp_splx_mex.c: MEX-file interface for libqp_splx solver.
                                                                     
 Synopsis:                                                                     
  [x,QP,QD,exitflag,nIter] = libqp_splx_mex(H,f,b,I,S,x0,MaxIter,TolAbs,TolRel,QP_TH,verb)

 Compile:

  mex libqp_splx_mex.c libqp_splx.c

 Description:
   See "help libqp_splx".
                                                                    
 Copyright (C) 2006-2008 Vojtech Franc, xfrancv@cmp.felk.cvut.cz
 Center for Machine Perception, CTU FEL Prague

-------------------------------------------------------------------------*/

#include "mex.h"
#include "string.h"

#define LIBQP_MATLAB
#include "../lib/libqp.h"

/* -- Global variables --------------------------------------*/

double   *mat_H;     /* pointer to the Hessian matrix [n x n] */
uint32_t nVar;       /* number of ariables */


/* ------------------------------------------------------------
  Returns pointer at the i-th column of the Hessian matrix H.
------------------------------------------------------------ */
const double *get_col( uint32_t i )
{
  return( &mat_H[ nVar*i ] );
}

/* -------------------------------------------------------------
  MEX main function.
------------------------------------------------------------- */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  int verb;          
  uint32_t MaxIter;
  uint32_t *vec_I; 
  uint32_t nConstr; 
  uint8_t *vec_S;
  double *vec_x;         
  double TolRel;     
  double TolAbs;     
  double QP_TH;
  double *vec_x0;        
  double *vec_f;         
  double *vec_b;
  double *diag_H;    
  long i ;           
  libqp_state_T state;

  /*------------------------------------------------------------------- 
     Get input arguments
   ------------------------------------------------------------------- */
  if( nrhs != 11) mexErrMsgTxt("Incorrect number of input arguments.");

  mat_H = mxGetPr(prhs[0]);
  nVar = mxGetM(prhs[0]);

  vec_f = mxGetPr(prhs[1]);
  vec_b = (double*)mxGetPr(prhs[2]);
  vec_I = (uint32_t*)mxGetPr(prhs[3]);
  vec_S = (uint8_t*)mxGetPr(prhs[4]);

  nConstr = LIBQP_MAX(mxGetN(prhs[2]),mxGetM(prhs[2]));

  vec_x0 = mxGetPr(prhs[5]);
  MaxIter = mxIsInf( mxGetScalar(prhs[6])) ? 0xFFFFFFFF : (uint32_t)mxGetScalar(prhs[6]);
  TolAbs = mxGetScalar(prhs[7]);   
  TolRel = mxGetScalar(prhs[8]);   
  QP_TH = mxGetScalar(prhs[9]);   
  verb = (int)mxGetScalar(prhs[10]);  

  /* print input setting if required */  
  if( verb > 0 ) {
    mexPrintf("Settings of LIBQP_SSVM solver:\n");
    mexPrintf("MaxIter  : %u\n", MaxIter );
    mexPrintf("TolAbs   : %f\n", TolAbs );
    mexPrintf("TolRel   : %f\n", TolRel );
    mexPrintf("QP_TH    : %f\n", QP_TH );
    mexPrintf("nVar     : %u\n", nVar );
    mexPrintf("nConstr  : %u\n", nConstr );
  }     
  
  /*------------------------------------------------------------------- 
     Inicialization                                                     
   ------------------------------------------------------------------- */

  /* create solution vector x [nVar x 1] */
  plhs[0] = mxCreateDoubleMatrix(nVar,1,mxREAL);
  vec_x = mxGetPr(plhs[0]);
  memcpy( vec_x, vec_x0, sizeof(double)*nVar );

  /* make diagonal of the Hessian matrix */
  diag_H = mxCalloc(nVar, sizeof(double));
  if( diag_H == NULL ) mexErrMsgTxt("Not enough memory.");
  for(i = 0; i < nVar; i++ ) {
    diag_H[i] = mat_H[nVar*i+i];
  }
  
  /*------------------------------------------------------------------- 
   Call the QP solver.
   -------------------------------------------------------------------*/

  state = libqp_splx_solver(&get_col, diag_H, vec_f, vec_b, vec_I, vec_S, vec_x, nVar, 
                        MaxIter, TolAbs, TolRel, QP_TH, NULL);
  
  /*------------------------------------------------------------------- 
    Set output arguments                                                   
    [x,QP,QD,exitflag,nIter] = libqp_splx_mex(...)
  ------------------------------------------------------------------- */

  plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
  *(mxGetPr(plhs[1])) = (double)state.QP;

  plhs[2] = mxCreateDoubleMatrix(1,1,mxREAL);
  *(mxGetPr(plhs[2])) = (double)state.QD;

  plhs[3] = mxCreateDoubleMatrix(1,1,mxREAL);
  *(mxGetPr(plhs[3])) = (double)state.exitflag;

  plhs[4] = mxCreateDoubleMatrix(1,1,mxREAL);
  *(mxGetPr(plhs[4])) = (double)state.nIter;


  /* ------------------------------------------------------------------- 
`    Clean up 
  ------------------------------------------------------------------- */
  mxFree( diag_H );  
  
  return;
}
 
