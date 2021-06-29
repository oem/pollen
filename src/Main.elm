module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, a, div, h1, h2, h3, p, text)
import Html.Attributes exposing (class, classList, href)
import Http
import Json.Decode as Decode exposing (Decoder, int, list, maybe, string)
import Json.Decode.Pipeline exposing (required)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)



-- MODEL


type alias Model =
    { page : Page
    , key : Nav.Key
    , url : Url
    , dataset : List Day
    , status : Status
    , selectedDay : Maybe Day
    }


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
    , date : String
    , formattedDate : String
    }


type Status
    = Loading
    | Loaded
    | Errored


type Page
    = WeekPage
    | DayPage
    | NotFoundPage


type Route
    = Week
    | SelectedDay String



-- MAIN


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( updateUrl url
        { page = NotFoundPage
        , key = key
        , url = url
        , dataset = []
        , status = Loading
        , selectedDay = Nothing
        }
    , fetchDataset
    )


updateUrl : Url -> Model -> Model
updateUrl url model =
    case Parser.parse parser url of
        Just Week ->
            { model | page = WeekPage }

        Just (SelectedDay date) ->
            { model | page = DayPage, selectedDay = stringToDay date model.dataset }

        Nothing ->
            { model | page = NotFoundPage }


stringToDay : String -> List Day -> Maybe Day
stringToDay date dataset =
    List.filter (isDay date) dataset |> List.head


isDay : String -> Day -> Bool
isDay date day =
    if day.date == date then
        True

    else
        False


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Week Parser.top
        , Parser.map Week (s "pollen")
        , Parser.map SelectedDay (s "pollen" </> s "days" </> Parser.string)
        , Parser.map SelectedDay (s "days" </> Parser.string)
        ]


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- UPDATE


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotData (Result Http.Error (List Day))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotData result ->
            case result of
                Ok data ->
                    ( updateUrl model.url { model | status = Loaded, dataset = data }, Cmd.none )

                Err _ ->
                    ( { model | status = Errored }, Cmd.none )

        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ChangedUrl url ->
            ( updateUrl url model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


dataUrl : String
dataUrl =
    "https://raw.githubusercontent.com/oem/Hamburg.jl/main/src/pollen/levels.json"


fetchDataset : Cmd Msg
fetchDataset =
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
        |> required "date" Decode.string
        |> required "formatted_date" Decode.string



-- VIEW


view : Model -> Document Msg
view model =
    let
        subPage =
            case model.page of
                WeekPage ->
                    weekView model

                DayPage ->
                    detailedDayView model

                NotFoundPage ->
                    div [] [ text "Sorry, I could not find what you were looking for." ]

        content =
            case model.status of
                Loading ->
                    div [] [ text "Loading data..." ]

                Errored ->
                    div [] [ text "Sorry, I could not load the pollen data." ]

                Loaded ->
                    subPage
    in
    { title = "Pollen levels in Hamburg"
    , body =
        [ headerView content ]
    }


headerView : Html Msg -> Html Msg
headerView content =
    div [ class "bg-gradient-to-b from-gray-500 via-gray-700 to-gray-500 bg-gray-500 min-h-screen" ]
        [ div [ class "container p-4 md:p-6 mx-auto max-w-2xl text-white text-center" ]
            [ h1 [ class "text-3xl font-black tracking-tight filter drop-shadow-lg pt-10" ]
                [ text "Pollen Levels" ]
            , h2 [ class "text-3xl font-thin tracking-wider filter drop-shadow-lg uppercase pb-14" ]
                [ text "in Hamburg" ]
            , content
            ]
        ]


detailedDayView : Model -> Html Msg
detailedDayView model =
    let
        content =
            case model.selectedDay of
                Just day ->
                    div [ class "pb-10" ]
                        [ h3 [ class "uppercase tracking-wider font-black text-lg pb-10" ] [ text day.formattedDate ]
                        , gridView day
                        ]

                Nothing ->
                    p [] [ text "Sorry, I have no data for the selected day." ]
    in
    content


gridView : Day -> Html Msg
gridView day =
    div [ class "grid grid-cols-3 gap-4" ]
        [ cellView day.grass "grass"
        , cellView day.elm "elm"
        , cellView day.willow "willow"
        , cellView day.poplar "poplar"
        , cellView day.hazel "hazel"
        , cellView day.alder "alder"
        , cellView day.oak "oak"
        , cellView day.beech "beech"
        , cellView day.birch "birch"
        , cellView day.mugwort "mugwort"
        , cellView day.ragweed "ragweed"
        , cellView day.plantain "plantain"
        , cellView day.sorrel "sorrel"
        , cellView day.rye "rye"
        ]


cellView : Int -> String -> Html Msg
cellView level name =
    div [ class (levelClass level ++ " flex flex-col items-center justify-center font-bold uppercase text-lg md:text-xl rounded-lg text-white shadow-lg p-6") ]
        [ div [ class "font-black tracking-tight md:tracking-wider md:text-xl text-sm" ] [ text name ]
        , div [ class "font-light" ] [ text (levelToString level) ]
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
                    dayView 10 "2xl" { a | formattedDate = "today" }

                Nothing ->
                    p [] [ text "found no data for today" ]
    in
    day


levelClass : Int -> String
levelClass level =
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


levelToString : Int -> String
levelToString level =
    case level of
        3 ->
            "strong"

        2 ->
            "medium"

        1 ->
            "light"

        _ ->
            "none"


dayView : Int -> String -> Day -> Html Msg
dayView padding shadow day =
    let
        url =
            "/days/" ++ day.date

        level : Int
        level =
            case List.maximum [ day.elm, day.willow, day.poplar, day.hazel, day.alder, day.oak, day.beech, day.birch, day.mugwort, day.ragweed, day.plantain, day.sorrel, day.rye, day.grass ] of
                Just a ->
                    a

                Nothing ->
                    0
    in
    a [ class "mb-14 block", href url ]
        [ div [ class (levelClass level ++ " flex flex-col items-center justify-center font-bold uppercase text-5xl md:text-4xl rounded-lg text-white shadow-" ++ shadow ++ " p-" ++ String.fromInt padding) ]
            [ div [ class "text-lg font-light tracking-tighter uppercase filter drop-shadow-lg" ] [ text day.formattedDate ]
            , div [ class "font-heavy tracking-tight" ] [ text ("Level " ++ String.fromInt level) ]
            , div [ class "font-thin" ] [ text (levelToString level) ]
            ]
        ]
