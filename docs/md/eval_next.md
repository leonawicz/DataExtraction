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
##                mean(v, na.rm = T) 394.96794 396.31210 402.12017 397.84007
##                  mean(v[dat.ind])  13.17356  14.01265  14.91157  14.09056
##                sum(v[dat.ind])/nd  12.07976  12.51361  16.38991  12.62044
##       .Internal(mean(v[dat.ind]))  13.19813  13.99975  15.70107  14.13410
##  .Primitive("sum")(v[dat.ind])/nd  11.79487  12.50816  14.34010  12.64190
##         uq       max neval
##  406.52131 431.02961   100
##   14.27110  37.75479   100
##   12.86053 129.59433   100
##   14.32459  37.83565   100
##   12.90889  35.95314   100
```

![](eval_next_files/figure-html/benchmarks1-1.png) 


```
## Unit: milliseconds
##                expr       min        lq      mean    median        uq
##    mean(v[dat.ind]) 13.104828 14.020738 15.739257 14.104088 14.222426
##  sum(v[dat.ind])/nd 11.640616 12.532113 14.144239 12.610796 12.729912
##             mean(d)  2.945843  2.958905  2.998083  2.969012  2.996225
##           sum(d)/nd  1.482563  1.491893  1.511856  1.497802  1.508065
##         max neval
##   39.341541  1000
##  128.070089  1000
##    4.115222  1000
##    2.227732  1000
```

![](eval_next_files/figure-html/benchmarks2-1.png) 
