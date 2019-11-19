# elm-fixer

This is a very simple example how to send, receive and handle HTTP requests in elm. We use
[NoRedInk/elm-json-decode-pipeline](https://github.com/NoRedInk/elm-json-decode-pipeline)
for easier JSON decoding.

## How it works

Run the local development (see below) and click on the `Fixer` link in the nav bar.
After that you will need to provide the API key which you get from [fixer.io](https://fixer.io/).
When you provide a valid key you can get gbp and usd rates for eur.

All the logic lives in `src/Fixer.elm`.

#### Code review

Let's review the most important parts of the code that makes this app "tick".

First, we define types of messages that our app will use.

```elm
type Msg
    = SetApiKey String
    | GetRates
    | GotRates (Result Http.Error Fixer)
```
> “A message is a value used to pass information from one part of the system to another.”

Excerpt From: Richard Feldman. “Elm in Action MEAP V11”. Apple Books.

We will ignore the `SetApiKey String` message because it is just used to set the API Key.

Let's take a look at `GetRates` message. If we want to trigger it we can put an on click
event on a button like this:

```elm
button [ Events.onClick GetRates ] [ text "Get Rates" ]
```

And we need to handle this message case in our `update` function:

```elm
GetRates ->
    ( { model | fixer = Loading }
    , getRates model
    , Cmd.none
    )
```

So when a user clicks on the `Get Rates` button the model will change and a function will
get called. The `model.fixer` value will become `Loading` and `getRates` function will
get called (with `model` argument).


```elm
getRates : Model -> Cmd Msg
getRates model =
    Http.get
        { url = model.endpoint ++ model.key
        , expect = Http.expectJson GotRates decodeFixer
        }
```

`getRates` returns a command which needs to be type `Cmd Msg`. In our case the `Msg` is
`GotRates (Result Http.Error Fixer)`. See [HTTP docs](https://package.elm-lang.org/packages/elm/http/latest/Http#get)
for more info.

In `expect` we define what do we expect and how to handle that. We expect JSON and we 
want to handle it with `decodeFixer` function.


```elm
decodeFixer : Json.Decode.Decoder Fixer
decodeFixer =
    Json.Decode.succeed buildFixer
        |> required "success" Json.Decode.bool
        |> required "timestamp" Json.Decode.int
        |> required "base" Json.Decode.string
        |> required "date" Json.Decode.string
        -- because rates is its own object we need to tell elm how to decode it
        |> required "rates" decodeFixerRates
```

`decodeFixer` uses [NoRedInk/elm-json-decode-pipeline](https://github.com/NoRedInk/elm-json-decode-pipeline)
library for easier JSON decoding. You can do decoding without any library but you need
to use `mapN` functions. For example:

```elm
type alias User = {id : Int, email : String, staff : Bool }

decodeUser : Decoder User
decodeUser =
  map3 User
    (field "id" int)
    (field "email" string)
    (field "staff" bool)
```

And if we want to add another field e.g. `username` we would need to change `map3` to
`map4` and add `(field "username" string)` at the end.

**This decoding works because a record type alias can be called as a normal function**

If we go back to our decoder and take a look at the last line:

```elm
|> required "rates" decodeFixerRates
```

This is a bit different from the previous lines where we just have `int`, `bool` or `string`
at the end (which indicates the type of the value that we want to decode). But here we
have a function called `decodeFixerRates`. This is because the JSON object that we get
is something like this:

```json
{
  "base": "USD",
  "date": "2018-02-13",
  "rates": {
     "CAD": 1.260046,
     "CHF": 0.933058,
     "EUR": 0.806942,
     "GBP": 0.719154,
  }
}
```
So the `rates` field is another object that we need to decode and we need to tell elm 
how to do this decoding. We do this by creating a new decoding function called
`decodeFixerRates`:


```elm
decodeFixerRates : Json.Decode.Decoder Rate
decodeFixerRates =
    Json.Decode.succeed buildRate
        |> required "EUR" Json.Decode.float
        |> required "GBP" Json.Decode.float
        |> required "USD" Json.Decode.float
```

It is actually a very simple decoding function that decodes 3 fields to float types.

*TIP: If you are lazy like me you can use this [tool](https://noredink.github.io/json-to-elm/)
to generate encoders and decoders for a given JSON object.*


Once we got all the decoding done elm runtime fires the `GotRates (Result Http.Error Fixer)`
message and we handle it in the `update` function:

```elm
GotRates result ->
    case result of
        Ok fixerData -> ( { model | fixer = fixerData }, Cmd.none, Cmd.none )

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
```
Similar to `Maybe` the `Result` type has two type variables:

```elm
type Result errValue okValue
    = Err errValue
    | Ok okValue
```

See the [docs](https://package.elm-lang.org/packages/elm-lang/core/latest/Result) fore more info.

Just like with `Maybe` where we need to write the logic to handle both the `Just` and
`Nothing` cases, so does the `Result` require to handle both the `Ok` and `Err` cases.

The `Ok` case is very straight forward. We just set the `model.fixer` value to whatever
we received and decoded from the Fixer API.

In the `Err` case we have several options. We can say that whenever an error (any error)
happens, we will set the `model.fixer` value to `Failure` with `Something went wrong`
message (`Fixer` type has `Failure String` option). For example:

```elm
Err error ->
  ( { model | fixer = Failure "Something went wrong" }
  , Cmd.none
  , Cmd.none
  )
```

Or we can specify what happens for each specific error. In our case, we explicitly handle
the `Http.BadBody` case. Here is a [list](https://package.elm-lang.org/packages/elm/http/latest/Http#Error)
of all `Error` values that you can handle.


## local development

1. `npm install`

1. `npm run dev`


## project structure

```elm
src/
  Components/  -- reusable bits of UI
  Layouts/     -- views that render pages
  Pages/       -- where pages live
  Global.elm   -- info shared across pages
  Main.elm     -- entrypoint to app
```
