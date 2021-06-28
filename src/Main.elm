module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Day as Day
import Html exposing (Html, a, div, footer, h1, h2, li, nav, text, ul)
import Html.Attributes exposing (class, classList, href)
import Html.Lazy exposing (lazy)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)
import Week as Week



-- MODEL


type alias Model =
    { page : Page, key : Nav.Key }


type Page
    = WeekPage Week.Model
    | DayPage
    | NotFound


type Route
    = Week
    | Day String



-- MAIN


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    updateUrl url { page = NotFound, key = key }


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Parser.parse parser url of
        Just Week ->
            Week.init () |> toWeek model

        Just (Day date) ->
            ( { model | page = DayPage }, Cmd.none )

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Week Parser.top
        , Parser.map Day (s "days" </> Parser.string)
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
    | GotWeekMsg Week.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ChangedUrl url ->
            updateUrl url model

        GotWeekMsg weekMsg ->
            case model.page of
                WeekPage week ->
                    toWeek model (Week.update weekMsg week)

                _ ->
                    ( model, Cmd.none )


toWeek : Model -> ( Week.Model, Cmd Week.Msg ) -> ( Model, Cmd Msg )
toWeek model ( week, cmd ) =
    ( { model | page = WeekPage week }, Cmd.map GotWeekMsg cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    let
        content =
            case model.page of
                WeekPage week ->
                    Week.view week |> Html.map GotWeekMsg

                _ ->
                    div [] [ text "initializing" ]
    in
    { title = "Pollen levels in Hamburg"
    , body =
        [ lazy headerView content ]
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
