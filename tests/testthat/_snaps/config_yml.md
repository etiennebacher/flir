# config.yml errors when it doesn't contain any rule

    Code
      lint()
    Condition
      Error in `lint()`:
      ! 'flir/config.yml' exists but doesn't contain any rule.

---

    Code
      lint()
    Condition
      Error in `lint()`:
      ! 'flir/config.yml' exists but doesn't contain any rule.

# config.yml errors when it contains unknown rules

    Code
      lint()
    Condition
      Error in `lint()`:
      ! Unknown linters: foo, bar

# config.yml errors when it contains duplicated rules

    Code
      lint()
    Condition
      Error in `lint()`:
      ! In 'flir/config.yml', the following linters are duplicated: equal_assignment

# config.yml errors with unknown fields

    Code
      lint()
    Condition
      Error in `lint()`:
      ! Unknown field in 'flir/config.yml': some_field

# config.yml errors with duplicated fields

    Code
      lint()
    Condition
      Error in `yaml.load()`:
      ! (flir/config.yml) Duplicate map key: 'keep'

# config: `from-package` checks duplicated package name

    Code
      lint()
    Condition
      Error in `lint()`:
      ! In 'flir/config.yml', the following packages are duplicated: foo

# config: `from-package` checks that package is installed

    Code
      lint()
    Condition
      Error in `get_external_linters_from_config()`:
      ! The package "foo" is required.

