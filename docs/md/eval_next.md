# Data Extraction Evaluation
Matthew Leonawicz  



### Next steps

Combining sampling and data reduction methods while using the most efficient **R** functions can be particularly useful when processing large numbers of high-resolution geotiff raster layers.
One thing I already do when extracting from many files by shapefile is I avoid extracting by shape more than once.
I do it one time to obtain the corresponding raster layer cell indices.
Then on all subsequent maps I extract by cell indices which is notably faster.
Ultimately, there is much more room for speed improvements in terms of efficient use of statistics than in strictly programmatic corner-cutting.

The plots below benchmark different sample mean computations.
Comparisons involve the sample mean of the entire data set and do not involve the main approach outlined above which focuses on efficiency gains by taking the mean of a smaller, representative sample.
This provides some insight into how it is beneficial nonetheless to considering the right programmatic approach in conjunction with statistical efficiencies.


```
## Unit: milliseconds
##                              expr       min        lq      mean    median
##                mean(v, na.rm = T) 392.94288 398.81443 414.25598 409.39501
##                  mean(v[dat.ind])  11.93313  14.10656  16.22744  14.18524
##                sum(v[dat.ind])/nd  10.76998  12.61406  14.25219  12.84638
##       .Internal(mean(v[dat.ind]))  11.99937  14.03176  15.84347  14.21712
##  .Primitive("sum")(v[dat.ind])/nd  12.03669  12.62946  15.91700  12.86955
##         uq       max neval
##  423.41387 482.09642   100
##   15.19180  43.22703   100
##   13.46014  38.57693   100
##   15.02028  37.75091   100
##   14.19255 143.76789   100
```

![](eval_next_files/figure-html/benchmarks1-1.png) 


```
## Unit: milliseconds
##                expr       min        lq      mean    median        uq
##    mean(v[dat.ind]) 11.461648 14.110447 15.896718 14.226762 14.483182
##  sum(v[dat.ind])/nd  9.976305 12.616085 14.556560 12.732556 13.020387
##             mean(d)  2.945184  2.968042  3.033637  2.987947  3.029621
##           sum(d)/nd  1.480989  1.496228  1.545608  1.504936  1.533704
##         max neval
##  128.973238  1000
##  128.335063  1000
##    4.888943  1000
##    3.639961  1000
```

![](eval_next_files/figure-html/benchmarks2-1.png) 
