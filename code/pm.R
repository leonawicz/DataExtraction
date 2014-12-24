# @knitr create_project
source("C:/github/ProjectManagement/code/projman.R") # eventually load a package instead of source script
proj.name <- "DataExtraction" # Project name
proj.location <- matt.proj.path # Use default file location

docDir <- c("Rmd/include", "md", "html", "Rnw", "pdf", "timeline")
newProject(proj.name, proj.location, docs.dirs=docDir, overwrite=T) # create a new project

rfile.path <- file.path(proj.location, proj.name, "code") # path to R scripts
docs.path <- file.path(proj.location, proj.name, "docs")
rmd.path <- file.path(docs.path, "Rmd")

# generate Rmd files from existing R scripts using default yaml front-matter
genRmd(path=rfile.path, header=rmdHeader())

# @knitr update_project
# update yaml front-matter only
genRmd(path=rfile.path, header=rmdHeader(), update.header=TRUE)

# obtain knitr code chunk names in existing R scripts
chunkNames(path=file.path(proj.location, proj.name, "code"))

# append new knitr code chunk names found in existing R scripts to any Rmd files which are outdated
chunkNames(path=file.path(proj.location, proj.name, "code"), append.new=TRUE)

# @knitr website
# Setup for generating a project website
proj.github <- file.path("https://github.com/leonawicz", proj.name)
index.url <- "index.html"
#file.copy(index.url, "index.html")

proj.title <- "Data Extraction"
proj.menu <- c("Extraction evaluation", "Density estimation", "Pre-indexing", "All Projects")

proj.submenu <- list(
	c("Project", "Introduction", "Case study: sample mean", "Results", "Next steps", "divider", "R Code", "Complete code"),
	c("Project", "Introduction", "Simulations", "divider", "Use cases", "Case 1: Climate", "Case 2: Vegetation", "divider", "R code", "Basic simulation"),
	c("Project", "Introduction", "Related items", "divider", "R Code", "Complete code"),
	c("Projects diagram", "divider", "About", "Other")
)

proj.files <- list(
	c("header", "eval_intro.html", "eval_case.html", "eval_res.html", "eval_next.html", "divider", "header", "extract_eval_code.html"),
	c("header", "dens_intro.html", "dens_sims.html", "divider", "header", "dens_use1.html", "dens_use2.html", "divider", "header", "dens_sims_code.html"),
	c("header", "ind_intro.html", "ind_related.html", "divider", "header", "ind_code.html"),
	c("proj_sankey.html", "divider", "proj_intro.html", "proj_intro.html")
)

# generate navigation bar html file common to all pages
genNavbar(htmlfile=file.path(proj.location, proj.name, "docs/Rmd/include/navbar.html"), title=proj.title, menu=proj.menu, submenus=proj.submenu, files=proj.files, title.url="index.html", home.url="index.html", site.url=proj.github, include.home=FALSE)

# generate _output.yaml file
# Note that external libraries are expected, stored in the "libs" below
yaml.out <- file.path(proj.location, proj.name, "docs/Rmd/_output.yaml")
libs <- "libs"
common.header <- "include/in_header.html"
genOutyaml(file=yaml.out, lib=libs, header=common.header, before_body="include/navbar.html")

# @knitr knit_setup
library(rmarkdown)
library(knitr)
setwd(rmd.path)

# R scripts
#files.r <- list.files("../../code", pattern=".R$", full=T)

# Rmd files
files.Rmd <- list.files(pattern=".Rmd$", full=T)

# potential non-Rmd directories for writing various output files
#outtype <- file.path(dirname(getwd()), list.dirs("../", full=F, recursive=F))
#outtype <- outtype[basename(outtype)!="Rmd"]

# @knitr save
# write all yaml front-matter-specified outputs to Rmd directory for all Rmd files
lapply(files.Rmd, render, output_format="all")
moveDocs(path.docs=docs.path)

# if also making PDFs for a project, speed up the Rmd to Rnw file conversion/duplication
rnw.path <- file.path(docs.path, "Rnw")
setwd(rnw.path)
#themes <- knit_theme$get()
highlight <- "solarized-dark"
convertDocs(path=rmd.path, emphasis="replace", overwrite=TRUE, highlight=highlight) # Be careful
lapply(list.files(pattern=".Rnw$"), knit2pdf)
moveDocs(path.docs=docs.path, type="pdf", remove.latex=FALSE)