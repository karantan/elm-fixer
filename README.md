# elm-fixer

This is a very simple example how to send, receive and handle HTTP requests in elm. We use
[NoRedInk/elm-json-decode-pipeline](https://github.com/NoRedInk/elm-json-decode-pipeline)
for easier JSON decoding.

## How it works

Run the local development (see below) and click on the `Fixer` link in the nav bar.
After that you will need to provide the API key which you get from [fixer.io](https://fixer.io/).
When you provide a valid key you can get gbp and usd rates for eur.

All the logic lives in `src/Fixer.elm`.


*TIP*: If you are lazy like me you can use this [tool](https://noredink.github.io/json-to-elm/)
to generate encoders and decoders for a given JSON object.

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
