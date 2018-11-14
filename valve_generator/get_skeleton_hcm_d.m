function skeleton = get_skeleton_hcm_d()
% 
% hardcoded patient specific MV skeleton
% 

debug = false; 


% NB: points are in mm 
ring_pts_raw = 0.1 * [65.2092 344.34 264.4 65.2219 344.275 264.4 65.1317 344.913 264.4  65.2339 344.22 264.4 65.1119 345.023 264.4 65.3515 343.668 264.4  65.0446 345.54 264.4 65.3835 343.557 264.4 65.0253 345.807 264.4  65.5032 343.087 264.4 65.002 345.968 264.4 65.5313 343.024 264.4  64.9484 346.454 264.4 65.7327 342.587 264.4 64.9431 346.472 264.4  65.8426 342.342 264.4 64.9373 346.496 264.4 65.8852 342.25 264.4  64.9301 346.549 264.4 66.0326 342.023 264.4 64.8559 347.15 264.4  66.2066 341.763 264.4 64.8303 347.44 264.4 66.4402 341.424 264.4  64.8006 347.619 264.4 66.5166 341.324 264.4 64.7773 347.932 264.4  66.8009 341.011 264.4 64.7509 348.359 264.4 66.8839 340.921 264.4  64.7504 348.483 264.4 67.1638 340.62 264.4 64.7535 348.816 264.4  67.2451 340.533 264.4 64.7605 348.936 264.4 67.5737 340.248 264.4  64.7616 349.272 264.4 67.6469 340.183 264.4 64.8072 349.781 264.4  67.959 339.914 264.4 64.8079 349.808 264.4 68.0688 339.818 264.4  64.844 350.194 264.4 68.3892 339.593 264.4 64.8611 350.368 264.4  68.4938 339.519 264.4 64.9179 350.73 264.4 68.8274 339.284 264.4  64.9575 350.988 264.4 68.9206 339.217 264.4 65.0287 351.286 264.4  69.2988 339.016 264.4 65.0534 351.382 264.4 69.4074 338.959 264.4  65.1962 351.851 264.4 69.769 338.769 264.4 65.2104 351.9 264.4  69.8648 338.716 264.4 65.2946 352.151 264.4 70.2637 338.561 264.4  65.3639 352.363 264.4 70.3838 338.514 264.4 65.4518 352.568 264.4  70.7645 338.367 264.4 65.5186 352.728 264.4 70.8699 338.324 264.4  65.5251 352.745 264.4 71.2773 338.211 264.4 65.5454 352.799 264.4  71.3994 338.177 264.4 65.7337 353.314 264.4 71.7929 338.069 264.4  65.8 353.485 264.4 71.9151 338.033 264.4 65.8474 353.619 264.4  72.3198 337.958 264.4 66.0606 354.268 264.4 72.4397 337.936 264.4  66.0812 354.341 264.4 72.8444 337.862 264.4 66.1682 354.857 264.4  72.973 337.836 264.4 66.1957 354.999 264.4 73.3757 337.792 264.4  66.2144 355.111 264.4 73.494 337.779 264.4 66.2455 355.41 264.4  73.9026 337.735 264.4 66.25 355.62 264.4 74.0303 337.72 264.4  66.2585 356.004 264.4 74.4416 337.701 264.4 66.2557 356.188 264.4  74.5564 337.696 264.4 66.2137 356.698 264.4 74.9661 337.677 264.4  66.1986 356.815 264.4 75.0975 337.67 264.4 66.1603 357.094 264.4  75.5111 337.668 264.4 66.1281 357.289 264.4 75.6245 337.667 264.4  66.1018 357.428 264.4 76.0323 337.663 264.4 66.0295 357.738 264.4  76.1688 337.662 264.4 65.981 357.926 264.4 76.5681 337.664 264.4  65.8751 358.378 264.4 76.7044 337.665 264.4 65.7279 358.825 264.4  77.0998 337.667 264.4 65.6913 358.927 264.4 77.2355 337.667 264.4  65.6727 358.983 264.4 77.6364 337.671 264.4 65.4929 359.459 264.4  77.7705 337.673 264.4 65.3007 359.94 264.4 78.1695 337.678 264.4  65.2396 360.087 264.4 78.3016 337.677 264.4 65.0765 360.429 264.4  78.7027 337.698 264.4 65.0026 360.595 264.4 78.8398 337.706 264.4  64.7851 361.027 264.4 79.2448 337.73 264.4 64.7549 361.095 264.4  79.38 337.736 264.4 64.328 361.869 264.4 79.7592 337.801 264.4  64.3227 361.879 264.4 79.9019 337.827 264.4 64.3106 361.903 264.4  80.2923 337.9 264.4 64.0118 362.439 264.4 80.4243 337.928 264.4  63.9348 362.585 264.4 80.7964 338.067 264.4 63.6565 363.118 264.4  80.8693 338.094 264.4 63.6534 363.125 264.4 81.2511 338.237 264.4  63.6514 363.129 264.4 81.3597 338.285 264.4 63.3915 363.609 264.4  81.7162 338.496 264.4 63.3703 363.661 264.4 81.7886 338.539 264.4  63.287 363.852 264.4 82.133 338.74 264.4 63.1246 364.196 264.4  82.2399 338.813 264.4 63.086 364.654 264.4 82.5735 339.061 264.4  63.0715 364.823 264.4 82.6577 339.123 264.4 63.1444 365.117 264.4  82.9784 339.36 264.4 63.2366 365.334 264.4 83.0894 339.445 264.4  63.591 365.888 264.4 83.4141 339.685 264.4 63.6068 365.916 264.4  83.5104 339.756 264.4 63.6149 365.927 264.4 83.8259 339.988 264.4  63.8951 366.298 264.4 83.9399 340.065 264.4 64.1236 366.624 264.4  84.2683 340.282 264.4 64.1987 366.743 264.4 84.3733 340.351 264.4  64.3489 366.957 264.4 84.6975 340.563 264.4 64.6052 367.316 264.4  84.8103 340.627 264.4 64.9145 367.748 264.4 85.1472 340.837 264.4  64.9266 367.764 264.4 85.2563 340.905 264.4 64.9618 367.811 264.4  85.5959 341.116 264.4 65.1668 368.091 264.4 85.7083 341.177 264.4  65.2011 368.136 264.4 86.0313 341.412 264.4 65.4351 368.448 264.4  86.1384 341.491 264.4 65.5855 368.632 264.4 86.4696 341.736 264.4  65.7192 368.79 264.4 86.5811 341.816 264.4 66.0737 369.176 264.4  86.855 342.105 264.4 66.1134 369.221 264.4 86.9232 342.176 264.4  66.1342 369.243 264.4 87.2036 342.473 264.4 66.1808 369.292 264.4  87.288 342.57 264.4 66.4197 369.546 264.4 87.4796 342.863 264.4  66.4936 369.617 264.4 87.553 342.979 264.4 66.7989 369.881 264.4  87.7454 343.292 264.4 66.9459 370.002 264.4 87.7954 343.392 264.4  67.1794 370.19 264.4 87.9733 343.727 264.4 67.3355 370.315 264.4  88.0387 343.852 264.4 67.5187 370.439 264.4 88.2147 344.196 264.4  67.7018 370.563 264.4 88.26 344.299 264.4 67.9475 370.724 264.4  88.4379 344.669 264.4 68.1068 370.832 264.4 88.4961 344.79 264.4  68.391 371.016 264.4 88.6714 345.155 264.4 68.568 371.121 264.4  88.7291 345.275 264.4 68.9691 371.351 264.4 88.8898 345.653 264.4  69.0781 371.416 264.4 88.9381 345.766 264.4 69.148 371.448 264.4  89.0963 346.136 264.4 69.4818 371.605 264.4 89.1519 346.261 264.4  69.5407 371.631 264.4 89.3173 346.624 264.4 69.6992 371.7 264.4  89.3722 346.745 264.4 70.0124 371.842 264.4 89.5426 347.12 264.4  70.1078 371.885 264.4 89.5929 347.23 264.4 70.5012 372.008 264.4  89.7638 347.595 264.4 70.6151 372.044 264.4 89.8201 347.715 264.4  71.0072 372.168 264.4 89.9905 348.081 264.4 71.1332 372.209 264.4  90.0445 348.198 264.4 71.5339 372.291 264.4 90.1865 348.574 264.4  71.6496 372.315 264.4 90.2331 348.697 264.4 72.0507 372.398 264.4  90.3749 349.072 264.4 72.1805 372.427 264.4 90.4225 349.193 264.4  72.5919 372.489 264.4 90.5191 349.575 264.4 72.7089 372.507 264.4  90.5617 349.734 264.4 73.1135 372.569 264.4 90.6412 350.034 264.4  73.2451 372.591 264.4 90.7011 350.285 264.4 73.6471 372.637 264.4  90.7565 350.616 264.4 73.7801 372.652 264.4 90.8389 351.015 264.4  74.1861 372.697 264.4 90.8782 351.295 264.4 74.31 372.713 264.4  90.9384 351.687 264.4 74.7139 372.736 264.4 90.9879 352.058 264.4  74.8488 372.744 264.4 91.0172 352.203 264.4 75.2551 372.767 264.4  91.0336 352.346 264.4 75.3797 372.775 264.4 91.0971 352.847 264.4  75.7842 372.769 264.4 91.1516 353.255 264.4 75.9206 372.767 264.4  91.1571 353.316 264.4 76.3275 372.759 264.4 91.214 353.841 264.4  76.46 372.757 264.4 91.2148 353.849 264.4 76.8685 372.707 264.4  91.2793 354.361 264.4 76.9792 372.694 264.4 91.2796 354.365 264.4  77.392 372.643 264.4 91.2804 354.374 264.4 77.5236 372.625 264.4  91.3226 354.754 264.4 77.9231 372.523 264.4 91.3796 355.248 264.4  78.0247 372.497 264.4 91.393 355.344 264.4 78.4254 372.394 264.4  91.4353 355.762 264.4 78.5461 372.36 264.4 91.4572 355.961 264.4  78.938 372.212 264.4 91.4888 356.315 264.4 79.0382 372.174 264.4  91.4947 356.407 264.4 79.4217 372.028 264.4 91.5223 356.779 264.4  79.5404 371.979 264.4 91.5289 357.023 264.4 79.8992 371.804 264.4  91.5305 357.375 264.4 80.0252 371.743 264.4 91.524 357.593 264.4  80.3846 371.566 264.4 91.5226 358.047 264.4 80.4976 371.509 264.4  91.5163 358.313 264.4 80.8526 371.293 264.4 91.4812 358.844 264.4  80.9526 371.232 264.4 91.4792 358.872 264.4 81.3033 371.019 264.4  91.4776 358.893 264.4 81.4123 370.953 264.4 91.4583 359.272 264.4  81.7495 370.714 264.4 91.4518 359.411 264.4 81.8467 370.645 264.4  91.4488 359.442 264.4 82.1777 370.41 264.4 91.4107 359.859 264.4  82.2868 370.335 264.4 91.3537 360.414 264.4 82.6132 370.085 264.4  91.3513 360.443 264.4 82.7078 370.013 264.4 91.349 360.458 264.4  83.0371 369.762 264.4 91.2817 360.869 264.4 83.1366 369.688 264.4  91.2146 361.238 264.4 83.4562 369.427 264.4 91.1831 361.433 264.4  83.5469 369.353 264.4 91.1137 361.691 264.4 83.8618 369.097 264.4  91.0569 361.903 264.4 83.9682 369.012 264.4 91.0293 361.996 264.4  84.2734 368.76 264.4 90.8961 362.471 264.4 84.3796 368.672 264.4  90.8189 362.656 264.4 84.6871 368.418 264.4 90.664 363.008 264.4  84.7979 368.324 264.4 90.6108 363.122 264.4 85.1138 368.077 264.4  90.4353 363.507 264.4 85.2031 368.008 264.4 90.3781 363.58 264.4  85.5308 367.754 264.4 90.1542 363.901 264.4 85.6157 367.686 264.4  90.0864 363.999 264.4 85.9599 367.433 264.4 89.8761 364.301 264.4  86.0526 367.365 264.4 89.7616 364.414 264.4 86.3866 367.121 264.4  89.471 364.715 264.4 86.4775 367.052 264.4 89.3826 364.805 264.4  86.8236 366.807 264.4 89.1023 365.09 264.4 86.9198 366.739 264.4  88.9896 365.18 264.4 87.2589 366.499 264.4 88.6658 365.445 264.4  87.3577 366.427 264.4 88.5635 365.528 264.4 87.6945 366.184 264.4  88.2395 365.79 264.4 87.8018 366.107 264.4 88.1352 365.866 264.4  38.2874 352.209 264.4 38.1163 352.13 264.4 38.4634 352.283 264.4  37.9165 352.013 264.4 38.874 352.495 264.4 37.7472 351.806 264.4  38.9639 352.526 264.4 37.4524 351.569 264.4 39.0266 352.548 264.4  37.3352 351.441 264.4 39.5159 352.696 264.4 37.1982 351.315 264.4  39.5318 352.701 264.4 36.9165 350.881 264.4 39.7357 352.77 264.4  36.8824 350.82 264.4 39.9658 352.83 264.4 36.7488 350.585 264.4  40.5451 353.059 264.4 36.6687 350.369 264.4 40.6207 353.077 264.4  36.5137 349.932 264.4 40.7833 353.14 264.4 36.4932 349.824 264.4  41.2741 353.421 264.4 36.4867 349.737 264.4 41.6101 353.671 264.4  36.4304 349.408 264.4 41.6909 353.731 264.4 36.4014 349.131 264.4  41.7293 353.771 264.4 36.3949 349.06 264.4 42.0231 354.056 264.4  36.3869 348.979 264.4 42.1459 354.216 264.4 36.4376 348.546 264.4  42.2975 354.361 264.4 36.451 348.207 264.4 42.3818 354.479 264.4  36.5347 347.819 264.4 42.5256 354.785 264.4 36.57 347.691 264.4  42.5937 354.956 264.4 36.6016 347.568 264.4 42.7675 355.346 264.4  36.7001 347.243 264.4 42.8393 355.527 264.4 36.7888 347.006 264.4  42.9111 355.825 264.4 36.8743 346.795 264.4 42.9341 355.925 264.4  36.9995 346.442 264.4 42.9891 356.228 264.4 37.0339 346.354 264.4  43.053 356.401 264.4 37.0706 346.268 264.4 43.0655 356.417 264.4  37.2169 345.969 264.4 43.3246 356.853 264.4 37.3757 345.56 264.4  43.3769 356.966 264.4 37.4141 345.471 264.4 43.606 357.404 264.4  37.4515 345.382 264.4 43.5259 357.732 264.4 37.6409 344.956 264.4  43.561 357.898 264.4 37.7344 344.727 264.4 43.6637 358.318 264.4  37.8755 344.383 264.4 43.7037 358.598 264.4 37.9284 344.267 264.4  43.8108 359.002 264.4 37.9491 344.207 264.4 43.9021 359.283 264.4  38.1653 343.744 264.4 43.9992 359.376 264.4 38.3155 343.369 264.4  44.1675 359.591 264.4 38.4624 343.033 264.4 44.2535 359.736 264.4  38.4993 342.959 264.4 44.5322 360.018 264.4 38.5238 342.907 264.4  44.6055 360.091 264.4 38.7806 342.473 264.4 44.9025 360.314 264.4  38.977 342.112 264.4 45.1873 360.664 264.4 39.035 342.022 264.4  45.2108 360.681 264.4 39.1033 341.935 264.4 45.2334 360.702 264.4  39.3317 341.637 264.4 45.545 360.968 264.4 39.471 341.459 264.4  45.7096 361.108 264.4 39.7386 341.151 264.4 45.9804 361.271 264.4  39.9209 340.954 264.4 46.2422 361.499 264.4 40.0523 340.827 264.4  46.2793 361.537 264.4 40.2554 340.626 264.4 46.439 361.668 264.4  40.4915 340.427 264.4 46.6131 361.755 264.4 40.708 340.243 264.4  46.7314 361.841 264.4 40.9133 340.087 264.4 47.1661 362.09 264.4  41.31 339.807 264.4 47.2861 362.163 264.4 41.614 339.621 264.4  47.552 362.29 264.4 42.0451 339.382 264.4 47.9519 362.518 264.4  42.1656 339.319 264.4 48.1535 362.599 264.4 42.61 339.104 264.4  48.2133 362.625 264.4 42.7327 339.049 264.4 48.3411 362.701 264.4  43.0382 338.944 264.4 48.6507 362.83 264.4 43.462 338.8 264.4  48.9724 362.923 264.4 43.6074 338.752 264.4 49.3246 363.137 264.4  43.9188 338.687 264.4 49.4386 363.174 264.4 44.1267 338.646 264.4  49.5229 363.226 264.4 44.5501 338.576 264.4 49.8202 363.287 264.4  44.7597 338.553 264.4 50.1247 363.502 264.4 44.9794 338.541 264.4  50.2487 363.548 264.4 45.2085 338.554 264.4 50.5747 363.724 264.4  45.5839 338.554 264.4 50.6866 363.774 264.4 46.0501 338.611 264.4  50.7252 363.796 264.4 46.1381 338.615 264.4 51.1031 363.953 264.4  46.1601 338.618 264.4 51.3604 364.08 264.4 46.683 338.736 264.4  51.7456 364.327 264.4 47.1664 338.875 264.4 51.907 364.42 264.4  47.2083 338.883 264.4 52.1889 364.589 264.4 47.2308 338.89 264.4  52.3308 364.646 264.4 47.5831 339.027 264.4 52.6465 364.886 264.4  48.0053 339.209 264.4 52.748 364.937 264.4 48.0774 339.246 264.4  52.7711 364.947 264.4 48.1397 339.285 264.4 52.8047 364.975 264.4  48.1877 339.307 264.4 53.158 365.126 264.4 48.5112 339.464 264.4  53.3734 365.284 264.4 48.7139 339.545 264.4 53.456 365.317 264.4  48.9633 339.676 264.4 53.5491 365.368 264.4 49.2091 339.795 264.4  53.8518 365.474 264.4 49.269 339.825 264.4 54.2918 365.667 264.4  49.3897 339.877 264.4 54.4593 365.726 264.4 49.8421 340.067 264.4  54.8596 365.831 264.4 50.2473 340.218 264.4 55.0036 365.861 264.4  50.3009 340.238 264.4 55.0401 365.866 264.4 50.8278 340.324 264.4  55.0678 365.871 264.4 50.8907 340.338 264.4 55.5984 365.923 264.4  50.9716 340.37 264.4 55.6846 365.932 264.4 51.2693 340.347 264.4  56.0166 365.963 264.4 51.4314 340.339 264.4 56.2887 365.971 264.4  51.7516 340.265 264.4 56.3553 365.971 264.4 52.1084 340.129 264.4  56.4218 365.983 264.4 52.487 339.911 264.4 56.7854 365.99 264.4  52.4888 339.91 264.4 56.9806 366.005 264.4 52.4901 339.909 264.4  57.1402 365.998 264.4 52.9169 339.568 264.4 57.3582 366.004 264.4  52.9432 339.548 264.4 57.586 365.996 264.4 53.3861 339.177 264.4  57.779 365.983 264.4 53.6284 338.963 264.4 58.1829 365.927 264.4  53.6667 338.938 264.4 58.2981 365.921 264.4 54.1125 338.599 264.4  58.6147 365.879 264.4 54.2035 338.556 264.4 58.8287 365.819 264.4  54.2871 338.506 264.4 59.4207 365.626 264.4 54.6481 338.321 264.4  59.4667 365.603 264.4 54.8953 338.273 264.4 59.9508 365.361 264.4  55.1388 338.2 264.4 60.2146 365.159 264.4 55.366 338.146 264.4  60.3272 365.089 264.4 55.5302 338.103 264.4 60.4685 364.961 264.4  55.8228 338.08 264.4 60.6441 364.772 264.4 56.0952 338.085 264.4  60.8533 364.512 264.4 56.4378 338.083 264.4 61.0212 364.345 264.4  56.8927 338.087 264.4 61.0763 364.26 264.4 56.9393 338.088 264.4  61.3277 363.785 264.4 57.195 338.103 264.4 61.3396 363.767 264.4  57.4418 338.126 264.4 61.3509 363.745 264.4 57.5117 338.133 264.4  61.716 363.11 264.4 58.0178 338.189 264.4 61.7966 362.988 264.4  58.466 338.238 264.4 62.0969 362.556 264.4 58.57 338.248 264.4  62.2321 362.387 264.4 58.9473 338.319 264.4 62.3755 362.253 264.4  59.2209 338.349 264.4 62.5146 362.118 264.4 59.4541 338.381 264.4  62.7324 361.942 264.4 60.0242 338.457 264.4 63.0194 361.665 264.4  60.0422 338.46 264.4 63.0957 361.608 264.4 60.0532 338.461 264.4  63.1333 361.569 264.4 60.5481 338.569 264.4 63.2296 361.47 264.4  60.7508 338.578 264.4 63.6315 361.105 264.4 61.083 338.646 264.4  63.7028 361.023 264.4 61.3492 338.691 264.4 64.0143 360.649 264.4  61.8709 338.811 264.4 64.0173 360.646 264.4 61.9696 338.842 264.4  64.3263 360.191 264.4 62.0368 338.869 264.4 64.3394 360.173 264.4  62.3609 338.987 264.4 64.6296 359.708 264.4 62.8132 339.201 264.4  64.6555 359.617 264.4 62.8634 339.227 264.4 64.8684 359.143 264.4  62.8775 339.232 264.4 64.9793 358.786 264.4 62.9263 339.249 264.4  65.0359 358.519 264.4 63.1792 339.423 264.4 65.071 358.129 264.4  63.4619 339.688 264.4 65.0996 357.977 264.4 63.5525 339.795 264.4  65.1167 357.706 264.4 63.7587 340.026 264.4 65.1498 357.457 264.4  63.87 340.355 264.4 65.1582 357.342 264.4 63.9469 340.485 264.4  65.2249 356.801 264.4 64.0497 340.943 264.4 65.224 356.543 264.4  64.0542 340.958 264.4 65.262 356.313 264.4 64.1001 341.358 264.4  65.2498 355.812 264.4 64.1043 341.385 264.4 65.2663 355.672 264.4  64.1039 341.543 264.4 65.2721 355.643 264.4 64.1231 342.005 264.4  65.2649 355.578 264.4 64.1292 342.09 264.4 65.3497 355.188 264.4  64.1274 342.141 264.4 65.3316 354.901 264.4 64.1106 342.259 264.4  65.3157 354.485 264.4 64.0942 342.772 264.4 65.291 354.268 264.4  64.0973 343.006 264.4 65.2336 354 264.4 64.0608 343.294 264.4  65.1747 353.774 264.4 64.0347 343.584 264.4 65.1098 353.49 264.4  63.9586 344.027 264.4 65.0845 353.336 264.4 63.9475 344.177 264.4  64.9865 353.063 264.4 63.9235 344.335 264.4 64.9854 352.942 264.4  63.9103 344.618 264.4 64.9707 352.867 264.4 63.8831 344.779 264.4  64.8984 352.614 264.4 63.8394 345.187 264.4 64.894 352.553 264.4  63.7991 345.453 264.4 64.8904 352.53 264.4 63.7633 345.833 264.4  64.872 352.424 264.4 63.7382 346.058 264.4 64.8377 351.946 264.4  63.7485 346.35 264.4 64.818 351.816 264.4 63.7309 346.646 264.4  64.857 351.456 264.4 63.7278 346.852 264.4 64.8049 351.169 264.4  63.7325 347.101 264.4 64.6641 350.758 264.4 63.7428 347.315 264.4  64.6405 350.598 264.4 63.748 347.678 264.4 64.542 350.179 264.4  63.8153 348.003 264.4 64.5026 350.015 264.4 63.8984 348.278 264.4  64.4251 349.815 264.4 63.9835 348.643 264.4 64.3373 349.537 264.4  64.0939 348.936 264.4 64.2698 349.34 264.4  ]; 
ring_pts_raw = reshape(ring_pts_raw, 3, []); 

connectivity_raw = [2 0 1 
2 210 208 
2 197 199 
2 271 273 
2 205 207 
2 130 128 
2 186 184 
2 44 42 
2 309 311 
2 15 17 
2 213 215 
2 174 172 
2 245 247 
2 17 19 
2 230 228 
2 237 239 
2 253 255 
2 5 7 
2 221 223 
2 229 231 
2 261 263 
2 48 46 
2 168 166 
2 311 313 
2 118 116 
2 297 299 
2 226 224 
2 319 321 
2 206 204 
2 144 142 
2 335 337 
2 273 275 
2 208 206 
2 285 287 
2 24 22 
2 199 201 
2 203 205 
2 359 361 
2 388 386 
2 380 378 
2 61 63 
2 383 385 
2 149 151 
2 173 175 
2 372 370 
2 191 193 
2 284 282 
2 134 132 
2 292 290 
2 26 24 
2 276 274 
2 375 377 
2 300 298 
2 3 5 
2 42 40 
2 165 167 
2 181 183 
2 308 306 
2 268 266 
2 211 213 
2 137 139 
2 170 168 
2 364 362 
2 357 359 
2 145 147 
2 316 314 
2 28 26 
2 36 34 
2 53 55 
2 259 261 
2 62 60 
2 157 159 
2 324 322 
2 260 258 
2 169 171 
2 2 0 
2 332 330 
2 340 338 
2 195 197 
2 252 250 
2 356 354 
2 177 179 
2 365 367 
2 348 346 
2 161 163 
2 19 21 
2 153 155 
2 129 131 
2 269 271 
2 244 242 
2 148 146 
2 251 253 
2 310 308 
2 366 364 
2 374 372 
2 113 115 
2 302 300 
2 287 289 
2 318 316 
2 342 340 
2 81 83 
2 105 107 
2 243 245 
2 238 236 
2 232 230 
2 358 356 
2 246 244 
2 334 332 
2 235 237 
2 350 348 
2 73 75 
2 97 99 
2 227 229 
2 27 29 
2 89 91 
2 82 80 
2 54 52 
2 326 324 
2 187 189 
2 294 292 
2 121 123 
2 65 67 
2 286 284 
2 278 276 
2 270 268 
2 382 380 
2 108 106 
2 202 200 
2 57 59 
2 49 51 
2 254 252 
2 35 37 
2 43 45 
2 219 221 
2 262 260 
2 373 375 
2 389 388 
2 240 238 
2 45 47 
2 142 140 
2 189 191 
2 381 383 
2 30 28 
2 349 351 
2 162 160 
2 104 102 
2 18 16 
2 1 3 
2 37 39 
2 184 182 
2 146 144 
2 355 357 
2 158 156 
2 50 48 
2 329 331 
2 307 309 
2 84 82 
2 152 150 
2 138 136 
2 98 96 
2 263 265 
2 20 18 
2 64 62 
2 248 246 
2 256 254 
2 264 262 
2 272 270 
2 280 278 
2 288 286 
2 296 294 
2 304 302 
2 312 310 
2 320 318 
2 328 326 
2 336 334 
2 344 342 
2 352 350 
2 360 358 
2 368 366 
2 376 374 
2 384 382 
2 387 389 
2 379 381 
2 371 373 
2 369 371 
2 363 365 
2 361 363 
2 265 267 
2 257 259 
2 249 251 
2 241 243 
2 233 235 
2 225 227 
2 217 219 
2 209 211 
2 201 203 
2 193 195 
2 185 187 
2 183 185 
2 175 177 
2 167 169 
2 159 161 
2 151 153 
2 143 145 
2 135 137 
2 127 129 
2 119 121 
2 111 113 
2 103 105 
2 95 97 
2 87 89 
2 79 81 
2 71 73 
2 63 65 
2 55 57 
2 47 49 
2 41 43 
2 33 35 
2 46 44 
2 52 50 
2 94 92 
2 236 234 
2 13 15 
2 100 98 
2 323 325 
2 32 30 
2 114 112 
2 70 68 
2 353 355 
2 351 353 
2 224 222 
2 136 134 
2 74 72 
2 150 148 
2 345 347 
2 16 14 
2 204 202 
2 132 130 
2 325 327 
2 69 71 
2 116 114 
2 141 143 
2 367 369 
2 179 181 
2 131 133 
2 139 141 
2 90 88 
2 122 120 
2 21 23 
2 77 79 
2 123 125 
2 85 87 
2 133 135 
2 93 95 
2 377 379 
2 115 117 
2 101 103 
2 147 149 
2 212 210 
2 194 192 
2 154 152 
2 171 173 
2 107 109 
2 109 111 
2 125 127 
2 385 387 
2 207 209 
2 117 119 
2 99 101 
2 14 12 
2 255 257 
2 386 384 
2 362 360 
2 155 157 
2 378 376 
2 370 368 
2 163 165 
2 354 352 
2 91 93 
2 247 249 
2 239 241 
2 83 85 
2 346 344 
2 231 233 
2 75 77 
2 106 104 
2 67 69 
2 39 41 
2 59 61 
2 51 53 
2 31 33 
2 120 118 
2 338 336 
2 110 108 
2 223 225 
2 215 217 
2 23 25 
2 7 9 
2 330 328 
2 96 94 
2 322 320 
2 314 312 
2 306 304 
2 298 296 
2 6 4 
2 290 288 
2 282 280 
2 60 58 
2 274 272 
2 266 264 
2 234 232 
2 315 317 
2 258 256 
2 78 76 
2 250 248 
2 242 240 
2 66 64 
2 327 329 
2 76 74 
2 216 214 
2 192 190 
2 222 220 
2 331 333 
2 190 188 
2 68 66 
2 166 164 
2 313 315 
2 72 70 
2 156 154 
2 8 6 
2 126 124 
2 38 36 
2 333 335 
2 188 186 
2 303 305 
2 88 86 
2 214 212 
2 267 269 
2 124 122 
2 11 13 
2 4 2 
2 178 176 
2 295 297 
2 299 301 
2 112 110 
2 10 8 
2 343 345 
2 12 10 
2 128 126 
2 301 303 
2 293 295 
2 317 319 
2 305 307 
2 200 198 
2 289 291 
2 172 170 
2 58 56 
2 180 178 
2 275 277 
2 196 194 
2 102 100 
2 337 339 
2 80 78 
2 56 54 
2 279 281 
2 164 162 
2 339 341 
2 25 27 
2 341 343 
2 40 38 
2 22 20 
2 182 180 
2 218 216 
2 29 31 
2 176 174 
2 140 138 
2 277 279 
2 9 11 
2 220 218 
2 92 90 
2 160 158 
2 228 226 
2 281 283 
2 291 293 
2 347 349 
2 283 285 
2 86 84 
2 198 196 
2 34 32 
2 321 323]; 

first_idx  = connectivity_raw(:,2); 
second_idx = connectivity_raw(:,3); 

valve_ring_pts = zeros(3,length(first_idx)); 
pt_idx = 0; 

current = first_idx(1); 
next = second_idx(1); 
complete = false; 
while true
    
    % add one to value of current when using as matlab index
    pt_idx = pt_idx + 1;
    valve_ring_pts(:,pt_idx) = ring_pts_raw(:, current + 1); 
    
    % search for the next index 
    current = first_idx(find(first_idx == next)); 
    next    = second_idx(find(first_idx == next)); 
    
    if isempty(current)
        error('Did not find a vertex with the correct index'); 
    end 
    
    % periodic return to the first point 
    if current == first_idx(1)
        complete = true; 
        break;
    end 
    
end 

if ~complete
    error('failed to find periodic cycle')
end 

skeleton.valve_ring_pts = valve_ring_pts; 

skeleton.n_ring_pts = size(skeleton.valve_ring_pts,2); 

if skeleton.n_ring_pts ~= pt_idx
    error('inconsistency in lengths')
end 

skeleton.ring_center = mean(skeleton.valve_ring_pts')'; 

radii = zeros(skeleton.n_ring_pts, 1); 
for j=1:skeleton.n_ring_pts
    radii(j) = norm(skeleton.valve_ring_pts(:,j) - skeleton.ring_center); 
end

skeleton.r = mean(radii); 

% NB: points are in mm 
papillary_raw = 0.1 * [82.3044 360.013 247.115 76.9983 358.512 245.207 75.5067 346.85 243.066 84.9069 357.568 245.356 80.3069 344.479 245.726 79.4786 361.368 247.096 77.5486 344.933 244.67 82.7627 344.659 244.975]; 

% this currently has got to be exactly 8 3d vectors 
skeleton.papillary = reshape(papillary_raw, [3 8]); 

% manually observed ordering, because paraview stores this in seemingly
% random order 
indices = [1 2 6 4 7 3 0 5] + 1; 
skeleton.papillary = skeleton.papillary(:,indices); 


if debug 
    fig = figure; 
    
    x = squeeze(skeleton.valve_ring_pts(1,:));
    y = squeeze(skeleton.valve_ring_pts(2,:));
    z = squeeze(skeleton.valve_ring_pts(3,:));
    plot3(x,y,z); 
    
    title('valve ring hcm d')
end 





