# fix works

    Code
      fix_text("expect_equal(typeof(x), 'double')", linters = linter)
    Output
      Old code: expect_equal(typeof(x), 'double') 
      New code: expect_type(x, 'double') 

---

    Code
      fix_text("expect_equal(typeof(x), \"double\")", linters = linter)
    Output
      Old code: expect_equal(typeof(x), "double") 
      New code: expect_type(x, "double") 

---

    Code
      fix_text("expect_identical(typeof(x), 'double')", linters = linter)
    Output
      Old code: expect_identical(typeof(x), 'double') 
      New code: expect_type(x, 'double') 

---

    Code
      fix_text("expect_identical(typeof(x), \"double\")", linters = linter)
    Output
      Old code: expect_identical(typeof(x), "double") 
      New code: expect_type(x, "double") 

---

    Code
      fix_text("expect_equal('double', typeof(x))", linters = linter)
    Output
      Old code: expect_equal('double', typeof(x)) 
      New code: expect_type(x, 'double') 

---

    Code
      fix_text("expect_identical('double', typeof(x))", linters = linter)
    Output
      Old code: expect_identical('double', typeof(x)) 
      New code: expect_type(x, 'double') 

---

    Code
      fix_text("expect_true(is.call(x))", linters = linter)
    Output
      Old code: expect_true(is.call(x)) 
      New code: expect_type(x, "language") 

---

    Code
      fix_text("expect_true(is.function(x))", linters = linter)
    Output
      Old code: expect_true(is.function(x)) 
      New code: expect_type(x, "closure") 

---

    Code
      fix_text("expect_true(is.name(x))", linters = linter)
    Output
      Old code: expect_true(is.name(x)) 
      New code: expect_type(x, "symbol") 

---

    Code
      fix_text("expect_true(is.primitive(x))", linters = linter)
    Output
      Old code: expect_true(is.primitive(x)) 
      New code: expect_type(x, "builtin") 

# no double replacement

    Code
      fix_text("expect_equal(typeof(x), 'double')")
    Output
      Old code: expect_equal(typeof(x), 'double') 
      New code: expect_type(x, 'double') 

