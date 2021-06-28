module Day exposing (Model, Msg, init, update, view)

import Browser
import Html exposing (Html, div, h1, h2, h3, p, text)
import Html.Attributes exposing (class)
import Week as Week


init : Maybe Week.Day -> ( Model, Cmd Msg )
init day =
    ( { initialModel | day = day }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


initialModel : Model
initialModel =
    { day = Nothing }



-- MODEL


type Msg
    = NothingYet


type alias Model =
    { day : Maybe Week.Day }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [] []
