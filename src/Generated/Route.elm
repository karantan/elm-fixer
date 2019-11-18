module Generated.Route exposing
    ( Route(..)
    , routes
    , toPath
    , DocsParams
    , FixerParams
    , IndexParams
    , NotFoundParams
    )


import Application.Route as Route



type alias DocsParams =
    ()


type alias FixerParams =
    ()


type alias IndexParams =
    ()


type alias NotFoundParams =
    ()




 
type Route
    = Docs DocsParams
    | Fixer FixerParams
    | Index IndexParams
    | NotFound NotFoundParams


routes =
    [ Route.path "docs" Docs
    , Route.path "fixer" Fixer
    , Route.index Index
    , Route.path "not-found" NotFound
    ]


toPath route =
    case route of
        Docs _ ->
            "/docs"

        Fixer _ ->
            "/fixer"

        Index _ ->
            "/"

        NotFound _ ->
            "/not-found"

