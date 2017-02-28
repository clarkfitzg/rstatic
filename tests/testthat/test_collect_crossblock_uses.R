context("collect_crossblock_uses")


test_that("assignment RHSs detected as a crossblock uses", {
  code = quote({
    if (TRUE)
      x = 3
    else
      x = 4
    y = x
  })
  cfg = to_cfg(to_ast(code), as_ssa = FALSE)

  result = collect_crossblock_uses(cfg)
  uses = result[[1]]
  assign_blocks = result[[2]]

  # -----
  expect_equal(uses, "x")
})


test_that("replacement RHSs detected as crossblock uses", {
  code = quote({
    if (TRUE)
      x = 3
    else
      x = 4
    y[1] = x
  })
  cfg = to_cfg(to_ast(code), as_ssa = FALSE)

  result = collect_crossblock_uses(cfg)
  uses = result[[1]]
  assign_blocks = result[[2]]

  # -----
  expect_equal(uses, "x")
})


test_that("arguments detected as crossblock uses", {
  code = quote({
    if (TRUE)
      x = 3
    else
      x = 4
    mean(x)
  })
  cfg = to_cfg(to_ast(code), as_ssa = FALSE)

  result = collect_crossblock_uses(cfg)
  uses = result[[1]]
  assign_blocks = result[[2]]

  # -----
  expect_equal(uses, "x")
})