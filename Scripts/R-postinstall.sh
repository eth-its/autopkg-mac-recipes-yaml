#!/bin/bash

# postinstall to install base set of R packages

echo "Installing R packages ..."
echo "NOTE: You should have Xcode command-line tools installed for this..."

/usr/local/bin/R --no-save --no-restore << 'EOF'
repos <- c(
"http://stat.ethz.ch/CRAN"
)
pkgs <- c(
"R.utils",
"RColorBrewer",
"RCurl",
"RM2",
"RODBC",
"RSQLite",
"RUnit",
"RandomFields",
"RcmdrPlugin.TeachingDemos",
"XML",
"abind",
"acepack",
"biglm",
"bigmemory",
"bootstrap",
"cobs",
"coda",
"combinat",
"corpcor",
"digest",
"earth",
"ellipse",
"evd",
"evir",
"fBasics",
"ff",
"fracdiff",
"gbm",
"geoR",
"gss",
"hdf5",
"hexbin",
"ipred",
"lars",
"lasso2",
"lme4",
"locfit",
"logspline",
"lokern",
"lpridge",
"mAr",
"maps",
"mboost",
"mclust",
"mda",
"multcomp",
"nws",
"pls",
"qtl",
"randomForest",
"rbugs",
"rgl",
"rlecuyer",
"robustbase",
"sampling",
"scatterplot3d",
"sciplot",
"snowFT",
"spatstat",
"splancs",
"sspir",
"survey",
"systemfit",
"tkrplot",
"tseries",
"tweedie",
"waveslim",
"wavethresh"
)
missing <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
cat(paste("Missing Packets: ",length(missing),"\n"))
if(length(missing)) install.packages(missing, repos=repos, dependencies=T)
EOF

echo "Updating any previously installed R packages ..."
/usr/local/bin/R --no-save --no-restore << EOF
update.packages(repos="http://stat.ethz.ch/CRAN", ask=F)
EOF

echo "Allowing local accounts to install/update packages (chgrp staff)"
chgrp -R staff /Library/Frameworks/R.framework/Versions/Current/Resources/library

echo "R Installation and updates completed successfully"
