module Main exposing (main)

import Browser
import Html exposing (Html, div, h1, h2, h3, p, text)
import Html.Attributes exposing (class)



-- MAIN


main =
    Browser.sandbox { init = 0, update = update, view = view }



-- MODEL
-- UPDATE


update msg model =
    model



-- VIEW


view model =
    div [ class "container p-4 md:p-6 mx-auto max-w-6xl" ]
        [ h1 [ class "text-3xl font-black tracking-tight pb-4 pt-14" ] [ text "Pollen in Hamburg" ]
        ]
