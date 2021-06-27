module Main exposing (main)

import Browser exposing (Document)
import Html exposing (Html, a, div, footer, h1, h2, li, nav, text, ul)
import Html.Attributes exposing (class, classList, href)
import Html.Lazy exposing (lazy)
import Svg
import Svg.Attributes



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
    , body = [ lazy headerView model.page ]
    }


headerView : Page -> Html msg
headerView page =
    let
        back =
            case page of
                Week ->
                    div [] []

                _ ->
                    backIconView
    in
    div [ class "bg-gradient-to-b from-gray-500 via-gray-700 to-gray-500 bg-gray-500 min-h-screen" ]
        [ div [ class "container p-4 md:p-6 mx-auto max-w-2xl text-white text-center" ]
            [ div [ class "grid grid-cols-12 pb-14 place-items-center pt-10" ]
                [ div [ class "col-span-2 pl-18 sm:pl-40" ] [ back ]
                , div [ class "col-span-8" ]
                    [ h1 [ class "text-3xl font-black tracking-tight filter drop-shadow-lg" ]
                        [ text "Pollen Levels" ]
                    , h2 [ class "text-3xl font-thin tracking-wider filter drop-shadow-lg uppercase" ]
                        [ text "in Hamburg" ]
                    ]
                ]
            ]
        ]


backIconView : Svg.Svg msg
backIconView =
    Svg.svg
        [ Svg.Attributes.width "42"
        , Svg.Attributes.height "42"
        , Svg.Attributes.viewBox "0 0 20 20"
        , Svg.Attributes.fill "currentColor"
        ]
        [ Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.stroke "currentColor"
            , Svg.Attributes.d "M10 18a8 8 0 100-16 8 8 0 000 16zm.707-10.293a1 1 0 00-1.414-1.414l-3 3a1 1 0 000 1.414l3 3a1 1 0 001.414-1.414L9.414 11H13a1 1 0 100-2H9.414l1.293-1.293z"
            ]
            []
        ]
