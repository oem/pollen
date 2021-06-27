module Week exposing (main)

import Browser
import Html exposing (Html, div, h1, h2, h3, p, text)
import Html.Attributes exposing (class)
import Http
import Json.Decode as Decode exposing (Decoder, int, list, maybe, string)
import Json.Decode.Pipeline exposing (required)



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , fetchLevels
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MODEL


initialModel : Model
initialModel =
    { dataset = [], status = Loading }


type alias Day =
    { elm : Int
    , willow : Int
    , poplar : Int
    , hazel : Int
    , alder : Int
    , oak : Int
    , beech : Int
    , birch : Int
    , mugwort : Int
    , ragweed : Int
    , plantain : Int
    , sorrel : Int
    , rye : Int
    , grass : Int
    , formatted_date : String
    }


type Status
    = Loading
    | Errored
    | Loaded


type alias Model =
    { dataset : List Day
    , status : Status
    }



-- UPDATE


type Msg
    = GotData (Result Http.Error (List Day))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotData result ->
            case result of
                Ok data ->
                    ( { model | status = Loaded, dataset = data }, Cmd.none )

                Err _ ->
                    ( { model | status = Errored }, Cmd.none )


dataUrl : String
dataUrl =
    "https://raw.githubusercontent.com/oem/Hamburg.jl/main/src/pollen/levels.json"


fetchLevels : Cmd Msg
fetchLevels =
    Http.get { url = dataUrl, expect = Http.expectJson GotData (list dayDecoder) }


dayDecoder : Decoder Day
dayDecoder =
    Decode.succeed Day
        |> required "elm" int
        |> required "willow" int
        |> required "poplar" int
        |> required "hazel" int
        |> required "alder" int
        |> required "oak" int
        |> required "beech" int
        |> required "birch" int
        |> required "mugwort" int
        |> required "ragweed" int
        |> required "plantain" int
        |> required "sorrel" int
        |> required "rye" int
        |> required "grass" int
        |> required "formatted_date" string



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "text-white text-center" ]
        [ div [ class "container p-4 md:p-6 mx-auto max-w-2xl" ]
            [ h1 [ class "text-3xl font-black tracking-tight pt-10 filter drop-shadow-xl" ]
                [ text "Pollen Levels" ]
            , h2 [ class "text-3xl font-thin tracking-wider pb-14 filter drop-shadow-xl uppercase" ]
                [ text "in Hamburg" ]
            , div
                []
              <|
                case model.status of
                    Loaded ->
                        [ weekView model ]

                    Loading ->
                        [ text "loading data..." ]

                    Errored ->
                        [ text "error loading the data" ]
            ]
        ]


weekView : Model -> Html Msg
weekView model =
    let
        days =
            List.reverse <| List.take 7 <| model.dataset

        today =
            List.head days

        forecast =
            case List.tail days of
                Just a ->
                    a

                Nothing ->
                    []
    in
    div []
        [ todayView today
        , div [ class "pb-40" ] (List.map (dayView 6 "lg") forecast)
        ]


todayView : Maybe Day -> Html Msg
todayView maybeDay =
    let
        day =
            case maybeDay of
                Just a ->
                    dayView 10 "2xl" { a | formatted_date = "today" }

                Nothing ->
                    p [] [ text "found no data for today" ]
    in
    day


dayView : Int -> String -> Day -> Html Msg
dayView padding shadow day =
    let
        level : Int
        level =
            case List.maximum [ day.elm, day.willow, day.poplar, day.hazel, day.alder, day.oak, day.beech, day.birch, day.mugwort, day.ragweed, day.plantain, day.sorrel, day.rye, day.grass ] of
                Just a ->
                    a

                Nothing ->
                    0

        levelClass : String
        levelClass =
            case level of
                3 ->
                    "bg-red-500"

                2 ->
                    "bg-purple-500"

                1 ->
                    "bg-green-500"

                0 ->
                    "bg-gray-400"

                _ ->
                    "bg-black"

        levelText =
            case level of
                3 ->
                    "strong"

                2 ->
                    "medium"

                1 ->
                    "light"

                _ ->
                    "none"
    in
    div [ class "pb-14" ]
        [ div [ class (levelClass ++ " flex flex-col items-center justify-center font-bold uppercase text-5xl md:text-4xl rounded-lg text-white shadow-" ++ shadow ++ " p-" ++ String.fromInt padding) ]
            [ div [ class "text-lg font-light tracking-tighter uppercase filter drop-shadow-lg" ] [ text day.formatted_date ]
            , div [ class "font-heavy tracking-tight" ] [ text ("Level " ++ String.fromInt level) ]
            , div [ class "font-thin" ] [ text levelText ]
            ]
        ]