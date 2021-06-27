module Main exposing (main)

import Browser exposing (Document)
import Html exposing (Html, a, div, footer, h1, h2, li, nav, text, ul)
import Html.Attributes exposing (class, classList, href)



-- MODEL


type alias Model =
    { page : Page }


type Page
    = Week
    | Day
    | NotFound



-- UPDATE


type Msg
    = NothingYet


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = \_ -> ( { page = Week }, Cmd.none )
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Pollen levels in Hamburg"
    , body = [ headerView ]
    }


headerView : Html Msg
headerView =
    div [ class "bg-gradient-to-b from-gray-500 via-gray-700 to-gray-500 bg-gray-500 min-h-screen" ]
        [ div [ class "container p-4 md:p-6 mx-auto max-w-2xl text-white text-center" ]
            [ h1 [ class "text-3xl font-black tracking-tight pt-10 filter drop-shadow-lg" ]
                [ text "Pollen Levels" ]
            , h2 [ class "text-3xl font-thin tracking-wider pb-14 filter drop-shadow-lg uppercase" ]
                [ text "in Hamburg" ]
            ]
        ]
