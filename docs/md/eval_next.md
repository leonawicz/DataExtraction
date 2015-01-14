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
##                mean(v, na.rm = T) 392.99513 394.43071 400.31757 395.33059
##                  mean(v[dat.ind])  13.24151  14.03099  15.86505  14.09039
##                sum(v[dat.ind])/nd  11.65945  12.51734  13.88396  12.57037
##       .Internal(mean(v[dat.ind]))  13.15816  13.94795  15.56267  14.00098
##  .Primitive("sum")(v[dat.ind])/nd  11.78354  12.53725  15.39732  12.59525
##         uq       max neval
##  409.14232 417.41217   100
##   14.16721 124.87611   100
##   12.63381  36.23882   100
##   14.08495  37.44551   100
##   12.65838 124.72123   100
```

![](eval_next_files/figure-html/benchmarks1-1.png) 


```
## Unit: milliseconds
##                expr       min        lq      mean    median        uq
##    mean(v[dat.ind]) 13.121464 14.090699 16.192409 14.269369 14.885930
##  sum(v[dat.ind])/nd 11.647627 12.610644 14.755189 12.793668 13.407429
##             mean(d)  2.947673  2.977996  3.080655  3.012672  3.073939
##           sum(d)/nd  1.483167  1.499650  1.569516  1.516289  1.562162
##         max neval
##  130.332315  1000
##  139.616330  1000
##    7.570088  1000
##    2.691718  1000
```

![](eval_next_files/figure-html/benchmarks2-1.png) 
