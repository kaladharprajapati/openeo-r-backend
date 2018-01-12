#' @docType class
#' @importFrom R6 R6Class
#' @export
User <- R6Class(
  "User",
  public = list(
    user_id = NULL,
    workspace = NULL,
    jobs = NULL,
    user_name = NULL,
    password = NULL,
    token = NULL,
    
    initialize = function(user_id) {
      self$user_id = user_id
      self$jobs = list()
    },
    
    toList = function() {
      return(
        list(
          user_id = self$user_id,
          user_name = self$user_name,
          password = self$password,
          jobs = self$jobs
        )
      )
    },
    
    fileList = function() {
      files.df = self$files
      rownames(files.df) <- NULL
      
      return(apply(files.df,1,function(row) {
       return(list(
         name = row["link"],
         size = row["size"]
       )) 
      }))
    },
    
    store = function() {
      if (is.null(self$workspace)) {
        stop("Cannot store user, because there was no workspace assigned.")
      }
      
      dir.create(self$workspace, showWarnings = FALSE)
      dir.create(paste(self$workspace,"files",sep="/"), showWarnings = FALSE)
      
      json = toJSON(self$toList(),auto_unbox = TRUE,pretty=TRUE)
      write(x=json,file=paste(self$workspace,"user.json",sep="/"))
    }
  ),
  active = list(
    files = function() {
      workspace = paste(self$workspace,"files",sep="/")
      
      relPath=list.files(workspace,recursive = TRUE)
      fileInfos=file.info(list.files(workspace,recursive = TRUE,full.names = TRUE))
      fileInfos$link = relPath
      
      return(fileInfos[,c("link","size")])
    }
  )
)

isUser = function(obj) {
  return(all("User" %in% class(obj)))
}