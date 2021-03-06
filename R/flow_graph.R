
#' @export
FlowGraph = R6::R6Class("FlowGraph",
  "private" = list(
    deep_clone = function(name, value) {
      switch(name,
        "blocks" = lapply(value, function(v) v$copy()),
        if (inherits(value, "R6")) value$clone(deep = TRUE)
        else value
      )
    }
  ),

  "public" = list(
    next_id = 1L,
    blocks = list(),
    graph = NULL,

    initialize = function() {
      self$graph = igraph::make_empty_graph()
    },

    copy = function() self$clone(deep = TRUE),

    add_vertex = function(id) {
      if (missing(id)) {
        id = sprintf("%%%i", self$next_id)
        self$next_id = self$next_id + 1L
      }

      self$graph = self$graph + igraph::vertex(id)

      return (id)
    },

    remove_vertex = function(id) {
      self$graph = self$graph - igraph::vertex(id)
      invisible (NULL)
    },

    add_edge = function(from, to) {
      self$graph = self$graph + igraph::edge(from, to)

      invisible (NULL)
    },

    get_index = function(name) {
      match(name, igraph::V(self$graph)$name)
    },

    get_name = function(index) {
      igraph::V(self$graph)$name[index]
    }
  )
)

#' @export
`[.FlowGraph` = function(x, i) {
      # No S4 so can't do multiple dispatch!
  if(is(i, "igraph.vs"))
    i = as_ids(i)
  x$blocks[i]
}

#' @export
`[[.FlowGraph` = function(x, i) {
  x$blocks[[i]]
}


#' @export
`[[<-.FlowGraph` = function(x, i, value) {
  x$blocks[[i]] = value
  return (x)
}


#' @export
length.FlowGraph = function(x) {
  length(x$blocks)
}


#' @export
names.FlowGraph = function(x) {
  names(x$blocks)
}


#' Plot Method for Flow Graphs
#'
#' This method plots a flow graph.
#'
#' @param x (FlowGraph) A flow graph.
#' @param ... Additional arguments to \code{plot.igraph}.
#'
#' @export
plot.FlowGraph = function(x, ...) {
  plot(x$graph, ...)
}


#' @export
ControlFlowGraph = R6::R6Class("ControlFlowGraph", inherit = FlowGraph,
  "public" = list(
    params = list(),
    entry = NULL,
    exit = NULL,
    ssa = NULL,

    initialize = function() {
      super$initialize()

      self$entry = self$add_vertex()
      self$blocks[[self$entry]] = BasicBlock$new(self$entry)

      self$exit = self$add_vertex()
      exit_block = BasicBlock$new(self$exit)
      exit_block$terminator = RetTerminator$new()
      self$blocks[[self$exit]] = exit_block

      return (self)
    },

    # FIXME: Make sure copying works correctly.
    set_params = function(value) {
      for (v in value)
        v$parent = self

      self$params = value
    }
  )
)
