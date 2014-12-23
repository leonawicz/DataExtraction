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
##                mean(v, na.rm = T) 393.68586 395.10932 404.52179 397.43296
##                  mean(v[dat.ind])  13.85729  14.06022  15.85771  14.14715
##                sum(v[dat.ind])/nd  12.40554  12.57301  14.55129  12.63770
##       .Internal(mean(v[dat.ind]))  13.83086  13.97905  15.51085  14.06442
##  .Primitive("sum")(v[dat.ind])/nd  12.45405  12.56524  15.23804  12.65247
##         uq       max neval
##  409.96617 512.88401   100
##   14.43420  38.15988   100
##   12.82694  37.51175   100
##   14.23905  38.25473   100
##   12.96254  36.27708   100
```

![](eval_next_files/figure-html/benchmarks1-1.png) 


```
## Unit: milliseconds
##                expr       min        lq      mean    median        uq
##    mean(v[dat.ind]) 13.910163 14.068307 15.836762 14.112624 14.186799
##  sum(v[dat.ind])/nd 12.419843 12.567880 14.313123 12.611731 12.691659
##             mean(d)  2.947361  2.965710  3.001732  2.980016  3.007850
##           sum(d)/nd  1.482233  1.493429  1.518239  1.500271  1.515354
##         max neval
##  131.861508  1000
##  128.139443  1000
##    4.179860  1000
##    2.301721  1000
```

![](eval_next_files/figure-html/benchmarks2-1.png) 
