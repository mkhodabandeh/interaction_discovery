/*Arithmetic Mean of a large number of Integers
  - or - solve a very large constraint matrix
         over 1 million rows and columns
  Nigel_Galloway@operamail.com
  March 18th., 2008.
*/

param e := 20;
/* set Sample := {-2**e..2**e-1}; */
set Sample := {1..2**e-1};

var Mean;
var E{z in Sample};

/* sum of variances is zero */
zumVariance: sum{z in Sample} E[z] = 0;

/* Mean + variance[n] = Sample[n] */
variances{z in Sample}: Mean + E[z] = z;

solve;

printf "The arithmetic mean of the integers from 1 to %d is %f\n", 2**e-1, Mean;

end;
