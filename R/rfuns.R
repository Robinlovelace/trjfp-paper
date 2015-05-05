# R Functions

declutter <- function(x){
  gsub(pattern = "All Hallows|All Hallows, |, Leeds|LBSU|, Hackney", replacement = "", x)
}
