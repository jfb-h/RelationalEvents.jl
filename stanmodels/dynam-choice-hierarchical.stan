data {
  int N; // number of rows
  int E; // number of events
  int L; // number of transaction categories
  int K; // number of covariates
  
  vector<lower = 0, upper = 1>[N] choice;
  matrix[N, K] X; 
  
  int whichChoice[E];
  int ll[E];      // index for category
  int start[E];   // the starting observation for each event
  int end[E];     // the ending observation for each event
}

parameters {
  vector[K] mu_beta;          
  vector<lower = 0>[K] tau; 
  matrix[L, K] z; 
  cholesky_factor_corr[K] L_Omega; 
}

transformed parameters {
  matrix[L, K] beta_category = rep_matrix(mu_beta', L) + z * diag_pre_multiply(tau, L_Omega);
}

model {
  vector[N] log_prob;

  tau ~ exponential(1);
  mu_beta ~ normal(0, 1);
  to_vector(z) ~ std_normal();
  L_Omega ~ lkj_corr_cholesky(3);

  for(e in 1:E) 
    log_prob[start[e]:end[e]] = log_softmax(X[start[e]:end[e]] * beta_category[ll[e]]');

  target += dot_product(log_prob, choice);
}

// generated quantities {
//   vector[E] log_lik; // pointwise log-likelihood for model comparison
//
//  {
//  vector[N] log_prob;
//
//  for(i in 1:E) {
//    log_prob[start[i]:end[i]] = log_softmax(X[start[i]:end[i]] * beta_category[ll[i]]');
//  }
//    log_lik = log_prob[whichChoice];
//  }
//}
