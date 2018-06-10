  * Many of the submodules in `Base` have moved to standalone "standard library modules".
    In the future it will be possible to update those modules independently of Julia's
    release schedule, much like regular packages. Changes to functionality in those
    standard library modules are listed in their own sections further down.









# LinearAlgebra

## Language changes

  * The `+` and `-` methods for `Number` and `UniformScaling` are not ambiguous anymore
    since `+` and `-` no longer do automatic broadcasting. Hence, the methods for
    `UniformScaling` and `Number` are no longer deprecated ([#23923]).