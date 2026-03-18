# ``TestConfiguration/withOptions(_:body:)-8tybz``

Calls the given closure with the given options.

All tests executed within the given closure use the scoped options
instead of the ``global`` options, unless those tests explicitly
specify options.

- Note: Scopes may be nested. An inner scope's options take precedence
over an outer scope's options.

- Parameters:
  - options: The options for testing.
  - body: The body closure to call.
