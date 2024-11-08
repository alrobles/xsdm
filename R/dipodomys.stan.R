# functions{
#   matrix kronecker_prod(matrix A, matrix B) {
#     int m;
#     int n;
#     int p;
#     int q;
#     m = rows(A);
#     n = cols(A);
#     p = rows(B);
#     q = cols(B);
#     matrix[m * p, n * q] C;
#     int row_start;
#     int row_end;
#     int col_start;
#     int col_end;
#     for (i in 1:m) {
#       for (j in 1:n) {
#         row_start = (i - 1) * p + 1;
#         row_end = (i - 1) * p + p;
#         col_start = (j - 1) * q + 1;
#         col_end = (j - 1) * q + q;
#         C[row_start:row_end, col_start:col_end] = A[i, j] * B;
#       }
#     }
#     return C;
#   }
  
#   vector eigenvalues22(matrix A){
#     real T;
#     real D;
#     vector[2] eigenvalues;
#     T = A[1,1] + A[2,2];                      // trace
#     D = A[1,1] * A[2,2] - A[1,2] * A[2,1];    // determinant
    
#     if ( (T^2) / 4 - D < 0 ){
#       print("complex EV");
#       reject("complex eigenvalue");
#     }
#     // det(A - lambda * I) -> eigevanlues
#     eigenvalues[1] = T / 2 + sqrt( (T^2)/4 - D );
#     eigenvalues[2] = T / 2 - sqrt( (T^2)/4 - D );
#     return(eigenvalues);
#   }

#   matrix eigenvectors22(matrix A){
#     real T;
#     real D;
#     vector[2] eigenvalues;
#     matrix[2,2] eigenvectors;
#     vector[2] evnorm;

#     eigenvalues = eigenvalues22(A);
#     // T = A[1,1] + A[2,2];
#     // D = A[1,1] * A[2,2] - A[1,2] * A[2,1];
#     // eigenvalues[1] = T/2+sqrt((T^2)/4-D);
#     // eigenvalues[2] = T/2-sqrt((T^2)/4-D);
    
#     eigenvectors[1,1] = eigenvalues[1] - A[2,2];
#     eigenvectors[2,1] = A[2,1];
#     eigenvectors[1,2] = eigenvalues[2] - A[2,2];
#     eigenvectors[2,2] = A[2,1];
    
#     // normalize
#     evnorm[1] = sqrt(eigenvectors[1,1]^2 + eigenvectors[2,1]^2);
#     evnorm[2] = sqrt(eigenvectors[1,2]^2 + eigenvectors[2,2]^2);
#     eigenvectors[1,1] = eigenvectors[1,1] / evnorm[1];
#     eigenvectors[2,1] = eigenvectors[2,1] / evnorm[1];
#     eigenvectors[1,2] = eigenvectors[1,2] / evnorm[2];
#     eigenvectors[2,2] = eigenvectors[2,2] / evnorm[2];

#     return(eigenvectors);
#   }
# }

# data{
#   int M;
#   int N;
#   array[N] int occ;
#   matrix[N,M] X1;
#   matrix[N,M] X2;
#   matrix[N,M] X3;
#   int hmax;
# }

# parameters{
#   // first is adult fecundity
#   // second is juvenile survival
#   // third is adult survival
#   vector[3] mu;
#   vector<lower=0>[3] sigl;
#   vector<lower=0>[3] sigr;
#   real c;
#   real<lower=0,upper=1> pd;
# }

# model{

#   array[2,2,M] real At; 
#   real u;
#   real res;

#   matrix[2,2] Abar;          // mean
#   vector[2] lambdai;         // eigenvalues
#   matrix[2,2] wi;            // right eigenvectors
#   matrix[2,2] vi;            // left eigenvectors
  
#   array[2,2,M] real Dt; 
#   array[4,4,hmax+1] real Ch;
#   array[4,4,M] real kronstack; // M here maximal length, loop does not always use all entries
  
#   matrix[2,2] matA;
#   matrix[2,2] matB;
#   matrix[4,4] matC;
  
#   real tausq;
#   matrix[4,4] Chsum;
#   real theta;
  
#   real iv;
#   vector[N] ltsgr;
  
#   // priors --------------------------
#   // climate is standardized (mu = 0 , sd = 1).
#   // these priors can be considered vague.
#   mu[1] ~ normal(0, 2);
#   mu[2] ~ normal(0, 2);
#   mu[3] ~ normal(0, 2);
#   sigl[1] ~ normal(1, 2);
#   sigl[2] ~ normal(1, 2);
#   sigl[3] ~ normal(1, 2);
#   sigr[1] ~ normal(1, 2);
#   sigr[2] ~ normal(1, 2);
#   sigr[3] ~ normal(1, 2);
#   c ~ normal(0, 10); 
#   pd ~ uniform(0, 1);

#   // for-loop over all observations --------------
#   for(i_obs in 1:N){
    
#     // model At[i,j] --------------
#     // juvenile fecundity
#     for(k in 1:M){
#       At[1,1,k] = 0;
#     }

#     // adult fecundity
#     for(k in 1:M){
#       u = X1[i_obs,k] - mu[1];
#       if (u < 0) { 
#         res = u/sigl[1]; 
#       }
#       else { 
#         res = u/sigr[1]; 
#       }
#       At[1,2,k] = exp(-0.5*res^2);
#     }
    
#     // juvenile survival
#     for(k in 1:M){
#       u = X2[i_obs,k] - mu[2];
#       if (u < 0) { 
#         res = u/sigl[2]; 
#       }
#       else { 
#         res = u/sigr[2]; 
#       }
#       At[2,1,k] = exp(-0.5*res^2);
#     }

#     // adult survival
#     for(k in 1:M){
#       u = X3[i_obs,k] - mu[3];
#       if (u < 0) { 
#         res = u/sigl[3]; 
#       }
#       else { 
#         res = u/sigr[3]; 
#       }
#       At[2,2,k] = exp(-0.5*res^2);
#     }
    
#     // mean matrix and eigenvals -----------------
#     for(i in 1:2)
#       for(j in 1:2)
#         Abar[i,j] = mean(At[i,j, ]);
 
#     lambdai = eigenvalues22(Abar);
#     wi = eigenvectors22(Abar);
#     vi = eigenvectors22(Abar');

#     vi = diag_post_multiply(
#       vi,
#       [1/((vi[,1]')*wi[,1]),
#       1/((vi[,2]')*wi[,2])] 
#     );
                            
#     for(i in 1:2)
#       for(j in 1:2)
#         for(k in 1:M)
#           Dt[i,j,k] = At[i,j,k] - Abar[i,j];
    
#     for(h in 0:hmax){
#       for(count in 1:(M-h)){
#         for(i in 1:2){
#           for(j in 1:2){
#             matA[i,j] = Dt[i,j,count];
#             matB[i,j] = Dt[i,j,count+h];
#           }
#         }
#         matC = kronecker_prod(matA,matB);
#         for(i in 1:4)
#           for(j in 1:4)
#             kronstack[i,j,count] = matC[i,j];
        
#       } // end count
      
#       for(i in 1:4)
#         for(j in 1:4)
#           Ch[i,j,h+1] = mean(kronstack[i,j, ]);
          
#     } // end h
    
#     for(i in 1:4)
#       for(j in 1:4)
#         matC[i,j]=Ch[i,j,1]; // Check the indices! Caswell starts C in C_0, not in C_1
        
#     tausq = (kronecker_prod(to_matrix(vi[,1]),to_matrix(vi[,1]))' * 
#              matC * 
#              kronecker_prod(to_matrix(wi[,1]),to_matrix(wi[,1])))[1,1];
    
#     for(i in 1:4)
#       for(j in 1:4)
#         Chsum[i,j]=0.0;
    
#     for (h in 1:hmax){
#       for(i in 1:4)
#         for(j in 1:4)
#           matC[i,j]=Ch[i,j,h+1]; // Check the indices! Caswell starts C in C_0, not in C_1
#           Chsum = Chsum+((lambdai[2]/lambdai[1])^(h-1))*matC; 
#     } // end h
    
#     theta = (kronecker_prod(to_matrix(vi[,1]),to_matrix(vi[,2]))' * 
#              Chsum * 
#              kronecker_prod(to_matrix(wi[,2]),to_matrix(wi[,1])))[1,1];  
    
#     iv = tausq/lambdai[1]^2-2*theta/lambdai[1]^2;
#     ltsgr[i_obs] = log(lambdai[1])-iv/2;
    
#   }
#   occ ~ bernoulli(pd * inv_logit(ltsgr - c)); 
# }

# generated quantities {

#   vector[N] log_lik;
#   array[2,2,M] real At; 
#   real u;
#   real res;

#   matrix[2,2] Abar;          // mean
#   vector[2] lambdai;         // eigenvalues
#   matrix[2,2] wi;            // right eigenvectors
#   matrix[2,2] vi;            // left eigenvectors
  
#   array[2,2,M] real Dt; 
#   array[4,4,hmax+1] real Ch;
#   array[4,4,M] real kronstack; // M here maximal length, loop does not always use all entries
  
#   matrix[2,2] matA;
#   matrix[2,2] matB;
#   matrix[4,4] matC;
  
#   real tausq;
#   matrix[4,4] Chsum;
#   real theta;
  
#   real iv;
#   vector[N] ltsgr;

#   // for-loop over all observations --------------
#   for(i_obs in 1:N){
    
#     // model At[i,j] --------------
#     // juvenile fecundity
#     for(k in 1:M){
#       At[1,1,k] = 0;
#     }

#     // adult fecundity
#     for(k in 1:M){
#       u = X1[i_obs,k] - mu[1];
#       if (u < 0) { 
#         res = u/sigl[1]; 
#       }
#       else { 
#         res = u/sigr[1]; 
#       }
#       At[1,2,k] = exp(-0.5*res^2);
#     }
    
#     // juvenile survival
#     for(k in 1:M){
#       u = X2[i_obs,k] - mu[2];
#       if (u < 0) { 
#         res = u/sigl[2]; 
#       }
#       else { 
#         res = u/sigr[2]; 
#       }
#       At[2,1,k] = exp(-0.5*res^2);
#     }

#     // adult survival
#     for(k in 1:M){
#       u = X3[i_obs,k] - mu[3];
#       if (u < 0) { 
#         res = u/sigl[3]; 
#       }
#       else { 
#         res = u/sigr[3]; 
#       }
#       At[2,2,k] = exp(-0.5*res^2);
#     }
    
#     // mean matrix and eigenvals -----------------
#     for(i in 1:2)
#       for(j in 1:2)
#         Abar[i,j] = mean(At[i,j, ]);
 
#     lambdai = eigenvalues22(Abar);
#     wi = eigenvectors22(Abar);
#     vi = eigenvectors22(Abar');

#     vi = diag_post_multiply(
#       vi,
#       [1/((vi[,1]')*wi[,1]),
#       1/((vi[,2]')*wi[,2])] 
#     );
                            
#     for(i in 1:2)
#       for(j in 1:2)
#         for(k in 1:M)
#           Dt[i,j,k] = At[i,j,k] - Abar[i,j];
    
#     for(h in 0:hmax){
#       for(count in 1:(M-h)){
#         for(i in 1:2){
#           for(j in 1:2){
#             matA[i,j] = Dt[i,j,count];
#             matB[i,j] = Dt[i,j,count+h];
#           }
#         }
#         matC = kronecker_prod(matA,matB);
#         for(i in 1:4)
#           for(j in 1:4)
#             kronstack[i,j,count] = matC[i,j];
        
#       } // end count
      
#       for(i in 1:4)
#         for(j in 1:4)
#           Ch[i,j,h+1] = mean(kronstack[i,j, ]);
          
#     } // end h
    
#     for(i in 1:4)
#       for(j in 1:4)
#         matC[i,j]=Ch[i,j,1]; // Check the indices! Caswell starts C in C_0, not in C_1
        
#     tausq = (kronecker_prod(to_matrix(vi[,1]),to_matrix(vi[,1]))' * 
#              matC * 
#              kronecker_prod(to_matrix(wi[,1]),to_matrix(wi[,1])))[1,1];
    
#     for(i in 1:4)
#       for(j in 1:4)
#         Chsum[i,j]=0.0;
    
#     for (h in 1:hmax){
#       for(i in 1:4)
#         for(j in 1:4)
#           matC[i,j]=Ch[i,j,h+1]; // Check the indices! Caswell starts C in C_0, not in C_1
#           Chsum = Chsum+((lambdai[2]/lambdai[1])^(h-1))*matC; 
#     } // end h
    
#     theta = (kronecker_prod(to_matrix(vi[,1]),to_matrix(vi[,2]))' * 
#              Chsum * 
#              kronecker_prod(to_matrix(wi[,2]),to_matrix(wi[,1])))[1,1];  
    
#     iv = tausq/lambdai[1]^2-2*theta/lambdai[1]^2;
#     ltsgr[i_obs] = log(lambdai[1])-iv/2;
#     log_lik[i_obs] = bernoulli_lpmf(occ[i_obs] | pd * inv_logit(ltsgr[i_obs] - c));    
#   }
# }
