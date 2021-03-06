context("insertReturn")

test_that("return inserted for Literal", {
  ast = toASTq(3.14)

  result = insertReturn(ast)

  # -----
  expect_is(result, "Return")
  expect_is(result$args[[1]], "Numeric")
})


test_that("return inserted for Symbol", {
  ast = toASTq(x)

  result = insertReturn(ast)

  # -----
  expect_is(result, "Return")
  expect_is(result$args[[1]], "Symbol")
})


test_that("return inserted for Call", {
  ast = toASTq(sum(x, 1, 3))

  result = insertReturn(ast)

  # -----
  expect_is(result, "Return")
  expect_is(result$args[[1]], "Call")
})


test_that("return inserted for Assign", {
  ast = toASTq(x <- 3)

  result = insertReturn(ast)

  # -----
  expect_is(result, "Return")
  expect_is(result$args[[1]], "Assign")
})


test_that("return inserted after While, without duplicate Brace", {
  ast = toASTq({
    while (x < 10) x = x + 1
  })

  result = insertReturn(ast)

  # -----
  expect_is(result, "Brace")

  expect_is(result$body[[1]], "While")
  expect_identical(result$body[[1]]$parent, result)

  expect_is(result$body[[2]], "Return")
  expect_identical(result$body[[2]]$parent, result)
})


test_that("return inserted after While, adding Brace", {
  ast = toASTq(
    while (x < 10) x = x + 1
  )

  result = insertReturn(ast)

  # -----
  expect_is(result, "Brace")

  expect_is(result$body[[1]], "While")
  expect_identical(result$body[[1]]$parent, result)

  expect_is(result$body[[2]], "Return")
  expect_identical(result$body[[2]]$parent, result)
})


test_that("return inserted for Function", {
  f = function(x) 42L

  ast = toAST(f)

  result = insertReturn(ast)

  # -----
  expect_is(result, "Function")
  expect_is(result$body, "Return")
  expect_identical(result$body$parent, result)
})
