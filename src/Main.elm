module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, a, div, footer, h1, h2, li, nav, text, ul)
import Html.Attributes exposing (class, classList, href)
import Html.Lazy exposing (lazy)
import Svg
import Svg.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)



-- MODEL


type alias Model =
    { page : Page, key : Nav.Key }


type Page
    = Week
    | Day String
    | NotFound



-- MAIN


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { page = urlToPage url, key = key }, Cmd.none )


urlToPage url =
    Parser.parse parser url |> Maybe.withDefault NotFound


parser : Parser (Page -> a) a
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
            ( { model | page = urlToPage url }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Pollen levels in Hamburg"
    , body = [ lazy headerView model.page ]
    }


headerView : page -> Html msg
headerView page =
    div [ class "bg-gradient-to-b from-gray-500 via-gray-700 to-gray-500 bg-gray-500 min-h-screen" ]
        [ div [ class "container p-4 md:p-6 mx-auto max-w-2xl text-white text-center" ]
            [ h1 [ class "text-3xl font-black tracking-tight filter drop-shadow-lg pt-10" ]
                [ text "Pollen Levels" ]
            , h2 [ class "text-3xl font-thin tracking-wider filter drop-shadow-lg uppercase" ]
                [ text "in Hamburg" ]
            ]
        ]
