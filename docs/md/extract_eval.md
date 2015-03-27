# Data Extraction Evaluation
Matthew Leonawicz  



## Statistical sampling for spatial data extraction

### Motivation: Data processing efficiency

We've gotten faster at SNAP, but so has our need for speed. What was once never bothered with (outside some of my own work),
using statistical sampling to obtain results at no cost to validity, accuracy or precision compared to a census of our data,
is now more relevant than ever.
Before, we were content to let a process run in the background for hours and look at the results when done.
There was little incentive to incorporate techniques like those laid out here.
Now we have more types of data delivery and presentation, e.g., web applications, where it is intended for there to be a human watching and waiting for data processing to occur.

#### Assumptions, bad ones
An assumption I often encounter from those outside statistics, but involved in "big data" is that with today's processing power there is no reason not to use all the data.
A corollary of this is that many statistical methods can be dispensed with,
which is based on another assumption that this is what statistics basically exists for;
to help us hobble along when we were in the stone age.
However, both of these views are flawed.
The latter suggests little knowledge of the broad uses of statistics.
The former suggests little knowledge of statistics period, or the myriad ways data can be improperly analyzed and results interpreted.

#### Speed not for speed's sake
Making things go faster is perhaps the last area of application I would ever find for statistical methods,
and since not a lot of traditional statistical analysis occurs at SNAP I do not want those untrained in statistics to get the wrong impression that speed improvements are all statistics is really good for.
But it is relevant and beneficial in the context of some of our workflows, particularly my own.
But I am also not the only one extracting and processing large amounts of data at SNAP.
One use of statistics is data reduction.
This is what I aim for when needing to "get things done faster," not really the speed itself.
I'd rather see a decrease in computational time required for large data processing occur as a latent consequence of smart application of statistical methods than as something forced for its own sake.
I will outline a simple and extremely common case.

### Case study: sample mean

Example of population mean vs. sample mean for a typical map of SNAP's Alaska-Canada 2-km downscaled data.
The sample mean converges in distribution to the population mean quite quickly.


```r
no.knit <- if ("knitr" %in% names(sessionInfo()$otherPkgs)) FALSE else TRUE
library(raster)
library(microbenchmark)
library(ggplot2)
library(reshape2)
```


```r
setwd("C:/github/DataExtraction/data")
# testfile <-
# 'Z:/Base_Data/ALFRESCO_formatted/ALFRESCO_Master_Dataset/ALFRESCO_Model_Input_Datasets/AK_CAN_Inputs/Climate/gfdl_cm2_1/sresa2/tas/tas_mean_C_alf_ar4_gfdl_cm2_1_sresa2_01_2045.tif'
testfile <- "tas_mean_C_AR5_GFDL-CM3_rcp60_01_2062.tif"

r <- readAll(raster(testfile))  # force into memory so I/O time does not confound extraction time
v <- getValues(r)  # numeric vector
dat.ind <- Which(!is.na(r), cells = T)
d <- v[dat.ind]  # numeric vector of data values (drop NAs)
nd <- length(dat.ind)
```


```r
# continue indexing v since this is how it will tend to occur in practice
# take mean of all cells
mean(v, na.rm = T)
```

```
## [1] -12.7623
```

```r
# take mean of only the data cells
mean(v[dat.ind])
```

```
## [1] -12.7623
```

```r
# take mean of only the data cells using sum and known length
sum(v[dat.ind])/nd
```

```
## [1] -12.7623
```

```r
# take mean of data cells with .Internal
.Internal(mean(v[dat.ind]))
```

```
## [1] -12.7623
```

```r
# take mean of data cells with .Internal sum, known length
.Primitive("sum")(v[dat.ind])/nd
```

```
## [1] -12.7623
```


```r
mean.pop <- sum(d)/nd
mean.pop.out <- round(mean.pop, 1)  # round to one decimal place for temperature data
discrete.out <- round(seq(mean.pop, mean.pop + 0.4, by = 0.1) - 0.2, 1)
# median.pop <- median(d) median.pop.out <- round(median.pop, 1) # round to
# one decimal place for temperature data
bounds.round <- mean.pop.out + c(-0.05, 0.05)  # within rounding distance of the rounded population mean
bounds.signif <- mean.pop + c(-0.1, 0.1)  # bounds on the unrounded population mean at the significant digits distance
# Use sample mean
n <- 1e+05
m <- 100
keep <- seq(1000, n, by = 1000)  # burn in and thin to facilitate visualization

set.seed(47)
d.sub <- replicate(m, sample(d, n, replace = F))
means <- data.frame(1:n, (1:n)/nd, apply(d.sub, 2, function(x, n) cumsum(x)/(1:n), 
    n = n))
names(means) <- c("Size", "Percent_Sample", paste0("Sample_", c(paste0(0, 0:9), 
    10:m)[1:m]))
means <- means[keep, ]
p <- data.frame(Size = keep, Percent_Sample = keep/nd, P_value = 1 - apply(means, 
    1, function(x) length(which(x >= bounds.signif[1] & x < bounds.signif[2]))/length(x)))
means <- melt(means, id.vars = c("Size", "Percent_Sample"), variable.name = c("Sample"), 
    value.name = "Mean")
p <- melt(p, id.vars = c("Size", "Percent_Sample"), variable.name = c("Type"), 
    value.name = "Pval")

clr <- c(Samples = "gray", `Pop. mean +/- 1 sig. fig.` = "blue", `Rounded pop. mean` = "red", 
    `Possible rounded values` = "black")
```


```r
if (no.knit) png("../plots/mean_by_size.png", width = 2000, height = 1600, res = 200)
g <- ggplot(means, aes(x = Percent_Sample, y = Mean, group = Sample)) + theme_bw() + 
    geom_line(aes(colour = "Samples")) + geom_hline(aes(yintercept = d, colour = "Rounded pop. mean"), 
    data = data.frame(d = mean.pop.out)) + geom_hline(aes(yintercept = d, colour = c("Pop. mean +/- 1 sig. fig.")), 
    data = data.frame(d = bounds.signif)) + geom_hline(aes(yintercept = d, colour = "Possible rounded values"), 
    , data = data.frame(d = discrete.out[2:5]), linetype = 2) + scale_colour_manual(name = "hello", 
    values = clr) + theme(legend.position = "bottom") + labs(title = "Sample mean ~ sample size")
print(g)
```

![](extract_eval_files/figure-html/size-1.png) 

```r
if (no.knit) dev.off()
```

#### Justification

The difference between sampling vs. using all data in a map layer is minimal.
It depends on various factors including but not limited to the statistic of interest, the spatial autocorrelation present in the map, and whether the entire map is of interest or just a particular region of a certain size.

In this example using the sample mean instead of the population mean, the difference is representative.
The difference is also not particularly meaningful.
It is also not final, as it tends to vanish anyway due to rounding to the nearest significant digits for the data after the statistic is computed.
The difference in means can also be bounded arbitrarily even without the rounding to significant digits performed at the end.

In the case of the mean we are helped out by the weak law of large numbers and the central limit theorem.
Consideration must also be given to the high level of spatial autocorrelation among pixels in the downscaled raster maps.
There is simply not as much data or information present as one might think and this drives the effective sample size.
 
#### Results

##### All points? No point.

Using the sample mean is helpful as a data reduction strategy while not being harmful in terms of representativeness.
The possible "tradeoff" itself appears to be largely a false dichotomy.
There is no benefit to computing the mean of all pixels in the example map layer.

##### How many samples do we really need?


```r
if (no.knit) png("../plots/pvalue_sigdig.png", width = 2000, height = 2000, 
    res = 200)
g <- ggplot(p, aes(x = Percent_Sample, y = Pval, group = Type, colour = Type)) + 
    theme_bw() + geom_line(colour = "black")
g <- g + geom_hline(aes(yintercept = 0.05, linetype = "P-value = 0.05"), colour = "red", 
    linetype = 2) + annotate("text", 0.005, 0.05 * 1.2, label = "P-value = 0.05", 
    size = 3)
g <- g + labs(title = "P(abs(sample mean - pop. mean) > 1 sig. digit | sample size)")
print(g)
```

![](extract_eval_files/figure-html/sigdig-1.png) 

```r
if (no.knit) dev.off()
```

In this example even a two percent subsample of the original non-NA data cells is small enough to limit us to a five percent probability of obtaining a mean that differs from the mean computed on the full dataset
by an amount equal to or greater than the smallest discrete increment possible (0.1 degrees Celsius for SNAP temperature data) based simply on the number of significant figures present.
Furthermore, even for nominal sample sizes, the 0.05 probability is one almost strictly of minimal deviation (0.1 degrees).
The probability that a sample mean computed on a subsample of the map layer deviates enough from the population mean
to cause it to be rounded to two discrete incremental units from the population mean (0.2 degrees) is essentially zero (except if using crudely small sample sizes).

Although a two percent subsample appears sufficient for this criterion, letâ€™s use a five percent subsample for illustration.
This is clearly overkill in this example since the p-value attenuates to the range of 0.019 to 0.029 by around 2.5 percent subsampling.

##### How much faster does this make things go?

Compute time for the mean is of course affected by the sample size.


```r
# compute time for means for different sample size
s005pct <- d.sub[1:round((nrow(d.sub) * 0.05)), 1]
s010pct <- d.sub[1:round((nrow(d.sub) * 0.1)), 1]
s025pct <- d.sub[1:round((nrow(d.sub) * 0.25)), 1]
s100pct <- d.sub[, 1]
```


```r
mb3 <- microbenchmark(sum(s005pct)/length(s005pct), sum(s010pct)/length(s010pct), 
    sum(s025pct)/length(s025pct), sum(s100pct)/length(s100pct), times = 10000)
mb3
```

```
## Unit: microseconds
##                          expr    min     lq      mean median     uq
##  sum(s005pct)/length(s005pct)  5.288  5.288  5.621956  5.599  5.599
##  sum(s010pct)/length(s010pct)  9.642  9.953 10.263679  9.953 10.264
##  sum(s025pct)/length(s025pct) 23.326 23.637 25.124662 23.948 23.949
##  sum(s100pct)/length(s100pct) 92.058 92.369 93.851933 92.370 92.681
##       max neval
##    91.748 10000
##   347.083 10000
##  9257.072 10000
##  2055.123 10000
```

```r
if (no.knit) png("../plots/benchmark3.png", width = 2000, height = 1600, res = 200)
autoplot(mb3) + theme_bw() + labs(title = "Compute time for mean by sample size", 
    y = "Function")
```

![](extract_eval_files/figure-html/benchmarks3-1.png) 

```r
if (no.knit) dev.off()
```

Using optimal subsampling to estimate the mean achieves speed improvements orders of magnitude greater than what can be achieved through strictly algorithmic changes to how the mean is computed on the full dataset,
though those help immensely as well, also by many orders of magnitude.
Sampling is vastly more effective, but both approaches can be combined for maximum benefit.


```r
mb4 <- microbenchmark(sum(s005pct)/length(s005pct), mean(v, na.rm = T), sum(d)/length(d), 
    mean(s005pct), times = 100)
mb4
```

```
## Unit: microseconds
##                          expr        min          lq         mean
##  sum(s005pct)/length(s005pct)      5.288      7.1540     11.09769
##            mean(v, na.rm = T) 394653.510 396898.3460 405652.72947
##              sum(d)/length(d)   1483.495   1495.7805   1536.17711
##                 mean(s005pct)     18.039     20.2165     46.38746
##       median         uq        max neval
##       9.6420     11.197     21.461   100
##  399774.6775 413095.498 510661.571   100
##    1505.2660   1542.742   2180.148   100
##      59.5585     63.757     77.442   100
```

```r
med <- print(mb4)$median
```

```
## Unit: microseconds
##                          expr        min          lq         mean
##  sum(s005pct)/length(s005pct)      5.288      7.1540     11.09769
##            mean(v, na.rm = T) 394653.510 396898.3460 405652.72947
##              sum(d)/length(d)   1483.495   1495.7805   1536.17711
##                 mean(s005pct)     18.039     20.2165     46.38746
##       median         uq        max neval
##       9.6420     11.197     21.461   100
##  399774.6775 413095.498 510661.571   100
##    1505.2660   1542.742   2180.148   100
##      59.5585     63.757     77.442   100
```

```r
names(med) <- print(mb4)$expr
```

```
## Unit: microseconds
##                          expr        min          lq         mean
##  sum(s005pct)/length(s005pct)      5.288      7.1540     11.09769
##            mean(v, na.rm = T) 394653.510 396898.3460 405652.72947
##              sum(d)/length(d)   1483.495   1495.7805   1536.17711
##                 mean(s005pct)     18.039     20.2165     46.38746
##       median         uq        max neval
##       9.6420     11.197     21.461   100
##  399774.6775 413095.498 510661.571   100
##    1505.2660   1542.742   2180.148   100
##      59.5585     63.757     77.442   100
```

```r
med <- med[c(1, 4:2)]

if (no.knit) png("../plots/benchmark4.png", width = 2000, height = 1600, res = 200)
autoplot(mb4) + theme_bw() + labs(title = "Compute time for mean | sampling and/or function change", 
    y = "Function")
```

![](extract_eval_files/figure-html/benchmarks4-1.png) 

```r
if (no.knit) dev.off()
```

Similar to above, below are the median compute times for the mean using (1) the full data while removing NAs, (2) the sum divided by the length after NAs removed, (3) the mean of a subsample, and (4) a combination of (2) and (3).


```r
if (no.knit) png("../plots/benchmark4medians.png", width = 2000, height = 1000, 
    res = 200)
ggplot(data.frame(x = names(med), y = med), aes(x = reorder(x, 1:length(x), 
    function(z) z), y = y, colour = x)) + geom_bar(stat = "identity", size = 0.5, 
    width = 0.9) + theme_bw() + theme(legend.position = "none", axis.ticks = element_blank(), 
    axis.text.y = element_blank()) + scale_colour_manual(values = c("gray", 
    "dodgerblue", "orange", "purple")[c(3, 1, 2, 4)]) + labs(title = "Compute time for mean | sampling and/or function change", 
    x = "Function +/- sampling", y = "Time [microseconds]") + annotate("text", 
    x = (1:4) - 0.2, y = 20000, label = names(med), size = 4, hjust = 0, colour = c(rep("black", 
        3), "white")) + coord_flip()
```

![](extract_eval_files/figure-html/benchmarks4med1-1.png) 

```r
if (no.knit) dev.off()
```

Here is the same plot after removing the first bar to better show the relative compute time for the other three methods.


```r
if (no.knit) png("../plots/benchmark4medians2.png", width = 2000, height = 1000, 
    res = 200)
ggplot(data.frame(x = names(med)[-4], y = med[-4]), aes(x = reorder(x, 1:length(x), 
    function(z) z), y = y, colour = x)) + geom_bar(stat = "identity", size = 0.5, 
    width = 0.9) + theme_bw() + theme(legend.position = "none", axis.ticks = element_blank(), 
    axis.text.y = element_blank()) + scale_colour_manual(values = c("dodgerblue", 
    "orange", "purple")[c(2, 1, 3)]) + labs(title = "Compute time for mean | sampling and/or function change", 
    x = "Function +/- sampling", y = "Time [microseconds]") + annotate("text", 
    x = (1:(4 - 1)) - 0.2, y = 125, label = names(med)[-4], size = 4, hjust = 0, 
    colour = c(rep("black", 3 - 1), "white")) + coord_flip()
```

![](extract_eval_files/figure-html/benchmarks4med2-1.png) 

```r
if (no.knit) dev.off()
```

How does the benefit extend to extractions on maps at different extents, data heterogeneity, climate variables,
or for other common statistics such as the standard deviation?
These are open questions at the moment, but for one thing,
I expect more samples are needed for precipitation than temperature.
I also expect more samples needed to estimate parameters with higher moments.

### Next steps

Combining sampling and data reduction methods while using the most efficient **R** functions can be particularly useful when processing large numbers of high-resolution geotiff raster layers.
One thing I already do when extracting from many files by shapefile is I avoid extracting by shape more than once.
I do it one time to obtain the corresponding raster layer cell indices.
Then on all subsequent maps I extract by cell indices which is notably faster.
Ultimately, there is much more room for speed improvements in terms of efficient use of statistics than in strictly programmatic corner-cutting.

The plots below benchmark different sample mean computations.
Comparisons involve the sample mean of the entire data set and do not involve the main approach outlined above which focuses on efficiency gains by taking the mean of a smaller, representative sample.
This provides some insight into how it is beneficial nonetheless to considering the right programmatic approach in conjunction with statistical efficiencies.


```r
mb <- microbenchmark(mean(v, na.rm = T), mean(v[dat.ind]), sum(v[dat.ind])/nd, 
    .Internal(mean(v[dat.ind])), .Primitive("sum")(v[dat.ind])/nd, times = 100)
mb
```

```
## Unit: milliseconds
##                              expr       min        lq      mean    median
##                mean(v, na.rm = T) 395.13370 396.57692 404.49644 397.88283
##                  mean(v[dat.ind])  11.79083  14.00006  15.84217  14.10347
##                sum(v[dat.ind])/nd  11.72179  12.48126  13.67419  12.60458
##       .Internal(mean(v[dat.ind]))  13.08181  13.89680  14.89434  13.98528
##  .Primitive("sum")(v[dat.ind])/nd  11.70624  12.47971  13.71615  12.61157
##         uq       max neval
##  413.04838 511.07863   100
##   14.38011  38.15008   100
##   12.78885  36.10895   100
##   14.16038  36.59630   100
##   12.77283  35.51680   100
```

```r
if (no.knit) png("../plots/benchmark1.png", width = 2000, height = 1600, res = 200)
autoplot(mb) + theme_bw() + labs(title = "Comparisons of time to index data and compute mean", 
    y = "Function")
```

![](extract_eval_files/figure-html/benchmarks1-1.png) 

```r
if (no.knit) dev.off()
```


```r
mb2 <- microbenchmark(mean(v[dat.ind]), sum(v[dat.ind])/nd, mean(d), sum(d)/nd, 
    times = 1000)
mb2
```

```
## Unit: milliseconds
##                expr       min        lq      mean    median        uq
##    mean(v[dat.ind]) 13.170140 14.061014 15.844107 14.168622 14.300487
##  sum(v[dat.ind])/nd 11.666740 12.577985 14.090884 12.673931 12.796623
##             mean(d)  2.947397  2.962325  3.009975  2.973522  3.006645
##           sum(d)/nd  1.484429  1.495004  1.524016  1.501223  1.514441
##         max neval
##  129.051621  1000
##  138.554697  1000
##    4.407256  1000
##    2.122301  1000
```

```r
if (no.knit) png("../plots/benchmark2.png", width = 2000, height = 1600, res = 200)
autoplot(mb2) + theme_bw() + labs(title = "Comparisons of time to compute mean", 
    y = "Function")
```

![](extract_eval_files/figure-html/benchmarks2-1.png) 

```r
if (no.knit) dev.off()
```
