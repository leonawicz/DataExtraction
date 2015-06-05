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
##                          expr    min     lq      mean median     uq
##  sum(s005pct)/length(s005pct)  4.976  5.288  5.521645  5.288  5.288
##  sum(s010pct)/length(s010pct)  9.641  9.642 10.169470  9.953  9.953
##  sum(s025pct)/length(s025pct) 23.325 23.326 24.262944 23.637 23.637
##  sum(s100pct)/length(s100pct) 91.745 92.057 95.724352 92.057 92.368
##       max neval
##   171.984 10000
##   192.820 10000
##   361.072 10000
##  9139.966 10000
```

![](eval_res_files/figure-html/benchmarks3-1.png) 

Using optimal subsampling to estimate the mean achieves speed improvements orders of magnitude greater than what can be achieved through strictly algorithmic changes to how the mean is computed on the full dataset,
though those help immensely as well, also by many orders of magnitude.
Sampling is vastly more effective, but both approaches can be combined for maximum benefit.


```
## Unit: microseconds
##                          expr        min          lq         mean
##  sum(s005pct)/length(s005pct)      4.977      6.9985     10.64652
##            mean(v, na.rm = T) 328957.260 332340.3125 338498.96803
##              sum(d)/length(d)   1504.617   1517.0565   1554.37041
##                 mean(s005pct)     14.618     16.4840     37.43600
##       median         uq        max neval
##       9.3310     10.575     19.905   100
##  333486.0350 345901.603 357516.969   100
##    1526.5415   1543.492   2186.950   100
##      44.6295     50.383    100.765   100
```

```
## Unit: microseconds
##                          expr        min          lq         mean
##  sum(s005pct)/length(s005pct)      4.977      6.9985     10.64652
##            mean(v, na.rm = T) 328957.260 332340.3125 338498.96803
##              sum(d)/length(d)   1504.617   1517.0565   1554.37041
##                 mean(s005pct)     14.618     16.4840     37.43600
##       median         uq        max neval
##       9.3310     10.575     19.905   100
##  333486.0350 345901.603 357516.969   100
##    1526.5415   1543.492   2186.950   100
##      44.6295     50.383    100.765   100
```

```
## Unit: microseconds
##                          expr        min          lq         mean
##  sum(s005pct)/length(s005pct)      4.977      6.9985     10.64652
##            mean(v, na.rm = T) 328957.260 332340.3125 338498.96803
##              sum(d)/length(d)   1504.617   1517.0565   1554.37041
##                 mean(s005pct)     14.618     16.4840     37.43600
##       median         uq        max neval
##       9.3310     10.575     19.905   100
##  333486.0350 345901.603 357516.969   100
##    1526.5415   1543.492   2186.950   100
##      44.6295     50.383    100.765   100
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
