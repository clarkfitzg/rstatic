#
# Functions for string conversion and printing.
#

.print = function(x, ...) cat(format(x, ...), "\n\n")

.format_tag = function(x) sprintf("<%s>", class(x)[1])


#' @export
format.ASTNode = function(x, indent = 0, ...) {
  members = setdiff(ls(x), c("initialize", "clone"))
  is_method = vapply(members, function(f) is.function(x[[f]]), TRUE)

  members[is_method] = paste(members[is_method], "()", sep = "")
  members = members[order(is_method, members)]
  members = paste("$", members, sep = "", collapse = " ")

  code = deparse_string(toR(x))
  sprintf("<%s> %s\n%s", class(x)[1], members, code)
}

#' @export
print.ASTNode = .print


#' @export
format.FlowGraph = function(x, ...) {
  # Format:
  #
  #   <CFGraph> 5 blocks
  #
  #   %v1 <BasicBlock>
  #   # branch %2
  #
  #   %v2 <BasicBlock>
  #   # if (z > 3) %3 else %4

  tag = .format_tag(x)
  msg = if (length(x) == 1) "%i block" else "%i blocks"
  v_count = sprintf(msg, length(x))

  fmt = vapply(x$blocks, format, character(1))
  blocks = sprintf('%s %s', names(x), fmt)
  blocks = paste0(blocks, collapse = "\n\n")

  sprintf("%s %s\n\n%s", tag, v_count, blocks)
}

#' @export
print.FlowGraph = .print


#' @export
format.BasicBlock = function(x, show_body = TRUE, ...) {
  # Format:
  #
  #   <BasicBlock>
  #   x = x + 1
  #   x = x / y
  #   foo(x)
  #   # if (x < 4) %3 else %4
  #
  display = paste0("# ", format(x$terminator, show_tag = FALSE))

  if (show_body) {
    to_str = function(line) deparse_string(toR(line))

    phi = vapply(x$phi, to_str, character(1))
    body = vapply(x$body, to_str, character(1))

    display = paste0(c(phi, body, display), collapse = "\n")
  }

  msg = sprintf("%s\n%s", .format_tag(x), display)

  return (msg)
}

#' @export
print.BasicBlock = .print


#' @export
format.RetTerminator = function(x, show_tag = TRUE, ...) {
  value = deparse_string(toR(x$value))
  term = sprintf("ret %s", value)

  if (show_tag)
    msg = sprintf("%s\n%s", .format_tag(x), term)
  else
    msg = sprintf("%s", term)

  return (msg)
}

#' @export
format.BrTerminator = function(x, show_tag = TRUE, ...) {
  term = sprintf("br %s", x$dest)

  if (show_tag)
    msg = sprintf("%s\n%s", .format_tag(x), term)
  else 
    msg = sprintf("%s", term)

  return (msg)
}

#' @export
format.CondBrTerminator = function(x, show_tag = TRUE, ...) {
  condition = deparse_string(toR(x$condition))
  term = sprintf("br (%s) %s, %s", condition, x$true, x$false)

  if (show_tag)
    msg = sprintf("%s\n%s", .format_tag(x), term)
  else 
    msg = sprintf("%s", term)

  return (msg)
}

#format.IterTerminator = function(x, show_tag = TRUE, ...) {
#
#  ivar = deparse_string(toR(x$ivar))
#  iter = deparse_string(toR(x$iter))
#  term = sprintf("iter (%s in %s) %s, %s", ivar, iter, x$true, x$false)
#
#  if (show_tag)
#    msg = sprintf("%s\n%s", .format_tag(x), term)
#  else
#    msg = sprintf("%s", term)
#
#  return (msg)
#}

#' @export
print.Terminator = .print


format.NONCONST = function(x, ...) "NONCONST"
print.NONCONST = function(x, ...) cat(format(x, ...), "\n")


deparse_string = function(expr, ...) {
  # Safely deparse() to a single string.
  paste0(deparse(expr, ...), collapse = "\n")
}
