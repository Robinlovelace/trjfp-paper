``` r
# aim: extract regional stats from data                                          
                                                                                 
# setup -------------------------------------------------------------------      
                                                                                 
setwd("/home/robin/paper-repos/trjfp-paper/")                                    
library(future)                                                                  
plan("multisession")                                                             
library(tidyverse)                                                               
#> ── Attaching packages ───────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✔ ggplot2 2.2.1.9000     ✔ purrr   0.2.5     
#> ✔ tibble  1.4.2          ✔ dplyr   0.7.5     
#> ✔ tidyr   0.8.1          ✔ stringr 1.3.1     
#> ✔ readr   1.1.1          ✔ forcats 0.3.0
#> ── Conflicts ──────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
devtools::install_github("robinlovelace/ukboundaries")                           
#> Using GitHub PAT from envvar GITHUB_PAT
#> Skipping install of 'ukboundaries' from a github remote, the SHA1 (1d162f0d) has not changed since last install.
#>   Use `force = TRUE` to force installation
library(ukboundaries)                                                            
#> Loading required package: sf
#> Linking to GEOS 3.5.1, GDAL 2.2.2, proj.4 4.9.2
#> Using default data cache directory ~/.ukboundaries/cache 
#> Use cache_dir() to change it.
#> Contains National Statistics data © Crown copyright and database right2018
#> Contains OS data © Crown copyright and database right, 2018
#> See https://www.ons.gov.uk/methodology/geography/licences
# run these lines in bash on Ubuntu or manually unrar pre-downloaded files:      
# sudo apt-get install p7zip-rar                                                 
# 7z x AllInterceptsToDate.rar                                                   
# d %<-% gdata::read.xls("AllInterceptsToDate.xls")                              
# d = as_tibble(d)                                                               
# saveRDS(d, "AllInterceptsToDate.rds")                                          
d = readRDS("AllInterceptsToDate.rds")                                           
d$DateIntercepted = lubridate::as_date(d$DateIntercepted)                        
                                                                                 
# sanity checks and viz ---------------------------------------------------      
                                                                                 
# summary of the data                                                            
dim(d)                                                                           
#> [1] 65535    10
summary(d)                                                                       
#>      CafeId                                                 Cafe      
#>  Min.   : 3.00   Sharehouse Leeds                             :29293  
#>  1st Qu.:10.00   Armley Junk-tion                             : 7185  
#>  Median :10.00   Cafe Abundance                               : 3783  
#>  Mean   :19.09   Moortown Junk-tion                           : 3681  
#>  3rd Qu.:18.00   TRJFP Plymouth                               : 3335  
#>  Max.   :83.00   Bethesda ‘PAYF’ Cafe – Caffi Cyfrannu i Rannu: 2333  
#>                  (Other)                                      :15925  
#>              County          IsOpen       IsFoodBoutique  
#>  England        :29293   Min.   :0.0000   Min.   :0.0000  
#>  UK             : 7185   1st Qu.:0.0000   1st Qu.:0.0000  
#>  West Yorkshire : 5380   Median :0.0000   Median :0.0000  
#>  Cornwall       : 3783   Mean   :0.3364   Mean   :0.2679  
#>                 : 3335   3rd Qu.:1.0000   3rd Qu.:1.0000  
#>  South Yorkshire: 2736   Max.   :1.0000   Max.   :1.0000  
#>  (Other)        :13823                                    
#>  DateIntercepted         Quantity            IsWeight     
#>  Min.   :2016-02-10   Min.   :        0   Min.   :0.0000  
#>  1st Qu.:2016-12-24   1st Qu.:      650   1st Qu.:1.0000  
#>  Median :2017-09-29   Median :     2500   Median :1.0000  
#>  Mean   :2017-06-17   Mean   :    43136   Mean   :0.9896  
#>  3rd Qu.:2018-02-13   3rd Qu.:     8100   3rd Qu.:1.0000  
#>  Max.   :2018-09-10   Max.   :100000000   Max.   :1.0000  
#>                                                           
#>              Product            Company     
#>  Unknown         : 4733   Morrisons :16195  
#>  Bread           : 4599   Ocado     : 7130  
#>  POTATOES        : 1810   Co-op     : 4541  
#>  MIXED VEGETABLES: 1229   M&S       : 2552  
#>  Cakes           : 1211   farm foods: 2346  
#>  BANANAS         : 1013   Sainsburys: 1666  
#>  (Other)         :50940   (Other)   :31105
                                                                                 
# cafes by number of items - with at least n items:                              
n = 50                                                                           
cafes_working = d %>%                                                            
group_by(Cafe) %>%                                                               
summarise(n = n()) %>%                                                           
arrange(desc(n)) %>%                                                             
filter(n > 50)                                                                   
cafes_working                                                                    
#> # A tibble: 30 x 2
#>    Cafe                                              n
#>    <fct>                                         <int>
#>  1 Sharehouse Leeds                              29293
#>  2 Armley Junk-tion                               7185
#>  3 Cafe Abundance                                 3783
#>  4 Moortown Junk-tion                             3681
#>  5 TRJFP Plymouth                                 3335
#>  6 Bethesda ‘PAYF’ Cafe – Caffi Cyfrannu i Rannu  2333
#>  7 TRJFP Sheffield                                2164
#>  8 Elsie's Cafe                                   2065
#>  9 Fur Clemt                                      1394
#> 10 TRJFP Birmingham                               1288
#> # ... with 20 more rows
                                                                                 
d = d %>% filter(Cafe %in% cafes_working$Cafe)                                   
                                                                                 
# filter-out very large quantities - more than 50 tonnes - most say 100 Tonnes   
max_quantity = 50e6                                                              
d %>% filter(Quantity > max_quantity)                                            
#> # A tibble: 13 x 10
#>    CafeId Cafe      County  IsOpen IsFoodBoutique DateIntercepted Quantity
#>     <int> <fct>     <fct>    <int>          <int> <date>             <int>
#>  1     10 Sharehou… England      0              0 2018-05-12        8.70e7
#>  2     47 TRJFP Br… East S…      1              0 2018-03-18        1.00e8
#>  3     10 Sharehou… England      0              0 2018-03-13        1.00e8
#>  4     10 Sharehou… England      0              0 2018-03-13        1.00e8
#>  5     10 Sharehou… England      0              0 2018-03-13        1.00e8
#>  6     10 Sharehou… England      0              0 2018-03-13        1.00e8
#>  7     10 Sharehou… England      0              0 2018-03-13        1.00e8
#>  8     57 testing   uk           0              0 2018-02-19        1.00e8
#>  9     10 Sharehou… England      0              0 2018-02-19        8.30e7
#> 10     57 testing   uk           0              0 2018-02-19        1.00e8
#> 11     57 testing   uk           0              0 2018-02-19        1.00e8
#> 12     57 testing   uk           0              0 2018-02-19        1.00e8
#> 13     57 testing   uk           0              0 2018-02-19        1.00e8
#> # ... with 3 more variables: IsWeight <int>, Product <fct>, Company <fct>
d = d %>% filter(Quantity < max_quantity)                                        
                                                                                 
# filter-out quantities that are not weights (for now)                           
d = d %>% filter(IsWeight == 1)                                                  
                                                                                 
# separate large from small cafes                                                
# plot(cafes_working$n) # most productive: top 10                                
large_cafe = cafes_working$Cafe[1:5] %>%                                         
as.character()                                                                   
d$Cafes = d$Cafe                                                                 
d$Cafes = as.character(d$Cafes)                                                  
d$Cafes[!d$Cafe %in% large_cafe] = NA                                            
d$Cafes[is.na(d$Cafes)] = "Other"                                                
summary(as.factor(d$Cafes))                                                      
#>   Armley Junk-tion     Cafe Abundance Moortown Junk-tion 
#>               7183               3782               3648 
#>              Other   Sharehouse Leeds     TRJFP Plymouth 
#>              17607              29253               3333
summary(nchar(large_cafe))                                                       
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    14.0    14.0    16.0    15.6    16.0    18.0
# (longest_name = large_cafe[which.max(nchar(large_cafe))])                      
# d$Cafes[d$Cafes == longest_name] = "Bethesda"                                  
                                                                                 
# time series analysis ----------------------------------------------------      
                                                                                 
# plot(d$Quantity, d$DateIntercepted)                                            
d$month = lubridate::round_date(d$DateIntercepted, unit = "month")               
dym = d %>%                                                                      
group_by(month) %>%                                                              
summarise(n = n(), tonnes = sum(Quantity) / 1e6)                                 
# plot(dym$month, dym$tonnes)                                                    
ggplot(dym) +                                                                    
geom_line(aes(month, tonnes))                                                    
```

![](https://i.imgur.com/ppVdeH7.png)

``` r
dym_cafes = d %>%                                                                
group_by(month, Cafes) %>%                                                       
summarise(n = n(), tonnes = sum(Quantity) / 1e6) %>%                             
arrange(Cafes, tonnes)                                                           
ggplot(dym_cafes) +                                                              
geom_bar(aes(month, tonnes, fill = Cafes), position = "stack", stat = "identity")
```

![](https://i.imgur.com/PlUOOEI.png)

<details><summary>Session info</summary>

``` r
devtools::session_info()
#> Session info -------------------------------------------------------------
#>  setting  value                       
#>  version  R version 3.5.0 (2018-04-23)
#>  system   x86_64, linux-gnu           
#>  ui       X11                         
#>  language en_GB:en                    
#>  collate  en_GB.UTF-8                 
#>  tz       Europe/London               
#>  date     2018-06-06
#> Packages -----------------------------------------------------------------
#>  package      * version    date      
#>  assertthat     0.2.0      2017-04-11
#>  backports      1.1.2      2017-12-13
#>  base         * 3.5.0      2018-04-23
#>  bindr          0.1.1      2018-03-13
#>  bindrcpp     * 0.2.2      2018-03-29
#>  broom          0.4.4      2018-03-29
#>  cellranger     1.1.0      2016-07-27
#>  class          7.3-14     2015-08-30
#>  classInt       0.2-3      2018-04-16
#>  cli            1.0.0      2017-11-05
#>  codetools      0.2-15     2016-10-05
#>  colorspace     1.3-2      2016-12-14
#>  compiler       3.5.0      2018-04-23
#>  crayon         1.3.4      2017-09-16
#>  curl           3.2        2018-03-28
#>  datasets     * 3.5.0      2018-04-23
#>  DBI            1.0.0      2018-05-02
#>  devtools       1.13.5     2018-02-18
#>  digest         0.6.15     2018-01-28
#>  dplyr        * 0.7.5      2018-05-19
#>  e1071          1.6-8      2017-02-02
#>  evaluate       0.10       2016-10-11
#>  forcats      * 0.3.0      2018-02-19
#>  foreign        0.8-70     2018-04-23
#>  future       * 1.8.1      2018-05-03
#>  ggplot2      * 2.2.1.9000 2018-06-02
#>  git2r          0.21.0     2018-01-04
#>  globals        0.11.0     2018-01-10
#>  glue           1.2.0      2017-10-29
#>  graphics     * 3.5.0      2018-04-23
#>  grDevices    * 3.5.0      2018-04-23
#>  grid           3.5.0      2018-04-23
#>  gtable         0.2.0      2016-02-26
#>  haven          1.1.1      2018-01-18
#>  hms            0.4.2      2018-03-10
#>  htmltools      0.3.6      2017-04-28
#>  httr           1.3.1      2017-08-20
#>  jsonlite       1.5        2017-06-01
#>  knitr          1.20       2018-02-20
#>  labeling       0.3        2014-08-23
#>  lattice        0.20-35    2017-03-25
#>  lazyeval       0.2.1      2017-10-29
#>  listenv        0.7.0      2018-01-21
#>  lubridate      1.7.4      2018-04-11
#>  magrittr       1.5        2014-11-22
#>  memoise        1.1.0      2017-04-21
#>  methods      * 3.5.0      2018-04-23
#>  mime           0.5        2016-07-07
#>  mnormt         1.5-5      2016-10-15
#>  modelr         0.1.2      2018-05-11
#>  munsell        0.4.3      2016-02-13
#>  nlme           3.1-137    2018-04-07
#>  parallel       3.5.0      2018-04-23
#>  pillar         1.2.3      2018-05-25
#>  pkgconfig      2.0.1      2017-03-21
#>  plyr           1.8.4      2016-06-08
#>  psych          1.6.9      2016-09-17
#>  purrr        * 0.2.5      2018-05-29
#>  R6             2.2.2      2017-06-17
#>  Rcpp           0.12.17    2018-05-18
#>  readr        * 1.1.1      2017-05-16
#>  readxl         1.1.0      2018-04-20
#>  reshape2       1.4.3      2017-12-11
#>  rlang          0.2.1      2018-05-30
#>  rmarkdown      1.9        2018-03-01
#>  rprojroot      1.3-2      2018-01-03
#>  rstudioapi     0.7        2017-09-07
#>  rvest          0.3.2      2016-06-17
#>  scales         0.5.0      2017-08-24
#>  sf           * 0.6-3      2018-05-17
#>  spData         0.2.8.9    2018-06-03
#>  spDataLarge    0.2.6.5    2018-06-02
#>  stats        * 3.5.0      2018-04-23
#>  stringi        1.2.2      2018-05-02
#>  stringr      * 1.3.1      2018-05-10
#>  tibble       * 1.4.2      2018-01-22
#>  tidyr        * 0.8.1      2018-05-18
#>  tidyselect     0.2.4      2018-02-26
#>  tidyverse    * 1.2.1      2017-11-14
#>  tools          3.5.0      2018-04-23
#>  udunits2       0.13       2016-11-17
#>  ukboundaries * 0.2.0      2018-06-01
#>  units          0.5-1      2018-01-08
#>  utf8           1.1.4      2018-05-24
#>  utils        * 3.5.0      2018-04-23
#>  withr          2.1.2      2018-03-15
#>  xml2           1.2.0      2018-01-24
#>  yaml           2.1.19     2018-05-01
#>  source                                     
#>  cran (@0.2.0)                              
#>  CRAN (R 3.5.0)                             
#>  local                                      
#>  cran (@0.1.1)                              
#>  cran (@0.2.2)                              
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  cran (@7.3-14)                             
#>  cran (@0.2-3)                              
#>  cran (@1.0.0)                              
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  local                                      
#>  CRAN (R 3.5.0)                             
#>  cran (@3.2)                                
#>  local                                      
#>  cran (@1.0.0)                              
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  cran (@0.7.5)                              
#>  cran (@1.6-8)                              
#>  CRAN (R 3.3.2)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  Github (tidyverse/ggplot2@cc48035)         
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  local                                      
#>  local                                      
#>  local                                      
#>  CRAN (R 3.3.2)                             
#>  CRAN (R 3.5.0)                             
#>  cran (@0.4.2)                              
#>  CRAN (R 3.5.0)                             
#>  cran (@1.3.1)                              
#>  cran (@1.5)                                
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.3.2)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  cran (@1.7.4)                              
#>  CRAN (R 3.3.2)                             
#>  CRAN (R 3.5.0)                             
#>  local                                      
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.3.2)                             
#>  CRAN (R 3.5.0)                             
#>  local                                      
#>  cran (@1.2.3)                              
#>  cran (@2.0.1)                              
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.3.2)                             
#>  cran (@0.2.5)                              
#>  cran (@2.2.2)                              
#>  CRAN (R 3.5.0)                             
#>  cran (@1.1.1)                              
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  cran (@0.2.1)                              
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.3.2)                             
#>  CRAN (R 3.5.0)                             
#>  cran (@0.6-3)                              
#>  Github (nowosad/spData@7b53933)            
#>  Github (nowosad/spDataLarge@bc058ad)       
#>  local                                      
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  cran (@1.4.2)                              
#>  CRAN (R 3.5.0)                             
#>  cran (@0.2.4)                              
#>  CRAN (R 3.5.0)                             
#>  local                                      
#>  cran (@0.13)                               
#>  Github (robinlovelace/ukboundaries@1d162f0)
#>  cran (@0.5-1)                              
#>  cran (@1.1.4)                              
#>  local                                      
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)                             
#>  CRAN (R 3.5.0)
```

</details>
