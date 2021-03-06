
# Checks to see if we need to enclose the final expression
# within a call to return()
#
# insertReturn(quote(return(x + 1))  )
# insertReturn(quote(x + 1))
# insertReturn(quote({ x = 2; x + 1} ))
# insertReturn(quote({ x = 2; return(x + 1)} ))
# insertReturn(quote(while(TRUE) {  return(x + 1) }  ))
# insertReturn(quote(while(TRUE) {  x + 1 }  ))
# insertReturn(quote(if(x < 10) 20 else 40  ))
# insertReturn(quote(if(x < 10) { x= 3; sqrt(x) } else 40  ))
# insertReturn(quote(if(x < 10) { x= 3; sqrt(x) } else { x = 100; sqrt(x)}  ))
#

#' @export
insertReturn = function(node) {
  UseMethod("insertReturn")
}

#' @export
`insertReturn.Brace` = function(node) {
  # Insert Return for last statement if not already.
  len = length(node$body)
  ret = insertReturn(node$body[[len]])

  if (is.list(ret)) {
    node$body = append(node$body[-len], ret)
    for (x in ret)
      x$parent = node

  } else {
    node$body[[len]] = ret
    ret$parent = node
  }

  node
}

#' @export
insertReturn.Function = function(node) {
  node$set_body( insertReturn(node$body) )

  node
}

#' @export
insertReturn.If = function(node) {
  node$set_true( insertReturn(node$true) )
  node$set_false( insertReturn(node$false) )

  node
}

#' @export
insertReturn.While = function(node) {
  # Need to insert a return(NULL) on following line
  ans = list(
    node,
    Return$new(Null$new())
  )

  if (is(node$parent, "Brace"))
    return (ans)

  Brace$new(ans)
}

#' @export
insertReturn.For = insertReturn.While

#' @export
insertReturn.Literal = function(node) {
  Return$new(node)
}

#' @export
insertReturn.Symbol = insertReturn.Literal

#' @export
insertReturn.Call = insertReturn.Literal

#' @export
insertReturn.Assign = insertReturn.Literal

#' @export
insertReturn.NULL = function(node) {
  Return$new(Null$new())
}

#' @export
insertReturn.Return = function(node) {
  node
}


isSelect =
    # checks if the body and alternative of an if() statement are single expressions.
    # Select corresponds to the LLVM concept of a Select, i.e.,  x ? a : b
function(call)
  length(call) == 4 && all(sapply(call[3:4], isSingleExpression))

isSingleExpression =
function(e)
{
  if(is.atomic(e))
      return(TRUE)

     # if the expression is return(expr)  then say no.
  if(is.call(e) && as.character(e[[1]]) == "return")
      return(FALSE)
  
  ( 
    (is(e, "{") && length(e) == 2 && ( is.call(k <- e[[2]]) ) ) ||
    (is.call(k <- e))
  ) &&
  !(class(k) %in% c("while", "for", "if", "=", "<-", "<<-", "{"))
}
