# idrisjs
Js libraries for idris.
Due to some dificulties with the default js backend this lib uses its own js backend. This backend is compatible with the default js IO type JS_IO, hence they are interchangeable. The test t8.idr shows the troubles with the idris default backend.

Note: The master branch at idris-dev has a new backend that solve this problems and has a few more improvements, I will delete de backend code from this library after the next idris release.

### To build
```shell
cabal install
cd lib
idris --install js.ipkg
```

### Compilation example:
```shell
cd examples
idris --codegen js -p js todo.idr -o todo.js
```
then open todo.html

Note: To use the regular backend use --codegen javascript instead.


### Documentation
The only documentation available right now is the idris generated doc
```shell
cd lib
idris --mkdoc js.ipkg
```
Open a github issue to discuss anything related to this project.
