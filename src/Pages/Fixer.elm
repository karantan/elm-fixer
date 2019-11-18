module Pages.Fixer exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page
import Global
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Http
import Json.Decode exposing (bool, float, int, string, succeed)
import Json.Decode.Pipeline exposing (required)


type alias Model =
    { key : String
    , endpoint : String
    , fixer : Fixer
    }


type Fixer
    = Loading
    | Failure String
    | Success FixerData



-- You can use https://noredink.github.io/json-to-elm/ to generate models from json


type alias FixerData =
    { success : Bool
    , timestamp : Int
    , base : String
    , date : String
    , rates : Rate
    }


type alias Rate =
    { eur : Float
    , gbp : Float
    , usd : Float
    }


type Msg
    = SetApiKey String
    | GetRates
    | GotRates (Result Http.Error Fixer)


page =
    Page.component
        { title = title
        , init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


title : Global.Model -> Model -> String
title _ _ =
    "Fixer API Example"



-- init


init : Global.Model -> () -> ( Model, Cmd Msg, Cmd Global.Msg )
init _ _ =
    ( { key = ""
      , endpoint = "http://data.fixer.io/api/latest?symbols=USD,GBP,EUR&access_key="
      , fixer = Loading
      }
    , Cmd.none
    , Cmd.none
    )



-- update


update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update _ msg model =
    case msg of
        SetApiKey key ->
            ( { model | key = key }
            , Cmd.none
            , Cmd.none
            )

        GetRates ->
            ( { model | fixer = Loading }
            , getRates model
            , Cmd.none
            )

        GotRates result ->
            case result of
                Ok fixerData ->
                    ( { model | fixer = fixerData }, Cmd.none, Cmd.none )

                Err error ->
                    case error of
                        Http.BadBody body ->
                            ( { model | fixer = Failure body }
                            , Cmd.none
                            , Cmd.none
                            )

                        _ ->
                            ( { model | fixer = Failure "Something went wrong" }
                            , Cmd.none
                            , Cmd.none
                            )



-- HTTP


getRates : Model -> Cmd Msg
getRates model =
    Http.get
        { url = model.endpoint ++ model.key
        , expect = Http.expectJson GotRates decodeFixer
        }



-- Decoders


decodeFixer : Json.Decode.Decoder Fixer
decodeFixer =
    Json.Decode.succeed buildFixer
        |> required "success" Json.Decode.bool
        |> required "timestamp" Json.Decode.int
        |> required "base" Json.Decode.string
        |> required "date" Json.Decode.string
        -- because rates is its own object we need to tell elm how to decode it
        |> required "rates" decodeFixerRates


decodeFixerRates : Json.Decode.Decoder Rate
decodeFixerRates =
    Json.Decode.succeed buildRate
        |> required "EUR" Json.Decode.float
        |> required "GBP" Json.Decode.float
        |> required "USD" Json.Decode.float


buildRate : Float -> Float -> Float -> Rate
buildRate eur gbp usd =
    { eur = eur, gbp = gbp, usd = usd }


buildFixer : Bool -> Int -> String -> String -> Rate -> Fixer
buildFixer success timestamp base date rates =
    Success
        { success = success
        , timestamp = timestamp
        , base = base
        , date = date
        , rates = rates
        }



-- subscription


subscriptions : Global.Model -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none



-- views


view : Global.Model -> Model -> Html Msg
view _ model =
    div []
        [ h1 [] [ text "Fixer" ]
        , p [] [ text ("API Key is set to " ++ model.key) ]
        , viewInput
            { label = "Api Key"
            , value = model.key
            , onInput = SetApiKey
            , type_ = "text"
            }
        , button [ Events.onClick GetRates ] [ text "Get Rates" ]
        , div [] [ displayRates model ]
        ]


displayRates : Model -> Html Msg
displayRates model =
    case model.fixer of
        Loading ->
            p [] [ text "Loading ..." ]

        Failure error ->
            p [] [ text error ]

        Success fixerData ->
            div []
                [ p [] [ text ("Rates from EUR on " ++ fixerData.date) ]
                , ul []
                    [ li [] [ String.fromFloat fixerData.rates.gbp |> text, span [] [ text " (to gbp)" ] ]
                    , li [] [ String.fromFloat fixerData.rates.usd |> text, span [] [ text " (to usd)" ] ]
                    , li [] [ String.fromFloat fixerData.rates.eur |> text, span [] [ text " (to eur)" ] ]
                    ]
                ]


viewInput :
    { label : String
    , value : String
    , onInput : String -> msg
    , type_ : String
    }
    -> Html Msg
viewInput config =
    label
        [ Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        , Attr.style "align-items" "flex-start"
        , Attr.style "margin" "1rem 0"
        ]
        [ span [] [ text config.label ]
        , input
            [ Attr.type_ config.type_
            , Events.onInput SetApiKey
            , Attr.value config.value
            ]
            []
        ]
