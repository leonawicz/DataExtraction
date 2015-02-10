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
##                mean(v, na.rm = T) 396.47883 397.82827 406.17620 400.14353
##                  mean(v[dat.ind])  13.90274  14.20379  16.13493  14.29787
##                sum(v[dat.ind])/nd  12.50043  12.67972  14.83503  12.73974
##       .Internal(mean(v[dat.ind]))  13.85267  14.12884  17.53939  14.21576
##  .Primitive("sum")(v[dat.ind])/nd  12.42454  12.69061  14.86212  12.77971
##         uq       max neval
##  413.33920 460.99813   100
##   14.48043  39.90315   100
##   12.93490  37.49413   100
##   14.61431 129.31290   100
##   13.10424  37.06526   100
```

![](eval_next_files/figure-html/benchmarks1-1.png) 


```
## Unit: milliseconds
##                expr       min        lq      mean    median        uq
##    mean(v[dat.ind]) 13.966493 14.197724 16.128581 14.275008 14.388991
##  sum(v[dat.ind])/nd 12.430764 12.685009 14.343592 12.755917 12.860413
##             mean(d)  2.957944  2.998063  3.035984  3.017034  3.045491
##           sum(d)/nd  1.485037  1.508673  1.541806  1.523446  1.541484
##         max neval
##  128.881233  1000
##  127.381268  1000
##    4.004467  1000
##    3.351673  1000
```

![](eval_next_files/figure-html/benchmarks2-1.png) 
