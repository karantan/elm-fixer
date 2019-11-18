module Generated.Pages exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page

import Generated.Route as Route
import Html
import Layouts.Main as Layout
import Pages.Docs as Docs
import Pages.Fixer as Fixer
import Pages.Index as Index
import Pages.NotFound as NotFound


type Model
    = DocsModel Docs.Model
    | FixerModel Fixer.Model
    | IndexModel Index.Model
    | NotFoundModel NotFound.Model


type Msg
    = DocsMsg Docs.Msg
    | FixerMsg Fixer.Msg
    | IndexMsg Index.Msg
    | NotFoundMsg NotFound.Msg


page =
    Page.layout
        { map = Html.map
        , view = Layout.view
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


docs =
        Page.recipe Docs.page
        { toModel = DocsModel
        , toMsg = DocsMsg
        , map = Html.map
        }


fixer =
        Page.recipe Fixer.page
        { toModel = FixerModel
        , toMsg = FixerMsg
        , map = Html.map
        }


index =
        Page.recipe Index.page
        { toModel = IndexModel
        , toMsg = IndexMsg
        , map = Html.map
        }


notFound =
        Page.recipe NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        , map = Html.map
        }


init route_ =
    case route_ of
        Route.Docs route ->
            docs.init route

        Route.Fixer route ->
            fixer.init route

        Route.Index route ->
            index.init route

        Route.NotFound route ->
            notFound.init route


update msg_ model_ =
    case ( msg_, model_ ) of
        ( DocsMsg msg, DocsModel model ) ->
            docs.update msg model

        ( FixerMsg msg, FixerModel model ) ->
            fixer.update msg model

        ( IndexMsg msg, IndexModel model ) ->
            index.update msg model

        ( NotFoundMsg msg, NotFoundModel model ) ->
            notFound.update msg model

        _ ->
            Page.keep model_


bundle model_ =
    case model_ of
        DocsModel model ->
            docs.bundle model

        FixerModel model ->
            fixer.bundle model

        IndexModel model ->
            index.bundle model

        NotFoundModel model ->
            notFound.bundle model

