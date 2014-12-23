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
##                mean(v, na.rm = T) 392.50592 394.21845 400.93451 395.11149
##                  mean(v[dat.ind])  13.12862  13.89492  14.85572  13.99102
##                sum(v[dat.ind])/nd  11.65385  12.42357  15.14220  12.51610
##       .Internal(mean(v[dat.ind]))  12.94233  13.84299  14.83546  13.91483
##  .Primitive("sum")(v[dat.ind])/nd  11.62679  12.42591  14.18133  12.50257
##         uq       max neval
##  406.94401 500.56525   100
##   14.11076  34.66920   100
##   12.62961 136.77409   100
##   13.97392  38.29361   100
##   12.59214  33.32972   100
```

![](eval_next_files/figure-html/benchmarks1-1.png) 


```
## Unit: milliseconds
##                expr       min        lq      mean    median        uq
##    mean(v[dat.ind]) 11.553082 13.926645 15.562461 14.014658 14.159274
##  sum(v[dat.ind])/nd 11.536910 12.445968 14.047323 12.519986 12.650451
##             mean(d)  2.938342  2.946117  3.007334  2.951715  2.985769
##           sum(d)/nd  1.477879  1.482233  1.518270  1.488453  1.494829
##         max neval
##  125.657962  1000
##  123.428393  1000
##    6.570528  1000
##    2.412438  1000
```

![](eval_next_files/figure-html/benchmarks2-1.png) 
