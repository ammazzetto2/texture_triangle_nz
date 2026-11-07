# Japanese-source comparison, independent of the package vertex transcription.
# HRO Analysis Methods 2012, corrected chapter III (2013-04-23), Table 2,
# printed p34 / PDF p6: ordered international-method key, not marginal ranges.
source("R/dependencies.R")
ensure_project_dependencies()
source("R/classification_systems.R")
source("R/classification.R")
system <- "ISSS (ISSS.TT 1.5.3, 12 classes)"
# Half-planes a*sand+b*clay <= d, in percentages. Silt=100-sand-clay.
# Equalities are closed for geometry comparison, not national key assignment.
limits <- list(
  HCl = rbind(c(0,-1,-45)),
  SiCl = rbind(c(0,-1,-25),c(0,1,45),c(1,1,55)),
  SaCl = rbind(c(0,-1,-25),c(0,1,45),c(-1,0,-55)),
  LCl = rbind(c(0,-1,-25),c(0,1,45),c(-1,-1,-55),c(1,0,55)),
  SiClLo = rbind(c(0,-1,-15),c(0,1,25),c(1,1,55)),
  ClLo = rbind(c(0,-1,-15),c(0,1,25),c(-1,-1,-55),c(1,1,80)),
  SaClLo = rbind(c(0,-1,-15),c(0,1,25),c(-1,-1,-80)),
  SiLo = rbind(c(0,1,15),c(1,1,55)),
  SaLo = rbind(c(0,1,15),c(-1,0,-65),c(1,0,85)),
  Lo = rbind(c(0,1,15),c(1,0,65),c(-1,0,-40),c(-1,-1,-55),c(1,1,80)),
  Sa = rbind(c(-1,0,-85),c(-0.5,1,-42.5)),
  LoSa = rbind(c(-1,0,-85),c(0.5,-1,42.5))
)
clip <- function(p, h) {
  out <- matrix(numeric(), ncol=2)
  for (i in seq_len(nrow(p))) {
    a <- p[i,]; b <- p[if(i == nrow(p)) 1L else i+1L,]
    da <- sum(a*h[1:2])-h[3]; db <- sum(b*h[1:2])-h[3]
    if (da <= 1e-10) out <- rbind(out,a)
    if ((da < -1e-10 && db > 1e-10) || (da > 1e-10 && db < -1e-10))
      out <- rbind(out,a + da/(da-db)*(b-a))
  }
  unique(out)
}
area <- function(p) {
  q <- p[c(seq_len(nrow(p))[-1],1L),,drop=FALSE]
  abs(sum(p[,1]*q[,2]-p[,2]*q[,1]))/2
}
definition <- classification_definition(system)
polygons <- classification_polygons(system)
checked_vertices <- list(); checked_edges <- 0L
for (code in names(limits)) {
  h <- limits[[code]]
  expected <- matrix(c(0,0,100,0,0,100),ncol=2,byrow=TRUE)
  for (j in seq_len(nrow(h))) expected <- clip(expected,h[j,])
  label <- unique(definition$data$Label)[startsWith(unique(definition$data$Label),paste0(code," · "))]
  stopifnot(length(label)==1L)
  actual <- as.matrix(definition$data[definition$data$Label==label,c("Sand","Clay")])*100
  # All actual vertices satisfy the independently derived convex region;
  # matching positive area then establishes the same closed polygon.
  stopifnot(all(h[,1:2,drop=FALSE] %*% t(actual) <= h[,3]+1e-8),
            abs(area(actual)-area(expected))<1e-8)
  details <- classification_details(data.frame(sand=expected[,1],clay=expected[,2]),polygons)
  stopifnot(all(vapply(strsplit(details$classification_candidates,"; ",fixed=TRUE),
                        function(x) label %in% x,logical(1))))
  next_p <- expected[c(seq_len(nrow(expected))[-1],1L),,drop=FALSE]
  mids <- (expected+next_p)/2
  details <- classification_details(data.frame(sand=mids[,1],clay=mids[,2]),polygons)
  stopifnot(all(vapply(strsplit(details$classification_candidates,"; ",fixed=TRUE),
                        function(x) label %in% x,logical(1))))
  checked_edges <- checked_edges+nrow(expected)
  checked_vertices[[code]] <- expected
}
stopifnot(nrow(unique(round(do.call(rbind,checked_vertices),9)))==18L,
          grepl("Japan",definition$display,fixed=TRUE),
          grepl("HRO",definition$source,fixed=TRUE))
# Independent strict-interior decision key, using HRO's order and sand line.
reference <- function(s,c) {
  z <- 100-s-c
  if(c>45) return("HCl")
  if(c>25) return(if(z>45) "SiCl" else if(s>55) "SaCl" else "LCl")
  if(c>15) return(if(z>45) "SiClLo" else if(z>20) "ClLo" else "SaClLo")
  if(z>45) return("SiLo")
  if(s>85) return(if(c<0.5*s-42.5) "Sa" else "LoSa")
  if(s>65) return("SaLo")
  "Lo"
}
set.seed(1955)
x <- matrix(rexp(30000),ncol=3);x <- x/rowSums(x)*100
p <- data.frame(sand=x[,1],clay=x[,2])
d <- classification_details(p,polygons)
stopifnot(all(d$classification_status=="classified"),
          identical(sub(" · .*","",d$classification),mapply(reference,p$sand,p$clay,USE.NAMES=FALSE)))
cat("Japanese ISSS comparison: 12 closed regions, 18 unique vertices,",checked_edges,
    "region edges, and 10,000 source-key interiors PASS; shared equalities retain app policy\n")
