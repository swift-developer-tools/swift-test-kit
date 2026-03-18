# ``TestConfiguration/withOptions(_:body:)-9gyp6``

Calls the given closure with modified options.

The modification closure receives the resolved options from an enclosing scope 
or the ``global`` options. All tests executed within the body closure use the 
modified options.

- Note: Scopes may be nested. An inner scope's options take precedence
over an outer scope's options.

- Parameters:
  - modify: The closure that modifies the options.
  - body: The body closure to call.
