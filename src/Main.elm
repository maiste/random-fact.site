module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Url



-- MAIN
main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }

-- MODEL
type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , content : String
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key url "",
      Http.get
      { url = "/api/about"
      , expect = Http.expectString GotText
      }
    )



-- UPDATE
type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotText (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let new_url = (Url.toString url) in
            ( { model | url = url }
            , Http.get
                { url = new_url
                , expect = Http.expectString GotText
                })
        GotText result ->
            case result of
                Ok fullText -> ({model | content = fullText}, Cmd.none)
                Err e ->
                    let strError =
                            case e of
                                Http.BadUrl u -> "BadUrl " ++ u
                                Http.Timeout -> "Timeout"
                                Http.BadStatus i -> "Status" ++ (String.fromInt i)
                                Http.NetworkError -> "Network"
                                Http.BadBody b -> "Badbody " ++ b

                    in
                    ({model | content = strError}, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW
view : Model -> Browser.Document Msg
view model =
    { title = "Page"
    , body =

        [ a [ href "/api/random" ] [ text "Random" ]
        , text "The current URL is: "
        , text model.content
        ]
    }
