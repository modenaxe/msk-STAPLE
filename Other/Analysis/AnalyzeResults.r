library(readr)
library(dunn.test)


# Read the .txt files of the ACS orientation results perfomed with Matlab script qRes.m
TP <- read_csv("TP.txt")

TP$Methods <- as.factor(TP$Methods)
kruskal.test(Rb~Methods, data = TP)
dunn.test(TP$Rb, g = TP$Methods)

TF <- read_csv("TF.txt")

TF$Methods <- as.factor(TF$Methods)
kruskal.test(Rb~Methods, data = TF)
dunn.test(TF$Rb, g = TF$Methods)

TT <- read_csv("TT.txt")

TT$Methods <- as.factor(TT$Methods)
kruskal.test(Rb~Methods, data = TT)
dunn.test(TT$Rb, g = TT$Methods)

ResRP <- aggregate(TP[, 2], list(TP$Methods), function(x) c(mean = mean(x), sd = sd(x), max = max(x)))
write.table(ResRP, file='ResRP.tsv', quote=FALSE, sep='\t', col.names = NA)

ResRF <- aggregate(TF[, 2], list(TF$Methods), function(x) c(mean = mean(x), sd = sd(x), max = max(x)))
write.table(ResRF, file='ResRF.tsv', quote=FALSE, sep='\t', col.names = NA)

ResRT <- aggregate(TT[, 2], list(TT$Methods), function(x) c(mean = mean(x), sd = sd(x), max = max(x)))
write.table(ResRT, file='ResRT.tsv', quote=FALSE, sep='\t', col.names = NA)


# Read the .txt files of the ACS origin minimal bounding spheres results perfomed with Matlab script RBSph.m
BSF <- read_csv("mBSF.txt")

BSF$Methods <- as.factor(BSF$Methods)
kruskal.test(Rb~Methods, data = BSF)
dunn.test(BSF$Rb, g = BSF$Methods)

BST <- read_csv("mBST.txt")

BST$Methods <- as.factor(BST$Methods)
kruskal.test(Rb~Methods, data = BST)
dunn.test(BST$Rb, g = BST$Methods)

BSP <- read_csv("mBSP.txt")

BSP$Methods <- as.factor(BSP$Methods)
kruskal.test(Rb~Methods, data = BSP)
dunn.test(BSP$Rb, g = BSP$Methods)

ResBSP <- aggregate(BSP[, 2], list(BSP$Methods), function(x) c(mean = mean(x), sd = sd(x), max = max(x)))
write.table(ResBSP, file='ResBSP.tsv', quote=FALSE, sep='\t', col.names = NA)

ResBST <- aggregate(BST[, 2], list(BST$Methods), function(x) c(mean = mean(x), sd = sd(x), max = max(x)))
write.table(ResBST, file='ResBST.tsv', quote=FALSE, sep='\t', col.names = NA)

ResBSF <- aggregate(BSF[, 2], list(BSF$Methods), function(x) c(mean = mean(x), sd = sd(x), max = max(x)))
write.table(ResBSF, file='ResBSF.tsv', quote=FALSE, sep='\t', col.names = NA)


