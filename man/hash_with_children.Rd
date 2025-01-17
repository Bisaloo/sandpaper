% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-built-db.R
\name{hash_with_children}
\alias{hash_with_children}
\alias{get_child_files}
\title{Create combined checksum of files}
\usage{
hash_with_children(checksums, files, children, root_path)

get_child_files(lsn)
}
\arguments{
\item{checksums}{the hashes of the parent files}

\item{files}{the relative path of the parent files to the \code{root_path}}

\item{children}{a named list of character vectors specifying the child files
for each parent file in order of appearance. These paths are relative to
the folder of the parent file.}

\item{root_path}{the root path to the lesson.}

\item{lsn}{a \link[pegboard:Lesson]{pegboard::Lesson} object}
}
\value{
\itemize{
\item \code{get_child_files()} a named list of charcter vectors specifying the
child files within files in a lesson.
\item \code{hash_with_children()} a character vector of hashes of the same length
as the parent files.
}
}
\description{
When handling child files for lessons, it is important that changes in child
files will cause the source file to change as well.
}
\details{
\itemize{
\item The \code{get_child_files()} function finds the child files from a
\link[pegboard:Lesson]{pegboard::Lesson} object.
\item Because we use a text database that relies on the hash of the file to
determine if a file should be rebuilt, \code{hash_with_children()} piggybacks
on this paradigm by assigning a unique hash to a parent file with
children that is the hash of the vector of hashes of the files. The hash
of hashes is created with \code{rlang::hash()}.
}
}
\examples{
# This demonstration will show how a temporary database can be set up. It
# will only work with a sandpaper lesson
# setup -----------------------------------------------------------------
# The setup needs to include an R Markdown file with a child file.
tmp <- tempfile()
on.exit(fs::dir_delete(tmp), add = TRUE)
create_lesson(tmp, rmd = FALSE, open = FALSE)
# get namespace to use internal functions
sp <- asNamespace("sandpaper")
db <- fs::path(tmp, "site/built/md5sum.txt")
resources <- fs::path(tmp, c("episodes/introduction.md", "index.md"))
# create child file
writeLines("Hello from another file!\n",
  fs::path(tmp, "episodes", "files", "hi.md"))
# use child file
cat("\n\n```{r child='files/hi.md'}\n```\n",
  file = resources[[1]], append = TRUE)
# convert to Rmd
fs::file_move(resources[[1]], fs::path_ext_set(resources[[1]], "Rmd"))
resources[[1]] <- fs::path_ext_set(resources[[1]], "Rmd")
set_episodes(tmp, fs::path_file(resources[[1]]), write = TRUE)

# get_child_files ------------------------------------------------------
# we can get the child files by scanning the Lesson object
lsn <- sp$this_lesson(tmp)
class(lsn)
children <- sp$get_child_files(lsn)
print(children)

# hash_with_children ---------------------------------------------------
# get hash of parent
phash <- tools::md5sum(resources[[1]])
rel_parent <- fs::path_rel(resources[[1]], start = tmp)
sp$hash_with_children(phash, rel_parent, children, tmp)
# demonstrate how this works ----------------
# the combined hashes have their names removed and then `rlang::hash()`
# creates the hash of the unnamed hashes.
chash <- tools::md5sum(fs::path(tmp, "episodes", children[[1]]))
hashes <- unname(c(phash, chash))
print(hashes)
rlang::hash(hashes)
}
\keyword{internal}
