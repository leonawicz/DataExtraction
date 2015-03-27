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
##                mean(v, na.rm = T) 395.12810 397.59624 405.07016 400.44723
##                  mean(v[dat.ind])  13.27930  13.99213  17.44195  14.27125
##                sum(v[dat.ind])/nd  11.77746  12.52138  15.58598  12.80331
##       .Internal(mean(v[dat.ind]))  13.12878  13.38691  14.78263  14.07470
##  .Primitive("sum")(v[dat.ind])/nd  11.74574  12.23075  15.07401  12.66056
##         uq       max neval
##  408.24988 457.77886   100
##   15.08655 132.71868   100
##   14.49393  36.51357   100
##   14.35134  36.08905   100
##   13.62265  36.55835   100
```

![](eval_next_files/figure-html/benchmarks1-1.png) 


```
## Unit: milliseconds
##                expr       min        lq      mean    median        uq
##    mean(v[dat.ind]) 13.210570 14.153849 16.186283 14.371242 15.165549
##  sum(v[dat.ind])/nd 11.700951 12.644851 14.871945 12.866910 13.469482
##             mean(d)  2.945221  2.976476  3.086633  3.007887  3.094504
##           sum(d)/nd  1.483496  1.500601  1.583292  1.516773  1.573999
##         max neval
##  134.808017  1000
##   47.060690  1000
##    4.647663  1000
##    3.920222  1000
```

![](eval_next_files/figure-html/benchmarks2-1.png) 
