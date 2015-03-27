# Data Extraction Evaluation
Matthew Leonawicz  



#### Results

##### All points? No point.

Using the sample mean is helpful as a data reduction strategy while not being harmful in terms of representativeness.
The possible "tradeoff" itself appears to be largely a false dichotomy.
There is no benefit to computing the mean of all pixels in the example map layer.

##### How many samples do we really need?

![](eval_res_files/figure-html/sigdig-1.png) 

In this example even a two percent subsample of the original non-NA data cells is small enough to limit us to a five percent probability of obtaining a mean that differs from the mean computed on the full dataset
by an amount equal to or greater than the smallest discrete increment possible (0.1 degrees Celsius for SNAP temperature data) based simply on the number of significant figures present.
Furthermore, even for nominal sample sizes, the 0.05 probability is one almost strictly of minimal deviation (0.1 degrees).
The probability that a sample mean computed on a subsample of the map layer deviates enough from the population mean
to cause it to be rounded to two discrete incremental units from the population mean (0.2 degrees) is essentially zero (except if using crudely small sample sizes).

Although a two percent subsample appears sufficient for this criterion, letâ€™s use a five percent subsample for illustration.
This is clearly overkill in this example since the p-value attenuates to the range of 0.019 to 0.029 by around 2.5 percent subsampling.

##### How much faster does this make things go?

Compute time for the mean is of course affected by the sample size.




```
## Unit: microseconds
##                          expr    min     lq     mean median     uq     max
##  sum(s005pct)/length(s005pct)  4.977  5.288  5.91272  5.599  5.599  97.035
##  sum(s010pct)/length(s010pct)  9.642  9.953 10.73492  9.953 10.264 476.772
##  sum(s025pct)/length(s025pct) 23.326 23.637 25.14469 23.638 23.949 992.418
##  sum(s100pct)/length(s100pct) 92.058 92.369 96.74378 92.370 93.303 604.284
##  neval
##  10000
##  10000
##  10000
##  10000
```

![](eval_res_files/figure-html/benchmarks3-1.png) 

Using optimal subsampling to estimate the mean achieves speed improvements orders of magnitude greater than what can be achieved through strictly algorithmic changes to how the mean is computed on the full dataset,
though those help immensely as well, also by many orders of magnitude.
Sampling is vastly more effective, but both approaches can be combined for maximum benefit.


```
## Unit: microseconds
##                          expr        min          lq         mean
##  sum(s005pct)/length(s005pct)      5.599      6.0655     12.04002
##            mean(v, na.rm = T) 394803.414 400618.1245 413228.42811
##              sum(d)/length(d)   1487.539   1497.1800   1566.62766
##                 mean(s005pct)     17.728     20.5270     46.71396
##      median         uq        max neval
##       9.798     19.594     29.547   100
##  408871.581 421030.797 532075.836   100
##    1509.776   1567.157   2030.554   100
##      54.738     63.757     92.058   100
```

```
## Unit: microseconds
##                          expr        min          lq         mean
##  sum(s005pct)/length(s005pct)      5.599      6.0655     12.04002
##            mean(v, na.rm = T) 394803.414 400618.1245 413228.42811
##              sum(d)/length(d)   1487.539   1497.1800   1566.62766
##                 mean(s005pct)     17.728     20.5270     46.71396
##      median         uq        max neval
##       9.798     19.594     29.547   100
##  408871.581 421030.797 532075.836   100
##    1509.776   1567.157   2030.554   100
##      54.738     63.757     92.058   100
```

```
## Unit: microseconds
##                          expr        min          lq         mean
##  sum(s005pct)/length(s005pct)      5.599      6.0655     12.04002
##            mean(v, na.rm = T) 394803.414 400618.1245 413228.42811
##              sum(d)/length(d)   1487.539   1497.1800   1566.62766
##                 mean(s005pct)     17.728     20.5270     46.71396
##      median         uq        max neval
##       9.798     19.594     29.547   100
##  408871.581 421030.797 532075.836   100
##    1509.776   1567.157   2030.554   100
##      54.738     63.757     92.058   100
```

![](eval_res_files/figure-html/benchmarks4-1.png) 

Similar to above, below are the median compute times for the mean using (1) the full data while removing NAs, (2) the sum divided by the length after NAs removed, (3) the mean of a subsample, and (4) a combination of (2) and (3).

![](eval_res_files/figure-html/benchmarks4med1-1.png) 

Here is the same plot after removing the first bar to better show the relative compute time for the other three methods.

![](eval_res_files/figure-html/benchmarks4med2-1.png) 

How does the benefit extend to extractions on maps at different extents, data heterogeneity, climate variables,
or for other common statistics such as the standard deviation?
These are open questions at the moment, but for one thing,
I expect more samples are needed for precipitation than temperature.
I also expect more samples needed to estimate parameters with higher moments.
